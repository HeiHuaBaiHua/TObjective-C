//
//  HHWebSocketMessageParser.h
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/3.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHWebSocketMessageParser : NSObject

+ (NSUInteger)responseURLFromMessage:(NSDictionary *)message;
+ (NSNumber *)responseSerialNumberFromMessage:(NSDictionary *)message;
+ (NSDictionary *)responseDataFromMessage:(NSDictionary *)message;

@end
