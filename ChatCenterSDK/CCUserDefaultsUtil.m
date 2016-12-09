//
//  CCUserDefaultsUtil.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2016/04/21.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCUserDefaultsUtil.h"

static NSString *CCUserDefaultsUtilKeyFilterBusinessFunnel = @"ChatCenterUserdefaults_filterBusinessFunnel";
static NSString *CCUserDefaultsUtilKeyFilterMessageStatus = @"ChatCenterUserdefaults_filterMessageStatus";

@implementation CCUserDefaultsUtil

+ (void)setFilterBusinessFunnel:(NSDictionary *)filterBusinessFunnel {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:filterBusinessFunnel forKey:CCUserDefaultsUtilKeyFilterBusinessFunnel];
    [ud synchronize];
}
+ (NSDictionary *)filterBusinessFunnel {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud objectForKey:CCUserDefaultsUtilKeyFilterBusinessFunnel];
}

+ (void)setFilterMessageStatus:(NSArray<NSString *> *)filterMessageStatus {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:filterMessageStatus forKey:CCUserDefaultsUtilKeyFilterMessageStatus];
    [ud synchronize];
}
+ (NSArray<NSString *> *)filterMessageStatus {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    return [ud objectForKey:CCUserDefaultsUtilKeyFilterMessageStatus];
}

@end
