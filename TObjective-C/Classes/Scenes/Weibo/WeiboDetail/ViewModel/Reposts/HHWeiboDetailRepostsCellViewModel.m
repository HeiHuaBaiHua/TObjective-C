//
//  HHWeiboDetailRepostsCellViewModel.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/16.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"
#import "HHWeiboDetailRepostsCellViewModel.h"

@interface HHWeiboDetailRepostsCellViewModel ()

@property (nonatomic, strong) HHWeibo *rawValue;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIImage *image;
@end

@implementation HHWeiboDetailRepostsCellViewModel

- (instancetype)initWithObject:(HHWeibo *)object {
    if (self = [super init]) {
        self.rawValue = object;
        
        self.text = [NSString stringWithFormat:@"礼貌性的回复%@下", object.ID];
        self.image = @"tabbar_compose_photo".image;
    }
    return self;
}

- (CGFloat)cellHeight {
    return 44;
}

@end
