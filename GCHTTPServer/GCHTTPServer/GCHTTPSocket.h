//
//  GCHTTPSocket.h
//  GCHTTPServer
//
//  Created by 小疯子 on 16/2/25.
//  Copyright © 2016年 GC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SVR_Version "COHTTPServer/1.1"

@protocol GCHTTPSocketDelegate <NSObject>

@optional

- (void)didReciveRequest:(NSString *)requst;
/**
 发生异常

 @param error 错误
 */
- (void)didReciveExecption:(NSException *)error;

@end

@interface GCHTTPSocket : NSObject

/// 监听地址,默认为127.0.0.1
@property (nonatomic,copy) NSString *interface;
/// 监听端口号,默认为8888
@property (nonatomic,assign) int port;
/// 服务器根目录,默认为/Libray/_caches
@property (nonatomic,copy) NSString *rootPath;

/**
 代理
 */
@property (nonatomic, weak) id<GCHTTPSocketDelegate> delegate;

/// 启动HTTP服务器
- (BOOL)startServer;
/// 停止HTTP服务器;
- (BOOL)stop;

@end
