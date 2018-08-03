//
//  HHSegmentViewDataSource.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/9/19.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString const *HHSegmentAttributeTitleBackgroundColor;

@class HHSegmentView;
@protocol HHSegmentViewDataSource <NSObject>

@optional
- (CGSize)sizeOfHeaderInSegmentView:(HHSegmentView *)segmentView;
- (CGSize)sizeOfIndicateViewInSegmentView:(HHSegmentView *)segmentView;
- (UIColor *)colorOfIndicateViewInSegmentView:(HHSegmentView *)segmentView;

@required
- (NSUInteger)numberOfItemsInSegmentView:(HHSegmentView *)segmentView;

- (UIView *)segmentView:(HHSegmentView *)segmentView itemViewAtIndex:(NSUInteger)index;
- (NSString *)segmentView:(HHSegmentView *)segmentView titleForItemAtIndex:(NSUInteger)index;
- (NSDictionary *)segmentView:(HHSegmentView *)segmentView attributesForTitleAtIndex:(NSUInteger)index selected:(BOOL)selected;

@end

@protocol HHSegmentViewDelegate <NSObject>

@optional
- (void)segmentViewDidEndReload:(HHSegmentView *)segmentView;
- (void)segmentView:(HHSegmentView *)segmentView didScrollToItemAtIndex:(NSUInteger)index;

@end

@protocol HHSegmentViewProtocol <NSObject>

@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) BOOL allowScrollDelay;
@property (nonatomic, assign) CGFloat duration;

- (void)setDelegate:(id<HHSegmentViewDelegate>)delegate;
- (void)setDataSource:(id<HHSegmentViewDataSource>)dataSource;
- (void)reloadData;

- (void)setHeaderBackgroundColor:(UIColor *)color;
- (void)setHeaderIsMultiplePage:(BOOL)isMultiplePage;
@end
