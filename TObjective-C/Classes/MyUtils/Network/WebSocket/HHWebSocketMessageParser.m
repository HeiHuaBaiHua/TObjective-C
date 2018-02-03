//
//  HHWebSocketMessageParser.m
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/3.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWebSocketMessageParser.h"

@implementation HHWebSocketMessageParser

+ (NSUInteger)responseURLFromMessage:(NSDictionary *)message {
    return [message[@"url"] integerValue];
}

+ (NSNumber *)responseSerialNumberFromMessage:(NSDictionary *)message {
    return @([message[@"serNum"] integerValue]);
}
+ (NSDictionary *)responseDataFromMessage:(NSDictionary *)message {
    return message[@"response"];
}

@end
