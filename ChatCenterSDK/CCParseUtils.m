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


@end
