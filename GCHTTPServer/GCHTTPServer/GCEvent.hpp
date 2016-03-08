//
//  GCEvent.hpp
//  GCHTTPServer
//
//  Created by 小疯子 on 16/3/3.
//  Copyright © 2016年 GC. All rights reserved.
//

#ifndef GCEvent_hpp
#define GCEvent_hpp

#include <stdio.h>
#include <iostream>
using namespace std;

class EventHandler {
public:
};

template <typename argType>
struct EventBind {
    argType arg;
};

template <typename argType>
EventBind<argType> ActionBind(argType arg) {
    EventBind<argType> evtbind;
    evtbind.arg = arg;
    return evtbind;
}

template <typename argType>
class GCEvent {
public:
    typedef void (*pMemFunc)(argType);
    void operator += (EventBind<pMemFunc> evtbind) {
        _pfunc = evtbind.arg;
    }
    void operator()(argType arg) {
        (*_pfunc)(arg);
    }
    bool isSubscript() {
        return _pfunc!=NULL;
    }
private:
    pMemFunc _pfunc;
    void* p1;
};

#endif /* GCEvent_hpp */
