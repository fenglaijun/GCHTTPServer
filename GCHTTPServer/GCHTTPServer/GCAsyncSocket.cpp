//
//  GCAsyncSocket.cpp
//  GCHTTPServer
//
//  Created by 小疯子 on 16/3/3.
//  Copyright © 2016年 GC. All rights reserved.
//
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>
#import <vector>
#import <array>
#import <sys/stat.h>
#include "GCAsyncSocket.hpp"

void funcdemo(int num);

sockaddr_in getSockAddr(char *addrStr,int port) {
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_addr.s_addr = addrStr == "0.0.0.0"?INADDR_ANY:inet_addr(addrStr);
    addr4.sin_port = htons(port);
    return addr4;
}

GCAsyncSocket::GCAsyncSocket() {
    port = 8888;
    addr = "0.0.0.0";//127.0.0.1
    rootPath = "";
    sockid = socket(AF_INET, SOCK_STREAM, 0);
    //fcntl(socketFD, F_SETFL,O_NONBLOCK);
    int optval = 1;
    // 允许重用本地地址和端口
    setsockopt(sockid, SOL_SOCKET, SO_REUSEADDR,(void *)&optval, sizeof(optval));
}

GCAsyncSocket::~GCAsyncSocket() {
    stopServer();
}

bool GCAsyncSocket::startServer() {
    if (sockid != -1) {
        sockaddr_in address = getSockAddr((char *)addr.c_str(), port);
        socklen_t addrlen = sizeof(address);
        const struct sockaddr *sockaddr4 = (const struct sockaddr*)&address;
        int result = bind(sockid, sockaddr4,addrlen);
        if (result == -1) {
            close(sockid);
            COLog("[GSver] bind error:%s:%u",inet_ntoa(address.sin_addr),ntohs(address.sin_port));
            return false;
        }
        //开始监听
        int status = listen(sockid, 20);
        if (status != -1) {
            COLog("HTTPServer started at %s:%u......",inet_ntoa(address.sin_addr),ntohs(address.sin_port));
            isRunning = true;
            beginSocketAccept();
        }else {
            COLog("call error in listen()");
        }
    }
    return true;
}

bool GCAsyncSocket::stopServer() {
    close(sockid);
    return false;
}

void GCAsyncSocket::beginSocketAccept() {
    struct sockaddr_in sockaddr4;
    socklen_t addrLen = sizeof(sockaddr4);
    while (isRunning) {
        int newSockId = accept(sockid, (struct sockaddr *)&sockaddr4, &addrLen);
        if (newSockId == -1) {
            continue;
        }else {
            if (onAccpeted.isSubscript()) {
                onAccpeted(newSockId);
            }
        }
    }
}
