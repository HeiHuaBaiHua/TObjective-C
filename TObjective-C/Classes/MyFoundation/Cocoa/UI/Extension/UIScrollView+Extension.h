//
//  UIScrollView+HHExtension.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/10/16.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (Extension)

@property (nonatomic, assign) BOOL isFirstScrollResponder;
@property (nonatomic, strong) BOOL(^gestureChoiceHandler)(UIGestureRecognizer *, UIGestureRecognizer *);

- (void)neverAdjustScrollInsets;

@end
