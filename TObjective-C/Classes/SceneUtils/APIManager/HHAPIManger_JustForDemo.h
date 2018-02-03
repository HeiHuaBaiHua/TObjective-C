//
//  HHAPIManger_JustForDemo.h
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/2.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    HHAPIMangerTypeTCP,
    HHAPIMangerTypeHTTP,
    HHAPIMangerTypeWebSocket,
} HHAPIMangerType;

FOUNDATION_EXTERN HHAPIMangerType APIType; 
@interface HHAPIManger_JustForDemo : NSObject

+ (id)userAPIManger;
+ (id)weiboAPIManger;

@end
