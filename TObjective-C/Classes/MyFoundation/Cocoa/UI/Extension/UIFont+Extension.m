//
//  UIFont+Categories+NN.m
//  NiuNiu
//
//  Created by HeiHuaBaiHua on 2017/7/12.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "UIFont+Extension.h"


@implementation UIFont(Extension)


+ (CGFloat)fontmodulus {
    
    CGFloat screenHeight = MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    if ( 568 == screenHeight ) return 0.9;
    return 1;
}

+ (CGFloat)fontSizeWithCode:(NSInteger)code {
    
    CGFloat fontmodulus = [self fontmodulus];
    switch (code) {
        case 0: return 7.0 * fontmodulus;
        case 1: return 11.0 * fontmodulus;
        case 2: return 13.0 * fontmodulus;
        case 3: return 15.0 * fontmodulus;
        case 4: return 17.0 * fontmodulus;
        case 5: return 19.0 * fontmodulus;
        case 6: return 26.0 * fontmodulus;
        case 7: return 34.0 * fontmodulus;
        case 8: return 39.0 * fontmodulus;
        case 9: return 44.0 * fontmodulus;
    }
    return 10;
}

+ (UIFont *)fontOfCode:(NSInteger)code{
    return [UIFont systemFontOfSize:[self fontSizeWithCode:code]];
}

+ (UIFont *)boldFontOfCode:(NSInteger)code {
    return [UIFont boldSystemFontOfSize:[self fontSizeWithCode:code]];
}

@end
