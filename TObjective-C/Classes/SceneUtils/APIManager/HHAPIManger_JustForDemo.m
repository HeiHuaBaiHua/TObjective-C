//
//  HHAPIManger_JustForDemo.m
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/2.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHAPIManger_JustForDemo.h"

#import "HHUserAPIManager.h"
#import "HHWeiboAPIManager.h"

#import "HHUserTCPAPIManager.h"
#import "HHWeiboTCPAPIManager.h"

#import "HHUserWebSocketAPIManager.h"
#import "HHWeiboWebSocketAPIManager.h"
HHAPIMangerType APIType = HHAPIMangerTypeTCP;
@implementation HHAPIManger_JustForDemo

+ (id)userAPIManger {
    
    switch (APIType) {
        case HHAPIMangerTypeTCP: return [HHUserTCPAPIManager new];
        case HHAPIMangerTypeHTTP: return [HHUserAPIManager new];
        case HHAPIMangerTypeWebSocket: return [HHUserWebSocketAPIManager new];
    }
}

+ (id)weiboAPIManger {
    
    switch (APIType) {
        case HHAPIMangerTypeTCP: return [HHWeiboTCPAPIManager new];
        case HHAPIMangerTypeHTTP: return [HHWeiboAPIManager new];
        case HHAPIMangerTypeWebSocket: return [HHWeiboWebSocketAPIManager new];
    }
}

@end
