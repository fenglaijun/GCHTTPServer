//
//  GCObject.m
//  GCHTTPServerDemo
//
//  Created by gcyang on 16/4/21.
//  Copyright © 2016年 GC. All rights reserved.
//

#import "GCObject.h"

@implementation GCObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.strRetain = [NSMutableString stringWithFormat:@"可变字符串"];
        self.strCpy = @"这个是Copy属性";
        DLogWarn(@"retian\tp:%p,%@",self.strRetain,self.strRetain);
        DLogWarn(@"copy\tp:%p,%@",self.strCpy,self.strCpy);
    }
    return self;
}

- (void)dealloc {
    DLogWarn(@"对象销毁:%@",self);
}

@end
