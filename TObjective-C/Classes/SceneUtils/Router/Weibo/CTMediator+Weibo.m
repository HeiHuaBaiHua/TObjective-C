//
//  CTMediator+Weibo.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "CTMediator+Weibo.h"

static NSString *const TargetWeibo = @"HHTargetWeibo";

@implementation CTMediator (Weibo)

- (void)pushToWeiboListVC {
    
    UIViewController *weiboListVC = [self performTarget:TargetWeibo action:@"weiboListVC" params:nil shouldCacheTarget:NO];
    weiboListVC.hidesBottomBarWhenPushed = YES;
    [self.currentNavVC pushViewController:weiboListVC animated:YES];
}

- (void)pushToWeiboDetailVCWithWeiboJson:(NSDictionary *)json {
    
    UIViewController *weiboDetailVC = [self performTarget:TargetWeibo action:@"weiboDetailVCWithPramas:" params:json shouldCacheTarget:NO];
    weiboDetailVC.hidesBottomBarWhenPushed = YES;
    [self.currentNavVC pushViewController:weiboDetailVC animated:YES];
}

@end
