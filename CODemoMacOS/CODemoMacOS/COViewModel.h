//
//  COViewModel.h
//  CODemoMacOS
//
//  Created by odyang on 16/11/11.
//  Copyright © 2016年 maintoco. All rights reserved.
//

#import "COLogModel.h"

@interface COViewModel : NSObject

/**
 输出消息
 */
@property (nonatomic, retain) NSMutableArray<COLogModel *> *logs;

@end
