//
//  NSUserDefaults+Extension.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "NSUserDefaults+Extension.h"

static NSString *const kToken = @"HH_Token";
static NSString *const kTCPSessionId = @"HH_TCPSessionId";

@implementation NSUserDefaults (Extension)

- (NSString *)token {
    return [SharedUserDefaults objectForKey:kToken];
}

- (void)setToken:(NSString *)token {
    [SharedUserDefaults setObject:token forKey:kToken];
}

- (NSString *)tcpSessionId {
    return [SharedUserDefaults objectForKey:kTCPSessionId];
}

- (void)setTcpSessionId:(NSString *)tcpSessionId {
    [SharedUserDefaults setObject:tcpSessionId forKey:kTCPSessionId];
}

@end
