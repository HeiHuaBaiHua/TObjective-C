//
//  HHTargetRoot.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHTargetRoot.h"

#import "TempViewController.h"
#import "HHTabBarViewController.h"
@implementation HHTargetRoot

- (UITabBarController *)tabbarViewController {
    return [HHTabBarViewController new];
}

- (UIViewController *)tempViewController:(NSDictionary *)params {
    
    id handler = params[@"onClickHandler"];
    return [[TempViewController alloc] initWithTitle:params[@"title"] onClickHandler:handler];
}

@end
