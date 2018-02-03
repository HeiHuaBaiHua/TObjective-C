//
//  HHWeiboTCPAPIManager.m
//  TObjective-C
//
//  Created by leihaiyin on 2018/1/27.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWeiboTCPAPIManager.h"

@implementation HHWeiboTCPAPIManager

/** TODO: 最新发布的微博列表 */
- (RACSignal *)publicWeiboListSignalWithPage:(int)page pageSize:(int)pageSize {
    
    HHTCPDataTaskConfiguration *config = [HHTCPDataTaskConfiguration new];
    config.url = TCP_weibo_list_public;
    config.requestParameters = @{@"page": @(page).stringValue,
                                 @"count": @(pageSize).stringValue};
    
    config.deserializePath = @"data";
    config.deserializeClass = [HHWeibo class];
    return [self dataSignalWithConfig:config];
}

/** TODO: 我关注的用户发布的微博列表 */
- (RACSignal *)followedWeiboListSignalWithPage:(int)page pageSize:(int)pageSize {
    
    HHTCPDataTaskConfiguration *config = [HHTCPDataTaskConfiguration new];
    config.url = TCP_weibo_list_followed;
    config.requestParameters = @{@"page": @(page).stringValue,
                                 @"count": @(pageSize).stringValue};
    
    config.deserializePath = @"data";
    config.deserializeClass = [HHWeibo class];
    return [self dataSignalWithConfig:config];
}

/** TODO: 给某条微博点赞/取消赞 */
- (RACSignal *)switchLikeStatusSignalWithWeiboID:(NSString *)ID isLike:(BOOL)isLike {
    
    HHTCPDataTaskConfiguration *config = [HHTCPDataTaskConfiguration new];
    config.url = TCP_weibo_like;
    config.requestParameters = @{@"id": ID ?: @"",
                                 @"is_like": @(isLike).stringValue};
    
    return [self dataSignalWithConfig:config];
}

@end
