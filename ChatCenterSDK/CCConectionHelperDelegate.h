//
//  CCConectionHelperDelegate.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/01/16.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#ifndef ChatCenterDemo_CCConectionHelperDelegate_h
#define ChatCenterDemo_CCConectionHelperDelegate_h
@protocol CCConectionHelperDelegate <NSObject>
 @required
    - (void)loadLocalData:(BOOL)isOrgChange;
    - (void)receiveChannelJoinFromWebSocket:(NSString *)channelId newChannel:(BOOL)newChannel;
    - (void)receiveChannelOnlineFromWebSocket:(NSString *)channelUid user:(NSDictionary *)user;
    - (void)receiveMessageFromWebSocket:(NSString *)messageType
                                    uid:(NSNumber *)uid
                                content:(NSDictionary *)content
                              channelId:(NSString *)channelId
                                userUid:(NSString *)userUid
                                   date:(NSDate *)date
                            displayName:(NSString *)displayName
                            userIconUrl:(NSString *)userIconUrl
                              userAdmin:(BOOL)userAdmin
                                 answer:(NSDictionary *)answer;
    - (void)receiveReceiptFromWebSocket:(NSString *)channelUid
                               messages:(NSArray *)messages
                                userUid:(NSString *)userUid
                              userAdmin:(BOOL)userAdmin;
    - (void)receiveAssignFromWebSocket:(NSString *)channelUid;
    - (void)receiveUnassignFromWebSocket:(NSString *)channelUid;
    - (void)receiveFollowFromWebSocket:(NSString *)channelUid;
    - (void)receiveUnfollowFromWebSocket:(NSString *)channelUid;
    - (void)receiveInviteCall:(NSString *)messageId channelId:(NSString *)channelId content:(NSDictionary *) content;
    - (void)receiveCallEvent:(NSString *)messageId content:(NSDictionary *) content;
    - (void)closeChatView;
    - (void)reloadLocalDataWhenComeOnline;
    - (void)receiveMessageTypingFromWebSocket:(NSString *)channelUid user:(NSDictionary *)user;
    - (void)receiveDeleteChannelFromWebSocket:(NSString *)channelUid;
    - (void)receiveCloseChannelFromWebSocket:(NSString *)channelUid;
 @optional
    - (void)initView;
    - (void)pressClose:(id)sender;
    - (void)loadLocalChannels;
    - (void)finishedLoadingUserToken;
@end
#endif
