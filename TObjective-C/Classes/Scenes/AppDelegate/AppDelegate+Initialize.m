//
//  AppDelegate+Initialize.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/17.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>
#import <RealReachability/RealReachability.h>

#import "AppDelegate+Initialize.h"

#import "HHWebSocketClient.h"
#import "HHTCPSocketClient.h"
@implementation AppDelegate (Initialize)

- (void)initializeWithLaunchOptions:(NSDictionary *)launchOptions {
    
    [self startNetworkMonitor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self setupSocket];
//        [self setupDatabase];
    });
}

- (void)setupDatabase {
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreAtURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/TObjective-C.sqlite"]]];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelOff];
}

- (void)setupSocket {
    
    [[HHWebSocketClient sharedInstance] connect];
    [[HHTCPSocketClient sharedInstance] connect];
}

- (void)startNetworkMonitor {
    GLobalRealReachability.hostForPing = @"www.baidu.com";
    [GLobalRealReachability startNotifier];
}

@end
