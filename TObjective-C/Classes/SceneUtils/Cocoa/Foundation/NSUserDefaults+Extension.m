//
//  NSUserDefaults+Extension.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "NSUserDefaults+Extension.h"

static NSString *const kToken = @"HH_Token";

@implementation NSUserDefaults (Extension)

- (void)setToken:(NSString *)token {
    [SharedUserDefaults setObject:token forKey:kToken];
}

- (NSString *)token {
    return [SharedUserDefaults objectForKey:kToken];
}

@end
