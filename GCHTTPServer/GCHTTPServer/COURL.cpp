//
//  COURL.cpp
//  GCHTTPServer
//
//  Created by odyang on 16/11/14.
//  Copyright © 2016年 GC. All rights reserved.
//

#include "COURL.hpp"

COURL::COURL() {}

COURL::COURL(char *data) {
    char *p = strtok(data, " ");
    p = strtok(NULL, " ");
    char *np = strchr(p, '?');
    if (np!=NULL) {
        char data[255];
        int n = np-p;
        strncpy(data, p, np-p);
        data[n] = '\0';
        relativePath = &data[0];
    }else {
        relativePath = p;
    }
    if (strcmp(relativePath, "/") == 0) {
        relativePath = "/index.html";
    }
}
