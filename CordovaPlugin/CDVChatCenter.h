//
//  CDVChatCenter.h
//  Example
//
//  Created by AppSocially Inc. on 2017/02/20.
//  Copyright (c) 2017年 AppSocially Inc. All rights reserved.
//
//

#import <Cordova/CDVPlugin.h>

@interface CDVChatCenter : CDVPlugin
//--------------------------------------------------------------------
//
// Initialize
//
//--------------------------------------------------------------------
- (void)setAppToken:(CDVInvokedUrlCommand *)command;
//--------------------------------------------------------------------
// Chat View
//--------------------------------------------------------------------
- (void)presentChatView:(CDVInvokedUrlCommand *)command;
//--------------------------------------------------------------------
//
// History View
//
//--------------------------------------------------------------------
- (void)presentHistoryView:(CDVInvokedUrlCommand *)command;
//--------------------------------------------------------------------
//
// SignIn/SignOut
//
//--------------------------------------------------------------------
- (void)signInDeviceToken:(CDVInvokedUrlCommand *)command;
- (void)signOutDeviceToken:(CDVInvokedUrlCommand *)command;
- (void)signOut:(CDVInvokedUrlCommand *)command;
//--------------------------------------------------------------------
//
// Utilities
//
//--------------------------------------------------------------------
- (NSUInteger)unreadMessageCount:(CDVInvokedUrlCommand *)command;
- (NSUInteger)unreadChannelCount:(CDVInvokedUrlCommand *)command;
-(void)isOrgOnline:(CDVInvokedUrlCommand *)command;
//--------------------------------------------------------------------
//
// Design customize
//
//--------------------------------------------------------------------
- (void)setHeaderBarStyle:(CDVInvokedUrlCommand *)command;
- (void)setHeaderTranslucent:(CDVInvokedUrlCommand *)command;
- (void)setHeaderItemColor:(CDVInvokedUrlCommand *)command;
- (void)setHeaderBackgroundColor:(CDVInvokedUrlCommand *)command;
- (void)setCloseBtnImage:(CDVInvokedUrlCommand *)command;
- (void)setBackBtnImage:(CDVInvokedUrlCommand *)command;
- (void)setVoiceCallBtnImage:(CDVInvokedUrlCommand *)command;
- (void)setVideoCallBtnImage:(CDVInvokedUrlCommand *)command;
- (void)setHistoryViewTitle:(CDVInvokedUrlCommand *)command;
- (void)setHistoryViewVoidMessage:(CDVInvokedUrlCommand *)command;
//--------------------------------------------------------------------
// Google Api Key
//--------------------------------------------------------------------
- (void)setGoogleApiKey:(CDVInvokedUrlCommand *)command;
//--------------------------------------------------------------------
// Base Url
//--------------------------------------------------------------------
- (void)setApiBaseUrl:(CDVInvokedUrlCommand *)command;
- (void)getApiBaseUrl:(CDVInvokedUrlCommand *)command;

- (void)setWebsocketBaseUrl:(CDVInvokedUrlCommand *)command;
- (void)getWebsocketBaseUrl:(CDVInvokedUrlCommand *)command;

- (void)setWebDashboardUrl:(CDVInvokedUrlCommand *)command;
- (void)getWebDashboardUrl:(CDVInvokedUrlCommand *)command;

- (void)setEnabledVideoCall:(CDVInvokedUrlCommand *)command;
- (void)isVideoEnabled:(CDVInvokedUrlCommand *)command;
@end
