//
//  HHUIBuilder.h
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHSegmentViewProtocol.h"
@interface HHUIBuilder : NSObject

+ (UINavigationController *)navigationControllerWithRootVC:(UIViewController *)rootVC;

+ (UIView<HHSegmentViewProtocol> *)segmentViewWithFrame:(CGRect)frame;

@end
