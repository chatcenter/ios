//
//  CDVChatCenter.m
//  Example
//
//  Created by AppSocially Inc. on 2017/02/20.
//  Copyright (c) 2017年 AppSocially Inc. All rights reserved.
//

#import "CDVChatCenter.h"
#import "ChatCenter.h"

@implementation CDVChatCenter
//--------------------------------------------------------------------
//
// Initialize
//
//--------------------------------------------------------------------
- (void)setAppToken:(CDVInvokedUrlCommand *)command {
    NSString *appToken = [command argumentAtIndex:0];
    [ChatCenter setAppToken:appToken completionHandler:^{
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Insert payload here"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

//--------------------------------------------------------------------
// Chat View
//--------------------------------------------------------------------
- (void)presentChatView:(CDVInvokedUrlCommand *)command {
    NSString *orgId                   = [command argumentAtIndex:0];
    NSString *firstName               = [command argumentAtIndex:1];
    NSString *familyName              = [command argumentAtIndex:2];
    NSString *email                   = [command argumentAtIndex:3];
    NSString *provider                = [command argumentAtIndex:4];
    NSString *providerToken           = [command argumentAtIndex:5];
    NSString *providerTokenSecret     = [command argumentAtIndex:6];
    NSString *providerRefreshToken    = [command argumentAtIndex:7];
    NSDate *providerCreatedAt         = [command argumentAtIndex:8];
    NSDate *providerExpiresAt         = [command argumentAtIndex:9];
    NSDictionary *channelInformations = [command argumentAtIndex:10];
    NSString *deviceToken             = [command argumentAtIndex:11];
    if (deviceToken == nil) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        deviceToken = [ud stringForKey:@"CCDeviceToken"];
    }
    
    [[ChatCenter sharedInstance] presentChatView:[self getTopPresentedViewController]
                                          orgUid:orgId
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
                               completionHandler:^{
                                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Insert payload here"];
                                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

//--------------------------------------------------------------------
//
// History View
//
//--------------------------------------------------------------------
- (void)presentHistoryView:(CDVInvokedUrlCommand *)command {
    NSString *provider = [command argumentAtIndex:0];
    NSString *providerToken = [command argumentAtIndex:1];
    NSString *providerTokenSecret = [command argumentAtIndex:2];
    NSString *providerRefreshToken = [command argumentAtIndex:3];
    NSDate *providerCreatedAt = [command argumentAtIndex:4];
    NSDate *providerExpiredAt = [command argumentAtIndex:5];
    
    [[ChatCenter sharedInstance] presentHistoryView:[self getTopPresentedViewController]
                                           provider:provider
                                      providerToken:providerToken
                                providerTokenSecret:providerTokenSecret
                               providerRefreshToken:providerRefreshToken
                                  providerCreatedAt:providerCreatedAt
                                  providerExpiresAt:providerExpiredAt
                                  completionHandler:^{
                                      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Insert payload here"];
                                      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

//--------------------------------------------------------------------
//
// SignIn/SignOut
//
//--------------------------------------------------------------------
- (void)signInDeviceToken:(CDVInvokedUrlCommand *)command {
    NSString *email = [command argumentAtIndex:0];
    NSString *password = [command argumentAtIndex:1];
    NSString *provider = [command argumentAtIndex:2];
    NSString *providerToken = [command argumentAtIndex:3];
    NSString *providerTokenSecret = [command argumentAtIndex:4];
    NSString *providerRefreshToken = [command argumentAtIndex:5];
    NSDate *providerCreatedAt = [command argumentAtIndex:6];
    NSDate *providerExpiresAt = [command argumentAtIndex:7];
    NSString *deviceToken = [command argumentAtIndex:8];

    [[ChatCenter sharedInstance] signInDeviceToken:email password:password provider:provider providerToken:providerToken providerTokenSecret:providerTokenSecret providerRefreshToken:providerRefreshToken providerCreatedAt:providerCreatedAt providerExpiresAt:providerExpiresAt deviceToken:deviceToken completionHandler:^(NSDictionary *result, NSError *error) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Insert payload here"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)signOutDeviceToken:(CDVInvokedUrlCommand *)command {
    NSString *deviceToken = [command argumentAtIndex:0];
    [[ChatCenter sharedInstance] signOutDeviceToken:deviceToken completionHandler:^(NSDictionary *result, NSError *error) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Insert payload here"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}
- (void) signOut:(CDVInvokedUrlCommand *)command {
    [[ChatCenter sharedInstance] signOut];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [ud stringForKey:@"deviceToken"];
    [[ChatCenter sharedInstance] signOutDeviceToken:deviceToken
                                  completionHandler:^(NSDictionary *result, NSError *error) {
                                      [[ChatCenter sharedInstance] signOut];
                                      [ud removeObjectForKey:@"deviceToken"];
                                  }];
}

//--------------------------------------------------------------------
//
// Utilities
//
//--------------------------------------------------------------------
- (NSUInteger)unreadMessageCount:(CDVInvokedUrlCommand *)command {
    NSUInteger unreadMessageCount = [[ChatCenter sharedInstance] unreadChannelCount];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:unreadMessageCount];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return unreadMessageCount;
}
    
- (NSUInteger)unreadChannelCount:(CDVInvokedUrlCommand *)command {
    NSUInteger unreadChannelCount = [[ChatCenter sharedInstance] unreadChannelCount];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsNSInteger:unreadChannelCount];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return unreadChannelCount;
}
    
-(void)isOrgOnline:(CDVInvokedUrlCommand *)command {
    NSString *orgId = [command argumentAtIndex:0];
    [[ChatCenter sharedInstance] isOrgOnline:orgId completeHandler:^(BOOL isOnline) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isOnline];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}
    
//--------------------------------------------------------------------
//
// Design customize
//
//--------------------------------------------------------------------
- (void)setHeaderBarStyle:(CDVInvokedUrlCommand *)command {
    // style = 0:UIBarStyleDefault
    // style = 1:UIBarStyleBlack
    NSNumber *style = [command argumentAtIndex:0];
    [ChatCenter setHeaderBarStyle:[style intValue]];
}
    
- (void)setHeaderTranslucent:(CDVInvokedUrlCommand *)command {
    BOOL translucent = [command argumentAtIndex:0];
    [ChatCenter setHeaderTranslucent:translucent];
}
    
- (void)setHeaderItemColor:(CDVInvokedUrlCommand *)command {
    NSNumber *red = [command argumentAtIndex:0];
    NSNumber *green = [command argumentAtIndex:1];
    NSNumber *blue = [command argumentAtIndex:2];
    NSNumber *alpha = [command argumentAtIndex:3];
    [ChatCenter setHeaderItemColor:[UIColor colorWithRed:[red floatValue] green:[green floatValue] blue:[blue floatValue] alpha:[alpha floatValue]]];
}
    
- (void)setHeaderBackgroundColor:(CDVInvokedUrlCommand *)command {
    NSNumber *red = [command argumentAtIndex:0];
    NSNumber *green = [command argumentAtIndex:1];
    NSNumber *blue = [command argumentAtIndex:2];
    NSNumber *alpha = [command argumentAtIndex:3];
    [ChatCenter setHeaderBackgroundColor:[UIColor colorWithRed:[red floatValue] green:[green floatValue] blue:[blue floatValue] alpha:[alpha floatValue]]];
}
    
- (void)setCloseBtnImage:(CDVInvokedUrlCommand *)command {
    NSString *normal = [command argumentAtIndex:0];
    NSString *hilighted = [command argumentAtIndex:1];
    NSString *disable = [command argumentAtIndex:2];
    [ChatCenter setCloseBtnImage:normal hilighted:hilighted disable:disable];
}
    
- (void)setBackBtnImage:(CDVInvokedUrlCommand *)command {
    NSString *normal = [command argumentAtIndex:0];
    NSString *hilighted = [command argumentAtIndex:1];
    NSString *disable = [command argumentAtIndex:2];
    [ChatCenter setBackBtnImage:normal hilighted:hilighted disable:disable];
}
    
- (void)setVoiceCallBtnImage:(CDVInvokedUrlCommand *)command {
    NSString *normal = [command argumentAtIndex:0];
    NSString *hilighted = [command argumentAtIndex:1];
    NSString *disable = [command argumentAtIndex:2];
    [ChatCenter setVoiceCallBtnImage:normal hilighted:hilighted disable:disable];
}
    
- (void)setVideoCallBtnImage:(CDVInvokedUrlCommand *)command {
    NSString *normal = [command argumentAtIndex:0];
    NSString *hilighted = [command argumentAtIndex:1];
    NSString *disable = [command argumentAtIndex:2];
    [ChatCenter setVideoCallBtnImage:normal hilighted:hilighted disable:disable];
}
    
- (void)setHistoryViewTitle:(CDVInvokedUrlCommand *)command {
    NSString *title = [command argumentAtIndex:0];
    [ChatCenter setHistoryViewTitle:title];
}
    
- (void)setHistoryViewVoidMessage:(CDVInvokedUrlCommand *)command {
    NSString *message = [command argumentAtIndex:0];
    [ChatCenter setHistoryViewVoidMessage:message];
}

//--------------------------------------------------------------------
// Google Api Key
//--------------------------------------------------------------------
- (void)setGoogleApiKey:(CDVInvokedUrlCommand *)command {
    NSString *apiKey = [command argumentAtIndex:0];
    [ChatCenter setGoogleApiKey:apiKey];
}

//--------------------------------------------------------------------
// Base Url
//--------------------------------------------------------------------
- (void)setApiBaseUrl:(CDVInvokedUrlCommand *)command {
    NSString *baseUrl = [command argumentAtIndex:0];
    [ChatCenter setApiBaseUrl:baseUrl];
}

- (void)getApiBaseUrl:(CDVInvokedUrlCommand *)command {
    NSString *baseUrl = [ChatCenter getApiBaseUrl];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:baseUrl];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setWebsocketBaseUrl:(CDVInvokedUrlCommand *)command {
    NSString *baseUrl = [command argumentAtIndex:0];
    [ChatCenter setWebsocketBaseUrl:baseUrl];
}

- (void)getWebsocketBaseUrl:(CDVInvokedUrlCommand *)command {
    NSString *wsBaseUrl = [ChatCenter getWebsocketBaseUrl];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:wsBaseUrl];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setWebDashboardUrl:(CDVInvokedUrlCommand *)command {
    NSString *baseUrl = [command argumentAtIndex:0];
    [ChatCenter setWebDashboardUrl:baseUrl];
}

- (void)getWebDashboardUrl:(CDVInvokedUrlCommand *)command {
    NSString *wdBaseUrl = [ChatCenter getWebsocketBaseUrl];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:wdBaseUrl];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setEnabledVideoCall:(CDVInvokedUrlCommand *)command {
    BOOL enabled = [command argumentAtIndex:0];
    [ChatCenter setEnabledVideoCall:enabled];
}

- (void)isVideoEnabled:(CDVInvokedUrlCommand *)command {
    BOOL enabled = [ChatCenter isVideoEnabled];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:enabled];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

    
-(UIViewController *)getTopPresentedViewController {
    UIViewController *presentingViewController = self.viewController;
    while(presentingViewController.presentedViewController != nil && ![presentingViewController.presentedViewController isBeingDismissed])
    {
        presentingViewController = presentingViewController.presentedViewController;
    }
    return presentingViewController;
}
    

    
@end
