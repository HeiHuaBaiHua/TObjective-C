//
//  HHSegmentBinder.m
//  HHvce
//
//  Created by leihaiyin on 2017/9/19.
//  Copyright © 2017年 tiger. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>

#import "HHFoundation.h"

#import "HHSegmentBinder.h"

NSString const *HHSegmentAttributeTitleBackgroundColor = @"HHSegmentAttributeTitleBackgroundColor";

@interface HHSegmentBinder ()<UIScrollViewDelegate>

@property (nonatomic, weak) id<HHSegmentViewDelegate> delegate;
@property (nonatomic, weak) id<HHSegmentViewDataSource> dataSource;

@property (nonatomic, assign) CGFloat titleWidth;
@property (nonatomic, assign) CGFloat titleHeight;
@property (nonatomic, strong) UIButton *selectedButton;

@property (nonatomic, assign) BOOL headerIsMultiplePage;
@property (nonatomic, assign) BOOL didRotateToLandscape;
@end

static const CGFloat screenItemCount = 6;
static const CGFloat titleHeight = 35;
static const NSUInteger initialTag = 101;

@implementation HHSegmentBinder

@synthesize selectedIndex = _selectedIndex;
@synthesize allowScrollDelay;
@synthesize duration;
@synthesize selectedButton = _selectedButton;

- (void)setDataSource:(id<HHSegmentViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    [self layoutContentView];
    [self setSelectedIndex:self.selectedIndex];
}

- (void)setHeaderBackgroundColor:(UIColor *)color {
    self.titleView.backgroundColor = color;
}

- (NSUInteger)selectedIndex {
    if (!self.selectedButton) { return _selectedIndex; }
    
    return self.selectedButton.tag - initialTag;
}

- (void)setSelectedIndex:(NSUInteger)index {
    _selectedIndex = index;
    if (index >= self.contentView.subviews.count) { return; }
    
    [self didSelectedTitle:[self.titleView viewWithTag:index + initialTag]];
}

- (void)setSelectedButton:(UIButton *)selectedButton {
    
    self.selectedButton.selected = NO;
    _selectedButton = selectedButton;
    self.selectedButton.selected = YES;
    
    CGFloat offsetX = self.contentWidth * (selectedButton.tag - initialTag);
    [self.contentView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    [self checkTitleOffset];
    
    if (self.allowScrollDelay) {
        if (self.duration <= 0)
            self.duration = 0.2;
        
        [UIView animateWithDuration:self.duration animations:^{
            self.indicatorView.mj_x = self.selectedButton.mj_x;
        }];
    }
}

- (void)reloadData {
    
    NSArray *titles = self.titleView.subviews;
    for (UIView *title in titles) {
        if (title == self.indicatorView) { continue; }
        [title removeFromSuperview];
    }
    
    NSArray *contents = self.contentView.subviews;
    for (UIView *content in contents) {
        [content removeFromSuperview];
    }
    
    [self layoutContentView];
    
    /** 重新设置选中效果 */
    [self scrollViewDidScroll:self.contentView];
    NSUInteger index = self.contentView.contentOffset.x / self.contentWidth + initialTag;
    self.selectedButton = [self.titleView viewWithTag:index];
    
    if ([self.delegate respondsToSelector:@selector(segmentViewDidEndReload:)]) {
        [self.delegate segmentViewDidEndReload:self];
    }
}

- (UIButton *)titleViewAtIndex:(NSUInteger)index {
    if (index >= self.contentView.subviews.count) { return nil; }
    
    return [self.titleView viewWithTag:index + initialTag];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.allowScrollDelay) { return; }
    
    CGFloat offsetX = self.titleWidth * (scrollView.contentOffset.x / self.contentWidth);
    self.indicatorView.mj_x = offsetX;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat offset = scrollView.contentOffset.x / self.contentWidth;
    NSString *decimal = [NSString stringWithFormat:@"%.2f", offset];
    decimal = [decimal componentsSeparatedByString:@"."].lastObject;
    if ([decimal isEqualToString:@"00"] || decimal.floatValue > 95) { offset = ceil(offset); }
    
    NSUInteger index = (NSUInteger)offset + initialTag;
    [self didSelectedTitle:[self.titleView viewWithTag:index]];
}

- (void)deviceOrientationDidChange:(NSNotification *)notif {
    if (self.allowScrollDelay) { return; }
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait: {
            self.indicatorView.mj_x = self.selectedButton.mj_x;
            
            if (self.didRotateToLandscape && UIScreen.type == HHScreenTypeIPhoneX) {
                
                self.didRotateToLandscape = NO;
                self.contentView.scrollEnabled = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.contentView.scrollEnabled = YES;
                });
            }
        }   break;
            
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            self.didRotateToLandscape = YES;
        }   break;
        default:break;
    }
}



#pragma mark - Utils

- (void)layoutContentView {
    
    NSUInteger itemCount = [self itemCount];
    CGSize headerSize = [self headerSize];
    CGFloat itemWidth = headerSize.width / screenItemCount;
    self.titleView.contentSize = CGSizeMake(itemWidth * itemCount, 0);
    self.titleWidth = headerSize.width / MIN(itemCount, screenItemCount);
    self.titleHeight = headerSize.height > 0 ? headerSize.height : titleHeight;
    if (self.headerIsMultiplePage) {
        
        self.titleWidth = self.contentWidth / 4.5;
        self.titleView.contentSize = CGSizeMake(self.titleWidth * itemCount, 0);
        [self.titleView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.titleHeight);
        }];
    } else {
        [self.titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(headerSize.width, self.titleHeight));
        }];
    }
    
    self.contentView.delegate = self;
    self.contentView.contentSize = CGSizeMake(self.contentWidth * itemCount, 0);
    
    for (int idx = 0; idx < itemCount; idx++) {
        
        [self addTitleAtIndex:idx];
        [self addItemAtIndex:idx];
    }
    
    [self layoutIndicatorView];
}

- (void)layoutIndicatorView {
    
    [self.titleView bringSubviewToFront:self.indicatorView];
    if ([self.dataSource respondsToSelector:@selector(sizeOfIndicateViewInSegmentView:)]) {
        
        CGSize indicateSize = [self.dataSource sizeOfIndicateViewInSegmentView:self];
        [self.colorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.indicatorView);
            make.height.equalTo(self.indicatorView);
            make.width.mas_equalTo(MAX(indicateSize.width, self.titleWidth * 0.25));
        }];
    }
    UIColor *color = [UIColor colorWithHex:0xEFBB53];
    if ([self.dataSource respondsToSelector:@selector(colorOfIndicateViewInSegmentView:)]) {
        color = [self.dataSource colorOfIndicateViewInSegmentView:self];
    }
    self.colorView.backgroundColor = color;
    self.indicatorView.frame = CGRectMake(0, self.titleHeight - 3, self.titleWidth, 2);
}

- (void)addTitleAtIndex:(NSUInteger)index {
    
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.titleView addSubview:titleButton];
    
    titleButton.tag = initialTag + index;
    titleButton.frame = CGRectMake(self.titleWidth * index, 0, self.titleWidth, self.titleHeight);
    NSString *titleText = [self titleAtIndex:index];
    titleButton.backgroundColor = [UIColor clearColor];
    
    NSMutableDictionary *normalAttributes = [self attributesForTitleAtIndex:index selected:NO].mutableCopy;
    NSMutableDictionary *selectedAttributes = [self attributesForTitleAtIndex:index selected:YES].mutableCopy;
    UIColor *normalBackgroundColor = normalAttributes[HHSegmentAttributeTitleBackgroundColor] ?: [UIColor clearColor];
    UIColor *selectedBackgroundColor = selectedAttributes[HHSegmentAttributeTitleBackgroundColor];
    if (selectedBackgroundColor) {
        
        [titleButton setBackgroundImage:[UIImage imageWithColor:normalBackgroundColor] forState:UIControlStateNormal];
        [titleButton setBackgroundImage:[UIImage imageWithColor:selectedBackgroundColor] forState:UIControlStateSelected];
    }
    [normalAttributes removeObjectForKey:HHSegmentAttributeTitleBackgroundColor];
    [selectedAttributes removeObjectForKey:HHSegmentAttributeTitleBackgroundColor];
    
    NSAttributedString *normalTitle = [[NSAttributedString alloc] initWithString:titleText attributes:normalAttributes];
    NSAttributedString *selectedTitle = [[NSAttributedString alloc] initWithString:titleText attributes:selectedAttributes];
    [titleButton setAttributedTitle:normalTitle forState:UIControlStateNormal];
    [titleButton setAttributedTitle:selectedTitle forState:UIControlStateSelected];
    
    [titleButton addTarget:self action:@selector(didSelectedTitle:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addItemAtIndex:(NSUInteger)index {
    
    UIView *itemView = [self itemViewAtIndex:index];
    CGFloat screenWidth = self.contentWidth;
    itemView.frame = CGRectMake(screenWidth * index, 0, screenWidth, CGRectGetHeight(self.bounds) - self.titleHeight);
    self.contentView.backgroundColor = itemView.backgroundColor;
    [self.contentView addSubview:itemView];
}

- (void)didSelectedTitle:(UIButton *)titleButton {
    
    if (self.selectedButton != titleButton) {
        
        if ([self.delegate respondsToSelector:@selector(segmentView:didScrollToItemAtIndex:)]) {
            [self.delegate segmentView:self didScrollToItemAtIndex:titleButton.tag - initialTag];
        }
        
        self.selectedButton = titleButton;
    }
}

- (void)checkTitleOffset {
    if (!self.headerIsMultiplePage) { return; }
    
    CGFloat titleOffsetX = self.titleWidth * (self.selectedButton.tag - initialTag);
    CGFloat contentOffsetX = self.titleView.contentOffset.x;
    if (titleOffsetX < contentOffsetX) {
        [self.titleView setContentOffset:CGPointMake(MAX(0, titleOffsetX - self.titleWidth), 0) animated:YES];
    } else if (titleOffsetX + self.titleWidth > contentOffsetX + self.contentWidth) {
        
        CGFloat maxOffsetX = self.titleView.contentSize.width - self.contentWidth;
        CGFloat baseOffsetX = titleOffsetX + self.titleWidth - self.contentWidth;
        [self.titleView setContentOffset:CGPointMake(MIN(maxOffsetX, baseOffsetX + self.titleWidth * 0.5), 0) animated:YES];
    }
}

#pragma mark - Forward

- (NSUInteger)itemCount {
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInSegmentView:)]) {
        return [self.dataSource numberOfItemsInSegmentView:self];
    }
    return 0;
}

- (CGSize)headerSize {
    if ([self.dataSource respondsToSelector:@selector(sizeOfHeaderInSegmentView:)]) {
        
        CGSize headerSize = [self.dataSource sizeOfHeaderInSegmentView:self];
        return CGSizeMake(MAX(headerSize.width, 100), MAX(headerSize.height, 35));
    }
    return CGSizeMake(self.contentWidth, 35);
}

- (UIView *)itemViewAtIndex:(NSUInteger)index {
    if ([self.dataSource respondsToSelector:@selector(segmentView:itemViewAtIndex:)]) {
        return [self.dataSource segmentView:self itemViewAtIndex:index];
    }
    return [UIView new];
}

- (NSString *)titleAtIndex:(NSUInteger)index {
    if ([self.dataSource respondsToSelector:@selector(segmentView:titleForItemAtIndex:)]) {
        return [self.dataSource segmentView:self titleForItemAtIndex:index];
    }
    return @"";
}

- (NSDictionary *)attributesForTitleAtIndex:(NSUInteger)index selected:(BOOL)selected {
    if ([self.dataSource respondsToSelector:@selector(segmentView:attributesForTitleAtIndex:selected:)]) {
        return [self.dataSource segmentView:self attributesForTitleAtIndex:index selected:selected];
    }
    return nil;
}

- (CGFloat)contentWidth {
    
    CGFloat width = CGRectGetWidth(self.bounds);
    return width > 100 ? width : UIScreen.width;
}

@end
