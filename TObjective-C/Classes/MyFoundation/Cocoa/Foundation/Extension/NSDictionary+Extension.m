//
//  NSDictionary+Categories+NM.m
//  NiuNiu
//
//  Created by HeiHuaBaiHua on 2017/7/5.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "NSDictionary+Extension.h"

@implementation NSDictionary(Extension)

- (NSString *)javascriptEncodedString{        
    NSString *result = @"{";
    for (NSString *key in self) {
        NSString *targetString = [NSString stringWithFormat:@"\"%@\":`%@`,", key, [self valueForKey:key]];
        result = [result stringByAppendingString:targetString];
    }
    result = [result substringToIndex:result.length-1];
    result = [result stringByAppendingString:@"}"];
    return result;
}

@end



