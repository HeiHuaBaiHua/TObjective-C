//
//  HHWeiboDetailLikesCellViewModel.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/16.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWeiboDetailLikesCellViewModel.h"

@interface HHWeiboDetailLikesCellViewModel ()

@property (nonatomic, strong) HHUser *rawValue;

@end

@implementation HHWeiboDetailLikesCellViewModel

- (instancetype)initWithObject:(id)object {
    if (self = [super init]) {
        self.rawValue = object;
    }
    return self;
}

- (CGFloat)cellHeight {
    return 44;
}


@end
