//
//  CCUserDefaultsUtil.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2016/04/21.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCUserDefaultsUtil : NSObject

/**
 *  Setting filterBusinessFunnel at UserDefaults.
 *
 *  @param filterBusinessFunnel
 */
+ (void)setFilterBusinessFunnel:(NSDictionary *)filterBusinessFunnel;

/**
 *  Getting filterBusinessFunnel at UserDefaults.
 *
 *  @return filterBusinessFunnel
 */
+ (NSDictionary *)filterBusinessFunnel;

/**
 *  Setting filterMessageStatus at UserDefaults.
 *
 *  @param filterMessageStatus
 */
+ (void)setFilterMessageStatus:(NSArray<NSString *> *)filterMessageStatus;

/**
 *  Getting filterMessageStatus at UserDefaults.
 *
 *  @return filterMessageStatus
 */
+ (NSArray<NSString *> *)filterMessageStatus;


@end
