//
//  HHUserWebSocketAPIManager.m
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/3.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//
#import "HHUser.h"

#import "HHUserWebSocketAPIManager.h"

@implementation HHUserWebSocketAPIManager

/** TODO: 登陆 */
- (RACSignal *)loginSignalWithAccount:(NSString *)account password:(NSString *)password {
    
    HHWebDataTaskConfiguration *config = [HHWebDataTaskConfiguration new];
    config.url = WEBSOCKET_login;
    config.requestParameters = @{@"account": account ?: @"",
                                 @"password": password ?: @""};
    
    config.deserializePath = @"data";
    config.deserializeClass = [HHUser class];
    return [self dataSignalWithConfig:config];
}

@end
