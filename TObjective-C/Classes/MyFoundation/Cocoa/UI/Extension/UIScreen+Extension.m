//
//  UIScreen+Extension.m
//  Template
//
//  Created by leihaiyin on 2018/8/3.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "UIScreen+Extension.h"

@implementation UIScreen (Extension)

+ (CGFloat)width{
    return  [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)height{
    return  [UIScreen mainScreen].bounds.size.height;
}

+ (CGFloat)contentHeight {
    return [self height] - [self topBarHeight];
}

+ (CGFloat)statusBarHeight {
    return self.type == HHScreenTypeIPhoneX ? 44 : 20;
}

+ (CGFloat)navBarHeight {
    return 44;
}

+ (CGFloat)topBarHeight {
    return self.statusBarHeight + self.navBarHeight;
}

+ (CGFloat)tabbarHeight {
    return 49;
}

+ (HHScreenType)type {
    
    if ([UIScreen instancesRespondToSelector:@selector(currentMode)] &&
        CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size)) {
        return HHScreenTypeIPhoneX;
    }
    
    CGFloat screenHeight = MAX([self width], [self height]);
    if( 568 == screenHeight ) return HHScreenTypeIPhone5;
    if( 667 == screenHeight ) return HHScreenTypeIPhone6;
    if( 736 == screenHeight ) return HHScreenTypeIPhone6Plus;
    return HHScreenTypeIPhone4;
}

@end
