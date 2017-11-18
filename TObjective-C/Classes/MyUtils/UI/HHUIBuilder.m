//
//  HHUIBuilder.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHUIBuilder.h"

#import "HHSegmentBinder.h"
#import "HHNavigationController.h"
@implementation HHUIBuilder

+ (UINavigationController *)navigationControllerWithRootVC:(UIViewController *)rootVC {
    return [[HHNavigationController alloc] initWithRootViewController:rootVC];
}

+ (UIView<HHSegmentViewProtocol> *)segmentViewWithFrame:(CGRect)frame {
    return [[HHSegmentBinder alloc] initWithFrame:frame];
}

@end
