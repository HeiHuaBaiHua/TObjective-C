//
//  UIView+ErrorView.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/9/26.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HHErrorBinderProtocol.h"
@interface UIView (ErrorView)

- (UIView<HHErrorBinderProtocol> *)errorView;

@end
