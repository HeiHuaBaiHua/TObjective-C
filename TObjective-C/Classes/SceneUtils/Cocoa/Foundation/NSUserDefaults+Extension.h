//
//  NSUserDefaults+Extension.h
//  TObjective-C
//
//  Created by leihaiyin on 2017/11/10.
//  Copyright © 2017年 HeiHuaBaiHua. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SharedUserDefaults [NSUserDefaults standardUserDefaults]

@interface NSUserDefaults (Extension)

@property (nonatomic, copy) NSString *token;

@end
