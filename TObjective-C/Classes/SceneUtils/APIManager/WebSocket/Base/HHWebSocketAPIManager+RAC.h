//
//  HHWebSocketAPIManager+RAC.h
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/3.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWebSocketAPIManager.h"

#import "ReactiveCocoa.h"
@interface HHWebSocketAPIManager (RAC)

- (RACSignal *)dataSignalWithConfig:(HHWebDataTaskConfiguration *)config;

@end
