//
//  COResponse.hpp
//  GCHTTPServer
//
//  Created by odyang on 16/11/14.
//  Copyright © 2016年 maintoco. All rights reserved.
//

#ifndef COResponse_hpp
#define COResponse_hpp

#include <stdio.h>

/**
 HTTP响应
 */
class COResponse {
public:
    char *responseData;//响应数据
    char *contentType;//响应类型
    char *contentEncoding;//响应编码
};

#endif /* COResponse_hpp */
