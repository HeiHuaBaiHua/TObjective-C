//
//  HHWeiboAPIManager.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <YYModel/YYModel.h>

#import "HHWeiboAPIManager.h"

#import "HHWeiboCellViewModel.h"
@implementation HHWeiboAPIManager

+ (void)initialize {
    [self cachedWeiboList];
}

+ (NSArray *)cachedWeiboList {
    static NSArray *cachedWeiboList;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"weibo" ofType:@"plist"];
        cachedWeiboList = [NSArray arrayWithContentsOfFile:filePath];
    });
    return cachedWeiboList;
}

#pragma mark - Interface

/** TODO: 最新发布的微博列表 */
- (RACSignal *)publicWeiboListSignalWithPage:(int)page pageSize:(int)pageSize {
    
    HHDataTaskConfiguration *config = [HHDataTaskConfiguration new];
    config.urlPath = @"/statuses/home_timeline.json";
    config.requestParameters = @{@"page": @(page),
                                 @"count": @(pageSize)};

    config.deserializePath = @"statuses";
    config.deserializeClass = [HHWeibo class];
    return [self dataSignalWithConfig:config];
    
//    return [self cachedWeiboListSignalWithPage:page];
}

/** TODO: 我关注的用户发布的微博列表 */
- (RACSignal *)followedWeiboListSignalWithPage:(int)page pageSize:(int)pageSize {
    
    HHDataTaskConfiguration *config = [HHDataTaskConfiguration new];
    config.urlPath = @"/statuses/home_timeline.json";
    config.requestParameters = @{@"page": @(page),
                                 @"count": @(pageSize)};
    
    config.deserializePath = @"data";
    config.deserializeClass = [HHWeibo class];
    return [self dataSignalWithConfig:config];
    
    return [self cachedWeiboListSignalWithPage:page];
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

/** TODO: 给某条微博点赞/取消赞 */
- (RACSignal *)switchLikeStatusSignalWithWeiboID:(NSString *)ID {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (arc4random() % 2) {
                [subscriber sendError:HHError(@"操作失败~", HHNetworkTaskErrorDefault)];
            } else {
                [subscriber sendNext:@YES];
                [subscriber sendCompleted];
            }
        });
        return nil;
    }];
}

#pragma mark - Utils

- (RACSignal *)cachedWeiboListSignalWithPage:(NSInteger)page {
    
    page = MAX(0, page - 1);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSArray *cache = [HHWeiboAPIManager cachedWeiboList];
            if (page >= cache.count) {
                [subscriber sendError:HHError(@"", HHNetworkTaskErrorNoMoreData)];
            } else {
                
                [subscriber sendNext:[NSArray yy_modelArrayWithClass:[HHWeibo class] json:cache[page]]];
                [subscriber sendCompleted];
            }
        });
        return nil;
    }];
}

@end
