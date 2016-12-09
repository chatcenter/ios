//
//  CCConnectionHelper.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2014/12/05.
//  Copyright (c) 2014年 AppSocially Inc. All rights reserved.
//

#import "CCConnectionHelper.h"
#import "ChatCenterClient.h"
#import "CCSRWebSocket.h"
#import "CCHistoryViewController.h"
#import "CCChatViewController.h"
#import "CCSVProgressHUD.h"
#import "UIView+CCToast.h"
#import "CCAFNetworkReachabilityManager.h"
#import "CCConstants.h"
#import "CCUISplitViewController.h"
#import "CCCoredataBase.h"
#import "ChatCenterPrivate.h"
#import "CCSSKeychain.h"
#import "CCAFHTTPRequestOperationManager.h"
#import "CCAFNetworkActivityLogger.h"
#import "CCHistoryFilterUtil.h"

BOOL const offlineDevelopmentMode = NO;  ///Insert "YES" only when developing with local server

@interface CCConnectionHelper (){
    UIView *toastView;
    CCAFNetworkReachabilityManager *reachability;
}

@property (nonatomic, strong) NSMutableArray *ChatChannelIds;

@end

@implementation CCConnectionHelper

+ (CCConnectionHelper *)sharedClient
{
    static CCConnectionHelper *sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[CCConnectionHelper alloc] init];
        [sharedClient setUp];
    });
    
    return sharedClient;
}

- (void)setUp
{
    #if CC_DEBUG
        [[CCAFNetworkActivityLogger sharedLogger] startLogging];
        [[CCAFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
    #endif
    self.isLoadingUserToken = NO;
    self.twoColumnLayoutMode = NO;
    self.isRefreshingData = NO;
    reachability = [CCAFNetworkReachabilityManager sharedManager];
    [reachability startMonitoring];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifiedNetworkStatus:)
                                                 name:CCAFNetworkingReachabilityDidChangeNotification
                                               object:nil];
    
    self.networkStatus = [self getNetworkStatus];
    [[CCSRWebSocket sharedInstance] setWebSocketDidOpenCallback:^(void) {
        self.webSocketStatus = CCCWebSocketOpened;
        [self hideToast];
        [self makeToast:@"Make connection" message:CCLocalizedString(@"Come online") duration:1.5 backgroundColor:[UIColor greenColor]];
    }];
    [[CCSRWebSocket sharedInstance] setDidFailWithErrorOrClosedCallback:^(NSError *error, NSString *reason) {
        if (error || reason){
            ///One time reconnect
            if (self.webSocketStatus == CCCWebSocketClosed) {
                [self hideToast];
                [self makeToast:@"Can not make connection" message:CCLocalizedString(@"Can not make connection") duration:99999 backgroundColor:[UIColor redColor]];
            }else{
                self.webSocketStatus = CCCWebSocketClosed;
                [self refreshData];
            }
        }
    }];
    [[CCSRWebSocket sharedInstance] setDidReceiveJoinCallback:^(NSString *channelId, BOOL newChannel) {
        if ([self.delegate respondsToSelector:@selector(receiveChannelJoinFromWebSocket: newChannel:)]){
            [self.delegate receiveChannelJoinFromWebSocket:(NSString *)channelId newChannel:(BOOL)newChannel];
        }
    }];
    [[CCSRWebSocket sharedInstance] setDidReceiveOnlineCallback:^(NSString *channelUid, NSDictionary *user) {
        if([self.delegate respondsToSelector:@selector(receiveChannelOnlineFromWebSocket:user:)]) {
            [self.delegate receiveChannelOnlineFromWebSocket:(NSString *)channelUid user:(NSDictionary *)user];
        }
    }];
    
    [[CCSRWebSocket sharedInstance] setDidReceiveMessageCallback:^(NSString *messageType, NSNumber *uid, NSDictionary *content, NSString *channelId, NSString *userUid, NSDate *date, NSString *displayName, NSString *userIconUrl, NSDictionary *answer){ //recieve message callback
        if ([self.delegate respondsToSelector:@selector(receiveMessageFromWebSocket:uid:content:channelId:userUid:date:displayName:userIconUrl:answer:)]){
            [self.delegate receiveMessageFromWebSocket:messageType
                                                   uid:uid
                                               content:content
                                             channelId:channelId
                                               userUid:userUid
                                                  date:date
                                           displayName:displayName
                                           userIconUrl:userIconUrl
                                                answer:answer];
        }
    }];
    [[CCSRWebSocket sharedInstance] setDidReceiveReceiptCallback:^(NSString *channelUid, NSArray *messages, NSString *userUid, BOOL userAdmin){
        if ([self.delegate respondsToSelector:@selector(receiveReceiptFromWebSocket:messages:userUid:userAdmin:)]){
            [self.delegate receiveReceiptFromWebSocket:channelUid
                                              messages:messages
                                               userUid:userUid
                                             userAdmin:userAdmin];
        }
    }];
    [[CCSRWebSocket sharedInstance] setDidReceiveAssignedCallback:^(NSString *channelUid){
        if ([self.delegate respondsToSelector:@selector(loadLocalChannels)]){
            [self.delegate loadLocalChannels];
        }
        if ([self.delegate respondsToSelector:@selector(receiveAssignFromWebSocket:)]) {
            [self.delegate receiveAssignFromWebSocket:channelUid];
        }
    }];
    [[CCSRWebSocket sharedInstance] setDidReceiveUnassignedCallback:^(NSString *channelUid){
        if ([self.delegate respondsToSelector:@selector(loadLocalChannels)]) {
            [self.delegate loadLocalChannels];
        }
        if ([self.delegate respondsToSelector:@selector(receiveUnassignFromWebSocket:)]) {
            [self.delegate receiveUnassignFromWebSocket:channelUid];
        }
    }];
    [[CCSRWebSocket sharedInstance] setDidReceiveFollowCallback:^(NSString *channelUid) {
        if ([self.delegate respondsToSelector:@selector(receiveFollowFromWebSocket:)]){
            [self.delegate receiveFollowFromWebSocket:channelUid];
        }
    }];
    [[CCSRWebSocket sharedInstance] setDidReceiveUnfollowCallback:^(NSString *channelUid) {
        if ([self.delegate respondsToSelector:@selector(receiveUnfollowFromWebSocket:)]){
            [self.delegate receiveUnfollowFromWebSocket:channelUid];
        }
    }];
    [[CCSRWebSocket sharedInstance] setDidReceiveInviteCallCallback:^(NSString *messageId, NSDictionary *content) {
        if ([self.delegate respondsToSelector:@selector(receiveInviteCall:content:)]){
            [self.delegate receiveInviteCall:messageId content:content];
        }
    }];
    [[CCSRWebSocket sharedInstance] setDidReceiveCallEventCallback:^(NSString *messageId, NSDictionary *content) {
        if ([self.delegate respondsToSelector:@selector(receiveCallEvent:content:)]) {
            [self.delegate receiveCallEvent:messageId content:content];
        }
    }];
    [[CCSRWebSocket sharedInstance] setDidReceiveDeleteChannelCallback:^(void) {
        if ([self.delegate respondsToSelector:@selector(receiveDeleteChannelFromWebSocket)]){
            [self.delegate receiveDeleteChannelFromWebSocket];
        }
    }];
}

# pragma mark - Load Data

-(void)loadChannels:(BOOL)showProgress
     getChennelType:(int)getChennelType
            org_uid:(NSString *)org_uid
              limit:(int)limit
      lastUpdatedAt:(NSDate *)lastUpdatedAt
  completionHandler:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{ //get channels from server, store channels to local
    __block NSDate *blockLastUpdatedAt = lastUpdatedAt;
    if(showProgress == YES && self.currentView != nil){
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading Messages...") maskType:SVProgressHUDMaskTypeBlack];
    }
    [[ChatCenterClient sharedClient] getChannel:getChennelType
                                        org_uid:org_uid
                                          limit:limit
                                  lastUpdatedAt:lastUpdatedAt
                              completionHandler:^(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation)
    {
        if(result != nil){
            if(showProgress == YES && self.currentView != nil){
                [CCSVProgressHUD dismiss];
            }
            ///reset data in first load
            if (blockLastUpdatedAt == nil) {
                self.ChatChannelIds = [[NSMutableArray alloc] init];
                if([[CCCoredataBase sharedClient] deleteAllChannel]){
                    NSLog(@"deleteAllChannel Success!");
                }else{
                    NSLog(@"deleteAllChannel Error!");
                }
            }
            NSMutableDictionary *unreadMessagesDic = [NSMutableDictionary dictionary];
            for (int i = 0; i < result.count; i++) {
                if (
                    [result[i] valueForKey:@"uid"] != nil
                    && ![result[i][@"uid"] isEqual:[NSNull null]]
                    && [result[i] valueForKey:@"status"] != nil
                    && ![result[i][@"status"] isEqual:[NSNull null]]
                    && [result[i] valueForKey:@"org_uid"] != nil
                    && ![result[i][@"org_uid"] isEqual:[NSNull null]]
                    && [result[i] valueForKey:@"created"] != nil
                    && ![result[i][@"created"] isEqual:[NSNull null]]
                    && [result[i] valueForKey:@"last_updated_at"] != nil
                    && ![result[i][@"last_updated_at"] isEqual:[NSNull null]]
                    && [result[i] valueForKey:@"users"] != nil
                    && ![result[i][@"users"] isEqual:[NSNull null]]
                    && [result[i] valueForKey:@"org_name"] != nil
                    && ![result[i][@"org_name"] isEqual:[NSNull null]]
                    && [result[i] valueForKey:@"unread_messages"] != nil
                    && ![result[i][@"unread_messages"] isEqual:[NSNull null]]
                    && [result[i] valueForKey:@"id"] != nil
                    && ![result[i][@"id"] isEqual:[NSNull null]]
                    && [result[i] valueForKey:@"read"] != nil
                    && ![result[i][@"read"] isEqual:[NSNull null]]
                    && [result[i] valueForKey:@"channel_informations"] != nil /// @"channel_informations" could be Null
                    && [result[i] valueForKey:@"icon_url"] != nil /// @"icon_url" could be Null
                    )/// @"latest_message" could be Null
                {
                    NSDictionary   *assignee    = [result[i] valueForKey:@"assignee"];
                    NSNumber *uid               = [result[i] valueForKey:@"id"];
                    NSString *channelUid        = [result[i] valueForKey:@"uid"];
                    NSString *status            = [result[i] valueForKey:@"status"];
                    NSString *orgUid            = [result[i] valueForKey:@"org_uid"];
                    NSString *stringCreatedDate = [result[i] valueForKey:@"created"];
                    NSDate *createdDate         = [NSDate dateWithTimeIntervalSince1970:[stringCreatedDate doubleValue]];
                    NSString *stringLastUpdatedAt = [result[i] valueForKey:@"last_updated_at"];
                    NSDate *lastUpdatedAt         = [NSDate dateWithTimeIntervalSince1970:[stringLastUpdatedAt doubleValue]];
                    NSArray *users              = [result[i] valueForKey:@"users"];
                    NSString *orgName           = [result[i] valueForKey:@"org_name"];
                    NSString *unreadMessages    = [[result[i] valueForKey:@"unread_messages"] stringValue];
                    NSDictionary *latestMessage = [result[i] valueForKey:@"latest_message"];
                    NSString *iconUrl           = [result[i] valueForKey:@"icon_url"];
                    NSNumber *read              = [result[i] valueForKey:@"read"];
                    NSDictionary *channelInformations = result[i][@"channel_informations"];
                    ///name and directmessage are only used for team now
                    NSString *name = @"";
                    BOOL directMessage = NO;
                    if (result[i][@"name"] != nil && ![result[i][@"name"] isEqual:[NSNull null]]) name = result[i][@"name"];
                    if (result[i][@"direct_message"] != nil && ![result[i][@"direct_message"] isEqual:[NSNull null]]) {
                        directMessage = [result[i][@"direct_message"] boolValue];
                    }
                    
                    // Filtering.
                    if (![CCHistoryFilterUtil isFilteringWithConnectionData:result[i]]) {
                        if([[CCCoredataBase sharedClient] insertChannel:channelUid
                                                              createdAt:createdDate
                                                               updateAt:nil
                                                                  users:users
                                                                org_uid:orgUid
                                                               org_name:orgName
                                                        unread_messages:unreadMessages
                                                         latest_message:latestMessage
                                                                    uid:uid
                                                                 status:status
                                                   channel_informations:channelInformations
                                                               icon_url:iconUrl
                                                                   read:[read boolValue]
                                                          lastUpdatedAt:lastUpdatedAt
                                                                   name:name
                                                         direct_message:directMessage
                                                               assignee:assignee])
                        {
                            NSLog(@"insertChannel Success!");
                        }else{
                            NSLog(@"insertChannel Error!");
                        }
                        [self.ChatChannelIds addObject:channelUid];
                    }
                    if (![unreadMessages isEqualToString:@"0"] && ![status isEqualToString:@"closed"]) {
                        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                        f.numberStyle = NSNumberFormatterDecimalStyle;
                        NSNumber *unreadMessagesNum = [f numberFromString:unreadMessages];
                        [unreadMessagesDic setObject:unreadMessagesNum forKey:channelUid];
                    }
                }
            }
            [[ChatCenter sharedInstance] setUnreadMessages:unreadMessagesDic];
            if(completionHandler != nil) completionHandler(result, nil, operation);
        }else{
            if(showProgress == YES && self.currentView != nil){
                [CCSVProgressHUD showErrorWithStatus:CCLocalizedString(@"Load Message Failed")]; ///This method is "channel load" but from user this is message load
            }
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

-(void)loadChannel:(BOOL)showProgress
        channelUid:(NSString *)channelUid
 completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{ //get channel from server and store it into coredata
    if(showProgress == YES && self.currentView != nil){
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading Messages...") maskType:SVProgressHUDMaskTypeBlack];
    }
    [[ChatCenterClient sharedClient] getChannel:channelUid
                              completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation)
     {
         if(result != nil){
             if(showProgress == YES && self.currentView != nil){
                 [CCSVProgressHUD dismiss];
             }
             NSMutableDictionary *unreadMessagesDic = [NSMutableDictionary dictionary];
             if (
                 [result valueForKey:@"uid"] != nil
                 && ![result[@"uid"] isEqual:[NSNull null]]
                 && [result valueForKey:@"status"] != nil
                 && ![result[@"status"] isEqual:[NSNull null]]
                 && [result valueForKey:@"org_uid"] != nil
                 && ![result[@"org_uid"] isEqual:[NSNull null]]
                 && [result valueForKey:@"created"] != nil
                 && ![result[@"created"] isEqual:[NSNull null]]
                 && [result valueForKey:@"last_updated_at"] != nil
                 && ![result[@"last_updated_at"] isEqual:[NSNull null]]
                 && [result valueForKey:@"users"] != nil
                 && ![result[@"users"] isEqual:[NSNull null]]
                 && [result valueForKey:@"org_name"] != nil
                 && ![result[@"org_name"] isEqual:[NSNull null]]
                 && [result valueForKey:@"unread_messages"] != nil
                 && ![result[@"unread_messages"] isEqual:[NSNull null]]
                 && [result valueForKey:@"id"] != nil
                 && ![result[@"id"] isEqual:[NSNull null]]
                 && [result valueForKey:@"read"] != nil
                 && ![result[@"read"] isEqual:[NSNull null]]
                 && [result valueForKey:@"channel_informations"] != nil /// @"channel_informations" could be Null
                 && [result valueForKey:@"icon_url"] != nil /// @"icon_url" could be Null
                 )/// @"latest_message" could be Null
             {
                 NSDictionary *assignee      = [result valueForKey:@"assignee"];
                 NSNumber *uid               = [result valueForKey:@"id"];
                 NSString *channelUid        = [result valueForKey:@"uid"];
                 NSString *status            = [result valueForKey:@"status"];
                 NSString *orgUid            = [result valueForKey:@"org_uid"];
                 NSString *stringCreatedDate = [result valueForKey:@"created"];
                 NSDate *createdDate         = [NSDate dateWithTimeIntervalSince1970:[stringCreatedDate doubleValue]];
                 NSString *stringLastUpdatedAt = [result valueForKey:@"last_updated_at"];
                 NSDate *lastUpdatedAt         = [NSDate dateWithTimeIntervalSince1970:[stringLastUpdatedAt doubleValue]];
                 NSArray *users              = [result valueForKey:@"users"];
                 NSString *orgName           = [result valueForKey:@"org_name"];
                 NSString *unreadMessages    = [[result valueForKey:@"unread_messages"] stringValue];
                 NSDictionary *latestMessage = [result valueForKey:@"latest_message"];
                 NSString *iconUrl           = [result valueForKey:@"icon_url"];
                 NSNumber *read              = [result valueForKey:@"read"];
                 NSDictionary *channelInformations = result[@"channel_informations"];
                 ///name and directmessage are only used for team now
                 NSString *name = @"";
                 BOOL directMessage = NO;
                 if (result[@"name"] != nil && ![result[@"name"] isEqual:[NSNull null]]) name = result[@"name"];
                 if (result[@"direct_message"] != nil && ![result[@"direct_message"] isEqual:[NSNull null]]) {
                     directMessage = [result[@"direct_message"] boolValue];
                 }

                 // Filtering.
                 if (![CCHistoryFilterUtil isFilteringWithConnectionData:result]) {
                     [[CCCoredataBase sharedClient] deleteChannelWithUid:channelUid];
                     if([[CCCoredataBase sharedClient] insertChannel:channelUid
                                                           createdAt:createdDate
                                                            updateAt:nil
                                                               users:users
                                                             org_uid:orgUid
                                                            org_name:orgName
                                                     unread_messages:unreadMessages
                                                      latest_message:latestMessage
                                                                 uid:uid
                                                              status:status
                                                channel_informations:channelInformations
                                                            icon_url:iconUrl
                                                                read:[read boolValue]
                                                       lastUpdatedAt:lastUpdatedAt
                                                                name:name
                                                      direct_message:directMessage
                                                            assignee:assignee])
                     {
                         NSLog(@"insertChannel Success!");
                     }else{
                         NSLog(@"insertChannel Error!");
                     }
                     [self.ChatChannelIds addObject:channelUid];
                 }
                 if (![unreadMessages isEqualToString:@"0"] && ![status isEqualToString:@"closed"]) {
                     NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                     f.numberStyle = NSNumberFormatterDecimalStyle;
                     NSNumber *unreadMessagesNum = [f numberFromString:unreadMessages];
                     [unreadMessagesDic setObject:unreadMessagesNum forKey:channelUid];
                 }
             }
             [[ChatCenter sharedInstance] setUnreadMessages:unreadMessagesDic];
             if(completionHandler != nil) completionHandler(result, nil, operation);
         }else{
             if(showProgress == YES && self.currentView != nil){
                 [CCSVProgressHUD showErrorWithStatus:CCLocalizedString(@"Load Message Failed")]; ///This method is "channel load" but from user this is message load
             }
             [self checkNetworkStatus];
             if(completionHandler != nil) completionHandler(nil, error, operation);
         }
     }];
}

-(void)updateChannel:(BOOL)showProgress
          channelUid:(NSString *)channelUid
   completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{ //get channel from server and store it into coredata
    if(showProgress == YES && self.currentView != nil){
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading Messages...") maskType:SVProgressHUDMaskTypeBlack];
    }
    [[ChatCenterClient sharedClient] getChannel:channelUid
                              completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation)
     {
         if(result != nil){
             if(showProgress == YES && self.currentView != nil){
                 [CCSVProgressHUD dismiss];
             }
              NSMutableDictionary *unreadMessagesDic = [[ChatCenter sharedInstance].unreadMessages mutableCopy];
             if (
                 [result valueForKey:@"uid"] != nil
                 && ![result[@"uid"] isEqual:[NSNull null]]
                 && [result valueForKey:@"status"] != nil
                 && ![result[@"status"] isEqual:[NSNull null]]
                 && [result valueForKey:@"org_uid"] != nil
                 && ![result[@"org_uid"] isEqual:[NSNull null]]
                 && [result valueForKey:@"created"] != nil
                 && ![result[@"created"] isEqual:[NSNull null]]
                 && [result valueForKey:@"last_updated_at"] != nil
                 && ![result[@"last_updated_at"] isEqual:[NSNull null]]
                 && [result valueForKey:@"users"] != nil
                 && ![result[@"users"] isEqual:[NSNull null]]
                 && [result valueForKey:@"org_name"] != nil
                 && ![result[@"org_name"] isEqual:[NSNull null]]
                 && [result valueForKey:@"unread_messages"] != nil
                 && ![result[@"unread_messages"] isEqual:[NSNull null]]
                 && [result valueForKey:@"id"] != nil
                 && ![result[@"id"] isEqual:[NSNull null]]
                 && [result valueForKey:@"read"] != nil
                 && ![result[@"read"] isEqual:[NSNull null]]
                 && [result valueForKey:@"channel_informations"] != nil /// @"channel_informations" could be Null
                 && [result valueForKey:@"icon_url"] != nil /// @"icon_url" could be Null
                 )/// @"latest_message" could be Null
             {
                 NSDictionary *assignee      = [result valueForKey:@"assignee"];
                 NSNumber *uid               = [result valueForKey:@"id"];
                 NSString *channelUid        = [result valueForKey:@"uid"];
                 NSString *status            = [result valueForKey:@"status"];
                 NSString *orgUid            = [result valueForKey:@"org_uid"];
                 NSString *stringCreatedDate = [result valueForKey:@"created"];
                 NSDate *createdDate         = [NSDate dateWithTimeIntervalSince1970:[stringCreatedDate doubleValue]];
                 NSString *stringLastUpdatedAt = [result valueForKey:@"last_updated_at"];
                 NSDate *lastUpdatedAt         = [NSDate dateWithTimeIntervalSince1970:[stringLastUpdatedAt doubleValue]];
                 NSArray *users              = [result valueForKey:@"users"];
                 NSString *orgName           = [result valueForKey:@"org_name"];
                 NSString *unreadMessages    = [[result valueForKey:@"unread_messages"] stringValue];
                 NSDictionary *latestMessage = [result valueForKey:@"latest_message"];
                 NSString *iconUrl           = [result valueForKey:@"icon_url"];
                 NSNumber *read              = [result valueForKey:@"read"];
                 NSDictionary *channelInformations = result[@"channel_informations"];
                 ///name and directmessage are only used for team now
                 NSString *name = @"";
                 BOOL directMessage = NO;
                 if (result[@"name"] != nil && ![result[@"name"] isEqual:[NSNull null]]) name = result[@"name"];
                 if (result[@"direct_message"] != nil && ![result[@"direct_message"] isEqual:[NSNull null]]) {
                     directMessage = [result[@"direct_message"] boolValue];
                 }
                 if([[CCCoredataBase sharedClient] updateChannelUpdatedWithUid:channelUid
                                                                     createdAt:createdDate
                                                                      updateAt:nil
                                                                         users:users
                                                                       org_uid:orgUid
                                                                      org_name:orgName
                                                               unread_messages:unreadMessages
                                                                latest_message:latestMessage
                                                                           uid:uid
                                                                        status:status
                                                          channel_informations:channelInformations
                                                                      icon_url:iconUrl
                                                                          read:[read boolValue]
                                                                 lastUpdatedAt:lastUpdatedAt
                                                                          name:name
                                                                direct_message:directMessage
                                                                      assignee:assignee])
                 {
                     NSLog(@"updateChannel Success!");
                 }else{
                     NSLog(@"updateChannel Error!");
                 }
                 [self.ChatChannelIds addObject:channelUid];
                 if (![unreadMessages isEqualToString:@"0"] && ![status isEqualToString:@"closed"]) {
                     NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                     f.numberStyle = NSNumberFormatterDecimalStyle;
                     NSNumber *unreadMessagesNum = [f numberFromString:unreadMessages];
                     [unreadMessagesDic setObject:unreadMessagesNum forKey:channelUid];
                 }
             }
             [[ChatCenter sharedInstance] setUnreadMessages:unreadMessagesDic];
             if(completionHandler != nil) completionHandler(result, nil, operation);
         }else{
             if(showProgress == YES && self.currentView != nil){
                 [CCSVProgressHUD showErrorWithStatus:CCLocalizedString(@"Load Message Failed")]; ///This method is "channel load" but from user this is message load
             }
             [self checkNetworkStatus];
             if(completionHandler != nil) completionHandler(nil, error, operation);
         }
     }];
}

- (void)updateChannel:(NSString *)channelId channelInformations:(NSDictionary *)channelInformations note:(NSString *)note completionHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    [[ChatCenterClient sharedClient] updateChannel:channelId channelInformations:channelInformations note:note completionHandler:completionHandler];
}

-(void)loadMessages:(NSString *)channelUid
       showProgress:(BOOL)showProgress
              limit:(int)limit
             lastId:(NSNumber *)lastId
  completionHandler:(void (^)(NSString *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{ //get messages from server, store messages to local
    if(showProgress == YES && self.currentView != nil){
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading Messages...") maskType:SVProgressHUDMaskTypeBlack];
    }
    __block NSNumber *blockLastId = lastId;
    [[ChatCenterClient sharedClient] getMessage:channelUid limit:limit lastId:lastId completionHandler:^(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation){
        if(result != nil){
            if(showProgress == YES && self.currentView != nil){
                [CCSVProgressHUD dismiss];
            }
            NSLog(@"Success!");
            ///reset data in first load
            if (blockLastId == nil) {
                if([[CCCoredataBase sharedClient] deleteAllMessagesWithChannel:channelUid]){
                    NSLog(@"deleteAllMessagesWithChannel Success!");
                }else{
                    NSLog(@"deleteAllMessagesWithChannel Error!");
                }
            }
            if (result.count != 0) {
                for (int i = (int)result.count-1; -1 < i; i--) {
                    //Check valid information, if message has type "information", let skip conditions about User
                    if ([result[i] valueForKey:@"id"] != nil &&
                        ![result[i][@"id"] isEqual:[NSNull null]] &&
                        [result[i] valueForKey:@"content"] &&
                        ![result[i][@"content"] isEqual:[NSNull null]] &&
                        [result[i] valueForKey:@"type"] &&
                        ![result[i][@"type"] isEqual:[NSNull null]] &&
                        (([result[i] valueForKey:@"user"] &&
                            ![result[i][@"user"] isEqual:[NSNull null]]) ||
                            [result[i][@"type"] isEqualToString:CC_RESPONSETYPEINFORMATION] ||
                            [result[i][@"type"] isEqualToString:CC_RESPONSETYPEPROPERTY])&&
                        [result[i] valueForKey:@"created"] &&
                        ![result[i][@"created"] isEqual:[NSNull null]] &&
                        [result[i] valueForKey:@"users_read_message"] &&
                        ![result[i][@"users_read_message"] isEqual:[NSNull null]])
                    {
                        NSNumber *uid                = [result[i] valueForKey:@"id"];
                        NSString *messageType        = [result[i] valueForKey:@"type"];
                        NSDictionary *content;
                        if ([messageType isEqualToString:CC_RESPONSETYPEUNEXPECTED]) {
                            content = @{@"text":CCLocalizedString(@"Your current version can't display the message. Please download the latest version in App Store.")};
                        }else{
                            content = [result[i] valueForKey:@"content"];
                        }
                        
                        NSString *stringDate         = [result[i] valueForKey:@"created"];
                        NSArray *usersReadMessage    = [result[i] valueForKey:@"users_read_message"];
                        NSLog(@"date format: %@", stringDate);
                        NSDate *date = [NSDate dateWithTimeIntervalSince1970:stringDate.doubleValue];
                        NSDictionary *user, *answer, *question;
                        if ([result[i] valueForKey:@"user"] &&
                            ![result[i][@"user"] isEqual:[NSNull null]]) {
                            user = [result[i] valueForKey:@"user"];
                        }else{
                            user = nil;
                        }
                        if([result[i] valueForKey:@"answer"] &&
                           ![result[i][@"answer"] isEqual:[NSNull null]]){
                            answer = result[i][@"answer"];
                        }else{
                            answer = nil;
                        }
                        if([result[i] valueForKey:@"question"] &&
                           ![result[i][@"question"] isEqual:[NSNull null]]){
                            question = result[i][@"question"];
                        }else{
                            question = nil;
                        }
                        
                        if([[CCCoredataBase sharedClient] insertMessage:uid
                                                                   type:messageType
                                                                content:content
                                                                   date:date
                                                             channelUid:channelUid
                                                              channelId:nil
                                                                   user:user
                                                       usersReadMessage:usersReadMessage
                                                                 answer:answer
                                                               question:question
                                                                 status:CC_MESSAGE_STATUS_SEND_SUCCESS])
                        {
                            NSLog(@"insertMessage Success!");
                        }else{
                            NSLog(@"insertMessage Error!");
                        }
                    }
                }
            }
            if(completionHandler != nil) completionHandler(@"success", nil, operation);
        }else{
            if(showProgress == YES && self.currentView != nil){
                [CCSVProgressHUD showErrorWithStatus:CCLocalizedString(@"Load Message Failed")];
            }
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

//- (void)loadChannelsAndConnectWebSocket:(BOOL)showProgress getChennelType:(int)getChennelType isOrgChange:(BOOL)isOrgChange org_uid:(NSString *)org_uid completionHandler:(void (^)(NSString *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
//    if ([[CCConstants sharedInstance] getKeychainToken] == nil) {
//        self.isRefreshingData = NO;
//        return;
//    }
//    ///get channels from server, store channels to local, connect channels, get messages from server, store messages to local
//    if(showProgress == YES && self.currentView != nil){
//        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading Messages...") maskType:SVProgressHUDMaskTypeBlack];
//    }
//    [self loadChannels:NO
//        getChennelType:getChennelType
//               org_uid:org_uid
//                 limit:CCloadChannelFirstLimit
//         lastUpdatedAt:nil
//     completionHandler:^(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation)
//    {
//        [self hideToast];
//        if (result != nil) {
//            NSLog(@"Load channels Success");
//            [self connectWebSocket];
//            if (self.ChatChannelIds.count > 0) {
//                __block int loadMessageSuccessCount = 0;
//                int maxLoadMessages = CCloadChannelFirstLimit < self.ChatChannelIds.count ? CCloadChannelFirstLimit : (int)self.ChatChannelIds.count;
//                for (int i=0; i < maxLoadMessages; i++) {
//                    [self loadMessages:self.ChatChannelIds[i] showProgress:NO limit:CCloadMessageFirstLimit lastId:nil completionHandler:^(NSString *result, NSError *error, CCAFHTTPRequestOperation *operation) {
//                        if (result != nil) {
//                            NSLog(@"Load previous message Success");
//                            loadMessageSuccessCount++;
//                            if (loadMessageSuccessCount == maxLoadMessages) {
//                                if(showProgress == YES && self.currentView != nil){
//                                    [CCSVProgressHUD dismiss];
//                                }
//                                [self setIsDataSynchronized:YES];
//                                if(completionHandler != nil) completionHandler(@"Success",nil, operation);
//                                [self hideToast];
//                                [self makeToast:@"Finished data load" message:CCLocalizedString(@"Finished data load") duration:1.5 backgroundColor:[UIColor greenColor]];
//                                if ([self.delegate respondsToSelector:@selector(loadLocalData:)]){
//                                    [self.delegate loadLocalData:isOrgChange];
//                                }
//                            }
//                        }else{
//                            [self setIsDataSynchronized:NO];
//                            if(showProgress == YES && self.currentView != nil){
//                                [CCSVProgressHUD showErrorWithStatus:CCLocalizedString(@"Load Message Failed")];
//                            }
//                            [self makeToast:@"Can not load data" message:CCLocalizedString(@"Can not load data") duration:99999 backgroundColor:[UIColor redColor]];
//                            NSLog(@"Load channel Error");
//                            if(completionHandler != nil) completionHandler(nil, error, operation);
//                        }
//                    }];
//                }
//            }else{
//                if(showProgress == YES && self.currentView != nil){
//                    [CCSVProgressHUD showSuccessWithStatus:CCLocalizedString(@"No Message yet")];
//                }
//                if(completionHandler != nil) completionHandler(@"No Message yet",nil, operation);
//                if ([self.delegate respondsToSelector:@selector(loadLocalData:)]){
//                    [self.delegate loadLocalData:isOrgChange];
//                }
//            }
//        }else{
//            [self setIsDataSynchronized:NO];
//            if(showProgress == YES && self.currentView != nil){
//                [CCSVProgressHUD showErrorWithStatus:CCLocalizedString(@"Load Message Failed")];
//            }
//            [self makeToast:@"Can not load data" message:CCLocalizedString(@"Can not load data") duration:99999 backgroundColor:[UIColor redColor]];
//            NSLog(@"Load channel Error");
//            if(completionHandler != nil) completionHandler(nil, error, operation);
//        }
//    }];
//}

- (void)loadChannelsAndConnectWebSocket:(BOOL)showProgress getChennelType:(int)getChennelType isOrgChange:(BOOL)isOrgChange org_uid:(NSString *)org_uid completionHandler:(void (^)(NSString *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    if ([[CCConstants sharedInstance] getKeychainToken] == nil) {
        self.isRefreshingData = NO;
        return;
    }
    ///get channels from server, store channels to local, connect channels, get messages from server, store messages to local
    if(showProgress == YES && self.currentView != nil){
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading...") maskType:SVProgressHUDMaskTypeBlack];
    }
    [self loadChannels:NO
        getChennelType:getChennelType
               org_uid:org_uid
                 limit:CCloadChannelFirstLimit
         lastUpdatedAt:nil
     completionHandler:^(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation)
     {
         [self hideToast];
         if (result != nil) {
             [self setIsDataSynchronized:YES];
             [self connectWebSocket];
             if (self.ChatChannelIds.count > 0) {
                 if (completionHandler != nil) completionHandler(@"Success",nil, operation);
                 if ([self.delegate respondsToSelector:@selector(loadLocalData:)]){
                     [self.delegate loadLocalData:isOrgChange];
                 }
                 if ([self.delegate respondsToSelector:@selector(reloadLocalDataWhenComeOnline)]){
                     [self.delegate reloadLocalDataWhenComeOnline];
                 }
                 if(showProgress == YES && self.currentView != nil){
                     [CCSVProgressHUD dismiss];
                 }
             }else{
                 if(showProgress == YES && self.currentView != nil){
                     [CCSVProgressHUD showSuccessWithStatus:CCLocalizedString(@"No Channel yet")];
                 }
                 if(completionHandler != nil) completionHandler(@"No Channel yet",nil, operation);
                 if ([self.delegate respondsToSelector:@selector(loadLocalData:)]){
                     [self.delegate loadLocalData:isOrgChange];
                 }
             }
         }else{
             [self setIsDataSynchronized:NO];
             if(showProgress == YES && self.currentView != nil){
                 [CCSVProgressHUD showErrorWithStatus:CCLocalizedString(@"Load Channels Failed")];
             }
             [self makeToast:@"Can not load data" message:CCLocalizedString(@"Can not load data") duration:99999 backgroundColor:[UIColor redColor]];
             NSLog(@"Load channel Error");
             if(completionHandler != nil) completionHandler(nil, error, operation);
         }
     }];
}

///load chatcenter token and store data into keychain
- (void)loadUserToken:(NSString*)email
             password:(NSString*)password
             provider:(NSString *)provider
        providerToken:(NSString *)providerToken
  providerTokenSecret:(NSString *)providerTokenSecret
    providerCreatedAt:(NSDate *)providerCreatedAt
    providerExpiresAt:(NSDate *)providerExpiresAt
          deviceToken:(NSString *)deviceToken
         showProgress:(BOOL)showProgress
    completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    self.isLoadingUserToken = YES;
    if (showProgress == YES && self.currentView != nil) {
        [CCSVProgressHUD showWithStatus:@"Checking Account..." maskType:SVProgressHUDMaskTypeBlack];
    }
    [[ChatCenterClient sharedClient] getUserToken:email
                                         password:password
                                         provider:provider
                                    providerToken:providerToken
                              providerTokenSecret:providerTokenSecret
                                providerCreatedAt:providerCreatedAt
                                providerExpiresAt:providerExpiresAt
                                      deviceToken:deviceToken
                                completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation){
        if(error == nil && result[@"token"] != nil
           && ![result[@"token"] isEqual:[NSNull null]]
           && result[@"id"] != nil
           && ![result[@"id"] isEqual:[NSNull null]]
           && result[@"apps"] != nil
           && ![result[@"apps"] isEqual:[NSNull null]])
        {
            [CCConstants sharedInstance].apps = result[@"apps"];
            [[CCConstants sharedInstance] setKeychainToken:result[@"token"]];
            NSString *userUid = [result[@"id"] stringValue];
            [[CCConstants sharedInstance] setKeychainUid:userUid];
            if (providerCreatedAt != nil) {
                double providerCreatedAtDouble = [providerCreatedAt timeIntervalSince1970];
                NSString *providerCreatedAtString = [NSString stringWithFormat:@"%f", providerCreatedAtDouble];
                [CCSSKeychain setPassword:providerCreatedAtString
                               forService:@"ChatCenter"
                                  account:@"providerCreatedAt"];
                [CCConnectionHelper sharedClient].providerOldCreatedAt = providerCreatedAtString;
            }
            if (providerExpiresAt != nil) {
                double providerExpiresAtDouble = [providerExpiresAt timeIntervalSince1970];
                NSString *providerExpiresAtString = [NSString stringWithFormat:@"%f", providerExpiresAtDouble];
                [CCSSKeychain setPassword:providerExpiresAtString
                               forService:@"ChatCenter"
                                  account:@"providerExpiresAt"];
                [CCConnectionHelper sharedClient].providerOldExpiresAt = providerExpiresAtString;
            }
            if (showProgress == YES) {
                [CCSVProgressHUD dismiss]; //Don't show message because "loadUserToken" is always used with "loadChannelsAndConnectWebSocket"
            }
            self.isLoadingUserToken = NO;
            if ([self.delegate respondsToSelector:@selector(finishedLoadingUserToken)]){
                [self.delegate finishedLoadingUserToken];
            }
            if(completionHandler != nil) completionHandler(result, nil, operation);
        }else{
            if (showProgress == YES && self.currentView != nil) {
                [CCSVProgressHUD dismiss]; //Don't show message because when user is not allowed, displaying alert view
            }
            [self deleteAllData];
            self.isLoadingUserToken = NO;
            if ([self.delegate respondsToSelector:@selector(finishedLoadingUserToken)]){
                [self.delegate finishedLoadingUserToken];
            }
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

///Just loading chatcenter token
- (void)loadUserAuth:(NSString*)email
            password:(NSString*)password
            provider:(NSString *)provider
       providerToken:(NSString *)providerToken
 providerTokenSecret:(NSString *)providerTokenSecret
   providerCreatedAt:(NSDate *)providerCreatedAt
   providerExpiresAt:(NSDate *)providerExpiresAt
         deviceToken:(NSString *)deviceToken
        showProgress:(BOOL)showProgress
   completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    self.isLoadingUserToken = YES;
    
    if (showProgress == YES && self.currentView != nil) {
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Data Loading...") maskType:SVProgressHUDMaskTypeBlack];
    }
    [[ChatCenterClient sharedClient] getUserToken:email
                                         password:password
                                         provider:provider
                                    providerToken:providerToken
                              providerTokenSecret:providerTokenSecret
                                providerCreatedAt:providerCreatedAt
                                providerExpiresAt:providerExpiresAt
                                      deviceToken:deviceToken
                                completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation)
    {
        if(error == nil && result[@"token"] != nil
           && ![result[@"token"] isEqual:[NSNull null]]
           && result[@"id"] != nil
           && ![result[@"id"] isEqual:[NSNull null]]
           && result[@"apps"] != nil
           && ![result[@"apps"] isEqual:[NSNull null]])
        {
            [CCConstants sharedInstance].apps = result[@"apps"];
            if (showProgress == YES) {
                [CCSVProgressHUD dismiss];
            }
            self.isLoadingUserToken = NO;
            
            // Save user id
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSNumber *userId = [NSNumber numberWithInt:[result[@"id"] intValue]];
            NSString *displayName = @"";
            if (result[@"display_name"] != nil
                && ![result[@"display_name"] isEqual:[NSNull null]]){
                displayName = result[@"display_name"];
            }
            NSString *iconUrl = @"";
            if (result[@"icon_url"] != nil
                && ![result[@"icon_url"] isEqual:[NSNull null]]){
                iconUrl = result[@"icon_url"];
            }
            NSString *email = @"";
            if (result[@"email"] != nil
                && ![result[@"email"] isEqual:[NSNull null]]){
                email = result[@"email"];
            }
            [ud setValue:userId forKey:kCCUserDefaults_userId];
            [ud setValue:displayName forKey:kCCUserDefaults_userDisplayName];
            [ud setValue:iconUrl forKey:kCCUserDefaults_userIconUrl];
            [ud setValue:email forKey:kCCUserDefaults_userEmail];
            [ud synchronize];
            
            if ([self.delegate respondsToSelector:@selector(finishedLoadingUserToken)]){
                [self.delegate finishedLoadingUserToken];
            }
            if(completionHandler != nil) completionHandler(result, nil, operation);
        }else{
            if (showProgress == YES) {
                [CCSVProgressHUD showErrorWithStatus:CCLocalizedString(@"Loading Failed")];
            }
            self.isLoadingUserToken = NO;
            if ([self.delegate respondsToSelector:@selector(finishedLoadingUserToken)]){
                [self.delegate finishedLoadingUserToken];
            }
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

- (void)loadOrg:(BOOL)showProgress completionHandler:(void (^)(NSString *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{ //get channels from server, store channels to local, connect channels,get messages from server, store messages to local
    if(showProgress == YES && self.currentView != nil){
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading Organizations...") maskType:SVProgressHUDMaskTypeBlack];
    }
    [[ChatCenterClient sharedClient] getOrg:^(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation){
        if(result != nil && result.count > 0){
            if(showProgress == YES){
                [CCSVProgressHUD dismiss]; //Don't show message because "loadUserToken" is always used with "loadChannelsAndConnectWebSocket"
            }
            NSLog(@"Success!");

            if([[CCCoredataBase sharedClient] deleteAllOrg]){
                NSLog(@"deleteAllMessagesWithChannel Success!");
            }else{
                NSLog(@"deleteAllMessagesWithChannel Error!");
            }
            for (int i = (int)result.count-1; -1 < i; i--) {
                if ([result[i] valueForKey:@"uid"] != nil
                    && ![result[i][@"uid"] isEqual:[NSNull null]]
                    && [result[i] valueForKey:@"name"] != nil
                    && ![result[i][@"name"] isEqual:[NSNull null]])
                {
                    NSString *uid           = [result[i] valueForKey:@"uid"];
                    NSString *name   = [result[i] valueForKey:@"name"];
                    NSData *unreadMessagesChannels = [NSKeyedArchiver archivedDataWithRootObject:[result[i] valueForKey:@"unread_messages_channels"]];
                    NSData *users = [NSKeyedArchiver archivedDataWithRootObject:[result[i] valueForKey:@"users"]];
                                     if([[CCCoredataBase sharedClient] insertOrg:uid name:name withUnreadMessagesChannels:unreadMessagesChannels users: users]){
                        NSLog(@"insertMessage Success!");
                    }else{
                        NSLog(@"insertMessage Error!");
                    }
                }else{
                    if(showProgress == YES && self.currentView != nil){
                        [CCSVProgressHUD showErrorWithStatus:CCLocalizedString(@"Load Organization Failed")];
                    }
                    if(completionHandler != nil) completionHandler(nil, error, operation);
                }
            }
            [self setCurrentOrg];
            if(completionHandler != nil) completionHandler(@"success", nil, operation);
        }else{
            if(showProgress == YES && self.currentView != nil){
                [CCSVProgressHUD showErrorWithStatus:CCLocalizedString(@"Load Organization Failed")];
            }
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

- (void)loadUserTokenAndOrg:(NSString*)email
                   password:(NSString*)password
               showProgress:(BOOL)showProgress
          completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    __block NSString *blockPassword = password;
    [self loadUserToken:email
               password:password
               provider:nil
          providerToken:nil
    providerTokenSecret:nil
      providerCreatedAt:nil
      providerExpiresAt:nil
            deviceToken:nil
           showProgress:showProgress
      completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation)
    {
        if(result != nil && result[@"id"] != nil && ![result[@"id"] isEqual:[NSNull null]] && result[@"email"] != nil && ![result[@"email"] isEqual:[NSNull null]] && result[@"token"] != nil && ![result[@"token"] isEqual:[NSNull null]]){
            NSLog(@"Success!");
            //set user prpperties(email/firstName/familyName/token) to Userdefault
            [[CCConstants sharedInstance] setKeychainUid:[result[@"id"] stringValue]];
            [CCSSKeychain setPassword:result[@"email"]  forService:@"ChatCenter" account:@"email"];
            [[CCConstants sharedInstance] setKeychainToken:result[@"token"]];
            [CCSSKeychain setPassword:blockPassword     forService:@"ChatCenter" account:@"password"];
            if(result[@"first_name"] == nil || [result[@"first_name"] isEqual:[NSNull null]]){
                [CCSSKeychain setPassword:@"" forService:@"ChatCenter" account:@"firstName"];
            }else{
                [CCSSKeychain setPassword:result[@"first_name"]  forService:@"ChatCenter" account:@"firstName"];
            }
            if(result[@"family_name"] == nil || [result[@"family_name"] isEqual:[NSNull null]]){
                [CCSSKeychain setPassword:@"" forService:@"ChatCenter" account:@"familyName"];
            }else{
                [CCSSKeychain setPassword:result[@"family_name"]  forService:@"ChatCenter" account:@"familyName"];
            }
            if (showProgress == YES) {
                [CCSVProgressHUD dismiss]; //Don't show message because "loadUserToken" is always used with "loadChannelsAndConnectWebSocket"
            }
            [self loadOrg:showProgress completionHandler:^(NSString *loadOrgResult, NSError *loadOrgError, CCAFHTTPRequestOperation *operation){
                if(loadOrgResult != nil){
                    if(completionHandler != nil) completionHandler(result, nil, operation);
                }else{
                    if(completionHandler != nil) completionHandler(nil, error, operation);
                }
            }];
        }else{
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

- (void)loadUser:(BOOL)showProgress
         userUid:(NSString*)userUid
completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    if(showProgress == YES && self.currentView != nil){
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading Profile...") maskType:SVProgressHUDMaskTypeBlack];
    }
    [[ChatCenterClient sharedClient] getUser:userUid completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation){
        if(result != nil){
            NSLog(@"Success!");
            if (showProgress == YES) {
                [CCSVProgressHUD dismiss];
            }
            if(completionHandler != nil) completionHandler(result, nil, operation);
        }else{
            if (showProgress == YES && self.currentView != nil) {
                [CCSVProgressHUD dismiss];
            }
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

- (void)loadUsers:(BOOL)showProgress
completionHandler:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    if(showProgress == YES && self.currentView != nil){
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading Users...") maskType:SVProgressHUDMaskTypeBlack];
    }
    [[ChatCenterClient sharedClient] getUsers:^(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation){
        if(result != nil){
            NSLog(@"Success!");
            if (showProgress == YES) {
                [CCSVProgressHUD dismiss];
            }
            if(completionHandler != nil) completionHandler(result, nil, operation);
        }else{
            if (showProgress == YES && self.currentView != nil) {
                [CCSVProgressHUD dismiss];
            }
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

- (void)loadUserMe:(BOOL)showProgress
 completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    if(showProgress == YES && self.currentView != nil){
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading Profile...") maskType:SVProgressHUDMaskTypeBlack];
    }
    [[ChatCenterClient sharedClient] getUserMe:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation){
        if(result != nil){
            NSLog(@"Success!");
            if (showProgress == YES) {
                [CCSVProgressHUD dismiss];
            }
            // Save current user
            NSNumber *userId = [result objectForKey:@"id"];
            NSString *displayName = @"";
            if (result[@"display_name"] != nil
                && ![result[@"display_name"] isEqual:[NSNull null]]){
                displayName = result[@"display_name"];
            }
            NSString *iconUrl = @"";
            if (result[@"icon_url"] != nil
                && ![result[@"icon_url"] isEqual:[NSNull null]]){
                iconUrl = result[@"icon_url"];
            }
            NSString *email = @"";
            if (result[@"email"] != nil
                && ![result[@"email"] isEqual:[NSNull null]]){
                email = result[@"email"];
            }
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setValue:userId forKey:kCCUserDefaults_userId];
            [ud setValue:displayName forKey:kCCUserDefaults_userDisplayName];
            [ud setValue:iconUrl forKey:kCCUserDefaults_userIconUrl];
            [ud setValue:email forKey:kCCUserDefaults_userEmail];
            [ud synchronize];
            if(completionHandler != nil) completionHandler(result, nil, operation);
        }else{
            if (showProgress == YES && self.currentView != nil) {
                [CCSVProgressHUD dismiss];
            }
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

- (void)loadFixedPhrase: (NSString *)orgUid showProgress:(BOOL)showProgress completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    if(showProgress == YES && self.currentView != nil){
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading...") maskType:SVProgressHUDMaskTypeBlack];
    }
    [[ChatCenterClient sharedClient] getFixedPhrases:orgUid withHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation){
        if(result != nil){
            NSLog(@"Success!");
            if (showProgress == YES) {
                [CCSVProgressHUD dismiss];
            }
            if(completionHandler != nil) completionHandler(result, nil, operation);
        }else{
            if (showProgress == YES && self.currentView != nil) {
                [CCSVProgressHUD dismiss];
            }
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

- (void)loadOrgsAndChannelsAndConnectWebSocket:(BOOL)showProgress
                                           getChennelType:(int)getChennelType
                                              isOrgChange:(BOOL)isOrgChange
                                        completionHandler:(void (^)(NSString *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{ //get channels from server, store
    [self loadOrg:showProgress completionHandler:^(NSString *loadOrgResult, NSError *loadOrgError, CCAFHTTPRequestOperation *operation){
        if(loadOrgResult != nil){
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *orgUid = [ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"];
            [self loadChannelsAndConnectWebSocket:showProgress getChennelType:getChennelType isOrgChange:NO org_uid:orgUid completionHandler:^(NSString *result, NSError *error, CCAFHTTPRequestOperation *operation) {
                if (result != nil) {
                    if(completionHandler != nil) completionHandler(result, nil, operation);
                }else{
                    if(completionHandler != nil) completionHandler(nil, error, operation);
                }
            }];
        }else{
            if(completionHandler != nil) completionHandler(nil, loadOrgError, operation);
        }
    }];
}

// Get org online status
- (void)getOrgOnlineStatus:orgUid completeHandler:(void (^)(BOOL isOnline))completionHandler {
    [[ChatCenterClient sharedClient] getOrgOnlineStatus:orgUid completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        if (result != nil && [result objectForKey:@"online"] != nil) {
            if (completionHandler != nil) completionHandler([[result objectForKey:@"online"] boolValue]);
        }else {
            [self checkNetworkStatus];
            if (completionHandler != nil) completionHandler(NO);
        }
    }];
}

- (void)setCurrentOrg{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *previousOrgUid = @"";
    if ([ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"]) { ///set previous chosen orgUid
        previousOrgUid = [ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"];
        [ud removeObjectForKey:@"ChatCenterUserdefaults_currentOrgUid"];
    }
    NSArray *orgArray = [[CCCoredataBase sharedClient] selectOrgAll:CCloadLoacalUserLimit];
    if(orgArray != nil && orgArray.count > 0){
        for (int i = 0; i<(int)orgArray.count; i++) {
            NSManagedObject *object   = [orgArray objectAtIndex:i];
            NSString *uid             = [object valueForKey:@"uid"];
            if (i == 0) { ///if no previous chosen orgUid, set index0 orgUid
                 [ud setObject:uid forKey:@"ChatCenterUserdefaults_currentOrgUid"];
                 [ud synchronize];
            }
            if ([uid isEqualToString:previousOrgUid]) {
                [ud setObject:uid forKey:@"ChatCenterUserdefaults_currentOrgUid"];
                [ud synchronize];
                break;
            }
        }
    }
    NSLog(@"CCCurrentOrgUidCCCurrentOrgUid: %@", [ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"]);
}

- (void)setCurrentApp:(void (^)(BOOL success))completionHandler{
    NSArray *apps = [CCConstants sharedInstance].apps;
    if(apps != nil && apps.count > 0){
        [self setAppToken:apps completionHandler:^{
            if(completionHandler != nil) completionHandler(YES);
        }];
    }else{
        [self getApps:^(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation) {
            if(result != nil && result.count > 0){
                [self setAppToken:result completionHandler:^{
                    if(completionHandler != nil) completionHandler(YES);
                }];
            }else{
                if(completionHandler != nil) completionHandler(NO);
            }
        }];
    }
}

- (void)setAppToken:(NSArray *)apps completionHandler:(void (^)(void))completionHandler{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *previousAppUid = @"";
    if ([ud stringForKey:@"ChatCenterUserdefaults_currentAppUid"]) { ///set previous chosen orgUid
        previousAppUid = [ud stringForKey:@"ChatCenterUserdefaults_currentAppUid"];
        [ud removeObjectForKey:@"ChatCenterUserdefaults_currentAppUid"];
    }
    NSString *token;
    for (int i = 0; i<(int)apps.count; i++) {
        NSDictionary *app = apps[i];
        NSString *uid = app[@"uid"];
        if (i == 0 || [uid isEqualToString:previousAppUid]) {
            token = app[@"token"];
            [CCConstants sharedInstance].appName = app[@"name"];
            [CCConstants sharedInstance].stickers = app[@"stickers"];
            [CCConstants sharedInstance].businessType = app[@"business_type"];
            [ud setObject:uid forKey:@"ChatCenterUserdefaults_currentAppUid"];
            [ud synchronize];
            
            if([uid isEqualToString:previousAppUid]) break;
        }
    }
    [ChatCenter setAppToken:token completionHandler:^{
        if(completionHandler != nil) completionHandler();
    }];
    NSLog(@"ChatCenterUserdefaults_currentAppUid: %@", [ud stringForKey:@"ChatCenterUserdefaults_currentAppUid"]);
}

- (NSString *)addAuthToUrl:(NSString *)url{
    NSString *token = [[CCConstants sharedInstance] getKeychainToken];
    NSString *newUrl = [url stringByAppendingString:[NSString stringWithFormat:@"?authentication=%@&app_token=%@",token,[ChatCenterClient sharedClient].appToken]];
    return newUrl;
}

#pragma mark - Business funnels
-(void)loadBusinessFunnels:(BOOL)showProgress
         completionHandler:(void (^)(NSString *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    if(showProgress == YES && self.currentView != nil){
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Data Loading...") maskType:SVProgressHUDMaskTypeBlack];
    }
    [[ChatCenterClient sharedClient] getBusinessFunnels:^(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation){
        if(result != nil){
            if(showProgress == YES && self.currentView != nil){
                [CCSVProgressHUD dismiss];
            }
            [result sortedArrayUsingComparator:^(id obj1, id obj2) {
                NSInteger obj1Sort = [[obj1 valueForKey:@"order"] integerValue];
                NSInteger obj2Sort = [[obj2 valueForKey:@"order"] integerValue];
                if (obj1Sort < obj2Sort) {
                    return NSOrderedAscending;
                } else if (obj1Sort > obj2Sort) {
                    return NSOrderedDescending;
                }
                return NSOrderedSame;
            }];
            [CCConstants sharedInstance].businessFunnels = result;
            NSLog(@"Success!");
            if(completionHandler != nil) completionHandler(@"success", nil, operation);
        }else{
            if(showProgress == YES && self.currentView != nil){
                [CCSVProgressHUD showErrorWithStatus:CCLocalizedString(@"Load Message Failed")];
            }
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

-(void)setBusinessFunnelToChannel:(NSString *)channelId funnelId:(NSString *)funnelId showProgress:(BOOL)showProgress completionHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    [[ChatCenterClient sharedClient] setBusinessFunnelToChannel:channelId funnelId:funnelId showProgress:showProgress completionHandler:completionHandler];
}

# pragma mark - Create Data

-(void)createUserAndConnectWebSocket:(NSString *)orgUid firstName:(NSString *)firstName
                          familyName:(NSString *)familyName
                               email:(NSString *)email
                            provider:(NSString *)provider
                       providerToken:(NSString *)providerToken
                 providerTokenSecret:(NSString *)providerTokenSecret
                   providerCreatedAt:(NSDate *)providerCreatedAt
                   providerExpiresAt:(NSDate *)providerExpiresAt
                 channelInformations:(NSDictionary *)channelInformations
                         deviceToken:(NSString *)deviceToken
                   completionHandler:(void (^)(NSString *channelId, NSError *error))completionHandler
{ //create a user and channel, connect the channel
    [[ChatCenterClient sharedClient] createGuestUser:orgUid firstName:firstName
                                          familyName:familyName
                                               email:email
                                            provider:provider
                                       providerToken:providerToken
                                 providerTokenSecret:providerTokenSecret
                                   providerCreatedAt:providerCreatedAt
                                   providerExpiresAt:providerExpiresAt
                                 channelInformations:channelInformations
                                         deviceToken:(NSString *)deviceToken
                                   completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation){
        if(result != nil
           && result[@"uid"] != nil
           && ![result[@"uid"] isEqual:[NSNull null]]
           && [result[@"users"] objectAtIndex:0][@"token"] != nil
           && ![[result[@"users"] objectAtIndex:0][@"token"] isEqual:[NSNull null]]
           && [result[@"users"] objectAtIndex:0][@"id"] != nil
           && ![[result[@"users"] objectAtIndex:0][@"id"] isEqual:[NSNull null]]
           && result[@"status"] != nil
           && result[@"uid"] != nil
           && result[@"created"] != nil
           && result[@"org_name"] != nil
           && result[@"channel_informations"] != nil
//           && result[@"icon_url"] != nil ///TODO: This will be used when API is ready
//           && result[@"read"] != nil
           )
        {
            NSDictionary *assignee      = [result valueForKey:@"assignee"];
            NSUserDefaults *ud                 = [NSUserDefaults standardUserDefaults];
            NSNumber *uid                      = nil; ///"id" is returned only when GET/channels/mine
            NSString *channelUid               = result[@"uid"];
            NSString *status                   = result[@"status"];
            NSString *stringCreatedDate        = result[@"created"];
            NSDate *createdDate                = [NSDate dateWithTimeIntervalSince1970:stringCreatedDate.doubleValue];
            NSDate *updatedDate                = [NSDate dateWithTimeIntervalSince1970:stringCreatedDate.doubleValue];
            NSDate *lastUpdatedAt              = [NSDate dateWithTimeIntervalSince1970:stringCreatedDate.doubleValue];
            NSArray *users                     = result[@"users"];
            NSString *orgName                  = result[@"org_name"];
            NSDictionary *channelInformations  = result[@"channel_informations"];
            ///name and directmessage are only used for team now
            NSString *name = @"";
            BOOL directMessage = NO;
            if (result[@"name"] != nil && ![result[@"name"] isEqual:[NSNull null]]) name = result[@"name"];
            if (result[@"direct_message"] != nil && ![result[@"direct_message"] isEqual:[NSNull null]]){
                directMessage = [result[@"direct_message"] boolValue];;
            }
//            NSString *icon_url                 = result[@"icon_url"];
//            NSNumber *read                     = result[@"read"];
            
            // Filtering.
            if (![CCHistoryFilterUtil isFilteringWithConnectionData:result]) {
                if([[CCCoredataBase sharedClient] insertChannel:channelUid
                                                      createdAt:createdDate
                                                       updateAt:updatedDate
                                                          users:users org_uid:orgUid
                                                       org_name:orgName
                                                unread_messages:@"0"
                                                 latest_message:nil
                                                            uid:uid
                                                         status:status
                                           channel_informations:channelInformations
                                                       icon_url:nil
                                                           read:NO
                                                  lastUpdatedAt:lastUpdatedAt
                                                           name:name
                                                 direct_message:directMessage
                                                       assignee:assignee])
                {
                    NSLog(@"insertChannel Success!");
                }else{
                    NSLog(@"insertChannel Error!");
                }
            }
            NSString *userUid = [[result[@"users"]  objectAtIndex:0][@"id"] stringValue];
            
            // Save guest user id
            NSNumber *userId = [NSNumber numberWithInt:[userUid intValue]];
            [ud setValue:userId forKey:kCCUserDefaults_userId];
            [ud synchronize];
            
            [[CCConstants sharedInstance] setKeychainUid:userUid];
            [[CCConstants sharedInstance] setKeychainToken:[result[@"users"] objectAtIndex:0][@"token"]];
            if (providerCreatedAt != nil) {
                double providerCreatedAtDouble = [providerCreatedAt timeIntervalSince1970];
                NSString *providerCreatedAtString = [NSString stringWithFormat:@"%f", providerCreatedAtDouble];
                [CCSSKeychain setPassword:providerCreatedAtString
                               forService:@"ChatCenter"
                                  account:@"providerCreatedAt"];
                [CCConnectionHelper sharedClient].providerOldCreatedAt = providerCreatedAtString;
            }
            if (providerExpiresAt != nil) {
                double providerExpiresAtDouble = [providerExpiresAt timeIntervalSince1970];
                NSString *providerExpiresAtString = [NSString stringWithFormat:@"%f", providerExpiresAtDouble];
                [CCSSKeychain setPassword:providerExpiresAtString
                               forService:@"ChatCenter"
                                  account:@"providerExpiresAt"];
                [CCConnectionHelper sharedClient].providerOldExpiresAt = providerExpiresAtString;
            }
            if([result[@"users"] objectAtIndex:0][@"icon_url"] != nil && ![[result[@"users"] objectAtIndex:0][@"icon_url"] isEqual:[NSNull null]]){
                [CCSSKeychain setPassword:[result[@"users"]  objectAtIndex:0][@"icon_url"] forService:@"ChatCenter" account:@"iconUrl"];
            }
            if([result[@"users"] objectAtIndex:0][@"first_name"] != nil && ![[result[@"users"] objectAtIndex:0][@"first_name"] isEqual:[NSNull null]]){
                [CCSSKeychain setPassword:[result[@"users"]  objectAtIndex:0][@"first_name"] forService:@"ChatCenter" account:@"firstName"];
            }
            if([result[@"users"] objectAtIndex:0][@"family_name"] != nil && ![[result[@"users"] objectAtIndex:0][@"family_name"] isEqual:[NSNull null]]){
                [CCSSKeychain setPassword:[result[@"users"]  objectAtIndex:0][@"family_name"] forService:@"ChatCenter" account:@"familyName"];
            }
            if([result[@"users"] objectAtIndex:0][@"email"] != nil && ![[result[@"users"] objectAtIndex:0][@"email"] isEqual:[NSNull null]]){
                [CCSSKeychain setPassword:[result[@"users"] objectAtIndex:0][@"email"] forService:@"ChatCenter" account:@"email"];
            }
            if([result[@"users"] objectAtIndex:0][@"mobile_number"] != nil && ![[result[@"users"] objectAtIndex:0][@"mobile_number"] isEqual:[NSNull null]]){
                [CCSSKeychain setPassword:[result[@"users"] objectAtIndex:0][@"mobile_number"] forService:@"ChatCenter" account:@"mobileNumber"];
            }
            [ud synchronize];
            
            [self connectWebSocket];
            
            if(completionHandler != nil) completionHandler(channelUid, nil);
        }else{
            if ([CCSSKeychain passwordForService:@"ChatCenter" account:@"providerToken"]) {
                [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"providerToken"];
            }
            if ([CCSSKeychain passwordForService:@"ChatCenter" account:@"providerTokenSecret"]) {
                [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"providerTokenSecret"];
            }
            NSLog(@"create user error");
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error);
        }
    }];
}

-(void)createChannelAndConnectWebSocket:(NSString *)orgUid
                    channelInformations:(NSDictionary *)channelInformations
                      completionHandler:(void (^)(NSString *channelId, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{ //create a channel, connect the channel
    [[ChatCenterClient sharedClient] createChannel:orgUid
                               channelInformations:channelInformations
                                 completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation){ //create Channel
        if(result != nil
           && result[@"uid"] != nil
           && ![result[@"uid"] isEqual:[NSNull null]]
           && result[@"status"] != nil
           && ![result[@"status"] isEqual:[NSNull null]]
           && result[@"users"] != nil
           && ![result[@"users"] isEqual:[NSNull null]]
           && result[@"org_name"] != nil
           && ![result[@"org_name"] isEqual:[NSNull null]]
           && result[@"channel_informations"] != nil
//           && result[@"icon_url"] != nil  ///TODO: This will be used when API is ready
           )
        {
            NSLog(@"result_createChannel: %@", result);
            NSLog(@"Success!");
            NSDictionary *assignee            = [result valueForKey:@"assignee"];
            NSNumber *uid                     = nil; ///"id" is returned only when GET/channels/mine
            NSString *channelUid              = [result valueForKey:@"uid"];
            NSString *status                  = [result valueForKey:@"status"];
            NSString *stringCreatedDate       = [result valueForKey:@"created"];
            NSDate *createdDate               = [NSDate dateWithTimeIntervalSince1970:stringCreatedDate.doubleValue];
            NSDate *updatedDate               = [NSDate dateWithTimeIntervalSince1970:stringCreatedDate.doubleValue];
            NSString *stringLastUpdatedAt      = result[@"last_updated_at"];
            NSDate *lastUpdatedAt              = [NSDate dateWithTimeIntervalSince1970:stringLastUpdatedAt.doubleValue];
            NSArray *users                    = [result valueForKey:@"users"];
            NSString *orgName                 = result[@"org_name"];
            NSDictionary *channelInformations = result[@"channel_informations"];
//            NSString *icon_url                = result[@"icon_url"];
            ///name and directmessage are only used for team now
            NSString *name = @"";
            BOOL directMessage = NO;
            if (result[@"name"] != nil && ![result[@"name"] isEqual:[NSNull null]]) name = result[@"name"];
            if (result[@"direct_message"] != nil && ![result[@"direct_message"] isEqual:[NSNull null]]){
                directMessage = [result[@"direct_message"] boolValue];
            }
            
            // Filtering.
            if (![CCHistoryFilterUtil isFilteringWithConnectionData:result]) {
                if([[CCCoredataBase sharedClient] insertChannel:channelUid
                                                      createdAt:createdDate
                                                       updateAt:updatedDate
                                                          users:users
                                                        org_uid:orgUid
                                                       org_name:orgName
                                                unread_messages:@"0"
                                                 latest_message:nil
                                                            uid:uid
                                                         status:status
                                           channel_informations:channelInformations
                                                       icon_url:nil
                                                           read:NO
                                                  lastUpdatedAt:lastUpdatedAt
                                                           name:name
                                                 direct_message:directMessage
                                                       assignee:assignee])
                {
                    NSLog(@"insertChannel Success!");
                    [[CCSRWebSocket sharedInstance] reconnect];
                }else{
                    NSLog(@"insertChannel Error or already existed!");
                }
                [self.ChatChannelIds addObject:channelUid];
            }
            [CCSVProgressHUD dismiss];
            if(completionHandler != nil) completionHandler(channelUid,nil, operation);
        }else{
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

///Only for team app
-(void)createChannelWithUsers:(NSString *)orgUid
                      userIds:(NSArray *)userIds
                directMessage:(BOOL)directMessage
                    groupName:(NSString *)groupName
          channelInformations:(NSDictionary *)channelInformations
            completionHandler:(void (^)(NSString *channelId, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{ //create a channel, connect the channel
    [[ChatCenterClient sharedClient] createChannel:orgUid
                                           userIds:userIds
                                     directMessage:directMessage
                                         groupName:groupName
                               channelInformations:channelInformations
                                 completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation)
     {
         //create Channel
         if(result != nil
            && result[@"uid"] != nil
            && ![result[@"uid"] isEqual:[NSNull null]]
            && result[@"status"] != nil
            && ![result[@"status"] isEqual:[NSNull null]]
            && result[@"users"] != nil
            && ![result[@"users"] isEqual:[NSNull null]]
            && result[@"org_name"] != nil
            && ![result[@"org_name"] isEqual:[NSNull null]]
            && result[@"channel_informations"] != nil
            //           && result[@"icon_url"] != nil  ///TODO: This will be used when API is ready
            )
         {
             NSLog(@"result_createChannel: %@", result);
             NSLog(@"Success!");
             NSDictionary *assignee      = [result valueForKey:@"assignee"];
             NSNumber *uid                     = nil; ///"id" is returned only when GET/channels/mine
             NSString *channelUid              = [result valueForKey:@"uid"];
             NSString *status                  = [result valueForKey:@"status"];
             NSString *stringCreatedDate       = [result valueForKey:@"created"];
             NSDate *createdDate               = [NSDate dateWithTimeIntervalSince1970:stringCreatedDate.doubleValue];
             NSDate *updatedDate               = [NSDate dateWithTimeIntervalSince1970:stringCreatedDate.doubleValue];
             NSString *stringLastUpdatedAt     = result[@"last_updated_at"];
             NSDate *lastUpdatedAt             = [NSDate dateWithTimeIntervalSince1970:stringLastUpdatedAt.doubleValue];
             NSArray *users                    = [result valueForKey:@"users"];
             NSString *orgName                 = result[@"org_name"];
             NSDictionary *channelInformations = result[@"channel_informations"];
             //            NSString *icon_url                = result[@"icon_url"];
             ///name and directmessage are only used for team now
             NSString *name = @"";
             BOOL directMessage = NO;
             if (result[@"name"] != nil && ![result[@"name"] isEqual:[NSNull null]]) name = result[@"name"];
             if (result[@"direct_message"] != nil && ![result[@"direct_message"] isEqual:[NSNull null]]) {
                 directMessage = [result[@"direct_message"] boolValue];
             }
             
             // Filtering.
             if (![CCHistoryFilterUtil isFilteringWithConnectionData:result]) {
                 if([[CCCoredataBase sharedClient] insertChannel:channelUid
                                                       createdAt:createdDate
                                                        updateAt:updatedDate
                                                           users:users
                                                         org_uid:orgUid
                                                        org_name:orgName
                                                 unread_messages:@"0"
                                                  latest_message:nil
                                                             uid:uid
                                                          status:status
                                            channel_informations:channelInformations
                                                        icon_url:nil
                                                            read:NO
                                                   lastUpdatedAt:lastUpdatedAt
                                                            name:name
                                                  direct_message:directMessage
                                                        assignee:assignee])
                 {
                     NSLog(@"insertChannel Success!");
                 }else{
                     NSLog(@"insertChannel Error or already existed!");
                 }
                 [self.ChatChannelIds addObject:channelUid];
             }
             [CCSVProgressHUD dismiss];
             if(completionHandler != nil) completionHandler(channelUid,nil, operation);
         }else{
             [self checkNetworkStatus];
             if(completionHandler != nil) completionHandler(nil, error, operation);
         }
     }];
}

-(void)loadChannelId:(NSString *)orgUid
           firstName:(NSString *)firstName
          familyName:(NSString *)familyName
               email:(NSString *)email
            provider:(NSString *)provider
       providerToken:(NSString *)providerToken
 providerTokenSecret:(NSString *)providerTokenSecret
   providerCreatedAt:(NSDate *)providerCreatedAt
   providerExpiresAt:(NSDate *)providerExpiresAt
 channelInformations:(NSDictionary *)channelInformations
         deviceToken:(NSString *)deviceToken
        showProgress:(BOOL)showProgress
   completionHandler:(void (^)(NSString *channelId, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    if (deviceToken != nil ///need registering devicetoken
        || [provider isEqualToString:@"twitter"]
        || ([[CCConstants sharedInstance] getKeychainToken] == nil) ///User not exist
        || (([CCConnectionHelper sharedClient].provider != nil) ///Token dates are changed and need authentication
            && ([[CCConnectionHelper sharedClient] isUpdatedProviderCreatedAt] == YES
                || [[CCConnectionHelper sharedClient] isUpdatedProviderExpiresAt] == YES)))
    {///User not exist or need authentication or need registering device token
        if ([self getNetworkStatus] == CCNotReachable && CCLocalDevelopmentMode == NO) {
            ///offline
            if(completionHandler != nil) completionHandler(nil,nil, nil);
            return;
        }
        if (showProgress == YES && self.currentView != nil) {
            [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading...") maskType:SVProgressHUDMaskTypeBlack];
        }
        [self createUserAndConnectWebSocket:orgUid
                                  firstName:firstName
                                 familyName:familyName
                                      email:email
                                   provider:provider
                              providerToken:providerToken
                        providerTokenSecret:providerTokenSecret
                          providerCreatedAt:providerCreatedAt
                          providerExpiresAt:providerExpiresAt
                        channelInformations:channelInformations
                                deviceToken:deviceToken
                          completionHandler:^(NSString *channelId, NSError *error) {
                              if(channelId != nil){
                                  if (showProgress == YES) {
                                      [CCSVProgressHUD dismiss];
                                  }
                                  [[CCConnectionHelper sharedClient] refreshData]; ///Reload all data with token because of displaying URL information and just in case user have already had account before
                                  completionHandler(channelId,nil, nil);
                              }else{
                                  if (showProgress == YES && self.currentView != nil) {
                                      [CCSVProgressHUD showErrorWithStatus:CCLocalizedString(@"Loading Failed")];
                                  }
                                  completionHandler(nil,error, nil);
                              }
                          }];
    }else{
        ///User already exists or no need authentication or no need registering device token
        if ([self getNetworkStatus] != CCNotReachable || CCLocalDevelopmentMode) {
            if (showProgress == YES && self.currentView != nil) {
                [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading...") maskType:SVProgressHUDMaskTypeBlack];
            }
            [self createChannelAndConnectWebSocket:orgUid channelInformations:channelInformations completionHandler:^(NSString *channelId, NSError *error, CCAFHTTPRequestOperation *operation) {
                if (channelId != nil) {
                    if (showProgress == YES) {
                        [CCSVProgressHUD dismiss];
                    }
                    [[CCConnectionHelper sharedClient] refreshData];
                    if(completionHandler != nil) completionHandler(channelId,nil, operation);
                }else{
                    if (showProgress == YES && self.currentView != nil) {
                        [CCSVProgressHUD showErrorWithStatus:CCLocalizedString(@"Loading Failed")];
                    }
                    if(completionHandler != nil) completionHandler(nil,error, operation);
                }
            }];
        }else{
            NSArray *reaultArray = [[CCCoredataBase sharedClient] selectChannelWithOrgUid:CCloadLoacalChannelLimit orgUid:orgUid];
            if ([reaultArray count] == 0) { ///Channel not exist.
                if(completionHandler != nil) completionHandler(nil,nil, nil);
            }else{ ///Channel already exists.
                NSManagedObject *object = [reaultArray objectAtIndex:0];
                NSString *channelId     = [object valueForKey:@"uid"];
                if(completionHandler != nil) completionHandler(channelId,nil, nil);
            }
        }
    }
}

- (void)sendMessage:(NSDictionary *)content
          channelId:(NSString *)channelId
               type:(NSString *)type
  completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    [[ChatCenterClient sharedClient] sendMessage:content
                                       channelId:channelId
                                            type:type
                               completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        if (result != nil) {
            ///POST assign me
            NSArray *channelArray = [[CCCoredataBase sharedClient] selectChannelWithUid:CCloadLoacalChannelLimit uid:channelId];
            if(channelArray != nil && channelArray.count > 0){
                NSManagedObject *object   = [channelArray objectAtIndex:0];
                NSData *usersData         = [object valueForKey:@"users"];
                NSArray *users            = [NSKeyedUnarchiver unarchiveObjectWithData:usersData];
                BOOL alreadyAssigned = NO;
                if ([[CCConstants sharedInstance] getKeychainUid]) {
                    for (int i=0; i < users.count; i++) {
                        if (![users[i][@"id"] isKindOfClass:[NSNumber class]]) {
                            continue;
                        }
                        if ([[users[i][@"id"] stringValue] isEqualToString:[[CCConstants sharedInstance] getKeychainUid]]) {
                            alreadyAssigned = YES;
                            break;
                        }
                    }
                    if (alreadyAssigned == NO) { ///Need to assign me
                        NSString *userUid = [[CCConstants sharedInstance] getKeychainUid];
                        [[ChatCenterClient sharedClient] assignChannel:channelId
                                                               userUid:userUid
                                                     completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation)
                        {
                            if (result != nil) {
                                if(completionHandler != nil) completionHandler(result,nil, operation);
                            }else{
                                if(completionHandler != nil) completionHandler(nil,error, operation);
                            }
                        }];
                    }else{
                        if(completionHandler != nil) completionHandler(result,nil, operation);
                    }
                }
            }
        }else{
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil,error, operation);
        }
    }];
}

- (void)sendFile:(NSString *)channelId
           files:(NSArray *)files
completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    [[ChatCenterClient sharedClient] sendFile:channelId
                                        files:files
                            completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation)
    {
                                   if (result != nil) {
                                       ///POST assign me
                                       NSArray *channelArray = [[CCCoredataBase sharedClient] selectChannelWithUid:CCloadLoacalChannelLimit uid:channelId];
                                       if(channelArray != nil && channelArray.count > 0){
                                           NSManagedObject *object   = [channelArray objectAtIndex:0];
                                           NSData *usersData         = [object valueForKey:@"users"];
                                           NSArray *users            = [NSKeyedUnarchiver unarchiveObjectWithData:usersData];
                                           BOOL alreadyAssigned = NO;
                                           if ([[CCConstants sharedInstance] getKeychainUid]) {
                                               for (int i=0; i < users.count; i++) {
                                                   if (![users[i][@"id"] isKindOfClass:[NSNumber class]]) {
                                                       continue;
                                                   }
                                                   if ([[users[i][@"id"] stringValue] isEqualToString:[[CCConstants sharedInstance] getKeychainUid]]) {
                                                       alreadyAssigned = YES;
                                                       break;
                                                   }
                                               }
                                               if (alreadyAssigned == NO) { ///Need to assign me
                                                   NSString *userUid = [[CCConstants sharedInstance] getKeychainUid];
                                                   [[ChatCenterClient sharedClient] assignChannel:channelId userUid:userUid completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
                                                       if (result != nil) {
                                                           if(completionHandler != nil) completionHandler(result,nil, operation);
                                                       }else{
                                                           if(completionHandler != nil) completionHandler(nil,error, operation);
                                                       }
                                                   }];
                                               }else{
                                                   if(completionHandler != nil) completionHandler(result,nil, operation);
                                               }
                                           }
                                       }
                                   }else{
                                       [self checkNetworkStatus];
                                       if(completionHandler != nil) completionHandler(nil,error, operation);
                                   }
                               }];
}

-(void)sendMessageReceivedStatus:(NSString *)channelId messageIds:(NSArray *)messageIds{ //send receive status to server
    //TODO Check network status and push que in Offline
    [[ChatCenterClient sharedClient] sendMessageStatus:channelId messageIds:messageIds completionHandler:^(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation){
        if(result != nil){
            NSLog(@"sendMessagetatus Success!");
        }else{
            if ([[CCConnectionHelper sharedClient] isAuthenticationError:operation] == YES){
                if ([self.delegate respondsToSelector:@selector(closeChatView)]){
                    [self displayAuthenticationErrorAlert];
                }
            }else{
                [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
                [self checkNetworkStatus];
            }
        }
    }];
}

-(void)sendMessageAnswer:(NSString *)channelId
               messageId:(NSNumber *)messageId
             answer_type:(NSNumber *)answer_type
             question_id:(NSString *)question_id
       completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    [[ChatCenterClient sharedClient] sendMessageAnswer:channelId
                                            message_id:messageId
                                           answer_type:answer_type
                                           question_id:question_id
                                     completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
                                         if (result != nil && result[@"answer"] != nil) {
                                             [CCSVProgressHUD showSuccessWithStatus:CCLocalizedString(@"Answered!")];
                                         }
                                         if(completionHandler != nil) completionHandler(result, error, operation);
                                         [self checkNetworkStatus];
                                     }];
}

- (void)closeChannels:(NSArray*)channelUids
   completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    [[ChatCenterClient sharedClient] closeChannels:channelUids completionHandler:completionHandler];
}

- (void)openChannels:(NSArray*)channelUids
    completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    [[ChatCenterClient sharedClient] openChannels:channelUids completionHandler:completionHandler];
}

- (void)deleteChannel:(NSString *)channelUid completionHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completionHandler{
    [[ChatCenterClient sharedClient] deleteChannel:channelUid completionHandler:completionHandler];
}

- (void)setAssigneeForChannel:(NSString *)channelID agentID:(NSString *)agentID completionHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    [[ChatCenterClient sharedClient] setAssigneeForChannel:channelID agentID:agentID completionHandler:completionHandler];
}

- (void) removeAssigneeFromChannel:(NSString *)channelID agentID:(NSString *)agentID completionHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    [[ChatCenterClient sharedClient] removeAssigneeFromChannel:channelID agentID:agentID completionHandler:completionHandler];
}

- (void)setFollowerForChannel:(NSString *)channelID agentID:(NSString *)agentID completionHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    [[ChatCenterClient sharedClient] setFollowerForChannel:channelID agentID:agentID completionHandler:completionHandler];
}

- (void)removeFollowerFromChannel:(NSString *)channelID agentID:(NSString *)agentID completionHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    [[ChatCenterClient sharedClient] removeFollowerFromChannel:channelID agentID:agentID completionHandler:completionHandler];
}


# pragma mark - Delete Data

-(BOOL)signOut{
    self.isDataSynchronized = NO;
    [[ChatCenter sharedInstance] clearUnreadMessages];
    [[CCConstants sharedInstance] setKeychainToken:nil];
    [[CCConstants sharedInstance] setKeychainUid:nil];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"familyName"];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"firstName"];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"email"];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"provider"];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"providerToken"];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"providerTokenSecret"];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"providerCreatedAt"];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"providerExpiresAt"];
    
    if([CCConstants sharedInstance].isAgent == YES){
        [ChatCenterClient sharedClient].appToken = nil;
        [CCConstants sharedInstance].apps = nil;
        [CCConstants sharedInstance].appName = nil;
        [CCConstants sharedInstance].stickers = nil;
        [CCConstants sharedInstance].businessType = nil;
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud removeObjectForKey:@"ChatCenterUserdefaults_currentOrgUid"];
        [ud removeObjectForKey:@"ChatCenterUserdefaults_currentAppUid"];
        [ud removeObjectForKey:kCCUserDefaults_userId];
    }
    
    if ([[CCCoredataBase sharedClient] deleteAllChannel] &&
        [[CCCoredataBase sharedClient] deleteAllMessages] &&
        [[CCCoredataBase sharedClient] deleteAllOrg]){
        return YES;
    }else{
        return NO;
    }
}

# pragma mark - Connect Websocket

-(void)connectWebSocket{ //connect channels
    [[CCSRWebSocket sharedInstance] reconnect];
}

# pragma mark - Refresh data
- (void)reloadChannelsAndConnectWebSocket{
    [self loadChannelsAndConnectWebSocket:YES getChennelType:CCGetChannelsMine isOrgChange:NO org_uid:nil completionHandler:^(NSString *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        if (error != nil) {
            if ([[CCConnectionHelper sharedClient] isAuthenticationError:operation] == YES){
                if ([self.delegate respondsToSelector:@selector(closeChatView)]){
                    [self displayAuthenticationErrorAlert];
                }
            }
        }else {
            [self checkNetworkStatus];
        }
        self.isRefreshingData = NO;
    }];
}

-(void)reloadOrgsAndChannelsAndConnectWebSocket{
    ///App must be specified
    if ([CCConstants sharedInstance].apps.count == 0) {
        self.isRefreshingData = NO;
        return;
    }
    
    [self loadOrgsAndChannelsAndConnectWebSocket:YES getChennelType:CCGetChannels isOrgChange:NO completionHandler:^(NSString *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        if (error != nil) {
            if ([[CCConnectionHelper sharedClient] isAuthenticationError:operation] == YES){
                if ([self.delegate respondsToSelector:@selector(closeChatView)]){
                    [self displayAuthenticationErrorAlert];
                }
            }
        }else {
            [self checkNetworkStatus];
        }
        self.isRefreshingData = NO;
    }];
}

- (void)refreshData{
    if (self.isRefreshingData == YES || [[CCConstants sharedInstance] getKeychainToken] == nil) return;
    self.isRefreshingData = YES;

    if(self.isDataSynchronized == NO || self.webSocketStatus == CCCWebSocketClosed){
        if ([CCConstants sharedInstance].isAgent == YES) {
            [self reloadOrgsAndChannelsAndConnectWebSocket];
        }else{
            [self reloadChannelsAndConnectWebSocket];
        }
    }else{
        self.isRefreshingData = NO;
    }
}

- (void)deleteAllData{
    [[CCConstants sharedInstance] setKeychainToken:nil];
    [[CCConstants sharedInstance] setKeychainUid:nil];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"familyName"];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"firstName"];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"email"];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"provider"];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"providerToken"];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"providerTokenSecret"];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"providerCreatedAt"];
    [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"providerExpiresAt"];
    [[CCCoredataBase sharedClient] deleteAllChannel];
    [[CCCoredataBase sharedClient] deleteAllMessages];
    [[CCCoredataBase sharedClient] deleteAllOrg];
}

- (void)coredataMigration:(void (^)(void))completionHandler{
    if ([[CCCoredataBase sharedClient] isRequiredMigration] == YES) {
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Data Loading...") maskType:SVProgressHUDMaskTypeBlack];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{[[CCCoredataBase sharedClient] doMigration];
            dispatch_async(dispatch_get_main_queue(), ^{
                [CCSVProgressHUD dismiss];
                if(completionHandler != nil) completionHandler();
            });
        });
    }else{
        if(completionHandler != nil) completionHandler();
    }
}

# pragma mark - Authentication
- (BOOL)isAuthenticationError:(CCAFHTTPRequestOperation *)operation{
    NSInteger statusCode = [operation.response statusCode];
    if (statusCode == 401) {
        [[CCConnectionHelper sharedClient] signOut];
        return YES;
    }
    return NO;
}

- (BOOL)isAuthenticationErrorWithEmptyuser:(CCAFHTTPRequestOperation *)operation{
    NSInteger statusCode = [operation.response statusCode];
    if (statusCode == 405) {
        return YES;
    }
    return NO;
}

//- (void)reAuthentication:(NSError *)error completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
//    if ([self isAuthenticationError:operation] == YES){
//        [self loadUserToken:[CCSSKeychain passwordForService:@"ChatCenter" account:@"email"]
//                   password:[CCSSKeychain passwordForService:@"ChatCenter" account:@"password"]
//                   provider:self.provider
//              providerToken:self.providerToken
//          providerCreatedAt:self.providerCreatedAt
//               showProgress:NO
//          completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
//            if(error == nil){
//                completionHandler(result, nil, operation);
//            }else{
//                completionHandler(nil, error, operation);
//                [[CCConstants sharedInstance] setKeychainToken:nil];
//                [[CCConstants sharedInstance] setKeychainUid:nil];
//                [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"firstName"];
//                [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"familyName"];
//                [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"email"];
//                if ([self.delegate respondsToSelector:@selector(pressClose:)]){
//                    [self.delegate pressClose:nil];
//                }
//            }
//        }];
//    }else{
//        completionHandler(nil, error, nil);
//    }
//}

-(BOOL)isUpdatedProviderCreatedAt{
    if (self.providerOldCreatedAt != nil && [self.providerCreatedAt isEqualToString:self.providerOldCreatedAt] == NO){
        return YES;
    }
    return NO;
}

-(BOOL)isUpdatedProviderExpiresAt{
    if (self.providerOldExpiresAt != nil && [self.providerExpiresAt isEqualToString:self.providerOldExpiresAt] == NO){
        return YES;
    }
    return NO;
}

-(BOOL)isExpiredProviderToken{
    NSString *providerCreatedAt = [CCConnectionHelper sharedClient].providerCreatedAt;
    double providerCreatedAtDouble = providerCreatedAt.doubleValue;
    NSDate *providerCreatedAtDate = [NSDate dateWithTimeIntervalSince1970:providerCreatedAtDouble];
    NSDate *date             = [NSDate date];
    float passedTime         = [date timeIntervalSinceDate:providerCreatedAtDate];
    int passedTimehh         = (int)(passedTime / 3600);
    int providerAuthPeriodhh = CCProviderAuthPeriod*24;
    if(providerAuthPeriodhh < passedTimehh){
        return YES;
    }
    return NO;
}

-(void)closeChatWindow{
    if ([self.delegate respondsToSelector:@selector(pressClose:)]){
        [self.delegate pressClose:nil];
    }
}

- (void)signInDeviceTokenWithAuthToken:(NSString *)deviceToken
                     completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler
{
    [[ChatCenterClient sharedClient] signInDeviceTokenWithAuthToken:deviceToken
                                                  completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation)
    {
        if(completionHandler != nil) completionHandler(result, error);
    }];
}

- (void)signOutDeviceToken:(NSString *)deviceToken
         completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler
{
    [[ChatCenterClient sharedClient] signOutDeviceToken:deviceToken
                                      completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation)
    {
        if(completionHandler != nil) completionHandler(result, error);
    }];
}

# pragma mark - Toast & Alert
///set View which is displayed alert
-(void)setCurrentView:(UIViewController *)currentView{
    _currentView = currentView;
    if ([self getNetworkStatus] == CCNotReachable && offlineDevelopmentMode == NO) { //offline
        [self hideToast];
        [self makeToast:@"Can not make connection" message:CCLocalizedString(@"Can not make connection") duration:1000 backgroundColor:[UIColor redColor]];
    }
}

-(void)makeToast:(NSString *)title message:(NSString *)message duration:(NSTimeInterval)duration backgroundColor:(UIColor *)backgroundColor{
    //CustomView
    if (self.currentView != nil) {
        toastView = [[UIView alloc] init];
        [toastView setBackgroundColor:backgroundColor];
        UITextView *textView = [[UITextView alloc] init];
        textView.text = message;
        textView.textColor = [UIColor whiteColor];
        textView.textAlignment = NSTextAlignmentCenter;
        textView.backgroundColor =[UIColor clearColor];
        textView.font = [UIFont boldSystemFontOfSize:14];
        textView.editable = NO;
        [toastView addSubview:textView];
        [self.currentView.view showToast:toastView
                                duration:duration
                                position:CSToastPositionTop
         ];
        CGFloat layoutTopConstant;
        if([[CCConstants sharedInstance] headerTranslucent] == YES){
            layoutTopConstant = 64;
        }else{
            layoutTopConstant = 0;
        }
        NSLayoutConstraint *layoutTop =
        [NSLayoutConstraint constraintWithItem:toastView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.currentView.view
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:layoutTopConstant];
        NSLayoutConstraint *layoutWidth =
        [NSLayoutConstraint constraintWithItem:toastView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.currentView.view
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:1.0
                                      constant:0];
        NSLayoutConstraint *layoutHeight =
        [NSLayoutConstraint constraintWithItem:toastView
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeHeight
                                    multiplier:1.0
                                      constant:32];
        NSArray *layoutConstraints = @[layoutTop,
                                       layoutWidth,
                                       layoutHeight];
        [toastView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.currentView.view addConstraints:layoutConstraints];
        
        NSLayoutConstraint *textViewLayoutTop =
        [NSLayoutConstraint constraintWithItem:textView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:toastView
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0];
        NSLayoutConstraint *textViewLayoutWidth =
        [NSLayoutConstraint constraintWithItem:textView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:toastView
                                     attribute:NSLayoutAttributeWidth
                                    multiplier:1.0
                                      constant:0];
        NSLayoutConstraint *textViewLayoutHeight =
        [NSLayoutConstraint constraintWithItem:textView
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeHeight
                                    multiplier:1.0
                                      constant:32];
        NSLayoutConstraint *textViewLayoutCenter =
        [NSLayoutConstraint constraintWithItem:textView
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:toastView
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1.0
                                      constant:0];
        NSArray *textViewLayoutConstraints = @[textViewLayoutTop,
                                       textViewLayoutWidth,
                                       textViewLayoutHeight,
                                       textViewLayoutCenter];
        [textView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.currentView.view addConstraints:textViewLayoutConstraints];
        
    }
}

-(void)hideToast{
    if(toastView != nil){
        if (self.currentView != nil) {
            [self.currentView.view hideToast:toastView];
        }
    }
}

-(void)displayAuthenticationErrorAlert{
//    [self displyAlert:nil message:CCLocalizedString(@"You are logout, please login") alertType:SingleButtonAlert];
    if (self.currentView == nil) return;
    
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(osVersion >= 8.0f)  { ///iOS8
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:CCLocalizedString(@"You are logout, please login") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self closeChatWindow];
            if ([ChatCenter sharedInstance].delegate != nil && [[ChatCenter sharedInstance].delegate respondsToSelector:@selector(authenticationErrorAlertClosed)]) {
                [[ChatCenter sharedInstance].delegate authenticationErrorAlertClosed];
            }
        }]];
        [self.currentView presentViewController:alertController animated:YES completion:nil];
    }else{ ///iOS7
        UIAlertView *alertView;
                alertView = [[UIAlertView alloc] initWithTitle:nil
                                                       message:CCLocalizedString(@"You are logout, please login")
                                                      delegate:self
                                             cancelButtonTitle:CCLocalizedString(@"OK")
                                             otherButtonTitles:nil, nil];
        alertView.tag = authenticationAlertTag;
        [alertView show];
    }
}

-(void)displyAlert:(NSString *)title message:(NSString *)message alertType:(CCAlertType)alertType{
    if (self.currentView == nil) return;
    
    
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(osVersion >= 8.0f)  { ///iOS8
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        switch (alertType) {
            case SingleButtonAlert:
                [alertController addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil]];
                break;
            case DoubbleButtonAlert:
                [alertController addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleDefault handler:nil]];
                [alertController addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil]];
                break;
        }
        [self.currentView presentViewController:alertController animated:YES completion:nil];
    }else{ ///iOS7
        UIAlertView *alertView;
        switch (alertType) {
            case SingleButtonAlert:
                alertView = [[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:CCLocalizedString(@"OK")
                                             otherButtonTitles:nil, nil];
                break;
            case DoubbleButtonAlert:
                alertView = [[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:self
                                             cancelButtonTitle:CCLocalizedString(@"cancel")
                                             otherButtonTitles:CCLocalizedString(@"OK"), nil];
                break;
        }
        alertView.tag = normalAlertTag;
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(authenticationAlertTag == alertView.tag){
        [self closeChatWindow];
        if ([ChatCenter sharedInstance].delegate != nil && [[ChatCenter sharedInstance].delegate respondsToSelector:@selector(authenticationErrorAlertClosed)]) {
            [[ChatCenter sharedInstance].delegate authenticationErrorAlertClosed];
        }
    }
}

#pragma mark - Reachability

- (CCNetworkStatusType)getNetworkStatus{
    if([CCAFNetworkReachabilityManager sharedManager].reachable) {
        if([CCAFNetworkReachabilityManager sharedManager].isReachableViaWiFi) {
            return CCReachableViaWiFi; // Wifi
        } else {
            return CCReachableViaWWAN; // WWAN
        }
    } else {
        return CCNotReachable; //Offline
    }
}

-(void)notifiedNetworkStatus:(NSNotification *)notification {
    self.networkStatus = [self getNetworkStatus];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (offlineDevelopmentMode == NO) {
            switch (_networkStatus) {
                case CCNotReachable:      //Offline
                    [self hideToast];
                    [self makeToast:@"Can not make connection" message:CCLocalizedString(@"Can not make connection") duration:99999 backgroundColor:[UIColor redColor]];
                    break;
                case CCReachableViaWWAN:  //3G or 4G
                    [self refreshData];
                    break;
                case CCReachableViaWiFi:  //WiFi
                    [self refreshData];
                    break;
                default:                  //Other
                    break;
            }
        }
    });
}

- (void)checkNetworkStatus {
    if ([self getNetworkStatus] == CCNotReachable && offlineDevelopmentMode == NO) {
        [self hideToast];
        [self makeToast:@"Can not make connection" message:CCLocalizedString(@"Can not make connection") duration:99999 backgroundColor:[UIColor redColor]];
    }
}

- (void)getApps:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    [[ChatCenterClient sharedClient] getApps:^(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        if (result != nil) {
            [CCConstants sharedInstance].apps = result;
            if(completionHandler != nil) completionHandler(result, nil, operation);
        }else{
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

- (void)getAppManifest:(BOOL)showProgress
     completionHandler:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    if (showProgress == YES && self.currentView != nil) {
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading...") maskType:SVProgressHUDMaskTypeBlack];
    }
    [[ChatCenterClient sharedClient]getAppManifest:^(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        if(showProgress == YES && self.currentView != nil){
            [CCSVProgressHUD dismiss];
        }
        if (result != nil) {
            for (NSDictionary *app in result) {
                if(app[@"token"] == nil || [app[@"token"] isEqual:[NSNull null]]){
                    continue;
                }
                if([app[@"token"] isEqualToString:[ChatCenterClient sharedClient].appToken])
                {
                    if(app[@"name"] != nil && ![app[@"name"] isEqual:[NSNull null]]){
                        [[CCConstants sharedInstance] setAppName:app[@"name"]];
                    }
                    if(app[@"stickers"] != nil && ![app[@"stickers"] isEqual:[NSNull null]]){
                        [[CCConstants sharedInstance] setStickers:app[@"stickers"]];
                    }
                    if(app[@"business_type"] != nil && ![app[@"business_type"] isEqual:[NSNull null]]){
                        [[CCConstants sharedInstance] setBusinessType:app[@"business_type"]];
                    }
                    if(app[@"read_for_guest"] != nil && ![app[@"read_for_guest"] isEqual:[NSNull null]]) {
                        BOOL value = [app[@"read_for_guest"] boolValue];
                        [[CCConstants sharedInstance] setShowReadStatusForGuest:value];
                    }
                }
            }
            if(completionHandler != nil) completionHandler(result, nil, operation);
        }else{
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}
- (void)sendMessageResponseForChannel:(NSString *)channelId answer:(NSObject *)answer answerLabel:(NSString *)answerLabel replyTo:(NSString *)replyTo completionHandler:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler {
    [[ChatCenterClient sharedClient] sendMessageResponseForChannel:channelId answer:answer answerLabel:answerLabel replyTo:replyTo completionHandler:^(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        if (result != nil) {
            if (completionHandler != nil) completionHandler(result, nil, operation);
        }else {
            [self checkNetworkStatus];
            if (completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

-(void)sendSuggestionMessage:(NSString *)channelId answer:(NSObject *)answer text:(NSString *)text replyTo:(NSString *)replyTo completionHandler:(void (^)(NSArray *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    [[ChatCenterClient sharedClient] sendSuggestionMessage:channelId answer:answer text:text replyTo:replyTo completionHandler:^(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        if (result != nil) {
            if (completionHandler != nil) completionHandler(result, nil, operation);
        }else {
            [self checkNetworkStatus];
            if (completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

#pragma mark - Video Call
- (void)getCallIdentity:(NSString *)channelId callerInfo:(NSDictionary *)callerInfo receiverInfo:(NSArray *)receiversInfo actionCall:(NSString *)actionCall completeHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completeHandler {
    [[ChatCenterClient sharedClient] getCallIdentity:channelId callerInfo:callerInfo receiverInfo:receiversInfo callAction:actionCall completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        [CCSVProgressHUD dismiss];
        if (result != nil) {
            if(completeHandler != nil) completeHandler(result, nil, operation);
        }else{
            [self checkNetworkStatus];
            if(completeHandler != nil) completeHandler(nil, error, operation);
        }
    }];
}

- (void)acceptCall:(NSString *)channelId
         messageId:(NSString *)messageId
              user:(NSDictionary *)user
 completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler {
    [[ChatCenterClient sharedClient] acceptCall:channelId messageId:messageId user:user completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        [CCSVProgressHUD dismiss];
        if (result != nil) {
            if(completionHandler != nil) completionHandler(result, nil, operation);
        }else{
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

- (void)rejectCall:(NSString *)channelId
         messageId:(NSString *)messageId
            reason:(NSDictionary *)reason
              user:(NSDictionary *)user
 completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler {
    [[ChatCenterClient sharedClient] rejectCall:channelId messageId:messageId reason:reason user:user completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        [CCSVProgressHUD dismiss];
        if (result != nil) {
            if(completionHandler != nil) completionHandler(result, nil, operation);
        }else{
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}

- (void)hangupCall:(NSString *)channelId
                              messageId:(NSString *)messageId
                                user:(NSDictionary *)user
                   completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler {
    [[ChatCenterClient sharedClient] hangupCall:channelId messageId:messageId user:user completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        [CCSVProgressHUD dismiss];
        if (result != nil) {
            if(completionHandler != nil) completionHandler(result, nil, operation);
        }else{
            [self checkNetworkStatus];
            if(completionHandler != nil) completionHandler(nil, error, operation);
        }
    }];
}
@end
