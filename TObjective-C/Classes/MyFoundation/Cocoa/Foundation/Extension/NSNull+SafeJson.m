//
//  NSNull+SafeJson.m
//  TObjective-C
//
//  Created by HeiHuaBaiHua on 2017/11/3.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import "NSNull+SafeJson.h"

#define NSNullObjects @[@"",@0,@{},@[]]
@implementation NSNull (SafeJson)

- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    for (id null in NSNullObjects) {
        if ([null respondsToSelector:aSelector]) {
            return null;
        }
    }
    return nil;
}

@end
