//
//  CORequest.hpp
//  GCHTTPServer
//
//  Created by odyang on 16/11/14.
//  Copyright © 2016年 maintoco. All rights reserved.
//

#ifndef CORequest_hpp
#define CORequest_hpp

#include <stdio.h>
#include <vector>
#include "COURL.hpp"
#include "COResponse.hpp"
using namespace std;

class CORequest {
    
    
public:
    char *lastModified;
    COURL *url;
    COResponse *response;
    char *allHTTPHeaders;
    CORequest();
    CORequest(char *data);
};

#endif /* CORequest_hpp */
