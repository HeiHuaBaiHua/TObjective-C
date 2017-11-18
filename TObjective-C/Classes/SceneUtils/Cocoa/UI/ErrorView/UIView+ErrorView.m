//
//  UIView+ErrorView.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/9/26.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <objc/runtime.h>
#import <Masonry/Masonry.h>

#import "HHErrorBinder.h"
#import "UIView+ErrorView.h"

@implementation UIView (ErrorView)

static void *ErrorViewKey = &ErrorViewKey;

- (UIView<HHErrorBinderProtocol> *)errorView {
    
    HHErrorBinder *errorView = objc_getAssociatedObject(self, ErrorViewKey);
    if (!errorView) {
        errorView = [self addErrorView];
        objc_setAssociatedObject(self, ErrorViewKey, errorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [self bringSubviewToFront:errorView];
    return errorView;
}

- (HHErrorBinder *)addErrorView {
    
    HHErrorBinder *errorView = [[HHErrorBinder alloc] initWithFrame:self.bounds];
    errorView.backgroundColor = self.backgroundColor;
    [self addSubview:errorView];
    
    if (![self isKindOfClass:[UIScrollView class]]) {
        [errorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsZero);
        }];
    }
    errorView.hidden = YES;
    return errorView;
}

@end
