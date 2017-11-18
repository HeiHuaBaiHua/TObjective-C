//
//  UIViewController+Extension.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "UIViewController+Extension.h"

@implementation UIViewController (Extension)

+ (instancetype)IBInstance {
    return [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
}

+ (instancetype)instanceWithStoryboardName:(NSString *)name identifier:(NSString *)identifier {
    return [[UIStoryboard storyboardWithName:name bundle:nil] instantiateViewControllerWithIdentifier:identifier];
}

@end
