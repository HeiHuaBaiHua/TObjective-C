//
//  HHWeiboCellContentView.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <YYText/YYText.h>
#import <Masonry/Masonry.h>

#import "HHFoundation.h"
#import "HHWeiboCellContentView.h"

@interface HHWeiboCellContentView ()

@property (nonatomic, strong) YYLabel *textLabel;
@property (nonatomic, strong) NSArray<UIButton *> *imageButtons;

@end

@implementation HHWeiboCellContentView

- (instancetype)init { return [self initWithFrame:CGRectZero]; }

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self configuration];
        
        [self layoutUI];
    }
    return self;
}

#pragma mark - Utils

- (void)configuration {
    self.backgroundColor = [UIColor whiteColor];
}

- (void)layoutUI {
    
    [self addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(Interval);
        make.left.equalTo(self).offset(Interval);
        make.right.equalTo(self).offset(-Interval);
    }];
    
    CGFloat imageHeight = (ScreenWidth - Interval * 4) / 3;
    [self.imageButtons enumerateObjectsUsingBlock:^(UIButton * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [self addSubview:image];
        CGFloat top = (imageHeight + Interval) * (idx / 3) + Interval;
        CGFloat left = (imageHeight + Interval) * (idx % 3) + Interval;
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.textLabel.mas_bottom).offset(top);
            make.left.equalTo(self).offset(left);
            make.size.mas_equalTo(CGSizeMake(imageHeight, imageHeight));
        }];
    }];
}

#pragma mark - Getter

- (YYLabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [YYLabel new];
        _textLabel.numberOfLines = 0;
        _textLabel.preferredMaxLayoutWidth = ScreenWidth - Interval * 2;
    }
    return _textLabel;
}

- (NSArray<UIButton *> *)imageButtons {
    if (!_imageButtons) {
        
        NSMutableArray *imageButtons = [NSMutableArray array];
        for (int i = 0; i < 9; i++) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i;
            button.imageView.contentMode = UIViewContentModeScaleAspectFill;
            button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
            button.layer.masksToBounds = YES;
            [imageButtons addObject:button];
        }
        _imageButtons = imageButtons;
    }
    return _imageButtons;
}

@end
