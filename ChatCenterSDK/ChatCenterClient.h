//
//  ChatCenterClient.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2014/10/04.
//  Copyright (c) 2014年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCAFHTTPSessionManager.h"

@interface ChatCenterClient : CCAFHTTPSessionManager

@property (nonatomic, strong) NSString *appToken;

+ (ChatCenterClient *) sharedClient;
///User
- (void)createGuestUser:(NSString *)orgUid
              firstName:(NSString *)firstName
             familyName:(NSString *)familyName
                  email:(NSString *)email
               provider:(NSString *)provider
          providerToken:(NSString *)providerToken
    providerTokenSecret:(NSString *)providerTokenSecret
   providerRefreshToken:(NSString *)providerRefreshToken
      providerCreatedAt:(NSDate *)providerCreatedAt
      providerExpiresAt:(NSDate *)providerExpiresAt
    channelInformations:(NSDictionary *)channelInformations
            deviceToken:(NSString *)deviceToken
      completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)getUserToken:(NSString*)email
            password:(NSString*)password
            provider:(NSString *)provider
       providerToken:(NSString *)providerToken
 providerTokenSecret:(NSString *)providerTokenSecret
providerRefreshToken:(NSString *)providerRefreshToken
   providerCreatedAt:(NSDate *)providerCreatedAt
   providerExpiresAt:(NSDate *)providerExpiresAt
         deviceToken:(NSString *)deviceToken
   completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)getUser :(NSString*)userUid
completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)getUsers:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)getUserMe:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)getFixedPhrases:(NSString *)orgUid withHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)assignChannel:(NSString *)channelId
              userUid:(NSString *)userUid
    completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)signInDeviceTokenWithAuthToken:(NSString *)deviceToken
                     completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)signOutDeviceToken:(NSString *)deviceToken
         completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
///Message
- (void)sendMessage:(NSDictionary *)content
          channelId:(NSString *)channelId
               type:(NSString *)type
  completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)sendFile:(NSString *)channelId uid:(NSString *)uid
           files:(NSArray *)files
completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)sendMessageStatus:(NSString *)channelId messageIds:(NSArray *)messageIds completionHandler:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
-(void)sendMessageResponseForChannel:(NSString *)channelId msgUid:(NSString *)uid answer:(NSObject *)answer answerLabel:(NSString *)answerLabel replyTo:(NSString *)replyTo completionHandler:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
-(void)sendMessageResponseForChannel:(NSString *)channelId
                              msgUid:(NSString *)uid
                             answers:(NSArray *)answers
                             replyTo:(NSString *)replyTo
                   completionHandler:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
-(void)getMessage:(NSString *)channelId
            limit:(int)limit
           lastId:(NSNumber *)lastId
completionHandler:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
-(void)sendMessageAnswer:(NSString *)channelId
              message_id:(NSNumber *)message_id
             answer_type:(NSNumber *)answer_type
             question_id:(NSString *)question_id
       completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
-(void)sendSuggestionMessage:(NSString *)channelId answer:(NSObject *)answer text:(NSString *)text replyTo:(NSString *)replyTo completionHandler:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
-(void)getMessage:(NSString *)channelId stickerType: (NSString *) stickerType limit:(int)limit lastId:(NSNumber *)lastId completionHandler:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
///Channel
-(void)createChannel:(NSString *)orgUid
 channelInformations:(NSDictionary *)channelInformations
   completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
-(void)updateChannel:(NSString *)channelId
 channelInformations:(NSDictionary *)channelInformations
                note:(NSString *)note
   completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)getChannels:(NSString *) orgUid channelName:(NSString *) channelName limit:(int)limit lastUpdatedAt:(NSDate *)lastUpdatedAt completionHandler:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)createChannel:(NSString*)orgUid
              userIds:(NSArray *)userIds
        directMessage:(BOOL)directMessage
            groupName:(NSString *)groupName
  channelInformations:(NSDictionary *)channelInformations
    completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
-(void)getChannel:(int)getChannelsType
          org_uid:(NSString *)org_uid
            limit:(int)limit
    lastUpdatedAt:(NSDate *)lastUpdatedAt
completionHandler:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)getChannel:(NSString*)channelUid
 completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)closeChannels:(NSArray*)channelUids
    completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)deleteChannel:(NSString*)channelUid
    completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)openChannels:(NSArray*)channelUids
    completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)getChannelCount:(NSString *)orgUid
               funnelId:(NSNumber *)funnelId
      completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)setAssigneeForChannel:(NSString *)channelID agentID: (NSString *) agentID completionHandler:(void (^) (NSDictionary *result, NSError *error,
          NSURLSessionDataTask *task))completionHandler;
- (void)removeAssigneeFromChannel:(NSString *)channelID agentID: (NSString *) agentID completionHandler:(void (^) (NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)setFollowerForChannel:(NSString *)channelID agentID: (NSString *) agentID completionHandler:(void (^) (NSDictionary *result, NSError *error,
                                                                                                               NSURLSessionDataTask *
                                                                                                               task))completionHandler;
- (void)removeFollowerFromChannel:(NSString *)channelID agentID:(NSString *)agentID completionHandler:(void (^)(NSDictionary *, NSError *, NSURLSessionDataTask *))completionHandler;

///Org
- (void)getOrg:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)getOrgOnlineStatus:(NSString*)orgUid completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
///App
- (void)getApps:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)getAppManifest:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
// get google calendar
-(void)getGoolgeCalandar:(NSString*)fromDate toDate:(NSString*)toDate completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler;

#pragma mark - Video Call
- (void) getCallIdentity: (NSString *) channelId
              callerInfo: (NSDictionary *) callerInfo
            receiverInfo: (NSArray *) receiversInfor
              callAction: (NSString *) callAction
       completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)acceptCall:(NSString *)channelId
         messageId:(NSString *)messageId
              user:(NSDictionary *)user
 completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)hangupCall:(NSString *)channelId
         messageId:(NSString *)messageId
              user:(NSDictionary *)user
 completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)rejectCall:(NSString *)channelId
         messageId:(NSString *)messageId
            reason:(NSDictionary *)reason
              user:(NSDictionary *)user
 completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

///Business funnel
-(void)getBusinessFunnels:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
-(void)setBusinessFunnelToChannel:(NSString *)channelId
                         funnelId:(NSString *)funnelId
                     showProgress:(BOOL)showProgress
                completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

//Video chat
- (BOOL)isSupportVideoChat;

// Landing page
- (void)sendLandingPageUrl:(NSString *)channelUid userId:(NSString *)userId completionHandler:(void (^)(NSDictionary *, NSError *, NSURLSessionDataTask *))completionHandler;
- (void)sendLandingPageQRCode:(NSString *)channelUid userId:(NSString *)userId completionHandler:(void (^)(NSDictionary *, NSError *, NSURLSessionDataTask *))completionHandler;
#pragma mark - Watch api
- (void)loadFixedPhraseAndUnreadChannels:(void (^)(NSDictionary *, NSError *, NSURLSessionDataTask *))completionHandler;
@end
