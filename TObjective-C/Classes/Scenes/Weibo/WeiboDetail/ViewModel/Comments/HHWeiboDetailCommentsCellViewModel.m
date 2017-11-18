//
//  HHWeiboDetailCommentsCellViewModel.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/16.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"
#import "HHWeiboDetailCommentsCellViewModel.h"

@interface HHWeiboDetailCommentsCellViewModel ()

@property (nonatomic, strong) HHWeiboComment *rawValue;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIImage *image;
@end

@implementation HHWeiboDetailCommentsCellViewModel

- (instancetype)initWithObject:(HHWeiboComment *)object {
    if (self = [super init]) {
        self.rawValue = object;
        
        self.text = [NSString stringWithFormat:@"象征性的评论%@下", object.ID];
        self.image = @"tabbar_compose_photo".image;
    }
    return self;
}

- (CGFloat)cellHeight {
    return 44;
}

@end
