//
//  COURL.hpp
//  GCHTTPServer
//
//  Created by odyang on 16/11/14.
//  Copyright © 2016年 GC. All rights reserved.
//

#ifndef COURL_hpp
#define COURL_hpp

#include <stdio.h>
#include <string>

/**
 资源路径
 */
class COURL {
public:
    char *absoluteString;//绝对路径
    char *host;//主机
    char *port;//端口
    char *query;//查询参数
    char *relativePath;//相对路径
    COURL();
    COURL(char *data);
};

#endif /* COURL_hpp */
