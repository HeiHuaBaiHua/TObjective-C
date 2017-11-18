//
//  HHAPIManager+RAC.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHAPIManager.h"

#import "ReactiveCocoa.h"
@interface HHAPIManager (RAC)

- (RACSignal *)dataSignalWithConfig:(HHDataTaskConfiguration *)config;
- (RACSignal *)uploadSignalWithConfig:(HHUploadTaskConfiguration *)config;

@end
