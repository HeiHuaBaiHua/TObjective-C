//
//  UIScreen+Extension.h
//  Template
//
//  Created by leihaiyin on 2018/8/3.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    HHScreenTypeIPhone4,
    HHScreenTypeIPhone5,
    HHScreenTypeIPhone6,
    HHScreenTypeIPhone6Plus,
    HHScreenTypeIPhoneX
} HHScreenType;

@interface UIScreen(Extension)

+ (HHScreenType)type;

+ (CGFloat)width;
+ (CGFloat)height;/**< 整个屏幕高度 */
+ (CGFloat)contentHeight;/**< 去除导航栏后的屏幕高度 */

+ (CGFloat)statusBarHeight;/**< 状态栏高度 */
+ (CGFloat)navBarHeight;/**< 导航栏高度(不包含状态栏) */
+ (CGFloat)topBarHeight;/**< 状态栏+导航高度 */
+ (CGFloat)tabbarHeight;/**< tabbar高度 */

@end
