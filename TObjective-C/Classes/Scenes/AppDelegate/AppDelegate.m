//
//  AppDelegate.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "AppDelegate.h"

#import "CTMediator+Root.h"
#import "AppDelegate+Initialize.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window.rootViewController = [CTRouter tabbarViewController];
    [self initializeWithLaunchOptions:launchOptions];

    return YES;
}

@end
