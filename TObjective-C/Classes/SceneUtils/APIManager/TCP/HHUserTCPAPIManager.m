//
//  HHUserTCPAPIManager.m
//  TObjective-C
//
//  Created by leihaiyin on 2018/1/31.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHUser.h"
#import "HHUserTCPAPIManager.h"

@implementation HHUserTCPAPIManager

/** TODO: 登陆 */
- (RACSignal *)loginSignalWithAccount:(NSString *)account password:(NSString *)password {
    
    HHTCPDataTaskConfiguration *config = [HHTCPDataTaskConfiguration new];
    config.url = TCP_login;
    config.requestParameters = @{@"account": account ?: @"",
                                 @"password": password ?: @""};
    
    config.deserializePath = @"data";
    config.deserializeClass = [HHUser class];
    return [self dataSignalWithConfig:config];
}


@end
