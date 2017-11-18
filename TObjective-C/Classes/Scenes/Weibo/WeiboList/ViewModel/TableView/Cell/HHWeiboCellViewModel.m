//
//  HHWeiboCellViewModel.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"

#import "HHWeiboCellViewModel.h"
#import "HHWeiboCellInfoViewModel.h"
#import "HHWeiboCellContentViewModel.h"
@interface HHWeiboCellViewModel ()

@property (nonatomic, strong) HHWeibo *rawValue;
@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, strong) HHWeiboCellInfoViewModel *weiboInfoVM;
@property (nonatomic, strong) HHWeiboCellContentViewModel *weiboContentVM;
@property (nonatomic, strong) HHWeiboCellContentViewModel *retweetedWeiboContentVM;
@end

@implementation HHWeiboCellViewModel

- (instancetype)initWithObject:(HHWeibo *)object {
    if (self = [super init]) {
        self.rawValue = object;
        
        self.weiboInfoVM = [[HHWeiboCellInfoViewModel alloc] initWithObject:object];
        self.weiboContentVM = [[HHWeiboCellContentViewModel alloc] initWithObject:object];
        if (object.retweetedWeibo != nil) {
            self.retweetedWeiboContentVM = [[HHWeiboCellContentViewModel alloc] initWithObject:object.retweetedWeibo];
        }
    }
    return self;
}

#pragma mark - HHListCellViewModelProtocol

- (CGFloat)cellHeight {
    if (_cellHeight == 0) {
        
        _cellHeight = self.weiboInfoVM.contentHeight + self.weiboContentVM.contentHeight;
        if (self.retweetedWeiboContentVM != nil) {
            _cellHeight += (Interval * 0.5 + self.retweetedWeiboContentVM.contentHeight);
        }
        _cellHeight += Interval;
    }
    return _cellHeight;
}

@end
