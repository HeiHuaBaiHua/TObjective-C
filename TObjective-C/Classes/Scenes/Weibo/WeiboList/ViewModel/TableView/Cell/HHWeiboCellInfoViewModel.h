//
//  HHWeiboCellInfoViewModel.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HHWeibo.h"
#import "HHWeiboCellInfoViewModelProtocol.h"

@interface HHWeiboCellInfoViewModel : NSObject<HHWeiboCellInfoViewModelProtocol>

- (instancetype)initWithObject:(HHWeibo *)object;

@end

