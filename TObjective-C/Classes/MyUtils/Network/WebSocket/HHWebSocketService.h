//
//  HHWebSocketService.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHNetworkConfig.h"
@interface HHWebSocketService : NSObject

+ (HHWebSocketService *)defaultService;
+ (HHWebSocketService *)serviceWithType:(HHServiceType)type;

- (NSString *)url;

@end
