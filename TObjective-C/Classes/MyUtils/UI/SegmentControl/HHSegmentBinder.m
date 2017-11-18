//
//  HHSegmentBinder.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/9/19.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>

#import "HHSegmentBinder.h"

@interface HHSegmentBinder ()<UIScrollViewDelegate>

@property (nonatomic, weak) id<HHSegmentViewDelegate> delegate;
@property (nonatomic, weak) id<HHSegmentViewDataSource> dataSource;

@property (nonatomic, assign) CGFloat titleWidth;
@property (nonatomic, assign) CGFloat titleHeight;
@property (nonatomic, strong) UIButton *selectedButton;

@end

static const CGFloat screenItemCount = 5;
static const CGFloat titleHeight = 35;
static const NSUInteger initialTag = 101;

@implementation HHSegmentBinder

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
    if (index >= self.contentView.subviews.count) { return; }
    
    [self didSelectedTitle:[self.titleView viewWithTag:index + initialTag]];
}

- (UIView *)selectedItemView {
    if (!self.selectedButton) { return nil; }
    
    return [self itemViewAtIndex:self.selectedIndex];
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
    CGFloat headerHeight = [self headerHeight];
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat itemWidth = screenWidth / screenItemCount;
    self.titleView.contentSize = CGSizeMake(itemWidth * itemCount, 0);
    self.titleWidth = screenWidth / MIN(itemCount, screenItemCount);
    self.titleHeight = headerHeight > 0 ? headerHeight : titleHeight;
    [self.titleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.titleHeight);
    }];
    
    self.contentView.delegate = self;
    self.contentView.contentSize = CGSizeMake(screenWidth * itemCount, 0);
    
    for (int idx = 0; idx < itemCount; idx++) {
        
        [self addTitleAtIndex:idx];
        [self addItemAtIndex:idx];
    }
    
    [self.titleView bringSubviewToFront:self.indicatorView];
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
    }
}

#pragma mark - Forward

- (NSUInteger)itemCount {
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInSegmentView:)]) {
        return [self.dataSource numberOfItemsInSegmentView:self];
    }
    return 0;
}

- (CGFloat)headerHeight {
    if ([self.dataSource respondsToSelector:@selector(heightOfHeaderInSegmentView:)]) {
        return [self.dataSource heightOfHeaderInSegmentView:self];
    }
    return 0;
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
