//
//  CCHistoryFilterUtil.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2016/05/18.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCHistoryFilterUtil : NSObject

/**
 *  Filtering.
 *
 *  @param connectionData
 *
 *  @return filtering.
 */
+ (BOOL)isFilteringWithConnectionData:(id)connectionData;

@end
