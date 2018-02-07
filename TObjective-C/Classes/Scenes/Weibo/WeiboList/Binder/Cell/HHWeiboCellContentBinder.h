//
//  HHWeiboCellContentBinder.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HHBinderProtocol.h"
#import "HHWeiboCellViewProtocol.h"
@interface HHWeiboCellContentBinder : NSObject<HHBinderProtocol>

- (instancetype)initWithView:(UIView<HHWeiboCellContentViewProtocol> *)view;

@end
