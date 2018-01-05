//
//  GCDTest.m
//  GCD多线程安全测试
//
//  Created by SarielTang on 2017/5/16.
//  Copyright © 2017年 IT. All rights reserved.
//

#import "GCDTest.h"

@interface GCDTest()
{
    dispatch_group_t myGCDGroup;
}

@end

@implementation GCDTest

- (instancetype)init {
    if (self = [super init]) {
        myGCDGroup = dispatch_group_create();
        [self createGroup1];
        [self createGroup2];
        dispatch_group_notify(myGCDGroup, dispatch_get_main_queue(), ^{
            NSLog(@"刷新界面等在主线程的操作"); 
        });
    }
    return self;
}

- (void)createGroup1 {
    dispatch_group_async(myGCDGroup, dispatch_queue_create("com.dispatch.test", DISPATCH_QUEUE_CONCURRENT), ^{
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
        // 创建一个信号量为0的信号(红灯)
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            // 请求完成，可以通知界面刷新界面等操作
            NSLog(@"第一步网络请求完成");
            // 使信号的信号量+1，这里的信号量本来为0，+1信号量为1(绿灯)
            dispatch_semaphore_signal(sema);
        }];
        [task resume];
        // 以下还要进行一些其他的耗时操作
        NSLog(@"耗时操作继续进行");
        // 开启信号等待，设置等待时间为永久，直到信号的信号量大于等于1（绿灯）
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    });
}

- (void)createGroup2 {
    dispatch_group_async(myGCDGroup, dispatch_queue_create("com.dispatch.test", DISPATCH_QUEUE_CONCURRENT), ^{
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.github.com"]];
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            // 请求完成，可以通知界面刷新界面等操作
            NSLog(@"第二步网络请求完成");
            dispatch_semaphore_signal(sema);
        }];
        [task resume];
        // 以下还要进行一些其他的耗时操作
        NSLog(@"耗时操作继续进行");
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    });
}

@end
