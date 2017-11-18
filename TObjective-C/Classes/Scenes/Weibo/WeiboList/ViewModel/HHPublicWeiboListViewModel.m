//
//  HHPublicWeiboListViewModel.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHPublicWeiboListViewModel.h"
#import "HHWeiboCellViewModel.h"

#import "HHWeiboAPIManager.h"

static const int pageSize = 20;

@implementation HHPublicWeiboListViewModel

#pragma mark - Override

- (RACSignal *)fetchDataSignalWithPage:(int)page {
    return [[[HHWeiboAPIManager new] publicWeiboListSignalWithPage:page pageSize:pageSize] map:^id(NSArray *weibos) {
        
        return [weibos.rac_sequence map:^id(HHWeibo *weibo) {
            return [[HHWeiboCellViewModel alloc] initWithObject:weibo];
        }].array;
    }];
}

@end
