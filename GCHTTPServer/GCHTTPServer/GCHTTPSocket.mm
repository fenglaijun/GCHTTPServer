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

using namespace std;

static int socketFD;
static bool isRuning = false;
const char *documentRootPath;//HTTP服务根目录

@interface GCHTTPSocket () {
    dispatch_queue_t serverQueue;
}

@end

@implementation GCHTTPSocket

- (instancetype)init
{
    self = [super init];
    if (self) {
        //documentRootPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0].UTF8String;
        documentRootPath = "/Users/xiaofeng/Documents/18bg/iphone/Workspace/Office_V4.0/Office/Class/ViewControllers/WebApp/WebResource";
        serverQueue = dispatch_queue_create("GCHTTPServerQueue", NULL);
        _interface = @"127.0.0.1";
        _port = 8888;
        [self initSocket];
    }
    return self;
}

- (void)setRootPath:(NSString *)rootPath {
    documentRootPath = rootPath.UTF8String;
}

- (NSString *)rootPath {
    return [NSString stringWithUTF8String:documentRootPath];
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

- (void)initSocket {
    socketFD = socket(AF_INET, SOCK_STREAM, 0);
    //fcntl(socketFD, F_SETFL,O_NONBLOCK);
    int optval = 1;
    setsockopt(socketFD, SOL_SOCKET, SO_REUSEADDR,// 允许重用本地地址和端口
               (void *)&optval, sizeof(optval));
    if (socketFD == -1) {
        printf("Error in socket() function");
    }
}

- (BOOL)startServer {
    if (socketFD != -1) {
        sockaddr_in address = [self getAddress];
        socklen_t addrlen = sizeof(address);
        const struct sockaddr *sockaddr4 = (const struct sockaddr*)&address;
        int result = bind(socketFD, sockaddr4,addrlen);
        if (result == -1) {
            NSLog(@"Bind to address failed!");
            close(socketFD);
            return NO;
        }
        //开始监听
        int status = listen(socketFD, 20);
        if (status != -1) {
            __weak typeof(self) self_weak = self;
            dispatch_async(serverQueue, ^{
                isRuning = YES;
                [self_weak doAccept];
            });
        }else {
            printf("call error in listen()");
        }
    }
    return YES;
}

- (BOOL)stop {
    isRuning = false;
    return YES;
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
char* resolveRequestHeaders(UInt8 headers[]) {
    string dstr((char *)headers);
    const char* split = "\n";
    char *p = strtok((char *)headers, split);
    p = strtok((char *)headers, " ");
    printf("%s ",p);
    int pos = 0;
    while (p!=NULL) {
        if (pos == 1) {
            break;
        }
        p = strtok(NULL," ");
        pos++;
    }
    char *path = strtok(p, "?");
    return path==NULL?p:path;
}

void recvData(int socketfd) {
    UInt8 buffer[1024];
    ssize_t len = recv(socketfd, buffer, (size_t)sizeof(buffer), 0);
    if (len >=0) {
        char *path = resolveRequestHeaders(buffer);
        int fid = -1;
        long fsize;
        int code = getStatusCode(path, &fid,&fsize);
        string contentType = getContentType(path);
        printf("%s\n",contentType.c_str());
        time_t t;
        if (code == 404) {
            t = time(0);
        }else {
            struct stat fileStat;
            fstat(fid, &fileStat);
            t = fileStat.st_mtimespec.tv_sec;
        }
        struct tm *ltm = gmtime(&t);
        char s[80];
        strftime(s, 80, "%a, %d %b %Y %H:%M:%S %Z", ltm);
        string headers = getResponseHeaders(code,contentType,fsize,s);
        sendResponseData(socketfd,headers);
        if (code != 404) {
            transferFile(socketfd, fid);
        }
        close(socketfd);
    }
}

void sendResponseData(int socketfd,string responseData) {
    send(socketfd, (const char *)responseData.c_str(), (size_t)responseData.length(),0);
}

string getResponseHeaders(int code,string contentType,long length,char *time) {
    char t[16];
    sprintf(t, "%d",code);
    string s = t;
    string str("HTTP/1.1 "+s+" "+getStatusText(code)+"\n");
    str += "Content-Type: "+contentType+"\n";
    str += "Server: GCHTTPServer/1.0\n";
    str += "Date: "+string(time)+"\n";
    sprintf(t, "%ld",length);
    s = t;
    str += "Content-Length: "+s+"\n\n";
    return str;
}
string getResponseBody(char *path,int* code) {
    printf("%s ",path);
    string filePath = string(documentRootPath)+string(path);
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
}

int getStatusCode(char *path,int *fid,long *fsize) {
    printf("%s ",path);
    if (strlen(path)==1 && path[0] == '/') {
        *fsize = 0;
        return 404;
    }
    string filePath = string(documentRootPath)+string(path);
    FILE *file = fopen(filePath.c_str(), "r");
    if (file == NULL) {
        *fsize = 0;
        return 404;
    }else {
        fseek(file, 0, SEEK_END);//将文件指针移到文件结尾
        *fsize = ftell(file);
        fclose(file);
        *fid = open(filePath.c_str(), ios::binary);
        return 200;
    }
}

string getStatusText(int code) {
    switch (code) {
        case 301:return "Moved Permanently";
        case 302:return "Move temporarily";
        case 404:return "Not Found";
        case 500:return "Internal Server Error";
        default:return "OK";
    }
}

string getContentType(char *path) {
    if (endWith(string(path), ".js")) {
        return "application/x-javascript";
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
    if (str.empty() || strEnd.empty() || str.size() < strEnd.size()) {
        return false;
    }
    return str.compare(str.size()-strEnd.size(),strEnd.size(),strEnd)==0;
}

@end
