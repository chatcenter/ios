//
//  CCConnectionHelper.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2014/12/05.
//  Copyright (c) 2014年 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCHistoryViewController.h"
#import "CCConectionHelperDelegate.h"
//#import "NSURLSessionDataTaskManager.h"

static const NSInteger normalAlertTag = 1;
static const NSInteger authenticationAlertTag = 2;

typedef enum {
    CCNotReachable,
    CCReachableViaWiFi,
    CCReachableViaWWAN,
} CCNetworkStatusType;

typedef enum {
    CCCWebSocketOpened,
    CCCWebSocketClosed,
} CCWebSocketStatusType;

typedef enum {
    SingleButtonAlert,
    DoubbleButtonAlert,
} CCAlertType;

@interface CCConnectionHelper : NSObject

@property (nonatomic, strong) UIViewController *currentView;
@property (nonatomic, weak) id<CCConectionHelperDelegate> delegate;
@property (nonatomic) CCNetworkStatusType networkStatus;
@property (nonatomic) CCWebSocketStatusType webSocketStatus;
@property (nonatomic) BOOL is_ToastShow;
@property (nonatomic) BOOL refreshLoadAndConnect;
@property (nonatomic) BOOL isDataSynchronized;
@property (nonatomic) BOOL isLoadingUserToken;
@property (nonatomic, strong) NSMutableArray *datepicker;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *provider;
@property (nonatomic, strong) NSString *providerToken;
@property (nonatomic, strong) NSString *providerTokenSecret;
@property (nonatomic, strong) NSString *providerRefreshToken;
@property (nonatomic, strong) NSString *providerCreatedAt;
@property (nonatomic, strong) NSString *providerExpiresAt;
@property (nonatomic, strong) NSString *providerOldCreatedAt;
@property (nonatomic, strong) NSString *providerOldExpiresAt;
@property BOOL twoColumnLayoutMode;
@property BOOL isRefreshingData;
@property (nonatomic, strong) NSMutableDictionary *shareLocationTasks;

+ (CCConnectionHelper *)sharedClient;

- (void)loadChannelsAndConnectWebSocket:(BOOL)showProgress
                         getChennelType:(int)getChennelType
                            isOrgChange:(BOOL)isOrgChange
                                org_uid:(NSString *)org_uid
                      completionHandler:(void (^)(NSString *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)loadOrgsAndChannelsAndConnectWebSocket:(BOOL)showProgress
                                getChennelType:(int)getChennelType
                                   isOrgChange:(BOOL)isOrgChange
                             completionHandler:(void (^)(NSString *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)sendMessageViaWebsocket:(NSString *)wsChannel content:(NSString *)content;

-(void)loadMessages:(NSString *)channelUid
       showProgress:(BOOL)showProgress
              limit:(int)limit
             lastId:(NSNumber *)lastId
  completionHandler:(void (^)(NSString *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

-(void)loadChannels:(BOOL)showProgress
     getChennelType:(int)getChennelType
            org_uid:(NSString *)org_uid
              limit:(int)limit
      lastUpdatedAt:(NSDate *)lastUpdatedAt
  completionHandler:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

-(void)loadChannel:(BOOL)showProgress
        channelUid:(NSString *)channelUid
 completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

-(void)updateChannel:(BOOL)showProgress
          channelUid:(NSString *)channelUid
   completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
-(void)updateChannel:(NSString *)channelId
 channelInformations:(NSDictionary *)channelInformations
                note:(NSString *)note
   completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)loadUserToken:(NSString*)email
             password:(NSString*)password
             provider:(NSString *)provider
        providerToken:(NSString *)providerToken
  providerTokenSecret:(NSString *)providerTokenSecret
 providerRefreshToken:(NSString *)providerRefreshToken
    providerCreatedAt:(NSDate *)providerCreatedAt
    providerExpiresAt:(NSDate *)providerExpiresAt
          deviceToken:(NSString *)deviceToken
         showProgress:(BOOL)showProgress
    completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)loadUserTokenAndOrg:(NSString*)email
                   password:(NSString*)password
               showProgress:(BOOL)showProgress
          completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)loadUser:(BOOL)showProgress
         userUid:(NSString*)userUid
completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)loadUsers:(BOOL)showProgress
completionHandler:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)loadUserMe:(BOOL)showProgress
 completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)loadUserAuth:(NSString*)email
            password:(NSString*)password
            provider:(NSString *)provider
       providerToken:(NSString *)providerToken
 providerTokenSecret:(NSString *)providerTokenSecret
providerRefreshToken:(NSString *)providerRefreshToken
   providerCreatedAt:(NSDate *)providerCreatedAt
   providerExpiresAt:(NSDate *)providerExpiresAt
         deviceToken:(NSString *)deviceToken
        showProgress:(BOOL)showProgress
   completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)loadOrg:(BOOL)showProgress
completionHandler:(void (^)(NSString *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)sendMessage:(NSDictionary *)content
          channelId:(NSString *)channelId
               type:(NSString *)type
  completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)sendFile:(NSString *)channelId
           files:(NSArray *)files
completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)sendMessageReceivedStatus:(NSString *)channelId
                       messageIds:(NSArray *)messageIds;

-(void)sendMessageAnswer:(NSString *)channelId
               messageId:(NSNumber *)messageId
             answer_type:(NSNumber *)answer_type
             question_id:(NSString *)question_id
       completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
-(void)sendSuggestionMessage:(NSString *)channelId answer:(NSObject *)answer text:(NSString *)text replyTo:(NSString *)replyTo completionHandler:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)closeChannels:(NSArray*)channelUids
    completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)openChannels:(NSArray*)channelUids
    completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)deleteChannel:(NSString*)channelUid
   completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)setAssigneeForChannel:(NSString *)channelID agentID:(NSString *)agentID completionHandler:(void(^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)removeAssigneeFromChannel:(NSString *)channelID agentID:(NSString *)agentID completionHandler:(void(^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)setFollowerForChannel:(NSString *)channelID agentID:(NSString *)agentID completionHandler:(void(^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;

- (void)removeFollowerFromChannel:(NSString *)channelID agentID:(NSString *)agentID completionHandler:(void (^)(NSDictionary *, NSError *, NSURLSessionDataTask *))completionHandler;

-(void)loadChannelId:(NSString *)orgUid
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
        showProgress:(BOOL)showProgress
   completionHandler:(void (^)(NSString *channelId, NSError *error, NSURLSessionDataTask *task))completionHandler;

-(void)createChannelWithUsers:(NSString *)orgUid
                      userIds:(NSArray *)userIds
                directMessage:(BOOL)directMessage
                    groupName:(NSString *)groupName
          channelInformations:(NSDictionary *)channelInformations
            completionHandler:(void (^)(NSString *channelId, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)reloadChannelsAndConnectWebSocket;
- (void)reloadOrgsAndChannelsAndConnectWebSocket;
- (BOOL)isAuthenticationError:(NSURLSessionDataTask *)operation;
- (BOOL)isAuthenticationErrorWithEmptyuser:(NSURLSessionDataTask *)operation;
- (CCNetworkStatusType)getNetworkStatus;
- (void)displyAlert:(NSString *)title
            message:(NSString *)message
          alertType:(CCAlertType)alertType;
-(BOOL)isUpdatedProviderCreatedAt;
-(BOOL)isUpdatedProviderExpiresAt;
-(BOOL)isExpiredProviderToken;
-(void)displayAuthenticationErrorAlert;
-(BOOL)signOut;
- (void)refreshData;
- (void)coredataMigration:(void (^)(void))completionHandler;
- (void)signInDeviceTokenWithAuthToken:(NSString *)deviceToken
                     completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler;
- (void)signOutDeviceToken:(NSString *)deviceToken
         completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler;
- (NSString *)addAuthToUrl:(NSString *)url;
- (void)getApps:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)getAppManifest:(BOOL)showProgress
     completionHandler:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)setCurrentApp:(void (^)(BOOL success))completionHandler;

- (void)loadFixedPhrase: (NSString *)orgUid showProgress:(BOOL)showProgress completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
- (void)getOrgOnlineStatus:orgUid completeHandler:(void (^)(BOOL isOnline))completionHandler;
- (void)sendMessageResponseForChannel:(NSString *)channelId answer:(NSObject *)answer answerLabel:(NSString *)answerLabel replyTo:(NSString *)replyTo completionHandler:(void (^)(NSArray *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
-(void)loadBusinessFunnels:(BOOL)showProgress
         completionHandler:(void (^)(NSString *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
-(void)setBusinessFunnelToChannel:(NSString *)channelId
                             funnelId:(NSString *)funnelId
                         showProgress:(BOOL)showProgress
                    completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler;
#pragma mark - Video call
-(void)getCallIdentity:(NSString *)channelId
            callerInfo:(NSDictionary *)callerInfo
          receiverInfo:(NSArray *)receiversInfo
            actionCall:(NSString *)actionCall
       completeHandler:(void (^) (NSDictionary *result, NSError *error, NSURLSessionDataTask *task)) completeHandler;

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
- (BOOL)isSupportVideoChat;
@end
