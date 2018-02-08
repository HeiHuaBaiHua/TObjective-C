//
//  HHProfileBuilder.m
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/8.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import "HHFoundation.h"
#import "HHProfileBuilder.h"

#import "HHRegisterView.h"
#import "HHRegisterBinder.h"
#import "HHRegisterViewModel.h"
@implementation HHProfileBuilder

+ (id<HHBinderProtocol>)registerBinder {
    HHRegisterView *view = [HHRegisterView IBInstance];
    HHRegisterBinder *binder = [[HHRegisterBinder alloc] initWithView:view];
    return binder;
}

+ (id<HHRegisterViewModelProtocol>)registerViewModel {
    return [HHRegisterViewModel new];
}

@end
