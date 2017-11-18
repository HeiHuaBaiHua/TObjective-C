//
//  HHWeiboCellInfoViewModel.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/13.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "HHFoundation.h"
#import "HHWeiboCellInfoViewModel.h"

#import "HHWeiboAPIManager.h"
@interface HHWeiboCellInfoViewModel ()

@property (nonatomic, strong) HHWeibo *rawValue;

@property (nonatomic, assign) BOOL hideVip;
@property (nonatomic, strong) NSURL *avatarUrl;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *createDate;

@property (nonatomic, copy) NSString *likesCount;
@property (nonatomic, copy) NSString *repostsCount;
@property (nonatomic, copy) NSString *commentsCount;

@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, strong) RACCommand *likeCommand;
@end

@implementation HHWeiboCellInfoViewModel

@synthesize contentHeight;

- (instancetype)initWithObject:(HHWeibo *)object {
    if (self = [super init]) {
        
        self.rawValue = object;
        
        self.name = object.sender.name;
        self.hideVip = NO;
        self.avatarUrl = object.sender.avatr.url;
        self.createDate = object.createdDate;
        
        self.likesCount = [self formatCount:object.attitudesCount];
        self.repostsCount = [self formatCount:object.repostsCount];
        self.commentsCount = [self formatCount:object.commentsCount];
        
        self.contentHeight = 55 + 33;
    }
    return self;
}

- (RACCommand *)likeCommand {
    if (!_likeCommand) {
        @weakify(self);
        _likeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            
            [self switchLikesStatus];
            return [[[HHWeiboAPIManager new] switchLikeStatusSignalWithWeiboID:@""] doError:^(NSError *error) {
                [self switchLikesStatus];
            }];
        }];
    }
    return _likeCommand;
}

#pragma mark - Utils

- (NSString *)formatCount:(NSInteger)count {
    
    if (count < 10000) { return @(count).stringValue; }
    return [NSString stringWithFormat:@"%zd万", count / 10000];
}

- (void)switchLikesStatus {
    
    self.isLiked = !self.isLiked;
    NSInteger count = self.rawValue.attitudesCount + (self.isLiked ? 1 : -1);
    self.likesCount = [self formatCount:count];
}

@end
