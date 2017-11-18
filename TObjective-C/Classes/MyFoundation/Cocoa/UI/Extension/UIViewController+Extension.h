//
//  UIViewController+Extension.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Extension)

+ (instancetype)IBInstance;
+ (instancetype)instanceWithStoryboardName:(NSString *)name identifier:(NSString *)identifier;

@end
