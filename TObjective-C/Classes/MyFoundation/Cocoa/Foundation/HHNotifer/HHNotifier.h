//
//  HHNotifier.h
//  TTRuntime
//
//  Created by 黑花白花 on 2017/2/25.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHNotifier : NSProxy

+ (instancetype)notifier;
+ (instancetype)ratainNotifier;

- (void)addObserver:(id)observer;
- (void)removeObserver:(id)observer;

@end
