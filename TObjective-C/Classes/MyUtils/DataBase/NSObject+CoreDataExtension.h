//
//  NSObject+CoreDataExtension.h
//  TCoreData
//
//  Created by HeiHuaBaiHua on 16/6/15.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

#import "HHPredicate.h"
@protocol HHCoreDataExtension <NSObject>

+ (Class)managedObjectClass;/**< Model对应的CoreData类 */
+ (NSDictionary *)primaryKeys;/**< Model的主键名和CoreData的主键名 */

+ (NSArray *)igonrePropertiesForCoreData;/**< 从CoreData解析时忽略的属性 */
+ (NSDictionary *)replacedPropertyKeypathsForCoreData;/**< CoreData替换键值 */
+ (NSDictionary *)containerPropertyKeypathsForCoreData;/**< 从CoreData解析时容器属性对应的类 */

+ (NSDictionary *)oneToOneRelationship;
+ (NSDictionary *)oneToManyRelationship;

@end

#define CDZero -1

@interface NSObject (CoreDataExtension)

- (void)clearRelationship;

+ (NSUInteger)countOfEntities;
+ (NSUInteger)countOfEntitiesWithPredicate:(NSPredicate *)searchFilter;

#pragma mark - FindAll(Sync)

+ (NSArray *)findAll;
+ (NSArray *)findAllWithPredicate:(NSPredicate *)searchTerm;
+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending;
+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm;
+ (NSArray *)findByAttribute:(NSString *)attribute withValue:(id)searchValue;
+ (NSArray *)findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSString *)sortTerm ascending:(BOOL)ascending;

+ (NSArray *)findAllWithPage:(NSUInteger)page row:(NSUInteger)row;
+ (NSArray *)findAllWithPredicate:(NSPredicate *)searchTerm page:(NSUInteger)page row:(NSUInteger)row;
+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending page:(NSUInteger)page row:(NSUInteger)row;
+ (NSArray *)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm page:(NSUInteger)page row:(NSUInteger)row;
+ (NSArray *)findByAttribute:(NSString *)attribute withValue:(id)searchValue page:(NSUInteger)page row:(NSUInteger)row;

#pragma mark - FindAll(Async)

+ (void)findAllWithCompletionHandler:(void (^)(NSArray *objects))completionHandler;
+ (void)findAllWithPredicate:(NSPredicate *)searchTerm completionHandler:(void (^)(NSArray *objects))completionHandler;
+ (void)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending completionHandler:(void (^)(NSArray *objects))completionHandler;
+ (void)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm completionHandler:(void (^)(NSArray *objects))completionHandler;
+ (void)findByAttribute:(NSString *)attribute withValue:(id)searchValue completionHandler:(void (^)(NSArray *objects))completionHandler;
+ (void)findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSString *)sortTerm ascending:(BOOL)ascending completionHandler:(void (^)(NSArray *objects))completionHandler;
+ (void)findAllWithPage:(NSUInteger)page row:(NSUInteger)row completionHandler:(void (^)(NSArray *objects))completionHandler;
+ (void)findAllWithPredicate:(NSPredicate *)searchTerm page:(NSUInteger)page row:(NSUInteger)row completionHandler:(void (^)(NSArray *objects))completionHandler;
+ (void)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending page:(NSUInteger)page row:(NSUInteger)row completionHandler:(void (^)(NSArray *objects))completionHandler;
+ (void)findAllSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending withPredicate:(NSPredicate *)searchTerm page:(NSUInteger)page row:(NSUInteger)row completionHandler:(void (^)(NSArray *objects))completionHandler;
+ (void)findByAttribute:(NSString *)attribute withValue:(id)searchValue page:(NSUInteger)page row:(NSUInteger)row completionHandler:(void (^)(NSArray *objects))completionHandler;

#pragma mark - FindFirst

+ (instancetype)findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue;
+ (instancetype)findFirstWithPredicate:(NSPredicate *)searchTerm;
+ (instancetype)findFirstWithPredicate:(NSPredicate *)searchterm sortedBy:(NSString *)property ascending:(BOOL)ascending;

+ (void)findFirstWithPredicate:(NSPredicate *)searchTerm completionHandler:(void (^)(id object))completionHandler;
+ (void)findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue completionHandler:(void (^)(id object))completionHandler;

#pragma mark - Save

- (void)save;
- (void)saveWithCompletionHandler:(void (^)(void))completionHandler;
- (void)saveWithEqualProperties:(NSArray *)properties;
- (void)saveWithEqualProperties:(NSArray *)properties completionHandler:(void (^)(void))completionHandler;
- (void)saveWithPredicate:(NSPredicate *)predicate;
- (void)saveWithPredicate:(NSPredicate *)predicate completionHandler:(void (^)(void))completionHandler;

+ (void)saveObjects:(NSArray *)objects;
+ (void)saveObjects:(NSArray *)objects completionHandler:(void (^)(void))completionHandler;
+ (void)saveObjects:(NSArray *)objects checkByPredicate:(HHPredicate *)predicate;
+ (void)saveObjects:(NSArray *)objects checkByPredicate:(HHPredicate *)predicate completionHandler:(void (^)(void))completionHandler;

#pragma mark - Delete

- (void)delete;
- (void)deleteWithCompletionHandler:(void (^)(void))completionHandler;
- (void)deleteWithEqualProperties:(NSArray *)properties;
- (void)deleteWithEqualProperties:(NSArray *)properties completionHandler:(void (^)(void))completionHandler;
- (void)deleteWithPredicate:(NSPredicate *)predicate;
- (void)deleteWithPredicate:(NSPredicate *)predicate completionHandler:(void (^)(void))completionHandler;

+ (void)deleteAll;
+ (void)deleteAllWithCompletionHandler:(void (^)(void))completionHandler;
+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate;
+ (void)deleteAllMatchingPredicate:(NSPredicate *)predicate completionHandler:(void (^)(void))completionHandler;
@end
