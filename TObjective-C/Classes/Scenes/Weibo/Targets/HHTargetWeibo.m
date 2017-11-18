//
//  HHTargetWeibo.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <YYModel/YYModel.h>

#import "HHFoundation.h"

#import "HHWeibo.h"
#import "HHTargetWeibo.h"

#import "HHWeiboListViewController.h"

#import "HHWeiboDetailView.h"
#import "HHWeiboDetailViewModel.h"
#import "HHWeiboDetailViewController.h"
@implementation HHTargetWeibo

- (UIViewController *)weiboListVC {
    return [HHWeiboListViewController new];
}

- (UIViewController *)weiboDetailVCWithPramas:(NSDictionary *)params {
    
    HHWeibo *weibo = [HHWeibo yy_modelWithJSON:params];
    if (weibo.ID.length == 0) { return nil; }

    return [[HHWeiboDetailViewController alloc] initWithWeibo:weibo];
}

@end
