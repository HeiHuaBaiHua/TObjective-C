//
//  HHWeiboTableCellViewModel.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHWeibo.h"
#import "HHWeiboCellViewModelProtocol.h"

@interface HHWeiboCellViewModel : NSObject<HHWeiboCellViewModelProtocol>

- (instancetype)initWithObject:(HHWeibo *)object;

@end
