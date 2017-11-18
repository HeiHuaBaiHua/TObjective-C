//
//  HHWeiboCellInfoViewModel.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"
#import "HHWeiboCellInfoViewModel.h"

@interface HHWeiboCellInfoViewModel ()

@property (nonatomic, assign) BOOL hideVip;
@property (nonatomic, strong) NSURL *avatarUrl;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *createDate;

@property (nonatomic, copy) NSString *likesCount;
@property (nonatomic, copy) NSString *repostsCount;
@property (nonatomic, copy) NSString *commentsCount;

@end

@implementation HHWeiboCellInfoViewModel

@synthesize contentHeight;

- (instancetype)initWithObject:(HHWeibo *)object {
    if (self = [super init]) {
        
        NSString *(^formatCount)(NSInteger) = ^(NSInteger count){
            
            if (count < 10000) { return @(count).stringValue; }
            return [NSString stringWithFormat:@"%zd万", count / 10000];
        };
        
        self.name = object.sender.name;
        self.hideVip = NO;
        self.avatarUrl = object.sender.avatr.url;
        self.createDate = object.createdDate;
        
        self.likesCount = formatCount(object.attitudesCount);
        self.repostsCount = formatCount(object.repostsCount);
        self.commentsCount = formatCount(object.commentsCount);
        
        self.contentHeight = 55 + 33;
    }
    return self;
}

@end
