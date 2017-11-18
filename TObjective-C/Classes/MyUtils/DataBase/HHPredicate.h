//
//  HHPredicate.h
//  xxx
//
//  Created by HeiHuaBaiHua on 16/7/11.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHPredicate : NSObject

+ (HHPredicate *)predicateWithEqualProperties:(NSArray *)properties;
+ (HHPredicate *)predicateWithContainProperties:(NSArray *)properties;
+ (HHPredicate *)predicateWithEqualProperties:(NSArray *)equalProperties containProperties:(NSArray *)containProperties;

+ (HHPredicate *)predicateWithEqualKeys:(NSDictionary *)equalKeys;
+ (HHPredicate *)predicateWithContainKeys:(NSDictionary *)containKeys;
+ (HHPredicate *)predicateWithEqualKeys:(NSDictionary *)equalKeys containKeys:(NSDictionary *)containKeys;

- (void)setEqualkeys:(NSDictionary *)equalKeys containKeys:(NSDictionary *)containKeys;
- (void)setEqualProperties:(NSArray *)equalProperties;
- (void)setContainProperties:(NSArray *)containProperties;
- (void)setEqualProperties:(NSArray *)equalProperties containProperties:(NSArray *)containProperties;

- (NSString *)identifierWithObjcet:(id)object;
- (NSString *)identifierWithManagedObjcet:(id)managedObject;

- (NSPredicate *)makePredicateWithObjcet:(id)objcet;
+ (NSPredicate *)makePredicateWithObjcet:(id)objcet equalProperties:(NSArray *)properties;

- (NSPredicate *)makePredicateWithObjcets:(NSArray *)objcets;
+ (NSPredicate *)makePredicateWithObjcets:(NSArray *)objcets equalProperties:(NSArray *)properties containProperties:(NSArray *)containProperties;
@end
