//
//  CCParseUtils.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 3/31/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import "CCParseUtils.h"

@implementation CCParseUtils

+ (long) longTryGet:(NSDictionary *)dictionary key:(NSString*) key {
    
    if ([dictionary[key] isKindOfClass:[NSString class]]) {
        long value = [dictionary[key] longValue];
        return value;
    } else if ([dictionary[key] isKindOfClass:[NSNumber class]]) {
        long value = [dictionary[key] longValue];
        return value;
    } else {
        long value = [dictionary[key] respondsToSelector:@selector(longValue)] ? [dictionary[key] longValue]: 0;
        return value;
    }
}

+ (NSString *) stringTryGet:(NSDictionary *)dictionary key:(NSString *) key {
    if ([dictionary[key] isKindOfClass:[NSString class]]) {
        NSString * value = dictionary[key];
        return value;
    }
    
    return @"";
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
