//
//  GCDAsyncManager.m
//  GCD多线程安全测试
//
//  Created by SarielTang on 2017/5/16.
//  Copyright © 2017年 IT. All rights reserved.
//

#import "GCDAsyncManager.h"
#import "GCDGroup.h"

@interface GCDAsyncManager ()
{
    dispatch_queue_t myQueue;
    dispatch_semaphore_t mySema;
    dispatch_semaphore_t myGroupSema;
    
    NSMutableDictionary<NSString *,GCDGroup *> *groups;
}

@end

@implementation GCDAsyncManager

+ (instancetype)sharedInstance {
    static GCDAsyncManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GCDAsyncManager alloc]init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        myQueue = dispatch_queue_create("GCDasyncManagerQueue", DISPATCH_QUEUE_CONCURRENT);
        mySema = dispatch_semaphore_create(concurrentNum);//同时最多有5条线程并发执行。
        myGroupSema = dispatch_semaphore_create(concurrentNum);//同时5个并发Group执行
        groups = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addNoti:(void (^)())noti group:(dispatch_group_t)group   {
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (noti) {
            noti();
        }
    });
}

- (void)excute:(void (^)())block {
    dispatch_semaphore_wait(mySema, DISPATCH_TIME_FOREVER);
    dispatch_async(myQueue, ^{
        if (block) {
            block();
        }
        dispatch_semaphore_signal(mySema);
    });
}

//异步执行某个操作，如果这个操作本身是同步的，将这个操作添加到对应的group中；
- (dispatch_group_t)excuteSyncBlock:(void (^)())block addToGroup:(NSString *)groupName{
    GCDGroup *myGroup = [groups objectForKey:groupName];
    if (myGroup == nil) {
        myGroup = [[GCDGroup alloc]init];
        [groups setObject:myGroup forKey:groupName];
        myGroup.group = dispatch_group_create();
        myGroup.queue = dispatch_queue_create(groupName.UTF8String, DISPATCH_QUEUE_CONCURRENT);
    }
    dispatch_semaphore_wait(myGroupSema, DISPATCH_TIME_FOREVER);
    dispatch_group_async(myGroup.group, myGroup.queue, ^{
        if (block) {
            block();
            NSLog(@"%@:耗时操作%@执行完成",groupName,block);
            dispatch_semaphore_signal(myGroupSema);
        }
    });
    return myGroup.group;
}

- (dispatch_group_t)excuteAsyncBlock:(void (^)(void (^)()))block addToGroup:(NSString *)groupName {
    GCDGroup *myGroup = [groups objectForKey:groupName];
    if (myGroup == nil) {
        myGroup = [[GCDGroup alloc]init];
        myGroup.group = dispatch_group_create();
        myGroup.queue = dispatch_queue_create(groupName.UTF8String, DISPATCH_QUEUE_CONCURRENT);
        [groups setObject:myGroup forKey:groupName];
    }
    dispatch_semaphore_wait(myGroupSema, DISPATCH_TIME_FOREVER);//限制组内同时并发执行的线程数。
    dispatch_group_async(myGroup.group, myGroup.queue, ^{
        dispatch_group_enter(myGroup.group);
        if (block) {
            block(^{
                dispatch_semaphore_signal(myGroupSema);
                // 以下还要进行一些其他的耗时操作
                NSLog(@"%@:耗时操作%@执行完成",groupName,block);
                dispatch_group_leave(myGroup.group);
            });
        }
    });
    return myGroup.group;
}

@end
