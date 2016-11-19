//
//  CORequest.cpp
//  GCHTTPServer
//
//  Created by odyang on 16/11/14.
//  Copyright © 2016年 maintoco. All rights reserved.
//

#include "CORequest.hpp"
#include <stdio.h>
#include <stdlib.h>

CORequest::CORequest() {}

CORequest::CORequest(char *data) {
    char* pchar = strtok(data, "\r\n");
    vector<char*> headers;
    headers.push_back(pchar);
    while (pchar!=NULL) {
        pchar = strtok(NULL, "\r\n");
        if (pchar!=NULL) {
            headers.push_back(pchar);
        }
    }
    const char* ifmodified = "If-Modified-Since";
    for (int i=0; i<headers.size(); i++) {
        if (i==0) {
            char *action = (char *)malloc(strlen(headers[i])+1);
            strncpy(action, headers[i], strlen(headers[i]));
            url = new COURL(action);
        }
        if (i>0) {
            char* p = strtok(headers.at(i), ":");
            char* value = strtok(NULL, "");
            if (strncasecmp(p, ifmodified, strlen(ifmodified)) == 0) {
                lastModified = value;
                break;
            }
        }
    }
}
