//
//  CTMediator+Root.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "CTMediator+Root.h"

static NSString *const TargetRoot = @"HHTargetRoot";

@implementation CTMediator (Root)

- (UITabBarController *)tabbarViewController {
    return [self performTarget:TargetRoot action:@"tabbarViewController" params:nil shouldCacheTarget:NO];
}

- (UIViewController *)tempViewControllerWithTitle:(NSString *)title onClickHandler:(void(^)(void))onClickHandler {
    if (!onClickHandler) { return nil; }
    
    NSDictionary *params = @{@"title": title ?: @"",
                             @"onClickHandler" : onClickHandler};
    return [self performTarget:TargetRoot action:@"tempViewController:" params:params shouldCacheTarget:NO];
}

@end
