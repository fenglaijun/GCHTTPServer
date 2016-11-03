//
//  GCHTTPSocket.h
//  GCHTTPServer
//
//  Created by 小疯子 on 16/2/25.
//  Copyright © 2016年 GC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SVR_Version "COHTTPServer/1.0"

@interface GCHTTPSocket : NSObject

/// 监听地址,默认为127.0.0.1
@property (nonatomic,copy) NSString *interface;
/// 监听端口号,默认为8888
@property (nonatomic,assign) int port;
/// 服务器根目录,默认为/Libray/_caches
@property (nonatomic,copy) NSString *rootPath;

/// 启动HTTP服务器
- (BOOL)startServer;
/// 停止HTTP服务器;
- (BOOL)stop;

@end
