//
//  COViewModel.m
//  CODemoMacOS
//
//  Created by odyang on 16/11/11.
//  Copyright © 2016年 maintoco. All rights reserved.
//

#import "COViewModel.h"

@implementation COViewModel

- (instancetype)init {
    if (self = [super init]) {
        self.logs = [NSMutableArray array];
    }
    return self;
}

@end
