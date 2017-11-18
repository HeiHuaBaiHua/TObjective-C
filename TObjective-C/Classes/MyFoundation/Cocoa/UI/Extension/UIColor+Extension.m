//
//  UIColor+Categories+NM.m
//  NiuNiu
//
//  Created by HeiHuaBaiHua on 2017/7/12.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor(Extension)

+ (UIColor *)colorWithHex:(long)rgbValue {
    return [UIColor colorWithRed:((rgbValue & 0xff0000) >> 16)/255.0 green:((rgbValue & 0x00FF00) >> 8)/255.0 blue:(rgbValue & 0x0000FF)/255.0 alpha:1.0];
}

- (UIImage *)image {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end


