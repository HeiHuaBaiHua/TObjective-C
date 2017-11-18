//
//  UIScrollView+HHExtension.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/10/16.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//
#import <objc/runtime.h>
#import "UIScrollView+Extension.h"

static void *ScrollResponderKEY = &ScrollResponderKEY;
static void *GestureHandlerKEY = &GestureHandlerKEY;
@implementation UIScrollView (Extension)

- (void)neverAdjustScrollInsets {
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (BOOL)isFirstScrollResponder {
    id isFirstScrollResponder = objc_getAssociatedObject(self, ScrollResponderKEY);
    if (!isFirstScrollResponder) { return YES; }
    return [isFirstScrollResponder boolValue];
}

- (void)setIsFirstScrollResponder:(BOOL)isFirstScrollResponder {
    objc_setAssociatedObject(self, ScrollResponderKEY, @(isFirstScrollResponder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))gestureChoiceHandler {
    return objc_getAssociatedObject(self, GestureHandlerKEY);
}

- (void)setGestureChoiceHandler:(BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))gestureChoiceHandler {
    objc_setAssociatedObject(self, GestureHandlerKEY, gestureChoiceHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.gestureChoiceHandler) {
        return self.gestureChoiceHandler(gestureRecognizer, otherGestureRecognizer);
    }
    return NO;
}

@end

@implementation UITableView (Extension)

- (void)neverAdjustScrollInsets {
    if (@available(iOS 11.0, *)) {
        
        [super neverAdjustScrollInsets];
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
    }
}

@end

