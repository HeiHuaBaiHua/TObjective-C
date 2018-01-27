//
//  HHTCPSocketAPIManager+RAC.h
//  TObjective-C
//
//  Created by leihaiyin on 2018/1/27.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHTCPSocketAPIManager.h"

#import "ReactiveCocoa.h"
@interface HHTCPSocketAPIManager (RAC)

- (RACSignal *)dataSignalWithConfig:(HHTCPDataTaskConfiguration *)config;

@end
