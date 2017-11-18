//
//  HHWeiboAPIManager.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWeiboAPIManager.h"

#import "HHWeiboCellViewModel.h"
@implementation HHWeiboAPIManager

/** TODO: 最新发布的微博列表 */
- (RACSignal *)publicWeiboListSignalWithPage:(int)page pageSize:(int)pageSize {
    
    HHDataTaskConfiguration *config = [HHDataTaskConfiguration new];
    config.urlPath = @"/statuses/public_timeline.json";
    config.requestParameters = @{@"page": @(page),
                                 @"count": @(pageSize),
                                 @"access_token": @"2.00mlsQHD08Vxev2c072c4f7eJeHFwB"};
    
    config.deserializePath = @"statuses";
    config.deserializeClass = [HHWeibo class];
    return [self dataSignalWithConfig:config];
}

/** TODO: 我关注的用户发布的微博列表 */
- (RACSignal *)followedWeiboListSignalWithPage:(int)page pageSize:(int)pageSize {
    
    HHDataTaskConfiguration *config = [HHDataTaskConfiguration new];
    config.urlPath = @"/statuses/home_timeline.json";
    config.requestParameters = @{@"page": @(page),
                                 @"count": @(pageSize),
                                 @"access_token": @"2.00mlsQHD08Vxev2c072c4f7eJeHFwB"};
    
    config.deserializePath = @"statuses";
    config.deserializeClass = [HHWeibo class];
    return [self dataSignalWithConfig:config];
}

/** TODO: 某条微博的转发列表 */
- (RACSignal *)weiboRepostListSignalWithWeiboID:(NSString *)ID page:(int)page pageSize:(int)pageSize {
    if (page == 3) {
        return [RACSignal error:HHError(@"", HHNetworkTaskErrorNoMoreData)];
    }
    
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < 20; i++) {
        
        HHWeibo *repost = [HHWeibo new];
        repost.ID = @(i + (page - 1) * 20).stringValue;
        [result addObject:repost];
    }
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:result];
            [subscriber sendCompleted];
        });
        return nil;
    }];
}

/** TODO: 某条微博的评论列表 */
- (RACSignal *)weiboCommentListSignalWithWeiboID:(NSString *)ID page:(int)page pageSize:(int)pageSize {
    if (page == 3) {
        return [RACSignal error:HHError(@"", HHNetworkTaskErrorNoMoreData)];
    }
    
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < 20; i++) {
        
        HHWeiboComment *comment = [HHWeiboComment new];
        comment.ID = @(i + (page - 1) * 20).stringValue;
        [result addObject:comment];
    }
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:result];
            [subscriber sendCompleted];
        });
        return nil;
    }];
}

/** TODO: 某条微博的点赞列表 */
- (RACSignal *)weiboLikeListSignalWithWeiboID:(NSString *)ID page:(int)page pageSize:(int)pageSize {
    return [RACSignal error:HHError(@"", HHNetworkTaskErrorNoData)];
}

@end
