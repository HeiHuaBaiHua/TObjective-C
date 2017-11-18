
//
//  NSObject+CoreDataExtension.m
//  TCoreData
//
//  Created by HeiHuaBaiHua on 16/6/15.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import <MagicalRecord/MagicalRecord.h>

#import "HHClassInfo.h"
#import "NSObject+CoreDataExtension.h"

#define IfUndefinedPrimaryKeyBreak \
                    Class objectClass = [self class];\
                    if (![(id)objectClass respondsToSelector:@selector(primaryKeys)]) { return ; }

#define IfInvalidManagedObjectClassBreak \
                    id managedObjectClass = [[self class] matchedManagedObjectClass];\
                    if (managedObjectClass == nil) { return ; }

#define IfInvalidManagedObjectClassReturn(value) \
                    id managedObjectClass = [[self class] matchedManagedObjectClass];\
                    if (managedObjectClass == nil) { return value; }

#define DispatchCompletionHandlerOnMainQueue \
                    if (completionHandler) {\
                        dispatch_async(dispatch_get_main_queue(), completionHandler);\
                    }

@interface NSManagedObject (CoreDataExtension)

- (void)saveWithObject:(id)object;
- (void)configWithObject:(id)object;

@end

#pragma mark - NSObject(CoreDataExtension)

@implementation NSObject (CoreDataExtension)

+ (instancetype)objectWithManagedObject:(NSManagedObject *)managedObject {
    return [self objectWithManagedObject:managedObject ignoreProperties:nil cacheTable:nil];
}

+ (instancetype)objectWithManagedObject:(NSManagedObject *)managedObject cacheTable:(NSMutableDictionary *)cacheTable {
    return [self objectWithManagedObject:managedObject ignoreProperties:nil cacheTable:cacheTable];
}

+ (instancetype)objectWithManagedObject:(NSManagedObject *)managedObject ignoreProperties:(NSSet *)ignoreProperties cacheTable:(NSMutableDictionary *)cacheTable {
    
    if (managedObject == nil) { return nil; }
    
    id object = [self new];
    HHClassInfo *classInfo = [NSObject managedObjectClassInfoWithObject:object];
    NSDictionary *containerPropertyKeypaths = [(id)classInfo.cls respondsToSelector:@selector(containerPropertyKeypathsForCoreData)] ? [classInfo.cls containerPropertyKeypathsForCoreData] : nil;
    NSDictionary *oneToOneRelationship = [(id)classInfo.cls respondsToSelector:@selector(oneToOneRelationship)] ? [classInfo.cls oneToOneRelationship] : nil;
    NSDictionary *oneToManyRelationship = [(id)classInfo.cls respondsToSelector:@selector(oneToManyRelationship)] ? [classInfo.cls oneToManyRelationship] : nil;
    for (HHPropertyInfo *property in classInfo.properties) {
        
        if ([(id)managedObject respondsToSelector:property->_getter]) {
            
            id propertyValue = [managedObject valueForKey:property->_getPath];
            if (propertyValue != nil) {
                
                switch (property->_type) {
                    case HHPropertyTypeBool:
                    case HHPropertyTypeInt8:
                    case HHPropertyTypeUInt8:
                    case HHPropertyTypeInt16:
                    case HHPropertyTypeUInt16:
                    case HHPropertyTypeInt32:
                    case HHPropertyTypeUInt32: {
                        
                        if ([propertyValue respondsToSelector:@selector(intValue)]) {
                            ((void (*)(id, SEL, int))(void *) objc_msgSend)(object, property->_setter, [propertyValue intValue]);
                        }
                    }   break;
                        
                    case HHPropertyTypeInt64:
                    case HHPropertyTypeUInt64: {
                        
                        if ([propertyValue respondsToSelector:@selector(longValue)]) {
                            ((void (*)(id, SEL, long))(void *) objc_msgSend)(object, property->_setter, [propertyValue longValue]);
                        }
                    }   break;
                        
                    case HHPropertyTypeFloat: {
                        
                        if ([propertyValue respondsToSelector:@selector(floatValue)]) {
                            ((void (*)(id, SEL, float))(void *) objc_msgSend)(object, property->_setter, [propertyValue floatValue]);
                        }
                    }   break;
                        
                    case HHPropertyTypeDouble:
                    case HHPropertyTypeLongDouble: {
                        
                        if ([propertyValue respondsToSelector:@selector(doubleValue)]) {
                            ((void (*)(id, SEL, float))(void *) objc_msgSend)(object, property->_setter, [propertyValue doubleValue]);
                        }
                    }   break;
                        
                    case HHPropertyTypeCustomObject: {//懒
                        
                        if ([ignoreProperties containsObject:property->_name]) { break; }
                        
                        NSString *oneToOneTargetName = oneToOneRelationship[property->_name];
                        NSString *cachedObjectKey = [NSString stringWithFormat:@"%p", propertyValue];
                        if ([cacheTable.allKeys containsObject:cachedObjectKey]) {
                            propertyValue = cacheTable[cachedObjectKey];
                        } else {
                            
                            NSMutableSet *ignorePropertyNames = [NSMutableSet setWithSet:ignoreProperties];
                            !oneToOneTargetName ?: [ignorePropertyNames addObject:oneToOneTargetName];
                            propertyValue = [property->_cls objectWithManagedObject:propertyValue ignoreProperties:ignorePropertyNames cacheTable:cacheTable];
                            !propertyValue ?: [cacheTable setObject:propertyValue forKey:cachedObjectKey];
                        }
                        
                        if (oneToOneTargetName) {
                            
                            id propertyValueClass = [propertyValue class];
                            if ([propertyValueClass respondsToSelector:@selector(oneToOneRelationship)] &&
                                [[propertyValueClass oneToOneRelationship].allKeys containsObject:oneToOneTargetName]) {
                                
                                [propertyValue setValue:object forKey:oneToOneTargetName];
                            } else if ([propertyValueClass respondsToSelector:@selector(oneToManyRelationship)] && [[propertyValueClass oneToManyRelationship].allKeys containsObject:oneToOneTargetName]) {
                                
                                NSMutableArray *objects = [NSMutableArray arrayWithArray:[propertyValue valueForKey:oneToOneTargetName]];
                                [objects addObject:object];
                                [propertyValue setValue:objects forKey:oneToOneTargetName];
                            }
                        }
                        
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)(object, property->_setter, propertyValue);
                    }   break;
                        
                    case HHPropertyTypeArray: {//懒

                        if ([propertyValue isKindOfClass:[NSString class]]) {
                            
                            if ([propertyValue length] > 0) {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)(object, property->_setter, [propertyValue componentsSeparatedByString:@","]);
                            }
                        } else {
                            
                            id objectsClass = NSClassFromString(containerPropertyKeypaths[property->_name]);
                            if (!objectsClass || [ignoreProperties containsObject:property->_name]) { break; }
                            
                            NSMutableSet *ignorePropertyNames = [NSMutableSet setWithSet:ignoreProperties];
                            NSString *oneToManyTargetName = oneToManyRelationship[property->_name];
                            !oneToManyTargetName ?: [ignorePropertyNames addObject:oneToManyTargetName];
                            
                            NSMutableArray *objects = [NSMutableArray array];
                            for (id managedObj in propertyValue) {
                             
                                NSString *cachedObjectKey = [NSString stringWithFormat:@"%p", managedObj];
                                id objValue = cacheTable[cachedObjectKey];;
                                if (!objValue) {
                                    
                                    objValue = [objectsClass objectWithManagedObject:managedObj ignoreProperties:ignorePropertyNames cacheTable:cacheTable];
                                    !objValue ?: [cacheTable setObject:objValue forKey:cachedObjectKey];
                                }
                                
                                if (objValue) {
                                    [objects addObject:objValue];
                                    
                                    if (oneToManyTargetName) {
                                        
                                        id objValueClass = [objValue class];
                                        if ([objValueClass respondsToSelector:@selector(oneToOneRelationship)] &&
                                            [[objValueClass oneToOneRelationship].allKeys containsObject:oneToManyTargetName]) {
                                            
                                            [objValue setValue:object forKey:oneToManyTargetName];
                                        } else if ([objValueClass respondsToSelector:@selector(oneToManyRelationship)] && [[objValueClass oneToManyRelationship].allKeys containsObject:oneToManyTargetName]) {
                                            
                                            NSMutableArray *objValueObjects = [NSMutableArray arrayWithArray:[objValue valueForKey:oneToManyTargetName]];
                                            [objValueObjects addObject:object];
                                            [objValue setValue:objValueObjects forKey:oneToManyTargetName];
                                        }
                                    }
                                }
                            }
                            
                            ((void (*)(id, SEL, id))(void *) objc_msgSend)(object, property->_setter, objects);
                        }
                    }   break;
                        
                    case HHPropertyTypeVoid:
                    case HHPropertyTypeUnknown: break;
                        
                    default: {
                        ((void (*)(id, SEL, id))(void *) objc_msgSend)(object, property->_setter, propertyValue);
                    }   break;
                }
            }
        }
    }
    return object;
}

#pragma mark - CoreDataFinder(sync)

+ (NSUInteger)countOfEntities {
    return [self countOfEntitiesWithPredicate:nil];
}

+ (NSUInteger)countOfEntitiesWithPredicate:(NSPredicate *)searchFilter {
    
    IfInvalidManagedObjectClassReturn(0);
    
    __block NSInteger count;
    dispatch_sync(self.perfromQueue, ^{
        count = [managedObjectClass MR_countOfEntitiesWithPredicate:searchFilter inContext:self.saveContext];
    });
    return count;
}

+ (NSArray *)findAll {
    
    return [self objectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [managedObjectClass MR_findAllInContext:self.saveContext];
    }];
}

+ (NSArray *)findAllWithPredicate:(NSPredicate *)searchTerm {
    
    return [self objectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [managedObjectClass MR_findAllWithPredicate:searchTerm inContext:self.saveContext];
    }];
}

+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending {
    
    return [self objectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [managedObjectClass MR_findAllSortedBy:sortTerm ascending:ascending inContext:self.saveContext];
    }];
}

+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm {
    
    return [self objectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [managedObjectClass MR_findAllSortedBy:sortTerm ascending:ascending withPredicate:searchTerm inContext:self.saveContext];
    }];
}

+ (NSArray *)findByAttribute:(NSString *)attribute withValue:(id)searchValue {
    
    return [self objectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [managedObjectClass MR_findByAttribute:attribute withValue:searchValue inContext:self.saveContext];
    }];
}

+ (NSArray *)findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSString *)sortTerm ascending:(BOOL)ascending {
    
    return [self objectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [managedObjectClass MR_findByAttribute:attribute withValue:searchValue andOrderBy:sortTerm ascending:ascending inContext:self.saveContext];
    }];
}

+ (NSArray *)findAllWithPage:(NSUInteger)page row:(NSUInteger)row {
    
    return [self objectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [self managedObjectsWithFetchRequest:[managedObjectClass MR_requestAllInContext:self.saveContext] page:page row:row];
    }];
}

+ (NSArray *)findAllWithPredicate:(NSPredicate *)searchTerm page:(NSUInteger)page row:(NSUInteger)row {
    
    return [self objectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [self managedObjectsWithFetchRequest:[managedObjectClass MR_requestAllWithPredicate:searchTerm inContext:self.saveContext] page:page row:row];
    }];
}

+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending page:(NSUInteger)page row:(NSUInteger)row {
    
    return [self objectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [self managedObjectsWithFetchRequest:[managedObjectClass MR_requestAllSortedBy:sortTerm ascending:ascending inContext:self.saveContext] page:page row:row];
    }];
}

+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm page:(NSUInteger)page row:(NSUInteger)row {
    
    return [self objectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [self managedObjectsWithFetchRequest:[managedObjectClass MR_requestAllSortedBy:sortTerm ascending:ascending withPredicate:searchTerm inContext:self.saveContext] page:page row:row];
    }];
}

+ (NSArray *)findByAttribute:(NSString *)attribute withValue:(id)searchValue page:(NSUInteger)page row:(NSUInteger)row {
    
    return [self objectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [self managedObjectsWithFetchRequest:[managedObjectClass MR_requestAllWhere:attribute isEqualTo:searchValue inContext:self.saveContext] page:page row:row];
    }];
}

+ (instancetype)findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue {
    
    return [self objectWithManagedObjectFetchHandler:^id(id managedObjectClass) {
        return [managedObjectClass MR_findFirstByAttribute:attribute withValue:searchValue inContext:self.saveContext];
    }];
}

+ (instancetype)findFirstWithPredicate:(NSPredicate *)searchTerm {
    
    return [self objectWithManagedObjectFetchHandler:^id(id managedObjectClass) {
        return [managedObjectClass MR_findFirstWithPredicate:searchTerm inContext:self.saveContext];
    }];
}

+ (instancetype)findFirstWithPredicate:(NSPredicate *)searchterm sortedBy:(NSString *)property ascending:(BOOL)ascending {
    
    return [self objectWithManagedObjectFetchHandler:^id(id managedObjectClass) {
        return [managedObjectClass MR_findFirstWithPredicate:searchterm sortedBy:property ascending:ascending inContext:self.saveContext];
    }];
}

#pragma mark - CoreDataFinder(async)

+ (void)findAllWithCompletionHandler:(void (^)(NSArray *objects))completionHandler {
    
    [self converObjectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [managedObjectClass MR_findAllInContext:self.saveContext];
    } completionHandler:completionHandler];
}

+ (void)findAllWithPredicate:(NSPredicate *)searchTerm completionHandler:(void (^)(NSArray *objects))completionHandler {
    
    [self converObjectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [managedObjectClass MR_findAllWithPredicate:searchTerm inContext:self.saveContext];
    } completionHandler:completionHandler];
}

+ (void)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending completionHandler:(void (^)(NSArray *objects))completionHandler {
    
    [self converObjectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [managedObjectClass MR_findAllSortedBy:sortTerm ascending:ascending inContext:self.saveContext];
    } completionHandler:completionHandler];
}

+ (void)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm completionHandler:(void (^)(NSArray *objects))completionHandler {
    
    [self converObjectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [managedObjectClass MR_findAllSortedBy:sortTerm ascending:ascending withPredicate:searchTerm inContext:self.saveContext];
    } completionHandler:completionHandler];
}

+ (void)findByAttribute:(NSString *)attribute withValue:(id)searchValue completionHandler:(void (^)(NSArray *objects))completionHandler {
    
    [self converObjectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [managedObjectClass MR_findByAttribute:attribute withValue:searchValue inContext:self.saveContext];
    } completionHandler:completionHandler];
}

+ (void)findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSString *)sortTerm ascending:(BOOL)ascending completionHandler:(void (^)(NSArray *objects))completionHandler {
    
    [self converObjectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [managedObjectClass MR_findByAttribute:attribute withValue:searchValue andOrderBy:sortTerm ascending:ascending inContext:self.saveContext];
    } completionHandler:completionHandler];
}

+ (void)findAllWithPage:(NSUInteger)page row:(NSUInteger)row completionHandler:(void (^)(NSArray *objects))completionHandler {
    
    [self converObjectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [self managedObjectsWithFetchRequest:[managedObjectClass MR_requestAllInContext:self.saveContext] page:page row:row];
    } completionHandler:completionHandler];
}

+ (void)findAllWithPredicate:(NSPredicate *)searchTerm page:(NSUInteger)page row:(NSUInteger)row completionHandler:(void (^)(NSArray *objects))completionHandler {
    
    [self converObjectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [self managedObjectsWithFetchRequest:[managedObjectClass MR_requestAllWithPredicate:searchTerm inContext:self.saveContext] page:page row:row];
    } completionHandler:completionHandler];
}

+ (void)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending page:(NSUInteger)page row:(NSUInteger)row completionHandler:(void (^)(NSArray *objects))completionHandler {
    
    [self converObjectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [self managedObjectsWithFetchRequest:[managedObjectClass MR_requestAllSortedBy:sortTerm ascending:ascending inContext:self.saveContext] page:page row:row];
    } completionHandler:completionHandler];
}

+ (void)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm  page:(NSUInteger)page row:(NSUInteger)row completionHandler:(void (^)(NSArray *objects))completionHandler {
    
    [self converObjectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [self managedObjectsWithFetchRequest:[managedObjectClass MR_requestAllSortedBy:sortTerm ascending:ascending withPredicate:searchTerm inContext:self.saveContext] page:page row:row];
    } completionHandler:completionHandler];
}

+ (void)findByAttribute:(NSString *)attribute withValue:(id)searchValue page:(NSUInteger)page row:(NSUInteger)row completionHandler:(void (^)(NSArray *objects))completionHandler {
    
    [self converObjectsWithManagedObjectsFetchHandler:^NSArray *(id managedObjectClass) {
        return [self managedObjectsWithFetchRequest:[managedObjectClass MR_requestAllWhere:attribute isEqualTo:searchValue inContext:self.saveContext] page:page row:row];
    } completionHandler:completionHandler];
}

+ (void)findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue completionHandler:(void (^)(id))completionHandler {
    [self convertObjectWithManagedObjectFetchHandler:^id(id managedObjectClass) {
        return [managedObjectClass MR_findFirstByAttribute:attribute withValue:searchValue inContext:self.saveContext];
    } completionHandler:completionHandler];
}

+ (void)findFirstWithPredicate:(NSPredicate *)searchTerm completionHandler:(void (^)(id))completionHandler {
    [self convertObjectWithManagedObjectFetchHandler:^id(id managedObjectClass) {
        return [managedObjectClass MR_findFirstWithPredicate:searchTerm inContext:self.saveContext];
    } completionHandler:completionHandler];
}

#pragma mark - CoreDataOperation(Save)

- (void)save {
    
    IfUndefinedPrimaryKeyBreak;
    
    [self saveWithPredicate:[[HHPredicate predicateWithEqualKeys:[objectClass primaryKeys]] makePredicateWithObjcet:self]];
}

- (void)saveWithEqualProperties:(NSArray *)properties {
    [self saveWithPredicate:[HHPredicate makePredicateWithObjcet:self equalProperties:properties]];
}

- (void)saveWithPredicate:(NSPredicate *)predicate {
    
    IfInvalidManagedObjectClassBreak;
    
    dispatch_barrier_sync(NSObject.perfromQueue, ^{
        
        NSManagedObject *managedObject = [NSObject managedObjectWithClass:managedObjectClass predicate:predicate];
        [managedObject saveWithObject:self];
    });
}

- (void)saveWithCompletionHandler:(void (^)())completionHandler {
    
    IfUndefinedPrimaryKeyBreak;
    
    [self saveWithPredicate:[[HHPredicate predicateWithEqualKeys:[objectClass primaryKeys]] makePredicateWithObjcet:self] completionHandler:completionHandler];
}

- (void)saveWithEqualProperties:(NSArray *)properties completionHandler:(void (^)())completionHandler {
    [self saveWithPredicate:[HHPredicate makePredicateWithObjcet:self equalProperties:properties] completionHandler:completionHandler];
}

- (void)saveWithPredicate:(NSPredicate *)predicate completionHandler:(void (^)())completionHandler {
    
    IfInvalidManagedObjectClassBreak;
    
    dispatch_barrier_async(NSObject.perfromQueue, ^{
        
        NSManagedObject *managedObject = [NSObject managedObjectWithClass:managedObjectClass predicate:predicate];
        [managedObject saveWithObject:self];
        DispatchCompletionHandlerOnMainQueue;
    });
}

+ (void)saveObjects:(NSArray *)objects {
    [self saveObjects:objects completionHandler:nil];
}

+ (void)saveObjects:(NSArray *)objects completionHandler:(void (^)())completionHandler {
    
    HHPredicate *predicate;
    if (objects.count > 0) {
        
        id objectClass = [objects.firstObject class];
        if ([objectClass respondsToSelector:@selector(primaryKeys)]) {
            predicate = [HHPredicate predicateWithContainKeys:[objectClass primaryKeys]];
        }
    }
    [self saveObjects:objects checkByPredicate:predicate completionHandler:completionHandler];
}

+ (void)saveObjects:(NSArray *)objects checkByPredicate:(HHPredicate *)predicate {
    [self saveObjects:objects checkByPredicate:predicate completionHandler:nil];
}

+ (void)saveObjects:(NSArray *)objects checkByPredicate:(HHPredicate *)predicate completionHandler:(void (^)())completionHandler {
    
    id managedObjectClass = [self matchedManagedObjectClass];
    if (objects.count == 0 || managedObjectClass == nil || predicate == nil) {
        DispatchCompletionHandlerOnMainQueue;
    } else {
        
        dispatch_barrier_async(NSObject.perfromQueue, ^{
            
            NSArray *managedObjects = [managedObjectClass MR_findAllWithPredicate:[predicate makePredicateWithObjcets:objects] inContext:self.saveContext];
            NSMutableArray *managedObjectIdentifierArray = [NSMutableArray array];
            for (NSManagedObject *managedObject in managedObjects) {
                
                id managedObjectIdentifier = [predicate identifierWithManagedObjcet:managedObject];
                if (managedObjectIdentifier) {
                    [managedObjectIdentifierArray addObject:managedObjectIdentifier];
                }
            }
            
            for (id object in objects) {
                
                NSManagedObject *managedObject;
                id objectIdentifier = [predicate identifierWithObjcet:object];
                if ([managedObjectIdentifierArray containsObject:objectIdentifier]) {
                    
                    managedObject = [managedObjects objectAtIndex:[managedObjectIdentifierArray indexOfObject:objectIdentifier]];
                } else {
                    managedObject = [managedObjectClass MR_createEntityInContext:self.saveContext];
                }
                [managedObject configWithObject:object];
            }
            [self.saveContext MR_saveToPersistentStoreAndWait];
            
            DispatchCompletionHandlerOnMainQueue;
        });
    }
}

#pragma mark - CoreDataOperation(Delete)

- (void)delete {
    
    IfUndefinedPrimaryKeyBreak;
    
    [self deleteWithPredicate:[[HHPredicate predicateWithEqualKeys:[objectClass primaryKeys]] makePredicateWithObjcet:self]];
}

- (void)deleteWithEqualProperties:(NSArray *)properties {
    [self deleteWithPredicate:[HHPredicate makePredicateWithObjcet:self equalProperties:properties]];
}

- (void)deleteWithPredicate:(NSPredicate *)predicate {
    
    IfInvalidManagedObjectClassBreak;
    
    dispatch_barrier_sync(NSObject.perfromQueue, ^{
        NSManagedObject *managedObject;
        if (predicate) {
            managedObject = [managedObjectClass MR_findFirstWithPredicate:predicate inContext:[self class].saveContext];
        }
        if (managedObject) {
            [managedObject MR_deleteEntityInContext:[self class].saveContext];
            [[self class].saveContext MR_saveToPersistentStoreAndWait];
        }
    });
}

- (void)deleteWithCompletionHandler:(void (^)())completionHandler {
    
    IfUndefinedPrimaryKeyBreak;
    
    [self deleteWithPredicate:[[HHPredicate predicateWithEqualKeys:[objectClass primaryKeys]] makePredicateWithObjcet:self] completionHandler:completionHandler];
}

- (void)deleteWithEqualProperties:(NSArray *)properties completionHandler:(void (^)())completionHandler {
    [self deleteWithPredicate:[HHPredicate makePredicateWithObjcet:self equalProperties:properties] completionHandler:completionHandler];
}

- (void)deleteWithPredicate:(NSPredicate *)predicate completionHandler:(void (^)())completionHandler {
    
    IfInvalidManagedObjectClassBreak;
    
    dispatch_barrier_async(NSObject.perfromQueue, ^{

        if (predicate) {
            NSManagedObject *managedObject = [managedObjectClass MR_findFirstWithPredicate:predicate inContext:[self class].saveContext];
            if (managedObject) {
                [managedObject MR_deleteEntityInContext:[self class].saveContext];
                [[self class].saveContext MR_saveToPersistentStoreAndWait];
            }
        }
        
        DispatchCompletionHandlerOnMainQueue;
    });
}

+ (void)deleteAll {
    [self deleteAllWithCompletionHandler:nil];
}

+ (void)deleteAllWithCompletionHandler:(void (^)())completionHandler {
    
    IfInvalidManagedObjectClassBreak;
    
    dispatch_barrier_async(NSObject.perfromQueue, ^{
        
        [managedObjectClass MR_truncateAllInContext:self.saveContext];
        [self.saveContext MR_saveToPersistentStoreAndWait];
        
        DispatchCompletionHandlerOnMainQueue;
    });
}

+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate  {
    [self deleteAllMatchingPredicate:predicate completionHandler:nil];
}

+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate completionHandler:(void (^)())completionHandler {
    
    IfInvalidManagedObjectClassBreak;
    
    dispatch_barrier_async(NSObject.perfromQueue, ^{
        
        [managedObjectClass MR_deleteAllMatchingPredicate:predicate inContext:self.saveContext];
        [self.saveContext MR_saveToPersistentStoreAndWait];
        
        DispatchCompletionHandlerOnMainQueue;
    });
}

#pragma mark - KVC

- (id)valueForUndefinedKey:(NSString *)key { return nil; }
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}

#pragma mark - Clear

- (void)clearRelationship {
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        [[(NSDictionary *)self allValues] clearRelationship];
    } else if ([self isKindOfClass:[NSSet class]]) {
        [[(NSSet *)self allObjects] clearRelationship];
    } else if ([self isKindOfClass:[NSArray class]]) {
        for (id object in (NSArray *)self) { [object clearRelationship]; }
    } else {
        
        NSDictionary *relationship = [self relationshipForObject:self];
        [relationship enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            id relateObject = [self valueForKey:key];
            BOOL relateObjectIsArray = [relateObject isKindOfClass:[NSArray class]];
            NSDictionary *objcetRelationship = [self relationshipForObject:relateObjectIsArray ? [relateObject firstObject] : relateObject];
            [objcetRelationship enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                
                if (!relateObjectIsArray) {
                    [[relateObject valueForKey:key] setValue:nil forKey:obj];
                } else {
                    
                    for (id element in relateObject) {
                        [[element valueForKey:key] setValue:nil forKey:obj];
                    }
                }
            }];
        }];
    }
}

- (NSDictionary *)relationshipForObject:(id)object {
    
    id cls = [object class];
    NSDictionary *oneToOneRelationship = [cls respondsToSelector:@selector(oneToOneRelationship)] ? [cls oneToOneRelationship] : nil;
    NSDictionary *oneToManyRelationship = [cls respondsToSelector:@selector(oneToManyRelationship)] ? [cls oneToManyRelationship] : nil;
    if (oneToOneRelationship || oneToManyRelationship) {
        
        NSMutableDictionary *relationship = [NSMutableDictionary dictionary];
        [relationship setValuesForKeysWithDictionary:oneToOneRelationship];
        [relationship setValuesForKeysWithDictionary:oneToManyRelationship];
        return relationship;
    }
    return nil;
}

#pragma mark - Utils

+ (id)matchedManagedObjectClass {
    
    id objectClass = [self class];
    if (![objectClass respondsToSelector:@selector(managedObjectClass)]) { return nil; }
    
    id managedObjectClass = [objectClass managedObjectClass];
    if (![managedObjectClass isSubclassOfClass:[NSManagedObject class]]) { return nil; }
    
    return managedObjectClass;
}

+ (NSManagedObject *)managedObjectWithClass:(id)managedObjectClass predicate:(NSPredicate *)predicate {
    
    if (predicate == nil || managedObjectClass == nil || ![managedObjectClass isSubclassOfClass:[NSManagedObject class]]) { return nil; }
    
    NSManagedObject *managedObject = [managedObjectClass MR_findFirstWithPredicate:predicate inContext:NSObject.saveContext];
    if (managedObject != nil) {
        return managedObject;
    } else {
        return [managedObjectClass MR_createEntityInContext:NSObject.saveContext];
    }
}

+ (NSArray *)managedObjectsWithFetchRequest:(NSFetchRequest *)request page:(NSUInteger)page row:(NSUInteger)row {
    
    IfInvalidManagedObjectClassReturn(nil);
    
    request.fetchLimit = row;
    request.fetchOffset = page * row;
    return [managedObjectClass MR_executeFetchRequest:request inContext:self.saveContext];
}

+ (id)objectWithManagedObjectFetchHandler:(id (^)(id managedObjectClass))fetchHandler {
    
    IfInvalidManagedObjectClassReturn(nil);
    
    __block id object;
    dispatch_sync(self.perfromQueue, ^{
        object = [self objectWithManagedObject:fetchHandler(managedObjectClass)];
    });
    return object;
}

+ (void)convertObjectWithManagedObjectFetchHandler:(id (^)(id managedObjectClass))fetchHandler completionHandler:(void (^)(id model))completionHandler {
    
    IfInvalidManagedObjectClassBreak;
    
    dispatch_async(self.perfromQueue, ^{
        
        id object = [self objectWithManagedObject:fetchHandler(managedObjectClass)];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler ? completionHandler(object) : nil;
        });
    });
}

+ (NSArray *)objectsWithManagedObjectsFetchHandler:(NSArray *(^)(id managedObjectClass))fetchHandler {
    
    IfInvalidManagedObjectClassReturn(nil);
    
    __block NSArray *objects;
    dispatch_sync(self.perfromQueue, ^{
        objects = [self objectsWithManagedObjects:fetchHandler(managedObjectClass)];
    });
    return objects;
}

+ (void)converObjectsWithManagedObjectsFetchHandler:(NSArray *(^)(id managedObjectClass))fetchHandler completionHandler:(void (^)(NSArray *objects))completionHandler {
    
    IfInvalidManagedObjectClassBreak;
    
    dispatch_async(self.perfromQueue, ^{
        
        NSArray *objects = [self objectsWithManagedObjects:fetchHandler(managedObjectClass)];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler ? completionHandler(objects) : nil;
        });
    });
}

+ (NSArray *)objectsWithManagedObjects:(NSArray<NSManagedObject *> *)managedObjects {
    
    if (managedObjects.count > 0) {
        
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        NSMutableArray *objects = [NSMutableArray array];
        NSMutableDictionary *cacheTable = [NSMutableDictionary dictionary];
        for (NSManagedObject *managedObject in managedObjects) {
            
            id object = [self objectWithManagedObject:managedObject cacheTable:cacheTable];
            if (object) { [objects addObject:object]; }
        }
        dispatch_semaphore_signal(lock);
        
        return objects;
    }
    return nil;
}

+ (HHClassInfo *)managedObjectClassInfoWithObject:(id)object {
    
    static NSMutableDictionary<Class, HHClassInfo *> *managedObjectClasses;
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = dispatch_semaphore_create(1);
        managedObjectClasses = [NSMutableDictionary dictionary];
    });
    
    Class cls = [object class];
    HHClassInfo *classInfo = managedObjectClasses[cls];
    if (!classInfo) {
        
        NSArray *ignoreProperties = [(id)cls respondsToSelector:@selector(igonrePropertiesForCoreData)] ? [(id)cls igonrePropertiesForCoreData] : nil;
        NSDictionary *replacePropertyKeypaths = [(id)cls respondsToSelector:@selector(replacedPropertyKeypathsForCoreData)] ? [(id)cls replacedPropertyKeypathsForCoreData] : nil;
        
        classInfo = [HHClassInfo classInfoWithClass:cls ignoreProperties:ignoreProperties replacePropertyKeypaths:replacePropertyKeypaths];
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        managedObjectClasses[(id)cls] = classInfo;
        dispatch_semaphore_signal(lock);
    }
    
    return classInfo;
}

#pragma mark - Getter

static dispatch_semaphore_t lock;
static NSManagedObjectContext *saveContext;
+ (NSManagedObjectContext *)saveContext {
    if (!saveContext) { [self perfromQueue]; }
    return saveContext;
}

+ (dispatch_queue_t)perfromQueue {
    
    static dispatch_queue_t perfromQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        perfromQueue = dispatch_queue_create("com.heiHuaBaiHua.coreDataQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_set_target_queue(perfromQueue, dispatch_get_global_queue(2, 0));
        lock = dispatch_semaphore_create(1);
        saveContext = [NSManagedObjectContext MR_rootSavingContext];
    });
    return perfromQueue;
}

@end

#pragma mark - NSManagedObject(CoreDataExtension)

@implementation NSManagedObject (CoreDataExtension)

- (void)saveWithObject:(id)object {
    
    if (!object || [object isKindOfClass:[self class]]) { return ; }
    
    [self configWithObject:object];
    [NSObject.saveContext MR_saveToPersistentStoreAndWait];
}

- (void)configWithObject:(id)object {

    if (!object || [object isKindOfClass:[self class]]) { return ; }

    HHClassInfo *classInfo = [NSObject managedObjectClassInfoWithObject:object];
    NSDictionary *containerPropertyKeypaths = [(id)classInfo.cls respondsToSelector:@selector(containerPropertyKeypathsForCoreData)] ? [classInfo.cls containerPropertyKeypathsForCoreData] : nil;
    for (HHPropertyInfo *property in classInfo.properties) {
        
        if ([self respondsToSelector:property->_getter]) {
            
            id propertyValue = [object valueForKey:property->_name];
            if (propertyValue != nil) {
             
                if (property->_type >= HHPropertyTypeBool && property->_type < HHPropertyTypeArray) {
                    
                    float number = [propertyValue floatValue];
                    if (number == 0) { continue; }
                    if (number == CDZero) { propertyValue = @0; }
                } else if (property->_type == HHPropertyTypeCustomObject) {
                    
                    if (propertyValue == kCFNull) {
                        
                        [self setValue:nil forKeyPath:property->_getPath];
                        continue;
                    }
                    if (![(id)property->_cls respondsToSelector:@selector(primaryKeys)]) { continue; }
                    
                    NSPredicate *predicate = [[HHPredicate predicateWithEqualKeys:[property->_cls primaryKeys]] makePredicateWithObjcet:propertyValue];
                    NSManagedObject *managedObject = [NSObject managedObjectWithClass:[property->_cls matchedManagedObjectClass] predicate:predicate];
                    [managedObject configWithObject:propertyValue];
                    propertyValue = managedObject;
                } else if (property->_type == HHPropertyTypeArray) {
                    
                    if ([propertyValue count] == 0) {
                        
                        [self setValue:nil forKeyPath:property->_getPath];
                        continue;
                    }
                    
                    id element = [propertyValue firstObject];
                    if ([element isKindOfClass:[NSString class]] ||
                        [element isKindOfClass:[NSNumber class]]) {
                        
                        propertyValue = [propertyValue componentsJoinedByString:@","];
                    } else {//直接Copy下来 懒得拆了
                    
                        id containerPropertyClass = NSClassFromString(containerPropertyKeypaths[property->_name]);
                        id managedObjectClass = [containerPropertyClass matchedManagedObjectClass];
                        if (!managedObjectClass ||
                            ![containerPropertyClass respondsToSelector:@selector(primaryKeys)]) { continue ; }

                        HHPredicate *predicate = [HHPredicate predicateWithContainKeys:[containerPropertyClass primaryKeys]];
                        NSArray *managedObjects = [managedObjectClass MR_findAllWithPredicate:[predicate makePredicateWithObjcets:propertyValue] inContext:NSObject.saveContext];
                        NSMutableArray *managedObjectIdentifierArray = [NSMutableArray array];
                        for (NSManagedObject *managedObject in managedObjects) {
                            
                            id managedObjectIdentifier = [predicate identifierWithManagedObjcet:managedObject];
                            if (managedObjectIdentifier) {
                                [managedObjectIdentifierArray addObject:managedObjectIdentifier];
                            }
                        }
                        
                        NSMutableSet *saveManagedObjects = [NSMutableSet set];
                        for (id obj in propertyValue) {
                            
                            NSManagedObject *managedObject;
                            id objectIdentifier = [predicate identifierWithObjcet:obj];
                            
                            if ([managedObjectIdentifierArray containsObject:objectIdentifier]) {
                                managedObject = [managedObjects objectAtIndex:[managedObjectIdentifierArray indexOfObject:objectIdentifier]];
                            } else {
                                managedObject = [managedObjectClass MR_createEntityInContext:NSObject.saveContext];
                            }
                            [managedObject configWithObject:obj];
                            [saveManagedObjects addObject:managedObject];
                        }
                        propertyValue = saveManagedObjects;
                    }
                }
            
                if (propertyValue) { [self setValue:propertyValue forKeyPath:property->_getPath]; }
            }
        }
    }
}

@end
