//
//  GCDAsyncManager.h
//  GCD多线程安全测试
//
//  Created by SarielTang on 2017/5/16.
//  Copyright © 2017年 IT. All rights reserved.
//

#import <Foundation/Foundation.h>

static int concurrentNum = 10;//最大并发数

@interface GCDAsyncManager : NSObject

+ (instancetype)sharedInstance;

//所有操作执行结束之后添加前面所有操作结束的通知。
- (void)addNoti:(void (^)())noti group:(dispatch_group_t)group;

//异步执行Block中的内容，限定最大并发数
- (void)excute:(void (^)())block;

//异步执行某个操作，如果这个操作本身是同步的，将这个操作添加到对应的group中；
- (dispatch_group_t)excuteSyncBlock:(void (^)())block addToGroup:(NSString *)groupName;

//异步执行某个操作，如果这个操作本身就是异步的，将completion传进去，将这个操作添加到对应的group中；
- (dispatch_group_t)excuteAsyncBlock:(void (^)(void (^completion)()))block addToGroup:(NSString *)groupName;

@end
