//
//  NSString+Extension.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Extension)

- (CGSize)sizeWithBoundingSize:(CGSize)boundingSize fontCode:(NSInteger)fontCode;

- (NSURL *)url;
- (UIImage *)image;
- (NSString *)encodeURLString;

- (BOOL)isValidPhoneNum;
@end
