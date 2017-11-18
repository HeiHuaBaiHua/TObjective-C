//
//  HHSocketService.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHNetworkConfig.h"
@interface HHSocketService : NSObject

+ (HHSocketService *)serviceWithType:(HHServiceType)type;

- (NSString *)url;
- (HHServiceEnvironment)environment;

@end
