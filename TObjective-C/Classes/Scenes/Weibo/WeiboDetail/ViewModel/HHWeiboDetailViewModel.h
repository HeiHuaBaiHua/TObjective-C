//
//  HHWeiboDetailViewModel.h
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/15.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHWeibo.h"
#import "HHWeiboDetailViewModelProtocol.h"
@interface HHWeiboDetailViewModel : NSObject<HHWeiboDetailViewModelProtocol>

- (instancetype)initWithObject:(HHWeibo *)weibo;

@end
