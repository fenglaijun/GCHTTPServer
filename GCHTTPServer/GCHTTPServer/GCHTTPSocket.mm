//
//  GCHTTPSocket.m
//  GCHTTPServer
//
//  Created by 小疯子 on 16/2/25.
//  Copyright © 2016年 GC. All rights reserved.
//

#import "GCHTTPSocket.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>
#import <iostream>
#import <string.h>
#import <vector>
#import <array>
#import <sys/stat.h>
#import "GCAsyncSocket.hpp"
using namespace std;

static int socketFD;
static bool isRuning = false;
unique_ptr<GCAsyncSocket> asyncSocket(new GCAsyncSocket());

struct GCRequestHeader {
    char *path;
    char *lastModified;
};

@interface GCHTTPSocket () {
    dispatch_queue_t serverQueue;
}

@end

@implementation GCHTTPSocket

- (instancetype)init
{
    self = [super init];
    if (self) {
        serverQueue = dispatch_queue_create("kCOHTTPServerQueue", NULL);
        //asyncSocket->addr = "127.0.0.1";
        asyncSocket->port = 8888;
        asyncSocket->onAccpeted += ActionBind(&onAccept);
    }
    return self;
}

void onAccept(int sockid) {
    recvData(sockid);
}

- (int)port {
    return asyncSocket->port;
}

- (void)setPort:(int)port {
    asyncSocket->port = port;
}

- (void)setRootPath:(NSString *)rootPath {
    NSFileManager *defaultMGR = [NSFileManager defaultManager];
    if (![defaultMGR fileExistsAtPath:rootPath]) {
        [defaultMGR createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSBundle *coWeb = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"COWebResource.bundle" ofType:nil]];
    for (NSURL *file in [coWeb URLsForResourcesWithExtension:nil subdirectory:nil]) {
        if (![defaultMGR fileExistsAtPath:file.absoluteString]) {
            [defaultMGR copyItemAtURL:file toURL:[NSURL fileURLWithPath:[rootPath stringByAppendingPathComponent:file.lastPathComponent]] error:nil];
        }
    }
    
    asyncSocket->rootPath = rootPath.UTF8String;
}

- (NSString *)rootPath {
    return [NSString stringWithUTF8String:asyncSocket->rootPath.c_str()];
}

- (sockaddr_in)getAddress {
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_addr.s_addr = inet_addr([_interface UTF8String]);
    addr4.sin_port = htons(self.port);
    return addr4;
}

- (BOOL)startServer {
    dispatch_async(serverQueue, ^{
       asyncSocket->startServer();
    });
    return YES;
}

- (BOOL)stop {
    return asyncSocket->stopServer();
}

- (void)doAccept {
    struct sockaddr_in sockaddr4;
    socklen_t addrLen = sizeof(sockaddr4);
    while (isRuning) {
        int newSocketFD = accept(socketFD, (struct sockaddr *)&sockaddr4, &addrLen);
        if (newSocketFD == -1) {
            continue;
        }else {
            recvData(newSocketFD);
        }
    }
}

/// 处理请求头
struct GCRequestHeader resolveRequestHeaders(char *buffer,bool& ifModified) {
    char* pchar = strtok(buffer, "\r\n");
    vector<char*> headers;
    headers.push_back(pchar);
    while (pchar!=NULL) {
        pchar = strtok(NULL, "\r\n");
        if (pchar!=NULL) {
            headers.push_back(pchar);
        }
    }
    const char* ifmodified = "If-Modified-Since";
    GCRequestHeader reqHeader;
    for (int i=0; i<headers.size(); i++) {
        if (i==0) {
            char *action = (char *)malloc(strlen(headers[i])+1);
            strncpy(action, headers[i], strlen(headers[i]));
            char* p = strtok(action, " ");
            p = strtok(NULL, " ");
            char *np = strchr(p, '?');
            if (np!=NULL) {
                char data[255];
                int n = np-p;
                strncpy(data, p, np-p);
                data[n] = '\0';
                reqHeader.path = &data[0];
            }else {
                reqHeader.path = p;
            }
            reqHeader.lastModified = "";
            if (strcmp(reqHeader.path, "/") == 0) {
                reqHeader.path = "/index.html";
            }
        }
        if (i>0) {
            char* p = strtok(headers.at(i), ":");
            char* value = strtok(NULL, "");
            if (strncasecmp(p, ifmodified, strlen(ifmodified)) == 0) {
                reqHeader.lastModified = value;
                break;
            }
        }
    }
    
    return reqHeader;
}

void recvData(int socketfd) {
    char buffer[BUFFER_SIZE];
    char *data = "";
    do {
        memset(buffer, 0, sizeof(buffer));
        int len = recv(socketfd, buffer, sizeof(buffer), 0);
        if (len > 0) {
            char *p = (char *)malloc(strlen(data)+len+1);
            if (strlen(data)>0) {
                strcpy(p, data);
            }
            strcat(p, buffer);
            data = p;
        }
        if(len ==0 || len < BUFFER_SIZE) {
            break;
        }
    } while (true);
    
    bool ifModified;
    struct GCRequestHeader reqHeader = resolveRequestHeaders(data,ifModified);
    int fid = -1;
    long fsize;
    int code = getStatusCode(reqHeader, &fid,&fsize);
    if (ifModified) {
        code = 304;
    }
    string contentType = getContentType(reqHeader.path);
    COLog("%s",contentType.c_str());
    time_t t;
    if (code == 404) {
        t = time(0);
    }else {
        struct stat fileStat;
        fstat(fid, &fileStat);
        t = fileStat.st_mtimespec.tv_sec;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:t];
    struct tm *ltm = gmtime(&t);
    char s[80];
    strftime(s, 80, "%a, %d %b %Y %H:%M:%S %Z", ltm);
    
    string headers = getResponseHeaders(code,contentType,fsize,dateAsString(date));
    sendResponseData(socketfd,headers);
    if (code != 404 && code != 304) {
        transferFile(socketfd, fid);
    }
    close(socketfd);
}

const char* dateAsString(NSDate *date) {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [df setDateFormat:@"EEE, dd MMM y HH:mm:ss Z"];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    return [df stringFromDate:date].UTF8String;
}

void sendResponseData(int socketfd,string responseData) {
    send(socketfd, (const char *)responseData.c_str(), (size_t)responseData.length(),0);
}

string getResponseHeaders(int code,string contentType,long length,const char *time) {
    char t[16];
    sprintf(t, "%d",code);
    string s = t;
    string str("HTTP/1.1 "+s+" "+getStatusText(code)+"\r\n");
    str += "Content-Type: "+contentType+"\r\n";
    str += "Server: " SVR_Version "\r\n";
    str += "Date: "+string(dateAsString([NSDate date]))+"\r\n";
    str += "Last-Modified: "+string(time)+"\r\n";
    str += "Cache-Control: max-age=5\r\n";
    sprintf(t, "%ld",length);
    s = t;
    str += "Content-Length: "+s+"\r\n\r\n";
    return str;
}
string getResponseBody(char *path,int* code) {
    COLog("%s ",path);
    string filePath = asyncSocket->rootPath+string(path);
    if (fopen(filePath.c_str(), "r")==NULL) {
        *code = 404;
        return "";
    }
    *code = 200;
    int fid = open(filePath.c_str(), ios::binary);
    string retStr = "";
    ssize_t readed;
    do {
        char rebuffer[1024];
        readed = read(fid, rebuffer, sizeof(rebuffer)/sizeof(char)-1);
        if (readed>0) {
            rebuffer[readed] = '\0';
            retStr += string(rebuffer);
        }
    } while (readed>0);
    return retStr;
}


void transferFile(int socketid,int fid) {
    ssize_t readed;
    do {
        UInt8 rebuffer[1024];
        readed = read(fid, rebuffer, sizeof(rebuffer)/sizeof(char)-1);
        if (readed>0) {
            send(socketid, rebuffer, readed, 0);
        }
    } while (readed>0);
    close(fid);
}

int getStatusCode(struct GCRequestHeader reqHeader,int *fid,long *fsize) {
    COLog("%s \n",reqHeader.path);
    string filePath = asyncSocket->rootPath+string(reqHeader.path);
    FILE *file = fopen(filePath.c_str(), "r");
    if (file == NULL) {
        *fsize = 0;
        return 404;
    }else {
        fseek(file, 0, SEEK_END);//将文件指针移到文件结尾
        *fsize = ftell(file);
        fclose(file);
        *fid = open(filePath.c_str(), ios::binary);
        if (strlen(reqHeader.lastModified) > 0) {
            /*NSDateFormatter *df = [[NSDateFormatter alloc] init];
             [df setFormatterBehavior:NSDateFormatterBehavior10_4];
             [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
             [df setDateFormat:@"EEE, dd MMM y HH:mm:ss 'GMT'"];
             [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
             
             [[df dateFromString:reqHeader.lastModified]];*/
            return 304;
        }
        return 200;
    }
}

static string getStatusText(int code) {
    switch (code) {
        case 301:return "Moved Permanently";
        case 302:return "Move temporarily";
        case 404:return "Not Found";
        case 500:return "Internal Server Error";
        default:return "OK";
    }
}

string getContentType(const char *path) {
    if (endWith(string(path), ".js") || endWith(string(path), ".json")) {
        return "text/javascript";
    }else if (endWith(string(path), ".css")) {
        return "text/css";
    }else if (endWith(string(path), ".jpg")) {
        return "image/jpeg";
    }else if (endWith(string(path), ".png")) {
        return "image/png";
    }
    return "text/html; charset=utf-8";
}

/// 是否已指定字符串结尾
bool endWith(string str,const string strEnd) {
    if (str.size()==0 || str.empty() || strEnd.empty() || str.size() < strEnd.size()) {
        return false;
    }
    return str.compare(str.size()-strEnd.size(),strEnd.size(),strEnd)==0;
}

@end
