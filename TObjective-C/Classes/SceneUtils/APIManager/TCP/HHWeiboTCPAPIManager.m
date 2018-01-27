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
    config.url = WEIBO_LIST;
    config.requestParameters = @{@"page": @(10).stringValue,
                                 @"count": @(pageSize).stringValue};
    
    config.deserializePath = @"data";
    config.deserializeClass = [HHWeibo class];
    return [self dataSignalWithConfig:config];
}

@end
