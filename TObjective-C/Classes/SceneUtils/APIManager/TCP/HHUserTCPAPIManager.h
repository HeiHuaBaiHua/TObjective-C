//
//  HHUserTCPAPIManager.h
//  TObjective-C
//
//  Created by leihaiyin on 2018/1/31.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWeiboTCPAPIManager.h"

@interface HHUserTCPAPIManager : HHWeiboTCPAPIManager

/** TODO: 登陆 */
- (RACSignal *)loginSignalWithAccount:(NSString *)account password:(NSString *)password;

@end
