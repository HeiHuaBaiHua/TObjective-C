//
//  HHWeiboDetailViewModel.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/15.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"

#import "HHWeiboCellViewModel.h"
#import "HHWeiboDetailViewModel.h"
#import "HHWeiboDetailLikesViewModel.h"
#import "HHWeiboDetailRepostsViewModel.h"
#import "HHWeiboDetailCommentsViewModel.h"
@interface HHWeiboDetailViewModel ()

@property (nonatomic, strong) HHWeibo *weibo;

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) HHWeiboCellViewModel *weiboDetailCellViewModel;
@property (nonatomic, strong) HHWeiboDetailLikesViewModel *likesViewModel;
@property (nonatomic, strong) HHWeiboDetailRepostsViewModel *repostsViewModel;
@property (nonatomic, strong) HHWeiboDetailCommentsViewModel *commentsViewModel;
@end

@implementation HHWeiboDetailViewModel

- (instancetype)initWithObject:(HHWeibo *)weibo {
    if (self = [super init]) {
        self.weibo = weibo;
        
        self.weiboDetailCellViewModel = [[HHWeiboCellViewModel alloc] initWithObject:weibo];
        self.likesViewModel = [HHWeiboDetailLikesViewModel new];
        self.repostsViewModel = [HHWeiboDetailRepostsViewModel new];
        self.commentsViewModel = [HHWeiboDetailCommentsViewModel new];
        
        [self formatCount];
    }
    return self;
}

#pragma mark - Interface

- (NSDictionary *)titleAttributes:(BOOL)selected {
    
    UIColor *color = [UIColor colorWithHex:selected ? 0x252525 : 0x999999];
    return @{NSFontAttributeName : [UIFont fontOfCode:2], NSForegroundColorAttributeName : color};
}

#pragma mark - Utils

- (void)formatCount {
    
    NSString *(^formatCount)(NSString *, NSInteger) = ^(NSString *prefix, NSInteger count){
        
        if (count < 10000) {
            return [NSString stringWithFormat:@"%@%zd", prefix, count];
        }
        return [NSString stringWithFormat:@"%@%zd万", prefix, count / 10000];
    };
    self.titles = @[formatCount(@"转发 ", self.weibo.repostsCount),
                    formatCount(@"评论 ", self.weibo.commentsCount),
                    formatCount(@"赞 ", self.weibo.attitudesCount)];
}

@end
