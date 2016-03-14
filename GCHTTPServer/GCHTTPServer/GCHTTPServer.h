//
//  GCHTTPServer.h
//  GCHTTPServer
//
//  Created by 小疯子 on 16/2/25.
//  Copyright © 2016年 GC. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for GCHTTPServer.
FOUNDATION_EXPORT double GCHTTPServerVersionNumber;

//! Project version string for GCHTTPServer.
FOUNDATION_EXPORT const unsigned char GCHTTPServerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <GCHTTPServer/PublicHeader.h>
#import <GCHTTPServer/GCHTTPSocket.h>

#if DEBUG
//输出带颜色的日志信息
#define DLogAll(fgcolor,format,...) do {   \
NSDateFormatter *fmt = [[NSDateFormatter alloc] init];\
fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss:sss";\
printf("\033[fg%s;%s %s+%d %s\033[;\n",fgcolor,[fmt stringFromDate:[NSDate date]].UTF8String,__func__,__LINE__,[NSString stringWithFormat:format,##__VA_ARGS__].UTF8String); \
} while(0)

#define DLogInfo(format,...) DLogAll("155,155,155",format,##__VA_ARGS__)
#define DLogWarn(format,...) DLogAll("198,124,72",format,##__VA_ARGS__)
#define DLogError(format,...) DLogAll("219,44,56",format,##__VA_ARGS__)
#define NSLog(format,...) DLogInfo(format,##__VA_ARGS__)
#else
#define DLogInfo(format,...)
#define DLogWarn(format,...)
#define DLogError(format,...)
#define NSLog(format,...)
#endif

