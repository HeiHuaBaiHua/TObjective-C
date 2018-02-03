//
//  HHTargetRoot.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHTargetRoot.h"

#import "HHTabBarViewController.h"

#import "HHJustForDemoViewController.h"
@implementation HHTargetRoot

- (UITabBarController *)tabbarViewController {
    return [HHTabBarViewController new];
}

- (UIViewController *)tempViewController:(NSDictionary *)params {
    
    UIViewController *vc = [HHJustForDemoViewController instanceWithOnClickHandler:params[@"onClickHandler"]];
    vc.title = params[@"title"];
    return vc;
}

@end
