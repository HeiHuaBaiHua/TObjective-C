//
//  HHPublicWeiboListViewModel.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHPublicWeiboListViewModel.h"
#import "HHWeiboCellViewModel.h"

#import "HHWeiboAPIManager.h"
#import "HHWeiboTCPAPIManager.h"

#import "HHAPIManger_JustForDemo.h"
static const int pageSize = 20;
@implementation HHPublicWeiboListViewModel

#pragma mark - Override

- (RACSignal *)fetchDataSignalWithPage:(int)page {
    
    id apiManager = [HHAPIManger_JustForDemo weiboAPIManger];
//    HHWeiboAPIManager *apiManger = [HHWeiboAPIManager new];
    return [[apiManager publicWeiboListSignalWithPage:page pageSize:pageSize] map:^id(NSArray *weibos) {
        
        return [weibos.rac_sequence map:^id(HHWeibo *weibo) {
            return [[HHWeiboCellViewModel alloc] initWithObject:weibo];
        }].array;
    }];
}

@end
