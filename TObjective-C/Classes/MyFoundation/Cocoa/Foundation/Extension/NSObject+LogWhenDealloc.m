//
//  NSObject+LogWhenDealloc.m
//  Test
//
//  Created by HeiHuaBaiHua on 2017/3/27.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "NSObject+LogWhenDealloc.h"

#define CustomPrefix @"HH"

//@implementation UIViewController (HHLog)
//
//+ (void)load {
//
//    Method m3 = class_getInstanceMethod(self, @selector(viewDidAppear:));
//    Method m4 = class_getInstanceMethod(self, @selector(swizzleViewDidAppear:));
//    method_exchangeImplementations(m3, m4);
//}
//
//- (void)swizzleViewDidAppear:(BOOL)animated {
//
//    NSString *className = NSStringFromClass([self class]);
//    if ([className hasPrefix:@"HH"]) {
//        NSLog(@"------------------------------viewDidAppear: %@------------------------------", NSStringFromClass([self class]));
//    }
//    [self swizzleViewDidAppear:animated];
//}
//
//@end

@interface HHDeallocLoger : NSObject

+ (instancetype)loger;
- (void)pushClass:(NSString *)className;

@end

@implementation NSObject (LogWhenDealloc)

+ (void)load {
    Method m1 = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
    Method m2 = class_getInstanceMethod(self, @selector(swizzleDealloc));
    method_exchangeImplementations(m1, m2);
}

- (void)swizzleDealloc {
    
    [[HHDeallocLoger loger] pushClass:NSStringFromClass([self class])];
    [self swizzleDealloc];
}

@end

#pragma mark - HHDeallocLoger

#define HH_Log_Classes_Level(x) \
        NSInteger count##x = 0;\
        while (count##x < logLevel_##x.count) {\
            [self logClass:logLevel_##x[count##x] level:x];\
            count##x++;\
        }\
        [logLevel_##x removeAllObjects];

@implementation HHDeallocLoger

+ (instancetype)allocWithZone:(struct _NSZone *)zone { return [self loger]; }

static BOOL hasController;
static NSMutableArray *logLevel_1;
static NSMutableArray *logLevel_2;
static NSMutableArray *logLevel_3;
+ (instancetype)loger {
    
    static HHDeallocLoger *loger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        loger = [super allocWithZone:NULL];
        logLevel_1 = [NSMutableArray array];
        logLevel_2 = [NSMutableArray array];
        logLevel_3 = [NSMutableArray array];
    });
    return loger;
}

- (void)pushClass:(NSString *)className {
    
    if ([className hasPrefix:CustomPrefix]) {
        
        BOOL isCell = [[className lowercaseString] containsString:@"cell"] || [className hasSuffix:@"ItemView"];
        if ([className hasSuffix:@"Binder"]) {
            
            if (isCell && [logLevel_1 containsObject:className]) { return; }
            [logLevel_1 addObject:className];
        } else if ([className hasSuffix:@"View"]) {
            
            if (isCell && [logLevel_2 containsObject:className]) { return; }
            [logLevel_2 addObject:className];
        } else if ([className hasSuffix:@"ViewModel"]) {
            
            if (isCell && [logLevel_3 containsObject:className]) { return; }
            [logLevel_3 addObject:className];
        } else if ([className hasSuffix:@"Controller"]) {
            
            hasController = YES;
            [self logClass:className level:0];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                hasController = NO;
                HH_Log_Classes_Level(1);
                HH_Log_Classes_Level(2);
                HH_Log_Classes_Level(3);
                [self logClass:className level:0];
            });
        }
    }
}

- (void)logClass:(NSString *)className level:(NSInteger)level {
    
    switch (level) {
        case 0: {
            fprintf(stderr, "%s",[[NSString stringWithFormat:@"\n********************************************%@********************************************\n",className] UTF8String]);
        }   break;
        case 1: {
            fprintf(stderr, "%s",[[NSString stringWithFormat:@"\n|----------%@\n",className] UTF8String]);
        }   break;
        case 2: {
            fprintf(stderr, "%s",[[NSString stringWithFormat:@"\n|--------------------%@\n",className] UTF8String]);
        }   break;
        case 3: {
            fprintf(stderr, "%s",[[NSString stringWithFormat:@"\n|------------------------------%@\n",className] UTF8String]);
        }   break;
    }
}

@end
