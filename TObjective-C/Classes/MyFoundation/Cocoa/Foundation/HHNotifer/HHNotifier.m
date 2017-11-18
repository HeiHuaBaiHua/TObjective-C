//
//  HHNotifier.m
//  OneToSay
//
//  Created by HeiHuaBaiHua on 2017/2/9.
//  Copyright © 2017年 Excetop. All rights reserved.
//

#import "HHNotifier.h"

@interface HHNotifier ()

@property (strong, nonatomic) NSHashTable *observers;

@end

@implementation HHNotifier

+ (instancetype)notifier:(BOOL)shouldRetainObserver {
    
    HHNotifier *notifier = [super alloc];
    notifier.observers = [NSHashTable hashTableWithOptions:shouldRetainObserver ? NSPointerFunctionsStrongMemory : NSPointerFunctionsWeakMemory];
    return notifier;
}

+ (id)alloc { return [HHNotifier notifier:NO]; }
+ (instancetype)notifier { return [HHNotifier notifier:NO]; }
+ (instancetype)ratainNotifier { return [HHNotifier notifier:YES]; }

#pragma mark - Interface

- (void)addObserver:(id)observer {
    if (observer) {
        
        dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
        [self.observers addObject:observer];
        dispatch_semaphore_signal(self.lock);
    }
}

- (void)removeObserver:(id)observer {
    if (observer) {
        
        dispatch_semaphore_wait(self.lock, DISPATCH_TIME_FOREVER);
        [self.observers removeObject:observer];
        dispatch_semaphore_signal(self.lock);
    }
}

#pragma mark - Override

- (BOOL)respondsToSelector:(SEL)aSelector {
    
    for (id observer in self.observers.allObjects) {
        if ([observer respondsToSelector:aSelector]) { return YES; }
    }
    return NO;
}

#pragma mark - Forward

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    
    for (id observer in self.observers.allObjects) {
        
        NSMethodSignature *signature = [observer methodSignatureForSelector:sel];
        if (signature) { return signature; }
    }
    return [super methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    
    for (id observer in self.observers.allObjects) {
        ![observer respondsToSelector:invocation.selector] ?: [invocation invokeWithTarget:observer];
    }
}

#pragma mark - Getter

- (dispatch_semaphore_t)lock {
    
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = dispatch_semaphore_create(1);
    });
    return lock;
}

@end
