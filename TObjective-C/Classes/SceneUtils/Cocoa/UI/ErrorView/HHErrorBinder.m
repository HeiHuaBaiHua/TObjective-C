//
//  HHErrorBinder.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/9/26.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//



#import "HHFoundation.h"
#import "HHErrorBinder.h"
#import "HHNetworkTaskError.h"

@implementation HHErrorBinder

#pragma mark - Interface

- (void)setError:(NSError *)error {
    
    self.errorTextButton.userInteractionEnabled = YES;
    switch (error.code) {
            
        case HHNetworkTaskErrorNoData: {
            
            self.errorTextButton.userInteractionEnabled = NO;
            [self.errorTextButton setTitle:@"暂无数据" forState:UIControlStateNormal];
            [self.errorTextButton setAttributedTitle:nil forState:UIControlStateNormal];
            self.errorImageView.image = @"UI_errorNoData".image;
        }   break;
            
        case HHNetworkTaskErrorCannotConnectedToInternet: {
            
            [self.errorTextButton setTitle:nil forState:UIControlStateNormal];
            [self.errorTextButton setAttributedTitle:[self attributedTextWithPrefixText:@"没有网络, " suffixText:@"点击重试"] forState:UIControlStateNormal];
            self.errorImageView.image = @"UI_errorNoNetwork".image;
        }   break;
            
        default: {
            
            [self.errorTextButton setTitle:nil forState:UIControlStateNormal];
            [self.errorTextButton setAttributedTitle:[self attributedTextWithPrefixText:@"加载失败, " suffixText:@"点击重试"] forState:UIControlStateNormal];
            self.errorImageView.image = @"UI_errorDefault".image;
        }   break;
    }
}

#pragma mark - Utils

- (NSAttributedString *)attributedTextWithPrefixText:(NSString *)prefixText suffixText:(NSString *)suffixText {
    
    UIColor *prefixTextColor = [UIColor colorWithRed:126.0/255 green:132.0/255 blue:145.0/255 alpha:1];
    UIColor *suffixTextColor = [UIColor colorWithRed:86.0/255 green:162.0/255 blue:247.0/255 alpha:1];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:prefixText attributes:@{NSForegroundColorAttributeName : prefixTextColor}];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:suffixText attributes:@{NSForegroundColorAttributeName : suffixTextColor, NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle), NSUnderlineColorAttributeName : suffixTextColor}]];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont fontOfCode:3] range:NSMakeRange(0, attributedText.length)];
    return attributedText;
}

@end
