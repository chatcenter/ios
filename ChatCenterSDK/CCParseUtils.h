//
//  CCParseUtils.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 3/31/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCParseUtils : NSObject

+ (long) longTryGet:(NSDictionary *)dictionary key:(NSString *) key;
+ (NSString *) stringTryGet:(NSDictionary *)dictionary key:(NSString *) key;
+ (NSDictionary *) removeUnsupportedTypesFrom: (NSDictionary *)dictionary;
@end
