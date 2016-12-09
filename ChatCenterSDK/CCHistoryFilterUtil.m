//
//  CCHistoryFilterUtil.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2016/05/18.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCHistoryFilterUtil.h"

#import "CCConstants.h"
#import "CCChannel.h"
#import "CCUserDefaultsUtil.h"
#import "CCHistoryFilterViewController.h"

@implementation CCHistoryFilterUtil

/**
 *  Filtering.
 *
 *  @param connectionData
 *
 *  @return filtering.
 */
+ (BOOL)isFilteringWithConnectionData:(id)connectionData {
    
    NSString *status;
    if (![[connectionData valueForKey:@"status"] isEqual:[NSNull null]]) {
        status = [connectionData valueForKey:@"status"];
    }
    NSString *funnelId;
    if (![[connectionData valueForKey:@"funnel_id"] isEqual:[NSNull null]]) {
        funnelId = [[connectionData valueForKey:@"funnel_id"] stringValue];
    }
    NSString *assigneeId;
    id assignee = [connectionData valueForKey:@"assignee"];
    if (![assignee isEqual:[NSNull null]]) {
        if (![[assignee valueForKey:@"id"] isEqual:[NSNull null]]) {
            assigneeId = [[assignee valueForKey:@"id"] stringValue];
        }
    }
    
    return [CCHistoryFilterUtil isFilteringWithFunnelId:funnelId status:status assigneeId:assigneeId];
}

/**
 *  Filtering.
 *
 *  @param funnelId
 *  @param status
 *  @param assigneeId
 *
 *  @return filtering.
 */
+ (BOOL)isFilteringWithFunnelId:(NSString *)funnelId
                         status:(NSString *)status
                     assigneeId:(NSString *)assigneeId {
    
    // Get filter condition for UserDefauls.
    NSDictionary *businessFunnel = [CCUserDefaultsUtil filterBusinessFunnel];
    NSArray <NSString *> *messageStatuses = [CCUserDefaultsUtil filterMessageStatus];
    
    if (businessFunnel != nil) {
        if (funnelId == nil) {
            return YES;
        }
        if (![funnelId isEqualToString:[businessFunnel[@"id"] stringValue]]) {
            return YES;
        }
    }
    
    if (messageStatuses.count > 0 && ![messageStatuses[0] isEqualToString:CCHistoryFilterMessagesStatusTypeAll]) {
        BOOL isFiltering = YES;
        for (NSString *messagesStatus in messageStatuses) {
            if ([messagesStatus isEqualToString:CCHistoryFilterMessagesStatusTypeUnassigned]) {
                if ([status isEqualToString:@"unassigned"]) {
                    isFiltering = NO;
                }
            } else if ([messagesStatus isEqualToString:CCHistoryFilterMessagesStatusTypeAssignedToMe]) {
                if ([status isEqualToString:@"assigned"]) {
                    NSString *uid = [[CCConstants sharedInstance] getKeychainUid];
                    if ([assigneeId isEqualToString:uid]) {
                        isFiltering = NO;
                    }
                }
            } else if ([messagesStatus isEqualToString:CCHistoryFilterMessagesStatusTypeClosed]) {
                if ([status isEqualToString:@"closed"]) {
                    isFiltering = NO;
                }
            }
        }
        return isFiltering;
    }
    
    return NO;
}

@end
