//
//  HHPredicate.m
//  xxx
//
//  Created by HeiHuaBaiHua on 16/7/11.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import "HHPredicate.h"

@interface HHPredicate()

@property (strong, nonatomic) NSDictionary *equalKeys;
@property (strong, nonatomic) NSDictionary *containKeys;

@end

@implementation HHPredicate

+ (HHPredicate *)predicateWithEqualProperties:(NSArray *)properties {
    return [self predicateWithEqualProperties:properties containProperties:nil];
}

+ (HHPredicate *)predicateWithContainProperties:(NSArray *)properties {
    return [self predicateWithEqualProperties:nil containProperties:properties];
}

+ (HHPredicate *)predicateWithEqualProperties:(NSArray *)equalProperties containProperties:(NSArray *)containProperties {
    
    HHPredicate *predicate = [HHPredicate new];
    predicate.equalKeys = [NSDictionary dictionaryWithObjects:equalProperties forKeys:equalProperties];;
    predicate.containKeys = [NSDictionary dictionaryWithObjects:containProperties forKeys:containProperties];;
    return predicate;
}

+ (HHPredicate *)predicateWithEqualKeys:(NSDictionary *)equalKeys {
    return [self predicateWithEqualKeys:equalKeys containKeys:nil];
}

+ (HHPredicate *)predicateWithContainKeys:(NSDictionary *)containKeys {
    return [self predicateWithEqualKeys:nil containKeys:containKeys];
}

+ (HHPredicate *)predicateWithEqualKeys:(NSDictionary *)equalKeys containKeys:(NSDictionary *)containKeys {
    
    HHPredicate *predicate = [HHPredicate new];
    predicate.equalKeys = equalKeys;
    predicate.containKeys = containKeys;
    return predicate;
}

- (void)setEqualProperties:(NSArray *)equalProperties {
    [self setEqualProperties:equalProperties containProperties:nil];
}

- (void)setContainProperties:(NSArray *)containProperties {
    [self setEqualProperties:nil containProperties:containProperties];
}

- (void)setEqualProperties:(NSArray *)equalProperties containProperties:(NSArray *)containProperties {
    [self setEqualkeys:[NSDictionary dictionaryWithObjects:equalProperties forKeys:equalProperties] containKeys:[NSDictionary dictionaryWithObjects:containProperties forKeys:containProperties]];
}

- (void)setEqualkeys:(NSDictionary *)equalKeys containKeys:(NSDictionary *)containKeys {
    
    if (equalKeys.count > 0) {
        self.equalKeys = [NSMutableDictionary dictionaryWithDictionary:self.equalKeys];
        [(NSMutableDictionary *)self.equalKeys setValuesForKeysWithDictionary:equalKeys];
    }
    if (containKeys.count > 0) {
        self.containKeys = [NSMutableDictionary dictionaryWithDictionary:self.containKeys];
        [(NSMutableDictionary *)self.containKeys setValuesForKeysWithDictionary:containKeys];
    }
}

- (NSPredicate *)makePredicateWithObjcet:(id)objcet {
    
    NSPredicate *predicate;
    if (self.equalKeys.count > 0 && objcet != nil) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        NSMutableArray *argumentArray = [NSMutableArray array];
        [self.equalKeys enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull objectKey, id  _Nonnull managedObjectKey, BOOL * _Nonnull stop) {
            [keyArray addObject:@"%K = %@"];
            
            [argumentArray addObject:managedObjectKey];
            [argumentArray addObject:[objcet valueForKey:objectKey]];
        }];
        
        NSString *format = [keyArray componentsJoinedByString:@"&&"];
        predicate = [NSPredicate predicateWithFormat:format argumentArray:argumentArray];
    }
    
    return predicate;
}

+ (NSPredicate *)makePredicateWithObjcet:(id)objcet equalProperties:(NSArray *)properties {
    HHPredicate *predicate = [HHPredicate predicateWithEqualProperties:properties];
    return [predicate makePredicateWithObjcet:objcet];
}

- (NSPredicate *)makePredicateWithObjcets:(NSArray *)objcets {
    
    NSPredicate *predicate;
    if (objcets.count > 0) {
        
        NSMutableArray *keyArray = [NSMutableArray array];
        NSMutableArray *argumentArray = [NSMutableArray array];
        if (self.equalKeys.count > 0) {
            
            id object = [objcets firstObject];
            [self.equalKeys enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull objectKey, id  _Nonnull managedObjectKey, BOOL * _Nonnull stop) {
                [keyArray addObject:@"%K = %@"];
                
                [argumentArray addObject:managedObjectKey];
                [argumentArray addObject:[object valueForKey:objectKey]];
            }];
        }
        
        [self.containKeys enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull objectKey, id  _Nonnull managedObjectKey, BOOL * _Nonnull stop) {
            [keyArray addObject:@"%K in %@"];
            
            NSMutableArray *values = [NSMutableArray array];
            for (id model in objcets) { [values addObject:[model valueForKey:objectKey]]; }
            [argumentArray addObject:managedObjectKey];
            [argumentArray addObject:values];
        }];
        
        if (keyArray.count > 0) {
            NSString *format = [keyArray componentsJoinedByString:@"&&"];
            predicate = [NSPredicate predicateWithFormat:format argumentArray:argumentArray];
        }
    }
    
    return predicate;
}

+ (NSPredicate *)makePredicateWithObjcets:(NSArray *)objects equalProperties:(NSArray *)properties containProperties:(NSArray *)containProperties {
    HHPredicate *predicate = [HHPredicate predicateWithEqualProperties:properties containProperties:containProperties];
    return [predicate makePredicateWithObjcets:objects];
}

- (NSString *)identifierWithObjcet:(id)object {
    return [self identifierWithKeys:self.containKeys.allKeys objcet:object];
}

- (NSString *)identifierWithManagedObjcet:(id)managedObject {
    return [self identifierWithKeys:self.containKeys.allValues objcet:managedObject];
}

- (NSString *)identifierWithKeys:(NSArray *)keys objcet:(id)object {
    
    if (keys.count > 0) {
        
        if (keys.count > 1) {
            keys = [keys sortedArrayUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString *  _Nonnull obj2) {
                return [obj1 compare:obj2];
            }];
        }
        
        NSMutableString *identifier = [NSMutableString string];
        [keys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
            [identifier appendFormat:@"%@:", [object valueForKey:key]];
        }];
        return [identifier copy];
    }
    return nil;
}

@end
