//
//  HHSegmentBinder.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/9/19.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>

#import "HHFoundation.h"

#import "HHSegmentBinder.h"

@interface HHSegmentBinder ()<UIScrollViewDelegate>

@property (nonatomic, weak) id<HHSegmentViewDelegate> delegate;
@property (nonatomic, weak) id<HHSegmentViewDataSource> dataSource;

@property (nonatomic, assign) CGFloat titleWidth;
@property (nonatomic, assign) CGFloat titleHeight;
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, assign) BOOL headerIsMultiplePage;
@end

static const CGFloat screenItemCount = 5;
static const CGFloat titleHeight = 35;
static const NSUInteger initialTag = 101;

@implementation HHSegmentBinder
@synthesize selectedIndex = _selectedIndex;

- (void)setDataSource:(id<HHSegmentViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    [self layoutContentView];
    [self setSelectedIndex:self.selectedIndex];
}

- (void)setHeaderBackgroundColor:(UIColor *)color {
    self.titleView.backgroundColor = color;
}

- (NSUInteger)selectedIndex {
    if (!self.selectedButton) { return 0; }
    
    return self.selectedButton.tag - initialTag;
}

- (void)setSelectedIndex:(NSUInteger)index {
    _selectedIndex = index;
    if (index >= self.contentView.subviews.count) { return; }
    
    [self didSelectedTitle:[self.titleView viewWithTag:index + initialTag]];
}

- (UIView *)selectedItemView {
    if (!self.selectedButton) { return nil; }
    
    return [self itemViewAtIndex:self.selectedIndex];
}
- (void)realodData {
    
    NSArray *titles = self.titleView.subviews;
    for (UIView *title in titles) {
        if (title == self.indicatorView) { continue; }
        [title removeFromSuperview];
    }
    
    NSArray *contents = self.contentView.subviews;
    for (UIView *content in contents) {
        [content removeFromSuperview];
    }
    
    self.selectedIndex = 0;
    [self layoutContentView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetX = scrollView.contentOffset.x * (self.titleWidth / CGRectGetWidth([UIScreen mainScreen].bounds));
    self.indicatorView.mj_x = offsetX;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSUInteger index = scrollView.contentOffset.x / CGRectGetWidth([UIScreen mainScreen].bounds) + initialTag;
    [self didSelectedTitle:[self.titleView viewWithTag:index]];
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
        self.titleWidth = CGRectGetWidth([UIScreen mainScreen].bounds) / 4.5;
        self.titleView.contentSize = CGSizeMake(self.titleWidth * itemCount, 0);
    } else {
        [self.titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(headerSize.width, self.titleHeight));
        }];
    }
    
    self.contentView.delegate = self;
    self.contentView.contentSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) * itemCount, 0);
    
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
    self.indicatorView.frame = CGRectMake(0, self.titleHeight - 3, self.titleWidth, 2);
}

- (void)addTitleAtIndex:(NSUInteger)index {
    
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.titleView addSubview:titleButton];
    
    titleButton.tag = initialTag + index;
    titleButton.frame = CGRectMake(self.titleWidth * index, 0, self.titleWidth, self.titleHeight);
    NSString *titleText = [self titleAtIndex:index];
    titleButton.backgroundColor = [UIColor clearColor];
    NSAttributedString *normalTitle = [[NSAttributedString alloc] initWithString:titleText attributes:[self attributesForTitleAtIndex:index selected:NO]];
    NSAttributedString *selectedTitle = [[NSAttributedString alloc] initWithString:titleText attributes:[self attributesForTitleAtIndex:index selected:YES]];
    [titleButton setAttributedTitle:normalTitle forState:UIControlStateNormal];
    [titleButton setAttributedTitle:selectedTitle forState:UIControlStateSelected];
    
    [titleButton addTarget:self action:@selector(didSelectedTitle:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addItemAtIndex:(NSUInteger)index {
    
    UIView *itemView = [self itemViewAtIndex:index];
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    itemView.frame = CGRectMake(screenWidth * index, 0, screenWidth, CGRectGetHeight(self.bounds) - self.titleHeight);
    self.contentView.backgroundColor = itemView.backgroundColor;
    [self.contentView addSubview:itemView];
}

- (void)didSelectedTitle:(UIButton *)titleButton {
    
    if (self.selectedButton != titleButton) {
        
        if ([self.delegate respondsToSelector:@selector(segmentView:didScrollToItemAtIndex:)]) {
            [self.delegate segmentView:self didScrollToItemAtIndex:titleButton.tag - initialTag];
        }
        
        self.selectedButton.selected = NO;
        self.selectedButton = titleButton;
        self.selectedButton.selected = YES;
        
        CGFloat offsetX = CGRectGetWidth([UIScreen mainScreen].bounds) * (titleButton.tag - initialTag);
        [self.contentView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
        [self checkTitleOffset];
    }
}

- (void)checkTitleOffset {
    if (!self.headerIsMultiplePage) { return; }
    
    CGFloat titleOffsetX = self.titleWidth * (self.selectedButton.tag - initialTag);
    CGFloat contentOffsetX = self.titleView.contentOffset.x;
    if (titleOffsetX < contentOffsetX) {
        [self.titleView setContentOffset:CGPointMake(MAX(0, titleOffsetX - self.titleWidth), 0) animated:YES];
    } else if (titleOffsetX + self.titleWidth > contentOffsetX + ScreenWidth) {
        
        CGFloat maxOffsetX = self.titleView.contentSize.width - ScreenWidth;
        CGFloat baseOffsetX = titleOffsetX + self.titleWidth - ScreenWidth;
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
    return CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 35);
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

@end
