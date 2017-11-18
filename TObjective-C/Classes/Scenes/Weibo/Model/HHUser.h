//
//  HHUser.h
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHUser : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *avatr;
@property (nonatomic, assign) BOOL verified;

@end
