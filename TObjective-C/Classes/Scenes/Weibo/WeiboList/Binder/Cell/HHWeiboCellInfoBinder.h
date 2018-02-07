//
//  HHWeiboCellInfoBinder.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HHBinderProtocol.h"
#import "HHWeiboCellViewProtocol.h"
@interface HHWeiboCellInfoBinder : NSObject<HHBinderProtocol>

- (instancetype)initWithView:(UIView<HHWeiboCellInfoViewProtocol> *)view;

@end
