//
//  HHService.h
//  HeiHuaBaiHua
//
//  Created by HeiHuaBaiHua on 16/6/2.
//  Copyright © 2016年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHNetworkConfig.h"
@interface HHService : NSObject

+ (HHService *)defaultService;
+ (HHService *)serviceWithType:(HHServiceType)type;

- (NSString *)baseUrl;
@end
