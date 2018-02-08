//
//  CTMediator+Profile.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "CTMediator+Profile.h"

static NSString *const TargetWeibo = @"HHTargetProfile";

@implementation CTMediator (Profile)

- (void)pushToRegisterVC {
    
    UIViewController *registerVC = [self performTarget:TargetWeibo action:@"registerVC" params:nil shouldCacheTarget:NO];
    registerVC.hidesBottomBarWhenPushed = YES;
    [self.currentNavVC pushViewController:registerVC animated:YES];
}

@end
