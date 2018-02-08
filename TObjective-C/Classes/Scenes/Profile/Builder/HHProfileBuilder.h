//
//  HHProfileBuilder.h
//  TObjective-C
//
//  Created by leihaiyin on 2018/2/8.
//  Copyright © 2018年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHBinderProtocol.h"

#import "HHRegisterView.h"
#import "HHRegisterViewModelProtocol.h"
@interface HHProfileBuilder : NSObject

+ (id<HHBinderProtocol>)registerBinder;
+ (id<HHRegisterViewModelProtocol>)registerViewModel;

@end
