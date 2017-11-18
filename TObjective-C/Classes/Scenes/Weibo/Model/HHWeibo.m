//
//  HHWeibo.m
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHWeibo.h"

@implementation HHWeibo

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"ID": @"idstr",
             @"sender": @"user",
             @"picUrls": @"pic_urls",
             @"createdDate": @"created_at",
             @"repostsCount": @"reposts_count",
             @"commentsCount": @"comments_count",
             @"attitudesCount": @"attitudes_count",
             @"retweetedWeibo": @"retweeted_status"};
}

@end

