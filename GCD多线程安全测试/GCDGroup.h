//
//  GCDGroup.h
//  GCD多线程安全测试
//
//  Created by SarielTang on 2017/5/17.
//  Copyright © 2017年 IT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDGroup : NSObject

@property (nonatomic, strong) dispatch_group_t group;
@property (nonatomic, strong) dispatch_queue_t queue;

@end
