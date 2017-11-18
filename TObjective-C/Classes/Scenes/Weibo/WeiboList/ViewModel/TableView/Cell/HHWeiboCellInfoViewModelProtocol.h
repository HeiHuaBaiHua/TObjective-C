//
//  HHWeiboCellInfoViewModelProtocol.h
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/14.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HHWeiboCellInfoViewModelProtocol <NSObject>

- (BOOL)hideVip;
- (NSURL *)avatarUrl;
- (NSString *)name;
- (NSString *)createDate;

- (NSString *)likesCount;
- (NSString *)repostsCount;
- (NSString *)commentsCount;

@property (nonatomic, assign) CGFloat contentHeight;

@end
