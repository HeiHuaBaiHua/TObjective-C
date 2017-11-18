//
//  UIView+Extension.h
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define ScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)
#define ScreenBounds [UIScreen mainScreen].bounds
#define ScreenMinusTopHeight (ScreenHeight - TopBarHeight)

#define NavBarHeight (44)
#define TopBarHeight (NavBarHeight + StatusBarHeight)
#define StatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define Interval (10)
#define InitialTag 101

@interface UIView (Extension)

@property (assign, nonatomic) CGFloat originX;
@property (assign, nonatomic) CGFloat originY;
@property (assign, nonatomic) CGFloat centerX;
@property (assign, nonatomic) CGFloat centerY;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGPoint origin;
@property (assign, nonatomic) CGSize size;

@property (assign, nonatomic, readonly) CGFloat left;
@property (assign, nonatomic, readonly) CGFloat right;
@property (assign, nonatomic, readonly) CGFloat top;
@property (assign, nonatomic, readonly) CGFloat bottom;

@end

@interface UIView (ViewController)

- (UIViewController *)viewController;
- (UINavigationController *)navigationController;

@end

@interface UIView (IB)

+ (instancetype)IBInstance;

@end


@protocol Alert <NSObject>

- (void)showHUD;
- (void)showHUDWithText:(NSString *)text;
- (void)hideHUD;

- (void)showToastWithText:(NSString *)toastString;
- (void)showToastWithText:(NSString *)toastString positon:(id)positon;
- (void)showToastWithText:(NSString *)toastString afterDelay:(NSTimeInterval)timeInterval;

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message confirmHandler:(void(^)(UIAlertAction *confirmAction))handler;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle confirmHandler:(void(^)(UIAlertAction *confirmAction))handler;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelAction:(UIAlertAction *)cancelAction confirmAction:(UIAlertAction *)confirmAction;

@end

@interface UIView (Alert)<Alert>
@end

@interface UIViewController (Alert)<Alert>
@end
