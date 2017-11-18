//
//  HHUser.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "HHUser.h"

@implementation HHUser

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"ID": @"idstr",
             @"avatr": @"avatar_large"};
}

@end
