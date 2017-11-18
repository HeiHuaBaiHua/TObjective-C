//
//  HHWeiboCellInfoViewModelProtocol.h
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACCommand;
@protocol HHWeiboCellInfoViewModelProtocol <NSObject>

@property (nonatomic, assign) CGFloat contentHeight;

- (BOOL)hideVip;
- (NSURL *)avatarUrl;
- (NSString *)name;
- (NSString *)createDate;

- (NSString *)likesCount;
- (NSString *)repostsCount;
- (NSString *)commentsCount;

- (BOOL)isLiked;
- (RACCommand *)likeCommand;

@end
