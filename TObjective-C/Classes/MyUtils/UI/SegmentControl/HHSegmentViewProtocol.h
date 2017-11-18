//
//  HHSegmentViewDataSource.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/9/19.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HHSegmentView;
@protocol HHSegmentViewDataSource <NSObject>

@optional
- (CGFloat)heightOfHeaderInSegmentView:(HHSegmentView *)segmentView;
@required
- (NSUInteger)numberOfItemsInSegmentView:(HHSegmentView *)segmentView;

- (UIView *)segmentView:(HHSegmentView *)segmentView itemViewAtIndex:(NSUInteger)index;
- (NSString *)segmentView:(HHSegmentView *)segmentView titleForItemAtIndex:(NSUInteger)index;
- (NSDictionary *)segmentView:(HHSegmentView *)segmentView attributesForTitleAtIndex:(NSUInteger)index selected:(BOOL)selected;

@end

@protocol HHSegmentViewDelegate <NSObject>

@optional
- (void)segmentView:(HHSegmentView *)segmentView didScrollToItemAtIndex:(NSUInteger)index;

@end

@protocol HHSegmentViewProtocol <NSObject>

@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong, readonly) UIView *selectedItemView;

- (void)setDelegate:(id<HHSegmentViewDelegate>)delegate;
- (void)setDataSource:(id<HHSegmentViewDataSource>)dataSource;

- (void)setHeaderBackgroundColor:(UIColor *)color;
@end
