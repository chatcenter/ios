//
//  CCSRWebSocket.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2014/10/03.
//  Copyright (c) 2014年 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCSRWebSocket : NSObject

@property (nonatomic, copy) void (^didReceiveMessageCallback)(NSString *type, NSNumber *uid, NSDictionary *content, NSString *channelId, NSString *userUid, NSDate *date, NSString *displayName, NSString *userIconUrl, NSDictionary *answer);
@property (nonatomic, copy) void (^didReceiveJoinCallback)(NSString *channelId, BOOL newChannel);
@property (nonatomic, copy) void (^didReceiveOnlineCallback)(NSString *channelUid, NSDictionary *user);
@property (nonatomic, copy) void (^didReceiveReceiptCallback)(NSString *channelId, NSArray *messages, NSString *userUid, BOOL userAdmin);
@property (nonatomic, copy) void (^didReceiveFollowCallback)(NSString *channelUid);
@property (nonatomic, copy) void (^didReceiveUnfollowCallback)(NSString *channelUid);
@property (nonatomic, copy) void (^didFailWithErrorOrClosedCallback)(NSError *error, NSString *reason);
@property (nonatomic, copy) void (^webSocketDidOpenCallback)(void);
@property (nonatomic, copy) void (^didReceiveAssignedCallback)(NSString *channelUid);
@property (nonatomic, copy) void (^didReceiveUnassignedCallback)(NSString *channelUid);
@property (nonatomic, copy) void (^didReceiveInviteCallCallback) (NSString *messageId, NSDictionary *content);
@property (nonatomic, copy) void (^didReceiveCallEventCallback) (NSString *messageId, NSDictionary *content);
@property (nonatomic, copy) void (^didReceiveDeleteChannelCallback)(void);

+ (CCSRWebSocket *)sharedInstance;
- (void)reconnect;
- (void)disconnect;

@end
