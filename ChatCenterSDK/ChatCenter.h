//
//  ChatCenter.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/02/15.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatCenterDelegate.h"

typedef enum {
    CCUnarchivedChannel,
    CCArchivedChannel,
    CCAllChannel,
} CCChannelType;

@interface ChatCenter : NSObject

@property (nonatomic, weak) id<ChatCenterDelegate> delegate;

+ (ChatCenter *)sharedInstance;

//--------------------------------------------------------------------
//
// 1. Initialize
//
//--------------------------------------------------------------------
+ (void)setAppToken:(NSString *)appToken completionHandler:(void (^)(void))completionHandler;



//--------------------------------------------------------------------
//
// 2. Chat View
//
//--------------------------------------------------------------------

//--------------------------------------------------------------------
// 2-1. Login with Provider
//--------------------------------------------------------------------
// Get viewController
- (id)getChatView:(NSString *)orgUid
         provider:(NSString *)provider
    providerToken:(NSString *)providerToken
providerTokenSecret:(NSString *)providerTokenSecret
providerCreatedAt:(NSDate *)providerCreatedAt
providerExpiresAt:(NSDate *)providerExpiresAt
channelInformations:(NSDictionary *)channelInformations
      deviceToken:(NSString *)deviceToken
completionHandler:(void (^)(void))completionHandler;
- (id)getChatView:(NSString *)orgUid
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
completionHandler:(void (^)(void))completionHandler;
// Present viewController
- (void)presentChatView:(UIViewController *)viewController
                 orgUid:(NSString *)orgUid
               provider:(NSString *)provider
          providerToken:(NSString *)providerToken
    providerTokenSecret:(NSString *)providerTokenSecret
      providerCreatedAt:(NSDate *)providerCreatedAt
      providerExpiresAt:(NSDate *)providerExpiresAt
    channelInformations:(NSDictionary *)channelInformations
            deviceToken:(NSString *)deviceToken
      completionHandler:(void (^)(void))completionHandler;
- (void)presentChatView:(UIViewController *)viewController
                 orgUid:(NSString *)orgUid
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
      completionHandler:(void (^)(void))completionHandler;
//--------------------------------------------------------------------
// 2-2. Login with Anonymous
//--------------------------------------------------------------------
// Get viewController
- (id)getChatView:(NSString *)orgUid
        firstName:(NSString *)firstName
       familyName:(NSString *)familyName
            email:(NSString *)email
channelInformations:(NSDictionary *)channelInformations
      deviceToken:(NSString *)deviceToken
completionHandler:(void (^)(void))completionHandler;
// Present viewController
- (void)presentChatView:(UIViewController *)viewController
                 orgUid:(NSString *)orgUid
              firstName:(NSString *)firstName
             familyName:(NSString *)familyName
                  email:(NSString *)email
    channelInformations:(NSDictionary *)channelInformations
            deviceToken:(NSString *)deviceToken
      completionHandler:(void (^)(void))completionHandler;



//--------------------------------------------------------------------
//
// 3. History View
//
//--------------------------------------------------------------------

//--------------------------------------------------------------------
// 3-1. Login with Provider
//--------------------------------------------------------------------
// Get viewController
- (id)getHistoryView:(NSString *)provider
       providerToken:(NSString *)providerToken
 providerTokenSecret:(NSString *)providerTokenSecret
   providerCreatedAt:(NSDate *)providerCreatedAt
   providerExpiresAt:(NSDate *)providerExpiresAt
   completionHandler:(void (^)(void))completionHandler;
- (id)getHistoryView:(CCChannelType)channelType
            provider:(NSString *)provider
       providerToken:(NSString *)providerToken
 providerTokenSecret:(NSString *)providerTokenSecret
   providerCreatedAt:(NSDate *)providerCreatedAt
   providerExpiresAt:(NSDate *)providerExpiresAt
   completionHandler:(void (^)(void))completionHandler;
// Present viewController
- (void)presentHistoryView:(UIViewController *)viewController
               channelType:(CCChannelType)channelType
                  provider:(NSString *)provider
             providerToken:(NSString *)providerToken
       providerTokenSecret:(NSString *)providerTokenSecret
         providerCreatedAt:(NSDate *)providerCreatedAt
         providerExpiresAt:(NSDate *)providerExpiresAt
         completionHandler:(void (^)(void))completionHandler;
//--------------------------------------------------------------------
// 3-2. Login with Anonymous
//--------------------------------------------------------------------
// Get viewController
- (id)getHistoryView:(void (^)(void))completionHandler;
- (id)getHistoryView:(CCChannelType)channelType
      completionHandler:(void (^)(void))completionHandler;
// Present viewController
- (void)presentHistoryView:(UIViewController *)viewController
               channelType:(CCChannelType)channelType
         completionHandler:(void (^)(void))completionHandler;



//--------------------------------------------------------------------
//
// 4. SignIn/SignOut
//
//--------------------------------------------------------------------
- (void)signInDeviceToken:(NSString*)email
                 password:(NSString*)password
                 provider:(NSString *)provider
            providerToken:(NSString *)providerToken
      providerTokenSecret:(NSString *)providerTokenSecret
        providerCreatedAt:(NSDate *)providerCreatedAt
        providerExpiresAt:(NSDate *)providerExpiresAt
              deviceToken:(NSString *)deviceToken
        completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler;
- (void)signInWithAnonymous;
- (void)signOutDeviceToken:(NSString *)deviceToken
         completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler;
- (BOOL)signOut;



//--------------------------------------------------------------------
//
// 5. Utilities
//
//--------------------------------------------------------------------
- (NSUInteger)unreadMessageCount;
- (NSUInteger)unreadChannelCount;
- (BOOL)isUnreadMessageCount;
- (BOOL)hasChatUser;
- (BOOL)hasChannel:(NSString *)orgUid;
- (BOOL)isDebug;
- (void)isOrgOnline:orgUid completeHandler:(void (^)(BOOL isOnline))completionHandler;



//--------------------------------------------------------------------
//
// 6. Design customize
//
//--------------------------------------------------------------------
+ (void)setBaseColor:(UIColor *)baseColor;
//--------------------------------------------------------------------
// ChatView and HistoryView
//--------------------------------------------------------------------
+ (void)setHeaderBarStyle:(UIBarStyle)headerBarStyle;
+ (void)setHeaderTranslucent:(BOOL)headerTranslucent;
+ (void)setHeaderItemColor:(UIColor *)headerItemColor;
+ (void)setHeaderBackgroundColor:(UIColor *)headerBackgroundColor;
+ (void)setCloseBtnImage:(NSString *)normal hilighted:(NSString *)hilighted disable:(NSString *)disable;
+ (void)setBackBtnImage:(NSString *)normal hilighted:(NSString *)hilighted disable:(NSString *)disable;
//--------------------------------------------------------------------
// ChatView
//--------------------------------------------------------------------
+ (void)setVoiceCallBtnImage:(NSString *)normal hilighted:(NSString *)hilighted disable:(NSString *)disable;
+ (void)setVideoCallBtnImage:(NSString *)normal hilighted:(NSString *)hilighted disable:(NSString *)disable;
//--------------------------------------------------------------------
// HistoryView
//--------------------------------------------------------------------
+ (void)setHistoryViewTitle:(NSString *)historyViewTitle;
+ (void)setHistoryViewVoidMessage:(NSString *)historyViewVoidMessage;

@end
