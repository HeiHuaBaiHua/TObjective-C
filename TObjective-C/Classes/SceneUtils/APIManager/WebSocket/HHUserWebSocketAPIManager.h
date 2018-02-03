//
//  HHUserWebSocketAPIManager.h
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/3.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWebSocketAPIManager.h"

#import "HHWebSocketAPIManager+RAC.h"
@interface HHUserWebSocketAPIManager : HHWebSocketAPIManager

/** TODO: 登陆 */
- (RACSignal *)loginSignalWithAccount:(NSString *)account password:(NSString *)password;

@end
