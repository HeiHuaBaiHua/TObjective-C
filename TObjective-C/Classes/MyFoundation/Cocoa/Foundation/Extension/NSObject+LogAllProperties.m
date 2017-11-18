//
//  NSObject+LogAllProperties.m
//  TCoreData
//
//  Created by HeiHuaBaiHua on 16/6/17.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import "NSObject+LogAllProperties.h"

#import <objc/runtime.h>

#define CustomPrefix @"HH"
#define IgnoreProperties @[@"debugDescription", @"description", @"superclass", @"hash"]

typedef enum : NSUInteger {
    HHLogPropertyNormal,
    HHLogPropertyCustom,
    HHLogPropertyArray,
    HHLogPropertyDictionary,
} HHLogProperty;

@implementation NSObject (LogAllProperties)

- (void)llog {
    
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
       
        NSMutableString *description = [NSMutableString stringWithString:@"\n-------------------------------------\n"];
        [description appendString:[NSString stringWithFormat:@"%@:\n",NSStringFromClass([self class])]];
        [description appendString:[self classPropertiesDescriptionWithClass:[self class]]];
        [description appendString:@"\n-------------------------------------\n"];
        NSLog(@"%@",description);
    });
}

- (NSString *)classPropertiesDescriptionWithClass:(Class)cls {
    
    static NSInteger level = -1;
    level += 1;
    NSMutableString *blankSpace = [NSMutableString stringWithString:@"  "];
    for (int i = 0; i < level; i++) { [blankSpace appendString:@"  "]; }
    
    NSMutableString *description = [NSMutableString string];
    
    NSString *className = NSStringFromClass(cls);
    if (![className hasPrefix:CustomPrefix]) {
        
        if ([self isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dict = (NSDictionary *)self;
            if (![className hasPrefix:@"__"]) {
                dict = nil;
            } else {
                
                BOOL needNewLine = [NSStringFromClass([[[dict allValues] firstObject] class]) hasPrefix:CustomPrefix];
                NSString *newLine = needNewLine ? @"\n" : @"";
                
                [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [description appendString:[NSString stringWithFormat:@"%@%@: %@%@\n",blankSpace, key, newLine, [obj classPropertiesDescriptionWithClass:[obj class]]]];
                }];
            }
            
            blankSpace = [blankSpace substringWithRange:NSMakeRange(0, blankSpace.length - 2)];
            description = description.length == 0 ? @"{}" : [NSString stringWithFormat:@"{\n\n%@\n%@}", description, blankSpace];
        } else if ([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSSet class]]) {
            
            NSArray *array = (NSArray *)self;
            if (![className hasPrefix:@"__"]) {
                array = nil;
            } else {
                
                BOOL needNewLine = [NSStringFromClass([[array firstObject] class]) hasPrefix:CustomPrefix];
                NSString *newLine = needNewLine ? @"\n" : @"";
                
                [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [description appendString:[NSString stringWithFormat:@"%@%ld: %@%@\n",blankSpace ,idx, newLine,[obj classPropertiesDescriptionWithClass:[obj class]]]];
                }];
            }
            
            blankSpace = [blankSpace substringWithRange:NSMakeRange(0, blankSpace.length - 2)];
            description = description.length == 0 ? @"[]" : [NSString stringWithFormat:@"[\n\n%@\n%@]",description, blankSpace];
        } else {
            description = [self description];
        }
    } else {

        while (cls != [NSObject class] && cls != [NSProxy class]) {
            [description appendString:[self customclassPropertiesDescriptionWithClass:cls blankSpace:blankSpace]];
            cls = [cls superclass];
        }

        description = description.length == 0 ? @"|-|\n" :[NSString stringWithFormat:@"|-\n\n%@\n%@-|\n", description, blankSpace];
    }
    
    level -= 1;
    return description;
}

- (NSString *)customclassPropertiesDescriptionWithClass:(Class)cls blankSpace:(NSString *)blankSpace {
    
    NSMutableString *description = [NSMutableString string];
    
    uint count;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    for (int i = 0; i < count; i++) {
        
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if ([IgnoreProperties containsObject:propertyName]) { continue; }
        
        id propertyValue = [self valueForKey:propertyName];
        if (propertyValue) {
            
            propertyValue = [propertyValue classPropertiesDescriptionWithClass:[propertyValue class]];
            [description appendString:[NSString stringWithFormat:@"%@%@: %@\n", blankSpace, propertyName, propertyValue]];
        }
    }
    free(properties);

    return description;
}

@end
