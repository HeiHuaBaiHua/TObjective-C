//
//  HHWeiboDetailCommentsViewModel.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/16.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWeiboDetailCommentsViewModel.h"
#import "HHWeiboDetailCommentsCellViewModel.h"

#import "HHWeiboAPIManager.h"

@interface HHWeiboDetailCommentsViewModel ()

@property (nonatomic, assign) BOOL noError;

@end

@implementation HHWeiboDetailCommentsViewModel

- (RACSignal *)fetchDataSignalWithPage:(int)page {
    if (!self.noError) {
        self.noError = YES;
        return [RACSignal error:[NSError errorWithDomain:@"" code:5645646 userInfo:nil]];
    }
    
    return [[[HHWeiboAPIManager new] weiboCommentListSignalWithWeiboID:@"" page:page pageSize:0] map:^id(NSArray *comments) {
        
        return [comments.rac_sequence map:^id(HHWeiboComment *value) {
            return [[HHWeiboDetailCommentsCellViewModel alloc] initWithObject:value];
        }].array;
    }];
}

@end
