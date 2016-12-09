//
//  ChatCenterPrivate.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/03/21.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatCenter.h"

#define CCLocalizedString(key)  [ChatCenter localizedStringForKey:key]
#define kLoacalizeResourceName      @"ChatCenterSDK"

@interface ChatCenter(PrivateMethods)

@property (nonatomic, strong) NSMutableDictionary *unreadMessages;
@property (nonatomic, strong) NSMutableArray *channelColorList;

+ (NSString *)localizedStringForKey:(NSString *)key;
- (UIImage *)createAvatarImage:(NSString *)text width:(CGFloat)width height:(CGFloat)height color:(UIColor *)color fontSize:(CGFloat)fontSize textOffset:(CGFloat)textOffset;
- (UIColor *)getRandomColor:(NSString *)userUid;
- (void)clearUnreadMessage:(NSString *)channelUid;
- (void)countUpUnreadMessage:(NSString *)channelUid;
- (void)closeChatAndHistoryViewFromViewController;
- (void)openChatHistoryAndChatView;
- (void)clearUnreadMessages;
- (BOOL)isLocaleJapanese;
//--------------------------------------------------------------------
//
// Only for specific apps
//
//--------------------------------------------------------------------
// Get getChatAndHistoryViewController
- (void)getChatAndHistoryViewController:(CCChannelType)channelType
                                userUid:(NSNumber *)userUid
                                  token:(NSString *)token
                       closeViewHandler:(void (^)(void))closeViewHandler
                      completionHandler:(void (^)(id chatAndHistoryView))completionHandler;
// Login with ChatCenter(Get viewController)
- (void)getHistoryView:(CCChannelType)channelType
               userUid:(NSNumber *)userUid
                 token:(NSString *)token
      closeViewHandler:(void (^)(void))closeViewHandler
     completionHandler:(void (^)(id historyView))completionHandler;
+ (void)setHideChatViewCloseBtn:(BOOL)hideChatViewCloseBtn;
- (void)setOrgId:(NSString *)orgUid;
- (void)isTokenVailid:(void (^)(BOOL result))completionHandler;
- (void)loadUserAuth:(NSString*)email
            password:(NSString*)password
            provider:(NSString *)provider
       providerToken:(NSString *)providerToken
 providerTokenSecret:(NSString *)providerTokenSecret
   providerCreatedAt:(NSDate *)providerCreatedAt
   providerExpiresAt:(NSDate *)providerExpiresAt
         deviceToken:(NSString *)deviceToken
        showProgress:(BOOL)showProgress
   completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler;
- (void)registerDeviceToken:(NSString *)deviceToken
          completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler;
+ (void)setHideChatViewPhoneBtn:(BOOL)hideChatViewPhoneBtn;
+ (void)setInfoBtnImage: (NSString *)normal hilighted:(NSString *)hilighted disable:(NSString *)disable;
+ (void)setAppIconName:(NSString *)setAppIconName;
+ (void)setSendButtonColor:(UIColor *)sendButtonColor;
+ (void)setLeftMenuViewSelectColor:(UIColor *)leftMenuViewSelectColor;

@end
