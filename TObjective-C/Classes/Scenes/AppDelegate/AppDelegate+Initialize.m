//
//  AppDelegate+Initialize.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/17.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>

#import "AppDelegate+Initialize.h"

#import "HHSocketClient.h"
@implementation AppDelegate (Initialize)

- (void)initializeWithLaunchOptions:(NSDictionary *)launchOptions {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupDatabase];
        [self setupSocket];
    });
}

- (void)setupDatabase {
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreAtURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/TObjective-C.sqlite"]]];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelOff];
}

- (void)setupSocket {
    [[HHSocketClient sharedClient] connect];
}

@end
