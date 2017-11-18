//
//  HHWeiboDetailLikesViewModel.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/16.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWeiboDetailLikesViewModel.h"
#import "HHWeiboDetailLikesCellViewModel.h"

#import "HHWeiboAPIManager.h"
@implementation HHWeiboDetailLikesViewModel

- (RACSignal *)fetchDataSignalWithPage:(int)page {
    return [[[HHWeiboAPIManager new] weiboLikeListSignalWithWeiboID:@"" page:page pageSize:0] map:^id(NSArray *users) {
        
        return [users.rac_sequence map:^id(HHUser *value) {
            return [[HHWeiboDetailLikesCellViewModel alloc] initWithObject:value];
        }].array;
    }];
}


@end
