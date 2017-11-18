//
//  HHWeiboCellContentViewModel.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <YYText/YYText.h>

#import "HHFoundation.h"
#import "HHWeiboCellContentViewModel.h"

@interface HHWeiboCellContentViewModel ()

@property (nonatomic, strong) HHWeibo *weibo;

@property (nonatomic, strong) NSAttributedString *text;
@property (nonatomic, strong) NSMutableArray<NSURL *> *imageUrls;
@property (nonatomic, strong) NSMutableArray<MWPhoto *> *largeImageUrls;

@property (nonatomic, copy) void(^onClickHrefHandler)(HHWeiboHrefType, NSString *);

@property (nonatomic, assign) CGFloat contentHeight;
@end

@implementation HHWeiboCellContentViewModel

- (instancetype)initWithObject:(HHWeibo *)object {
    if (self = [super init]) {
        self.weibo = object;
        
        [self formatText];
        [self formatImage];
        [self calculateContentHeight];
    }
    return self;
}

#pragma mark - Utils

- (void)formatText {
    NSString *text = self.weibo.text.length > 0 ? self.weibo.text : @"";
    
    NSMutableArray *hrefs = [NSMutableArray array];
    void(^regex)(NSString *) = ^(NSString *pattern) {
        
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matchs = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        for (NSTextCheckingResult *match in matchs) {
            [hrefs addObject:[NSValue valueWithRange:match.range]];
        }
    };
    
    regex(@"#[^#]+#");
    regex(@"@[^ ]+ ");
    regex(@"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?");
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    attributedText.yy_font = [UIFont fontOfCode:4];
    attributedText.yy_color = [UIColor colorWithHex:0x333333];
    attributedText.yy_maximumLineHeight = 20;
    attributedText.yy_minimumLineHeight = 20;
    for (NSValue *range in hrefs) {
        [attributedText yy_setTextHighlightRange:range.rangeValue color:[UIColor colorWithHex:0x007AFF] backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            
            NSString *href = [[text.string substringWithRange:range] stringByReplacingOccurrencesOfString:@"..." withString:@""];
            HHWeiboHrefType hrefType = HHWeiboHrefURL;
            if ([href hasPrefix:@"#"]) {
                
                hrefType = HHWeiboHrefTopic;
                href = [href substringWithRange:NSMakeRange(1, href.length - 2)];
            } else if ([href hasPrefix:@"@"]) {
                
                hrefType = HHWeiboHrefNickname;
                href = [href substringWithRange:NSMakeRange(1, href.length - 2)];
            }
            !self.onClickHrefHandler ?: self.onClickHrefHandler(hrefType, href);
        }];
    }
    self.text = attributedText;
}

- (void)formatImage {
    if (self.weibo.picUrls.count == 0) { return; }
    
    self.imageUrls = [NSMutableArray array];
    self.largeImageUrls = [NSMutableArray array];
    [self.weibo.picUrls enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *urlString = obj[@"thumbnail_pic"];
        NSURL *url = [urlString stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"].url;
        if (url != nil) {
            
            [self.imageUrls addObject:url];
            NSURL *largeUrl = [urlString stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"large"].url;
            [self.largeImageUrls addObject:[[MWPhoto alloc] initWithURL:largeUrl]];
        }
    }];
}

- (void)calculateContentHeight {
    
    CGFloat textHeight = (self.weibo.text != nil ? [self.weibo.text sizeWithBoundingSize:CGSizeMake(ScreenWidth - 2 * Interval, 999) fontCode:4].height : 0);
    self.contentHeight = Interval + textHeight;
    if (self.imageUrls.count > 0) {
        
        NSInteger imageRows = self.imageUrls.count / 3;
        imageRows += ((self.imageUrls.count % 3) != 0 ? 1 : 0);
        CGFloat imageHeight = (ScreenWidth - Interval * 4) / 3;
        self.contentHeight += ((imageHeight + Interval) * imageRows);
    }
}

@end
