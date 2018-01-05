//
//  ViewController.m
//  GCD多线程安全测试
//
//  Created by SarielTang on 2017/5/16.
//  Copyright © 2017年 IT. All rights reserved.
//

#import "ViewController.h"
#import "GCDTest.h"
#import "GCDAsyncManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    GCDTest *testObj = [[GCDTest alloc]init];
//    NSLog(@"%@",testObj);

    dispatch_group_t group1;
    dispatch_group_t group2;
    for (int i = 0; i< 100; i++) {
        [[GCDAsyncManager sharedInstance] excute:^{
            sleep(1);
            NSLog(@"%@ --- %d",[NSThread currentThread],i);
        }];
        
        group1 = [[GCDAsyncManager sharedInstance] excuteSyncBlock:^{
            NSLog(@"group1: - %@ --- %d",[NSThread currentThread],i);
            sleep(1);
        } addToGroup:@"group1"];
        
        group2 = [[GCDAsyncManager sharedInstance] excuteAsyncBlock:^(void (^completion)()){
            NSLog(@"group2: - %@ --- %d",[NSThread currentThread],i);
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                sleep(1);
                completion();
            });
        } addToGroup:@"group2"];
    }
    
    [[GCDAsyncManager sharedInstance] addNoti:^{
        NSLog(@"group1中的数据处理完了!");
    } group:group1];
    [[GCDAsyncManager sharedInstance] addNoti:^{
        NSLog(@"group2中的数据处理完了!");
    } group:group2];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
