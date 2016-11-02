//
//  GCObject.h
//  GCHTTPServerDemo
//
//  Created by gcyang on 16/4/21.
//  Copyright © 2016年 GC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCObject : NSObject

@property (nonatomic, assign) int tag;

@property (nonatomic, retain) NSMutableString *strRetain;
@property (nonatomic, copy) NSMutableString *strCpy;

@end
