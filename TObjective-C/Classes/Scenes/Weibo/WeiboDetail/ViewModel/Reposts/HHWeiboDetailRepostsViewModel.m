//
//  HHWeiboDetailRepostsViewModel.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/16.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWeiboDetailRepostsViewModel.h"
#import "HHWeiboDetailRepostsCellViewModel.h"

#import "HHWeiboAPIManager.h"
@implementation HHWeiboDetailRepostsViewModel

- (RACSignal *)fetchDataSignalWithPage:(int)page {    
    return [[[HHWeiboAPIManager new] weiboRepostListSignalWithWeiboID:@"" page:page pageSize:20] map:^id(NSArray *reposts) {
        
        return [reposts.rac_sequence map:^id(HHWeibo *value) {
            return [[HHWeiboDetailRepostsCellViewModel alloc] initWithObject:value];
        }].array;
    }];
}

@end
