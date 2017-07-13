//
//  CCParseUtils.m
//  ChatCenterDemo
//
//  Created by GiapNH on 06/29/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import "CCParseUtils.h"

@implementation CCParseUtils
+ (id)getObjectAtPath:(NSString*)path fromObject:(id)obj {
    NSArray<NSString*> *components = [path componentsSeparatedByString:@"/"];
    if (components.count<1) {
        return nil;
    }
    
    id retObj;
    if ([components[0] hasSuffix:@"#"]) { //array
        if (![obj isKindOfClass:[NSArray class]]) {
            return nil;
        } else {
            NSInteger num = [[components[0] substringFromIndex:1] integerValue];
            if ([(NSArray *)obj count] > num ) {
                retObj = [(NSArray*)obj objectAtIndex:num];
            } else {
                return nil;
            }
        }
    } else {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            return nil;
        } else {
            retObj = [(NSDictionary*)obj objectForKey:components[0]];
        }
    }
    if (components.count==1) {
        return [retObj copy];
    } else {
        NSMutableArray *a2 = [components mutableCopy];
        [a2 removeObjectAtIndex:0];
        NSString *newPath = [a2 componentsJoinedByString:@"/"];
        
        return [self getObjectAtPath:newPath fromObject:retObj];
    }
    return nil;
}

+ (NSDictionary*)getDictionaryAtPath:(NSString*)path fromObject:(id)inObj {
    id retObj = [self getObjectAtPath:path fromObject:inObj];
    if ([retObj isKindOfClass:[NSDictionary class]]) {
        return retObj;
    } else {
        return nil;
    }
}
+ (NSArray*)getArrayAtPath:(NSString*)path fromObject:(id)inObj {
    id retObj = [self getObjectAtPath:path fromObject:inObj];
    if ([retObj isKindOfClass:[NSArray class]]) {
        return retObj;
    } else {
        return nil;
    }
}
+ (NSString*)getStringAtPath:(NSString*)path fromObject:(id)inObj {
    id retObj = [self getObjectAtPath:path fromObject:inObj];
    if ([retObj isKindOfClass:[NSString class]]) {
        return retObj;
    } else {
        return [retObj respondsToSelector:@selector(stringValue)] ? [retObj stringValue] : nil;
    }
}

+ (NSNumber*)getNumberAtPath:(NSString*)path fromObject:(id)inObj {
    id retObj = [self getObjectAtPath:path fromObject:inObj];
    if ([retObj isKindOfClass:[NSNumber class]]) {
        return retObj;
    } else {
        return nil;
    }
}

+ (long)getLongAtPath:(NSString*)path fromObject:(id)inObj {
    id retObj = [self getObjectAtPath:path fromObject:inObj];
    return [retObj respondsToSelector:@selector(longValue)] ? [retObj longValue] : 0;
}

+ (int)getIntAtPath:(NSString*)path fromObject:(id)inObj {
    id retObj = [self getObjectAtPath:path fromObject:inObj];
    return [retObj respondsToSelector:@selector(intValue)] ? [retObj intValue] : 0;
}

+ (BOOL)getBoolAtPath:(NSString*)path fromObject:(id)inObj {
    id retObj = [self getObjectAtPath:path fromObject:inObj];
    return [retObj respondsToSelector:@selector(boolValue)] ? [retObj boolValue] : false;
}

+ (NSInteger)getIntegerAtPath:(NSString*)path fromObject:(id)inObj {
    id retObj = [self getObjectAtPath:path fromObject:inObj];
    return [retObj respondsToSelector:@selector(integerValue)] ? [retObj integerValue]: 0;
}
///
/// Removed unsupported types from a dictionary
/// For example: nil, NSNull,...
///
+ (NSDictionary *) removeUnsupportedTypesFrom: (NSDictionary *)dictionary {
    if (!dictionary) {
        return dictionary;
    }
    const NSMutableDictionary *replaced = [dictionary mutableCopy];
    const id nul = [NSNull null];
    
    for(NSString *key in dictionary) {
        const id object = [dictionary objectForKey:key];
        if(object == nul || [object isEqual:[NSNull null]]) {
            //pointer comparison is way faster than -isKindOfClass:
            //since [NSNull null] is a singleton, they'll all point to the same
            //location in memory.
            [replaced removeObjectForKey:key];
        } else if ([object isKindOfClass:[NSArray class]]) {
            NSMutableArray *replacedArray = [object mutableCopy];
            for (int index = 0; index < replacedArray.count; index ++) {
                NSDictionary *dict = [replacedArray objectAtIndex:index];
                if ([dict isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *replacedDict = [self removeUnsupportedTypesFrom:dict];
                    [replacedArray setObject:replacedDict atIndexedSubscript:index];
                } else {
                    [replacedArray setObject:dict atIndexedSubscript:index];
                }
            }
            [replaced setObject:replacedArray forKey:key];
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *replacedDict = [self removeUnsupportedTypesFrom:object];
            [replaced setObject:replacedDict forKey:key];
        }
    }
    return [replaced copy];
}
@end
