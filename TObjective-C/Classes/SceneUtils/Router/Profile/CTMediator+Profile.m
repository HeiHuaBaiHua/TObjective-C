//
//  CTMediator+Profile.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "CTMediator+Profile.h"

static NSString *const TargetWeibo = @"HHTargetProfile";

@implementation CTMediator (Profile)

- (void)pushToProfileVC {
    
    UIViewController *profileVC = [self performTarget:TargetWeibo action:@"profileVC" params:nil shouldCacheTarget:NO];
    profileVC.hidesBottomBarWhenPushed = YES;
    [self.currentNavVC pushViewController:profileVC animated:YES];
}

@end
