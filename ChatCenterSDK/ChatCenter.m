//
//  ChatCenter.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/02/15.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "ChatCenter.h"
#import "ChatCenterPrivate.h"
#import "ChatCenterClient.h"
#import "CCConnectionHelper.h"
#import "CCConstants.h"
#import "CCSSKeychain.h"
#import "CCCoredataBase.h"
#import "CCNavigationController.h"

@interface ChatCenter()

@property (nonatomic, strong) NSMutableDictionary *unreadMessages;
@property (nonatomic, strong) NSMutableArray *channelColorList;
@property (nonatomic, strong) UIViewController *lastRootViewController;

@end

@implementation ChatCenter


+ (ChatCenter *)sharedInstance
{
    static ChatCenter *sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [ChatCenter new];
        [sharedClient setUp];
    });
    
    return sharedClient;
}

#pragma mark Private

- (void)setUp{
    [CCSSKeychain setAccessibilityType:kSecAttrAccessibleAlways];
    _unreadMessages = [NSMutableDictionary dictionary];
    self.channelColorList = [NSMutableArray array];
    [CCConnectionHelper sharedClient].twoColumnLayoutMode = NO;
}

#pragma mark Public

+ (void)setAppToken:(NSString *)appToken completionHandler:(void (^)(void))completionHandler
{
    ///Clear keychain on first run, the authnetication of agent(inbox) is done before here
    if (![CCConstants sharedInstance].isAgent && ![[NSUserDefaults standardUserDefaults] objectForKey:@"ChatCenterUserdefaults_firstRun"]) {
        [self deleteKeychainData];
        [[NSUserDefaults standardUserDefaults] setValue:@"firstRun" forKey:@"ChatCenterUserdefaults_firstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[ChatCenterClient sharedClient] setAppToken:appToken];
    [ChatCenterClient sharedClient];
    [self setBaseColor:[CCConstants defaultBaseColor]];
    [self setHeaderBackgroundColor:[CCConstants defaultHeaderBackgroundColor]];
    [self setHeaderItemColor:[CCConstants defaultHeaderItemColor]];
    [self setHeaderTranslucent:[CCConstants defaultHeaderTranslucent]];
    [self setHeaderBarStyle:[CCConstants defaultHeaderBarStyle]];
    [self setSendButtonColor:[CCConstants defaultSendButtonColor]];
    [self setHistoryViewSelectColor:[CCConstants defaultHistoryViewSelectColor]];
    [self setHistoryViewTitle:[CCConstants defaultHistoryViewTitle]];
    [self setChatHeaderBackgroundColor :[CCConstants defaultChatHeaderBackgroundColor]];
    [self setHistoryHeaderBackgroundColor :[CCConstants defaultHistoryHeaderBackgroundColor]];
    [self setHistoryViewVoidMessage:[CCConstants defaultHistoryViewVoidMessage]];
    [self setChatViewCircleAvatarSize:[CCConstants defaultChatViewCircleAvatarSize]];
    [self setHideOutGoingCircleAvatar:[CCConstants defaultHideOutGoingCircleAvatar]];
    [self setHideChatViewPhoneBtn:[CCConstants defaultHideChatViewPhoneBtn]];
    [self setHideChatViewCloseBtn:[CCConstants defaultHideChatViewCloseBtn]];
    [self setInfoBtnImage:CC_INFO_ICON_NORMAL hilighted:nil disable:nil];
    [self setLeftMenuViewSelectColor:[UIColor colorWithRed:214/255.0 green:214/255.0 blue:214/255.0 alpha:1.0]];
    [self setLeftMenuViewNormalColor:[UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1.0]];
    [self setHistoryCellBackgroundColor:[CCConstants defaultHistoryCellBackgroundColor]];
    [self setHistorySelectedCellBackgroundColor:[CCConstants defaultHistorySelectedCellBackgroundColor]];
    [self setHeaderBottomLineColor:[CCConstants defaultHeaderBottomLineColor]];
    [self setBackBtnImage:[CCConstants defaultBackButtonPointer] hilighted:[CCConstants defaultBackButtonPointer] disable:[CCConstants defaultBackButtonPointer]];
    [ChatCenter setAppIconName:CC_APP_ICON_DEFAULT_NAME];
    [self setVoiceCallBtnImage:CC_VOICECALL_ICON_NORMAL hilighted:nil disable:nil];
    [self setVideoCallBtnImage:CC_VIDEOCALL_ICON_NOMAL hilighted:nil disable:nil];
    [[CCConnectionHelper sharedClient] coredataMigration:^{
        [[CCConnectionHelper sharedClient] setWebSocketStatus:CCCWebSocketClosed];
        [[CCConnectionHelper sharedClient] setIsDataSynchronized:NO];
        
        // Getting business funnels.
        if ([CCConstants sharedInstance].isAgent){
            [[CCConnectionHelper sharedClient] loadBusinessFunnels:NO
                                                 completionHandler:nil];
        }
        if(completionHandler != nil)completionHandler();
    }];
}

+ (void)setBaseColor:(UIColor *)baseColor{
    [[CCConstants sharedInstance] setBaseColor:baseColor];
}

+ (void)setHeaderBackgroundColor:(UIColor *)headerBackgroundColor{
    [[CCConstants sharedInstance] setHeaderBackgroundColor:headerBackgroundColor];
}

+ (void)setHeaderItemColor:(UIColor *)headerItemColor{
    [[CCConstants sharedInstance] setHeaderItemColor:headerItemColor];
}

+ (void)setHeaderTranslucent:(BOOL)headerTranslucent{
    [[CCConstants sharedInstance] setHeaderTranslucent:headerTranslucent];
}

+ (void)setHeaderBarStyle:(UIBarStyle)headerBarStyle{
    [[CCConstants sharedInstance] setHeaderBarStyle:headerBarStyle];
}

+ (void)setSendButtonColor:(UIColor *)sendButtonColor{
    [[CCConstants sharedInstance] setSendButtonColor:sendButtonColor];
}

+ (void)setHistoryViewSelectColor:(UIColor *)historyViewSelectColor{
    [[CCConstants sharedInstance] setHistoryViewSelectColor:historyViewSelectColor];
}

+ (void)setLeftMenuViewSelectColor:(UIColor *)leftMenuViewSelectColor{
    [[CCConstants sharedInstance] setLeftMenuViewSelectColor:leftMenuViewSelectColor];
}
+ (void)setLeftMenuViewNormalColor:(UIColor *)leftMenuViewNormalColor{
    [[CCConstants sharedInstance] setLeftMenuViewNormalColor:leftMenuViewNormalColor];
}

+ (void)setHistoryViewTitle:(NSString *)historyViewTitle{
    [[CCConstants sharedInstance] setHistoryViewTitle:historyViewTitle];
}

+ (void)setChatHeaderBackgroundColor:(UIColor *)chatHeaderBackgroundColor{
    [[CCConstants sharedInstance] setChatHeaderBackgroundColor :chatHeaderBackgroundColor];
}

+ (void)setHistoryHeaderBackgroundColor:(UIColor *)historyHeaderBackgroundColor{
    [[CCConstants sharedInstance] setHistoryHeaderBackgroundColor :historyHeaderBackgroundColor];
}

+ (void)setHistoryCellBackgroundColor:(UIColor *)historyCellBackgroundColor{
    [[CCConstants sharedInstance] setHistoryCellBackgroundColor :historyCellBackgroundColor];
}

+ (void)setHistorySelectedCellBackgroundColor:(UIColor *)historySelectedCellBackgroundColor{
    [[CCConstants sharedInstance] setHistorySelectedCellBackgroundColor :historySelectedCellBackgroundColor];
}

+ (void)setHeaderBottomLineColor:(UIColor *)historyHeaderBottomLineColor{
    [[CCConstants sharedInstance] setHeaderBottomLineColor :historyHeaderBottomLineColor];
}

+ (void)setHistoryViewVoidMessage:(NSString *)historyViewVoidMessage{
    [[CCConstants sharedInstance] setHistoryViewVoidMessage:historyViewVoidMessage];
}

+ (void)setChatViewCircleAvatarSize:(CGFloat)chatViewCircleAvatarSize{
    [[CCConstants sharedInstance] setChatViewCircleAvatarSize:chatViewCircleAvatarSize];
}

+ (void)setHideOutGoingCircleAvatar:(BOOL)hideOutGoingCircleAvatar{
    [[CCConstants sharedInstance] setHideOutGoingCircleAvatar:hideOutGoingCircleAvatar];
}

+ (void)setHideChatViewPhoneBtn:(BOOL)hideChatViewPhoneBtn{
    [[CCConstants sharedInstance] setHideChatViewPhoneBtn:hideChatViewPhoneBtn];
}

+ (void)setHideChatViewCloseBtn:(BOOL)hideChatViewCloseBtn{
    [[CCConstants sharedInstance] setHideChatViewCloseBtn:hideChatViewCloseBtn];
}

+ (void)setCloseBtnImage:(NSString *)normal hilighted:(NSString *)hilighted disable:(NSString *)disable{
    [CCConstants sharedInstance].closeBtnNormal = normal;
    [CCConstants sharedInstance].closeBtnHilighted = hilighted;
    [CCConstants sharedInstance].closeBtnDisable = disable;
}

+ (void)setBackBtnImage:(NSString *)normal hilighted:(NSString *)hilighted disable:(NSString *)disable{
    [CCConstants sharedInstance].backBtnNormal = normal;
    [CCConstants sharedInstance].backBtnHilighted = hilighted;
    [CCConstants sharedInstance].backBtnDisable = disable;
}

+ (void)setVoiceCallBtnImage:(NSString *)normal hilighted:(NSString *)hilighted disable:(NSString *)disable{
    [CCConstants sharedInstance].voiceCallBtnNormal = normal;
    [CCConstants sharedInstance].voiceCallBtnHilighted = hilighted;
    [CCConstants sharedInstance].voiceCallBtnDisable = disable;
}

+ (void)setVideoCallBtnImage:(NSString *)normal hilighted:(NSString *)hilighted disable:(NSString *)disable {
    [CCConstants sharedInstance].videoCallBtnNormal = normal;
    [CCConstants sharedInstance].videoCallBtnHilighted = hilighted;
    [CCConstants sharedInstance].videoCallBtnDisable = disable;
}

+ (void)setInfoBtnImage:(NSString *)normal hilighted:(NSString *)hilighted disable:(NSString *)disable{
    [CCConstants sharedInstance].infoBtnNormal = normal;
    [CCConstants sharedInstance].infoBtnHilighted = hilighted;
    [CCConstants sharedInstance].infoBtnDisable = disable;
}

+ (void)setAppIconName:(NSString *) appIconName{
    if (appIconName) {
        [CCConstants sharedInstance].appIconName = appIconName;
    } else {
        [CCConstants sharedInstance].appIconName = CC_APP_ICON_DEFAULT_NAME;
    }
}

+ (void)setGoogleApiKey:(NSString *)apiKey {
    if (apiKey) {
        [CCConstants sharedInstance].googleApiKey = apiKey;
    }
}

+ (void)setApiBaseUrl:(NSString *)apiBaseUrl {
    if (apiBaseUrl) {
        [CCConstants sharedInstance].apiBaseUrl = apiBaseUrl;
    } else {
        [CCConstants sharedInstance].apiBaseUrl = CC_DEFAULT_API_BASE_URL;
    }
}

+ (NSString *)getApiBaseUrl {
    if ([CCConstants sharedInstance].apiBaseUrl != nil) {
        return [CCConstants sharedInstance].apiBaseUrl;
    }
    return CC_DEFAULT_API_BASE_URL;
}

+ (void)setWebsocketBaseUrl:(NSString *)websocketBaseUrl {
    if (websocketBaseUrl) {
        [CCConstants sharedInstance].websocketBaseUrl = websocketBaseUrl;
    }
}

+ (NSString *)getWebsocketBaseUrl {
    if ([CCConstants sharedInstance].websocketBaseUrl != nil) {
        return [CCConstants sharedInstance].websocketBaseUrl;
    }
    return CC_DEFAULT_WEBSOCKET_BASE_URL;
}

+ (void)setWebDashboardUrl:(NSString *)webDashboardUrl {
    if (webDashboardUrl) {
        [CCConstants sharedInstance].webDashboardUrl = webDashboardUrl;
    }
}

+ (NSString *)getWebDashboardUrl {
    if ([CCConstants sharedInstance].webDashboardUrl != nil) {
        return [CCConstants sharedInstance].webDashboardUrl;
    }
    return CC_DEFAULT_WEB_DASHBOARD_URL;
}

+ (void)setEnabledVideoCall:(BOOL)enabled {
    [CCConstants sharedInstance].enableVideoCall = enabled;
}

+ (BOOL)isVideoEnabled {
    return [CCConstants sharedInstance].enableVideoCall;
}

- (id)getChatView:(NSString *)orgUid
         provider:(NSString *)provider
    providerToken:(NSString *)providerToken
providerTokenSecret:(NSString *)providerTokenSecret
providerRefreshToken:(NSString *)providerRefreshToken
providerCreatedAt:(NSDate *)providerCreatedAt
providerExpiresAt:(NSDate *)providerExpiresAt
channelInformations:(NSDictionary *)channelInformations
      deviceToken:(NSString *)deviceToken
completionHandler:(void (^)(void))completionHandler
{
    [CCConstants sharedInstance].isModal = NO;
    if (provider == nil
        || providerToken == nil)
    {
        return nil;
    }
    id chatViewController = [[CCChatViewController alloc] initWithUserdata:orgUid
                                                                 firstName:nil
                                                                familyName:nil
                                                                     email:nil
                                                                  provider:provider
                                                             providerToken:providerToken
                                                       providerTokenSecret:providerTokenSecret
                                                      providerRefreshToken:providerRefreshToken
                                                         providerCreatedAt:providerCreatedAt
                                                         providerExpiresAt:providerExpiresAt
                                                       channelInformations:channelInformations
                                                               deviceToken:deviceToken
                                                         completionHandler:completionHandler];
    return chatViewController;
}

- (id)getChatView:(NSString *)orgUid
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
completionHandler:(void (^)(void))completionHandler
{
    [CCConstants sharedInstance].isModal = NO;
    if (provider == nil
        || providerToken == nil)
    {
        return nil;
    }
    id chatViewController = [[CCChatViewController alloc] initWithUserdata:orgUid
                                                                 firstName:firstName
                                                                familyName:familyName
                                                                     email:email
                                                                  provider:provider
                                                             providerToken:providerToken
                                                       providerTokenSecret:providerTokenSecret
                                                      providerRefreshToken:providerRefreshToken
                                                         providerCreatedAt:providerCreatedAt
                                                         providerExpiresAt:providerExpiresAt
                                                       channelInformations:channelInformations
                                                               deviceToken:deviceToken
                                                         completionHandler:completionHandler];
    return chatViewController;
}

- (void)presentChatView:(UIViewController *)viewController
                 orgUid:(NSString *)orgUid
               provider:(NSString *)provider
          providerToken:(NSString *)providerToken
    providerTokenSecret:(NSString *)providerTokenSecret
   providerRefreshToken:(NSString *)providerRefreshToken
      providerCreatedAt:(NSDate *)providerCreatedAt
      providerExpiresAt:(NSDate *)providerExpiresAt
    channelInformations:(NSDictionary *)channelInformations
            deviceToken:(NSString *)deviceToken
      completionHandler:(void (^)(void))completionHandler{
    [CCConstants sharedInstance].isModal = YES;
    CCChatViewController *chatViewController = [[CCChatViewController alloc] initWithUserdata:orgUid
                                                                                    firstName:nil
                                                                                   familyName:nil
                                                                                        email:nil
                                                                                     provider:provider
                                                                                providerToken:providerToken
                                                                          providerTokenSecret:providerTokenSecret
                                                                         providerRefreshToken:providerRefreshToken
                                                                            providerCreatedAt:providerCreatedAt
                                                                            providerExpiresAt:providerExpiresAt
                                                                          channelInformations:channelInformations
                                                                                  deviceToken:deviceToken
                                                                            completionHandler:completionHandler];
    CCNavigationController *navChatViewController = [[CCNavigationController alloc] initWithRootViewController:chatViewController];
    [viewController presentViewController:navChatViewController animated:YES completion:nil];
}

- (void)presentChatView:(UIViewController *)viewController
                 orgUid:(NSString *)orgUid
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
      completionHandler:(void (^)(void))completionHandler{
    [CCConstants sharedInstance].isModal = YES;
    CCChatViewController *chatViewController = [[CCChatViewController alloc] initWithUserdata:orgUid
                                                                                    firstName:firstName
                                                                                   familyName:familyName
                                                                                        email:email
                                                                                     provider:provider
                                                                                providerToken:providerToken
                                                                          providerTokenSecret:providerTokenSecret
                                                                         providerRefreshToken:providerRefreshToken
                                                                            providerCreatedAt:providerCreatedAt
                                                                            providerExpiresAt:providerExpiresAt
                                                                          channelInformations:channelInformations
                                                                                  deviceToken:deviceToken
                                                                            completionHandler:completionHandler];
    CCNavigationController *navChatViewController = [[CCNavigationController alloc] initWithRootViewController:chatViewController];
    [viewController presentViewController:navChatViewController animated:YES completion:nil];
}

- (id)getChatView:(NSString *)orgUid
        firstName:(NSString *)firstName
       familyName:(NSString *)familyName
            email:(NSString *)email
channelInformations:(NSDictionary *)channelInformations
      deviceToken:(NSString *)deviceToken
completionHandler:(void (^)(void))completionHandler
{
    [CCConstants sharedInstance].isModal = NO;
    id chatViewController = [[CCChatViewController alloc] initWithUserdata:orgUid
                                                                 firstName:firstName
                                                                familyName:familyName email:email
                                                                  provider:nil
                                                             providerToken:nil
                                                       providerTokenSecret:nil
                                                      providerRefreshToken:nil
                                                         providerCreatedAt:nil
                                                         providerExpiresAt:nil
                                                       channelInformations:channelInformations
                                                               deviceToken:deviceToken
                                                         completionHandler:completionHandler];
    return chatViewController;
}

- (void)presentChatView:(UIViewController *)viewController
                 orgUid:(NSString *)orgUid
              firstName:(NSString *)firstName
             familyName:(NSString *)familyName
                  email:(NSString *)email
    channelInformations:(NSDictionary *)channelInformations
            deviceToken:(NSString *)deviceToken
      completionHandler:(void (^)(void))completionHandler{
    [CCConstants sharedInstance].isModal = YES;
    CCChatViewController *chatViewController = [[CCChatViewController alloc] initWithUserdata:orgUid
                                                                                    firstName:firstName
                                                                                   familyName:familyName
                                                                                        email:email
                                                                                     provider:nil
                                                                                providerToken:nil
                                                                          providerTokenSecret:nil
                                                                         providerRefreshToken:nil
                                                                            providerCreatedAt:nil
                                                                            providerExpiresAt:nil
                                                                          channelInformations:channelInformations
                                                                                  deviceToken:deviceToken
                                                                            completionHandler:completionHandler];
    CCNavigationController *navChatViewController = [[CCNavigationController alloc] initWithRootViewController:chatViewController];
    [viewController presentViewController:navChatViewController animated:YES completion:nil];
}


- (void)presentHistoryView:(UIViewController *)viewController
                  provider:(NSString *)provider
             providerToken:(NSString *)providerToken
       providerTokenSecret:(NSString *)providerTokenSecret
      providerRefreshToken:(NSString *)providerRefreshToken
         providerCreatedAt:(NSDate *)providerCreatedAt
         providerExpiresAt:(NSDate *)providerExpiresAt
         completionHandler:(void (^)(void))completionHandler{
    [CCConstants sharedInstance].isModal = YES;
    CCHistoryViewController *historyView = [[CCHistoryViewController alloc] initWithUserdata:CCAllChannel
                                                                                    provider:provider
                                                                               providerToken:providerToken
                                                                         providerTokenSecret:providerTokenSecret
                                                                        providerRefreshToken:providerRefreshToken
                                                                           providerCreatedAt:providerCreatedAt
                                                                           providerExpiresAt:providerExpiresAt
                                                                           completionHandler:completionHandler];
    CCNavigationController *navHistoryViewController = [[CCNavigationController alloc] initWithRootViewController:historyView];
    [viewController presentViewController:navHistoryViewController animated:YES completion:nil];
}

- (id)getHistoryView:(NSString *)provider
       providerToken:(NSString *)providerToken
 providerTokenSecret:(NSString *)providerTokenSecret
providerRefreshToken:(NSString *)providerRefreshToken
   providerCreatedAt:(NSDate *)providerCreatedAt
   providerExpiresAt:(NSDate *)providerExpiresAt
   completionHandler:(void (^)(void))completionHandler{
    [CCConstants sharedInstance].isModal = NO;
    if (provider == nil
        || providerToken == nil)
    {
        return nil;
    }
    id historyView = [[CCHistoryViewController alloc] initWithUserdata:CCAllChannel
                                                              provider:provider
                                                         providerToken:providerToken
                                                   providerTokenSecret:providerTokenSecret
                                                  providerRefreshToken:providerRefreshToken
                                                     providerCreatedAt:providerCreatedAt
                                                     providerExpiresAt:providerExpiresAt
                                                     completionHandler:completionHandler];
    return historyView;
}

- (id)getHistoryView:(CCChannelType)channelType
            provider:(NSString *)provider
       providerToken:(NSString *)providerToken
 providerTokenSecret:(NSString *)providerTokenSecret
providerRefreshToken:(NSString *)providerRefreshToken
   providerCreatedAt:(NSDate *)providerCreatedAt
   providerExpiresAt:(NSDate *)providerExpiresAt
   completionHandler:(void (^)(void))completionHandler{
    [CCConstants sharedInstance].isModal = NO;
    if (provider == nil
       || providerToken == nil)
    {
        return nil;
    }
    id historyView = [[CCHistoryViewController alloc] initWithUserdata:channelType
                                                              provider:provider
                                                         providerToken:providerToken
                                                   providerTokenSecret:providerTokenSecret
                                                  providerRefreshToken:providerRefreshToken
                                                     providerCreatedAt:providerCreatedAt
                                                     providerExpiresAt:providerExpiresAt
                                                     completionHandler:completionHandler];
    return historyView;
}

- (void)getHistoryView:(CCChannelType)channelType
               userUid:(NSNumber *)userUid
                 token:(NSString *)token
      closeViewHandler:(void (^)(void))closeViewHandler
     completionHandler:(void (^)(id historyView))completionHandler{
    [CCConstants sharedInstance].isModal = NO;
    if (token == nil || userUid == nil) {
        if ([[CCConstants sharedInstance] getKeychainToken] == nil
            || [[CCConstants sharedInstance] getKeychainUid] == nil) {
            if(completionHandler != nil) completionHandler(nil);
        }
    }else{
        [[CCConstants sharedInstance] setKeychainToken:token];
        [[CCConstants sharedInstance] setKeychainUid:[userUid stringValue]];
    }
    if ([ChatCenterClient sharedClient].appToken == nil){
        [[CCConnectionHelper sharedClient] setCurrentApp:^(BOOL success) {
            if (success == YES) {
                ///Re-register unregistered device-token
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                NSString *deviceToken = [ud stringForKey:@"deviceToken"];
                [self registerDeviceToken:deviceToken completionHandler:^(NSDictionary *result, NSError *error) {
                    id historyView = [[CCHistoryViewController alloc] initWithUserdata:channelType
                                                                              provider:nil
                                                                         providerToken:nil
                                                                   providerTokenSecret:nil
                                                                  providerRefreshToken:nil
                                                                     providerCreatedAt:nil
                                                                     providerExpiresAt:nil
                                                                     completionHandler:closeViewHandler];
                    if(completionHandler != nil) completionHandler(historyView);
                }];
            }else{
                if(completionHandler != nil) completionHandler(nil);
            }
        }];
    }else{
        ///Re-register unregistered device-token
        [self checkRegisterDeviceToken:^(NSDictionary *result, NSError *error) {
            id historyView = [[CCHistoryViewController alloc] initWithUserdata:channelType
                                                                      provider:nil
                                                                 providerToken:nil
                                                           providerTokenSecret:nil
                                                          providerRefreshToken:nil
                                                             providerCreatedAt:nil
                                                             providerExpiresAt:nil
                                                             completionHandler:closeViewHandler];
            if(completionHandler != nil) completionHandler(historyView);
        }];
    }
}

- (id)getHistoryView:(void (^)(void))completionHandler{
    [CCConstants sharedInstance].isModal = NO;
    id historyView = [[CCHistoryViewController alloc] initWithUserdata:CCAllChannel
                                                              provider:nil
                                                         providerToken:nil
                                                   providerTokenSecret:nil
                                                  providerRefreshToken:nil
                                                     providerCreatedAt:nil
                                                     providerExpiresAt:nil
                                                     completionHandler:completionHandler];
    return historyView;
}

- (id)getHistoryView:(CCChannelType)channelType
      completionHandler:(void (^)(void))completionHandler{
    [CCConstants sharedInstance].isModal = NO;
    id historyView = [[CCHistoryViewController alloc] initWithUserdata:channelType
                                                              provider:nil
                                                         providerToken:nil
                                                   providerTokenSecret:nil
                                                  providerRefreshToken:nil
                                                     providerCreatedAt:nil
                                                     providerExpiresAt:nil
                                                     completionHandler:completionHandler];
    return historyView;
}

- (void)presentHistoryView:(UIViewController *)viewController
         completionHandler:(void (^)(void))completionHandler{
    [CCConstants sharedInstance].isModal = YES;
    CCHistoryViewController *historyView = [[CCHistoryViewController alloc] initWithUserdata:CCAllChannel
                                                                                    provider:nil
                                                                               providerToken:nil
                                                                         providerTokenSecret:nil
                                                                        providerRefreshToken:nil
                                                                           providerCreatedAt:nil
                                                                           providerExpiresAt:nil
                                                                           completionHandler:completionHandler];
    CCNavigationController *navHistoryViewController = [[CCNavigationController alloc] initWithRootViewController:historyView];
    [viewController presentViewController:navHistoryViewController animated:YES completion:nil];
}

-(void)checkRegisterDeviceToken:(void (^)(NSDictionary *result, NSError *error))completionHandler{
    ///Re-register unregistered device-token
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if([ud stringForKey:@"CCUnregisterdDeviceToken"] != nil){
        [self registerDeviceToken:[ud stringForKey:@"CCUnregisterdDeviceToken"]
                completionHandler:^(NSDictionary *result, NSError *error)
        {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud removeObjectForKey:@"CCUnregisterdDeviceToken"];
            [ud synchronize];
            if(completionHandler != nil) completionHandler(result, error);
        }];
    }else{
        if(completionHandler != nil) completionHandler(nil, nil);
    }
}


- (void)getChatAndHistoryViewController:(CCChannelType)channelType
                              userUid:(NSNumber *)userUid
                                token:(NSString *)token
                     closeViewHandler:(void (^)(void))closeViewHandler
                    completionHandler:(void (^)(id chatAndHistoryView))completionHandler{
    if (token == nil || userUid == nil) {
        if ([[CCConstants sharedInstance] getKeychainToken] == nil
            || [[CCConstants sharedInstance] getKeychainUid] == nil) {
            if(completionHandler != nil) completionHandler(nil);
        }
    }else{
        [[CCConstants sharedInstance] setKeychainToken:token];
        [[CCConstants sharedInstance] setKeychainUid:[userUid stringValue]];
    }
    [CCConnectionHelper sharedClient].twoColumnLayoutMode = YES;
    
    if ([ChatCenterClient sharedClient].appToken == nil){
        [[CCConnectionHelper sharedClient] setCurrentApp:^(BOOL success) {
            if (success == YES) {
                ///Re-register unregistered device-token
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                NSString *deviceToken = [ud stringForKey:@"deviceToken"];
                [self registerDeviceToken:deviceToken completionHandler:^(NSDictionary *result, NSError *error) {
                    id instance = [[CCChatAndHistoryViewController alloc] initWithUserdata:channelType
                                                                                  provider:nil
                                                                             providerToken:nil
                                                                       providerTokenSecret:nil
                                                                      providerRefreshToken:nil
                                                                         providerCreatedAt:nil
                                                                         providerExpiresAt:nil
                                                                          closeViewHandler:closeViewHandler];
                    [[CCConnectionHelper sharedClient] setCurrentView:instance];
                    if(completionHandler != nil) completionHandler(instance);
                }];
            }else{
                if(completionHandler != nil) completionHandler(nil);
            }
        }];
    }else{
        [self checkRegisterDeviceToken:^(NSDictionary *result, NSError *error) {
            id instance = [[CCChatAndHistoryViewController alloc] initWithUserdata:channelType
                                                                          provider:nil
                                                                     providerToken:nil
                                                               providerTokenSecret:nil
                                                              providerRefreshToken:nil
                                                                 providerCreatedAt:nil
                                                                 providerExpiresAt:nil
                                                                  closeViewHandler:closeViewHandler];
            [[CCConnectionHelper sharedClient] setCurrentView:instance];
            if(completionHandler != nil) completionHandler(instance);
        }];
    }
}

///This method is not used now, getChatAndHistoryViewController is used instead
- (void)presentChatAndHistoryViewFromViewControllerAndData:(UIViewController *)rootViewController
                                               channelType:(CCChannelType)channelType
                                                    orgUid:(NSString *)orgUid
                                                   userUid:(NSNumber *)userUid
                                                     token:(NSString *)token
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
                                         completionHandler:(void (^)(void))completionHandler{
    [CCConstants sharedInstance].isModal = YES;
    [[CCConstants sharedInstance] setKeychainUid:[userUid stringValue]];
    [[CCConstants sharedInstance] setKeychainToken:token];
    self.lastRootViewController = rootViewController;
    [CCConnectionHelper sharedClient].twoColumnLayoutMode = YES;
    CCHistoryViewController *historyView = [[CCHistoryViewController alloc] initWithUserdata:channelType
                                                                                    provider:provider
                                                                               providerToken:providerToken
                                                                         providerTokenSecret:providerTokenSecret
                                                                        providerRefreshToken:providerRefreshToken
                                                                           providerCreatedAt:providerCreatedAt
                                                                           providerExpiresAt:providerExpiresAt
                                                                           completionHandler:completionHandler];
    UINavigationController *historyNaviView = [[UINavigationController alloc] initWithRootViewController:historyView];
    CCChatViewController *chatView = [[CCChatViewController alloc] initWithUserdata:orgUid
                                                                          firstName:firstName
                                                                         familyName:familyName
                                                                              email:email
                                                                           provider:provider
                                                                      providerToken:providerToken
                                                                providerTokenSecret:providerTokenSecret
                                                               providerRefreshToken:providerRefreshToken
                                                                  providerCreatedAt:providerCreatedAt
                                                                  providerExpiresAt:providerExpiresAt
                                                                channelInformations:channelInformations
                                                                        deviceToken:deviceToken
                                                                  completionHandler:completionHandler];
    UINavigationController *chatNaviView = [[UINavigationController alloc] initWithRootViewController:chatView];
    CCUISplitViewController* splitVC = [[CCUISplitViewController alloc] init];
    [[CCConnectionHelper sharedClient] setCurrentView:splitVC];
    splitVC.viewControllers = [NSArray arrayWithObjects:historyNaviView, chatNaviView, nil];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window == nil) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    window.rootViewController = splitVC;
    historyView.mySplitViewController = splitVC;
}

///This method is not used now.
- (void)closeChatAndHistoryViewFromViewController{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window == nil) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    window.rootViewController = self.lastRootViewController;
    [[CCConnectionHelper sharedClient] setCurrentView:nil];
    [[CCConnectionHelper sharedClient] setDelegate:nil];
}

-(void)openChatHistoryAndChatView{
    [CCConnectionHelper sharedClient].twoColumnLayoutMode = YES;
    CCHistoryViewController *historyView = [[CCHistoryViewController alloc] init];
    UINavigationController *historyNaviView = [[UINavigationController alloc] initWithRootViewController:historyView];
    CCChatViewController *chatView = [[CCChatViewController alloc] init];
    UINavigationController *chatNaviView = [[UINavigationController alloc] initWithRootViewController:chatView];
    CCUISplitViewController* splitVC = [[CCUISplitViewController alloc] init];
    [[CCConnectionHelper sharedClient] setCurrentView:splitVC];
    splitVC.viewControllers = [NSArray arrayWithObjects:historyNaviView, chatNaviView, nil];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window == nil) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    window.rootViewController = splitVC;
    historyView.mySplitViewController = splitVC;
    if ([CCConstants sharedInstance].isAgent == YES) {
        [self loadOrgsAndChannelsAndMessagesAndConnectWebSocket:splitVC];
    }
}

-(void)loadOrgsAndChannelsAndMessagesAndConnectWebSocket:(CCUISplitViewController *)splitVC{
    __block CCUISplitViewController *blockSplitVC = splitVC;
    [[CCConnectionHelper sharedClient] loadOrgsAndChannelsAndConnectWebSocket:YES getChennelType:CCGetChannels isOrgChange:NO completionHandler:^(NSString *result, NSError *error, NSURLSessionDataTask *task) {
        if (result != nil) {
            NSLog(@"loadChannelsAndConnectWebSocket success!");
            if ([result isEqualToString:@"No Message yet"]) {
                [blockSplitVC displayModalList];
            }
        }else{
            if ([[CCConnectionHelper sharedClient] isAuthenticationError:task] == YES){
                [[CCConnectionHelper sharedClient] displayAuthenticationErrorAlert];
            }
        }
    }];
}

- (BOOL)hasChatUser{
    if ([[CCConstants sharedInstance] getKeychainToken] != nil) return YES;
    return NO;
}

- (BOOL)hasChannel:(NSString *)orgUid{  
    NSArray *reaultArray = [[CCCoredataBase sharedClient] selectChannelWithOrgUid:CCloadLoacalChannelLimit orgUid:orgUid];
    if ([reaultArray count] == 0) { ///Channel not exist.
        return NO;
    }else{
        return YES;
    }
}

- (BOOL)signOut{
    if ([[CCConnectionHelper sharedClient] signOut]){
        return YES;
    }else{
        return NO;
    }
}

- (void)signInDeviceToken:(NSString*)email
                 password:(NSString*)password
                 provider:(NSString *)provider
            providerToken:(NSString *)providerToken
      providerTokenSecret:(NSString *)providerTokenSecret
     providerRefreshToken:(NSString *)providerRefreshToken
        providerCreatedAt:(NSDate *)providerCreatedAt
        providerExpiresAt:(NSDate *)providerExpiresAt
              deviceToken:(NSString *)deviceToken
        completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler
{
    if ([CCConnectionHelper sharedClient].isRefreshingData == YES || [CCConnectionHelper sharedClient].currentView != nil){
        if (completionHandler != nil) completionHandler(nil, nil);
        return;
    }
    
    [[CCConnectionHelper sharedClient] loadUserToken:email
                                            password:password
                                            provider:provider
                                       providerToken:providerToken
                                 providerTokenSecret:providerTokenSecret
                                providerRefreshToken:providerRefreshToken
                                   providerCreatedAt:providerCreatedAt
                                   providerExpiresAt:providerExpiresAt
                                         deviceToken:deviceToken
                                        showProgress:NO
                                   completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task)
    {
        if (result != nil) {
            [[CCConnectionHelper sharedClient] refreshData];
            if(completionHandler != nil) completionHandler(result, error);
        }
    }];
}

- (void)signInWithAnonymous{
    [[CCConnectionHelper sharedClient] refreshData];
}

- (void)registerDeviceToken:(NSString *)deviceToken
          completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler{
    [[CCConnectionHelper sharedClient] signInDeviceTokenWithAuthToken:deviceToken
                                                    completionHandler:^(NSDictionary *result, NSError *error)
    {
        if (completionHandler != nil) completionHandler(result, error);
    }];
}

- (void)signOutDeviceToken:(NSString *)deviceToken
         completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler{
    [[CCConnectionHelper sharedClient] signOutDeviceToken:deviceToken completionHandler:^(NSDictionary *result, NSError *error) {
        if(completionHandler != nil) completionHandler(result, error);
    }];
}

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
   completionHandler:(void (^)(NSDictionary *result, NSError *error))completionHandler{
    [[CCConnectionHelper sharedClient] loadUserAuth:email
                                           password:password
                                           provider:provider
                                      providerToken:providerToken
                                providerTokenSecret:providerTokenSecret
                               providerRefreshToken:providerRefreshToken
                                  providerCreatedAt:providerCreatedAt
                                  providerExpiresAt:providerExpiresAt
                                        deviceToken:deviceToken
                                       showProgress:showProgress
                                  completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
                                      if(completionHandler != nil) completionHandler(result, error);
                                  }];
}

- (BOOL)isDebug{
    #ifdef CC_DEBUG
        return YES;
    #else
        return NO;
    #endif
}

- (void)isTokenVailid:(void (^)(BOOL result))completionHandler{
    [[CCConnectionHelper sharedClient] loadUserMe:NO
                                completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task)
    {
            if(result != nil) {
                if(completionHandler != nil) completionHandler(YES);
            }else{
                if(completionHandler != nil) completionHandler(NO);
            }
    }];
}

///Added for team app only instantly. Removed after adding switching org function
- (void)setOrgId:(NSString *)orgUid{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:orgUid forKey:@"orgUid"];
    [ud synchronize];
}

- (void)isOrgOnline:orgUid completeHandler:(void (^)(BOOL isOnline))completionHandler{
[[CCConnectionHelper sharedClient] getOrgOnlineStatus:orgUid completeHandler:^(BOOL isOnline) {
    if (completionHandler != nil) {
        completionHandler(isOnline);
    }
}];
}

#pragma mark Public Private

+ (NSString *)localizedStringForKey:(NSString *)key {
    
    NSString *str = [SDK_BUNDLE localizedStringForKey:(key) value:@"" table:kLoacalizeResourceName];
    
    return [str length] ? str : key;
}

+(void)deleteKeychainData{
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
}

- (UIImage *)createAvatarImage:(NSString *)text width:(CGFloat)width height:(CGFloat)height color:(UIColor *)color fontSize:(CGFloat)fontSize textOffset:(CGFloat)textOffset
{
    NSString *uppercaseText = [text uppercaseString]; ///uppercase
    CGSize size = CGSizeMake(width, height); ///imageSize
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    ///create circle
    [[UIColor clearColor] setStroke];
    [color setFill];
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, width, height)];
    [rectPath fill];
    [rectPath stroke];
    
    ///create text
    UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByClipping;
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSBackgroundColorAttributeName: [UIColor clearColor]
                                 };
    [uppercaseText drawInRect:CGRectMake(0, textOffset, size.width, size.height) withAttributes:attributes];
    
    ///get image as UIImage
    UIImage *image = nil;
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIColor *)getRandomColor:(NSString *)userUid{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    long CCrandom;
    if ([ud integerForKey:@"ChatCenterUserdefaults_random"]) {
        CCrandom = (long)[ud integerForKey:@"ChatCenterUserdefaults_random"];
    }else{
        CCrandom = random();
        [ud setInteger:(int)CCrandom forKey:@"ChatCenterUserdefaults_random"];
    }
    NSLog(@"create avatar image getRandomColor userUid:%@", userUid );
    NSLog(@"create avatar image getRandomColor CCArc4random:%d", (int)CCrandom );
    NSLog(@"create avatar image getRandomColor intValue:%d", [userUid intValue] );
    
    CGFloat hue;
    if (userUid == nil) {///user is not assigned to the chat yet in history view
        hue = rand() * CCrandom % 256 / 256.0; /// hue will become uniq as each userUid
    }else{
        hue = [userUid intValue] * CCrandom % 256 / 256.0; /// hue will become uniq as each userUid
    }
    NSLog(@"create avatar image getRandomColor hue:%f", hue );
    UIColor *randomColor = [UIColor colorWithHue:hue saturation:CC_AVATAR_SATURATION brightness:CC_AVATAR_BRIGHTNESS alpha:1.0];
    
    return randomColor;
}

- (void)setUnreadMessages:(NSMutableDictionary *)unreadMessages{
    NSMutableDictionary *oldUnreadMessages = [self.unreadMessages mutableCopy];
    NSMutableDictionary *newUnreadMessages = [unreadMessages mutableCopy];
    BOOL isChanged = NO;
    for (id key in [oldUnreadMessages allKeys]) {
        if (newUnreadMessages[key] == nil) {
            isChanged = YES;
        }else{
            if (![newUnreadMessages[key] isEqualToNumber:oldUnreadMessages[key]]){ ///TODO: need to test
                isChanged = YES;
            }
            [newUnreadMessages removeObjectForKey:key];
        }
    }
    if ([newUnreadMessages count] > 0) isChanged = YES;
    
    _unreadMessages = unreadMessages;
    if(isChanged == YES) [self postUnreadMessageCountChangedNotification];
}

- (void)clearUnreadMessage:(NSString *)channelUid{
    if (self.unreadMessages[channelUid] != nil) {
        int unreadMessage = [self.unreadMessages[channelUid] intValue];
        if (unreadMessage != 0){
            [self.unreadMessages removeObjectForKey:channelUid];
            [self postUnreadMessageCountChangedNotification];
        }
    }
}

- (void)clearUnreadMessages{
    self.unreadMessages = [NSMutableDictionary dictionary];
}

- (void)countUpUnreadMessage:(NSString *)channelUid{
    int unreadMessageNum;
    if (self.unreadMessages[channelUid] != nil) {
        unreadMessageNum = [self.unreadMessages[channelUid] intValue];
        unreadMessageNum++;
    }else{
        unreadMessageNum = 1;
    }
    [self.unreadMessages setObject:[[NSNumber alloc] initWithInt:unreadMessageNum] forKey:channelUid];
    [self postUnreadMessageCountChangedNotification];
}

- (NSNumber *)countTotalUnreadMessage{
    int countTotalUnreadMessageInt = 0;
    for (id key in [self.unreadMessages allKeys]) {
        countTotalUnreadMessageInt += [self.unreadMessages[key] intValue];
    }
    NSNumber *countTotalUnreadMessage = [[NSNumber alloc] initWithInt:countTotalUnreadMessageInt];
    return countTotalUnreadMessage;
}

- (NSNumber *)countTotalUnreadChannel{
    int countTotalUnreadChannelInt = 0;
    for (id key in [self.unreadMessages allKeys]) {
        if([self.unreadMessages[key] intValue] > 0) countTotalUnreadChannelInt++;
    }
    NSNumber *countTotalUnreadChannel = [[NSNumber alloc] initWithInt:countTotalUnreadChannelInt];
    return countTotalUnreadChannel;
}

- (void)postUnreadMessageCountChangedNotification
{
    NSDictionary *userInfo = @{@"unreadMessageCount":[self countTotalUnreadMessage],
                               @"unreadChannelCount":[self countTotalUnreadChannel]};
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"CCUnreadMessageCountChangedNotification"
                      object:self
                    userInfo:userInfo];
}

- (NSUInteger)unreadMessageCount{
    NSUInteger countTotalUnreadMessageInt = [[self countTotalUnreadMessage] intValue];
    return countTotalUnreadMessageInt;
}

- (NSUInteger)unreadChannelCount{
    NSUInteger countTotalUnreadChannelInt = [[self countTotalUnreadChannel] intValue];
    return countTotalUnreadChannelInt;
}

- (BOOL)isUnreadMessageCount{
    NSUInteger countTotalUnreadMessageInt = [[self countTotalUnreadMessage] intValue];
    if (countTotalUnreadMessageInt == 0) {
        return NO;
    }else{
        return YES;
    }
}

-(BOOL)isLocaleJapanese{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *languageID = [languages objectAtIndex:0];
    if ([languageID isEqualToString:@"ja"]) { ///~iOS8
        return YES;
    }
    if ([languageID isEqualToString:@"ja-JP"]) { ///iOS9~
        return YES;
    }
    return NO;
}

@end
