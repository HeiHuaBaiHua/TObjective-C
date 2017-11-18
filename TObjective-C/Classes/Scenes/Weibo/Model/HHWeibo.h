//
//  HHWeibo.h
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHUser.h"
typedef enum : NSUInteger {
    HHWeiboHrefURL,
    HHWeiboHrefTopic,
    HHWeiboHrefNickname,
} HHWeiboHrefType;

@interface HHWeibo : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, strong) HHUser *sender;

@property (nonatomic, copy) NSString *createdDate;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSArray *picUrls;
@property (nonatomic, assign) NSInteger repostsCount;
@property (nonatomic, assign) NSInteger commentsCount;
@property (nonatomic, assign) NSInteger attitudesCount;
@property (nonatomic, assign) BOOL favorited;

@property (nonatomic, strong) HHWeibo *retweetedWeibo;
@end
