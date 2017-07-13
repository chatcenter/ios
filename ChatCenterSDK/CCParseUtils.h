//
//  CCParseUtils.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 3/31/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCParseUtils : NSObject
//
// Object Retrieval Utility
//
+ (id)getObjectAtPath:(NSString*)path fromObject:(id)obj;
+ (NSDictionary*)getDictionaryAtPath:(NSString*)path fromObject:(id)inObj;
+ (NSArray*)getArrayAtPath:(NSString*)path fromObject:(id)inObj;
+ (NSString*)getStringAtPath:(NSString*)path fromObject:(id)inObj;
+ (NSNumber*)getNumberAtPath:(NSString*)path fromObject:(id)inObj;
+ (long)getLongAtPath:(NSString*)path fromObject:(id)inObj;
+ (int)getIntAtPath:(NSString*)path fromObject:(id)inObj;
+ (BOOL)getBoolAtPath:(NSString*)path fromObject:(id)inObj;
+ (NSInteger)getIntegerAtPath:(NSString*)path fromObject:(id)inObj;

+ (NSDictionary *) removeUnsupportedTypesFrom: (NSDictionary *)dictionary;
@end
