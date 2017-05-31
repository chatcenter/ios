//
//  CCConstants.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/01/17.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCConstants.h"
#import "ChatCenterPrivate.h"
#import "CCSSKeychain.h"
#import "CCSVProgressHUD.h"

@implementation CCConstants

const BOOL CCLocalDevelopmentMode = NO; ///Only developing in offline environment communicating with loacal server, this should be YES
const int CCProviderAuthPeriod = 30;///Days
const int CCloadMessageFirstLimit = 21;
const int CCloadChannelFirstLimit = 20;
const int CCloadLoacalMessageLimit = 21;
const int CCloadLoacalMessageSelectLimit = 10000;
const int CCupdateMessageUsersReadMessageLimit = 10000;
const int CCloadLoacalMessageForLabelLimit = 10000;
const int CCloadLoacalChannelLimit = 10000;

const int CCloadLoacalUserLimit = 10000;
const int CCloadLoacalOrgLimit = 10000;
const int CCdeleteLoacalLimit = 10000;
const int CCInputTextLimit = 2000;
const int CCWidgetInputTitleLimit = 100;
const int CCWidgetInputChoiceTextLimit = 100;
const int CCWidgetInputNumberChoiceLimit = 10;
const int CCNoteInputtextLimit = 500;

const int CCImageMaxSize = 100 * 1024; //Kilobytes

// key for notification center
NSString * const kCCNoti_UserReactionToSticker = @"kCCNoti_UserReactionToSticker";
NSString * const kCCNoti_UserReactionToStickerContent = @"kCCNoti_UserReactionToStickerContent";
NSString * const kCCNoti_UserReactionToCallAgain = @"kCCNoti_UserReactionToCallAgain";

// key for user information
NSString *const kCCUserDefaults_userDisplayName = @"ChatCenterUserdefaults_currentDisplayName";
NSString *const kCCUserDefaults_userIconUrl = @"ChatCenterUserdefaults_currentIconUrl";
NSString *const kCCUserDefaults_userId = @"ChatCenterUserdefaults_currentUserUid";
NSString *const kCCUserDefaults_userEmail = @"ChatCenterUserdefaults_currentEmail";
NSString *const kCCUserDefaults_privilege = @"ChatCenterUserdefaults_privelege";

NSString *const kCCUserDefaults_liveLocationDuration = @"ChatCenterUserdefaults_liveLocationDuration";

const int CCUploadFileSizeLimit = 20 * 1024 * 1024; // 20MB

+ (CCConstants *)sharedInstance
{
    static CCConstants *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [CCConstants new];
        instance.isAgent = NO;
        instance.isModal = NO;
        instance.enableVideoCall = CC_DEFAULT_VIDEO_ENABLED;
        [CCSVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    });
    return instance;
}

- (UIColor *)defaultChatTextColor {
    UIColor *color = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.0];
    return color;
}

+ (UIColor *)defaultBaseColor
{
    UIColor *color = [UIColor colorWithRed:0.0 green:0.42 blue:0.99 alpha:1.0]; //AppSocially
    return color;
}

+ (UIColor *)defaultHeaderBackgroundColor
{
    UIColor *color = nil;
    return color;
}

+ (UIColor *)defaultHeaderItemColor
{
    UIColor *color = nil; //AppSocially
    return color;
}

+ (BOOL)defaultHeaderTranslucent
{
    return YES;
}

+ (UIBarStyle)defaultHeaderBarStyle
{
    UIBarStyle barStyle = UIBarStyleDefault; //AppSocially
    return barStyle;
}

+ (UIColor *)defaultSendButtonColor
{
    UIColor *color = [UIColor colorWithRed:0.0 green:0.42 blue:0.99 alpha:1.0]; //AppSocially
    return color;
}

+ (UIColor *)defaultHistoryViewSelectColor
{
    UIColor *color = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0]; //AppSocially
    return color;
}

+ (NSString *)defaultHistoryViewTitle
{
    NSString *historyViewTitle = CCLocalizedString(@"Inbox"); //AppSocially
    return historyViewTitle;
}

+ (UIColor *)defaultHistoryHeaderBackgroundColor
{
    UIColor *color = [UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1.0];
    return color;
}

+ (UIColor *)defaultChatHeaderBackgroundColor
{
    UIColor *color = [UIColor whiteColor];
    return color;
}

+ (UIColor *)defaultHistoryCellBackgroundColor
{
    UIColor *color = [UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1.0];
    return color;
}

+ (UIColor *)defaultHistorySelectedCellBackgroundColor
{
    UIColor *color = [UIColor colorWithRed:214/255.0 green:214/255.0 blue:214/255.0 alpha:1.0];
    return color;
}

+ (UIColor *)defaultHeaderBottomLineColor;
{
    UIColor *color = [UIColor colorWithRed:214/255.0 green:214/255.0 blue:214/255.0 alpha:1.0];
    return color;
}

+ (NSString *)defaultHistoryViewVoidMessage
{
    NSString *historyViewVoidMessage = CCLocalizedString(@"No chat"); //AppSocially
    return historyViewVoidMessage;
}

+ (CGFloat)defaultChatViewCircleAvatarSize
{
    CGFloat chatViewCircleAvatarSize = 30.0f; //AppSocially
    return chatViewCircleAvatarSize;
}

+ (BOOL)defaultHideOutGoingCircleAvatar
{
    BOOL hideOutGoingCircleAvatar = YES; //AppSocially Color
    return hideOutGoingCircleAvatar;
}

+ (BOOL)defaultHideChatViewPhoneBtn
{
    return NO;
}

+ (BOOL)defaultHideChatViewCloseBtn
{
    return NO;
}

+ (NSString *)defaultBackButtonPointer
{
    NSString *backButtonPointer = @"CCBackArrow";
    return backButtonPointer;
}

+ (NSArray *)weekDayArray
{
   NSArray *weekDayArray = @[CCLocalizedString(@"Monday"),
                             CCLocalizedString(@"Tuesday"),
                             CCLocalizedString(@"Wednesday"),
                             CCLocalizedString(@"Thursday"),
                             CCLocalizedString(@"Friday"),
                             CCLocalizedString(@"Saturday"),
                             CCLocalizedString(@"Sunday")];
    return weekDayArray;
}

+ (NSArray *)weekDayArrayMiddle
{
    NSArray *weekDayArrayMiddle = @[CCLocalizedString(@"Monday-Middle"),
                              CCLocalizedString(@"Tuesday-Middle"),
                              CCLocalizedString(@"Wednesday-Middle"),
                              CCLocalizedString(@"Thursday-Middle"),
                              CCLocalizedString(@"Friday-Middle"),
                              CCLocalizedString(@"Saturday-Middle"),
                              CCLocalizedString(@"Sunday-Middle")];
    return weekDayArrayMiddle;
}

- (NSString *)getKeychainUid
{
    if (_keychainUid == nil || [_keychainUid isEqualToString:@""]) {
        // load from SSKeyChain
        _keychainUid = [CCSSKeychain passwordForService:@"ChatCenter" account:@"uid"];
        return _keychainUid;
    }
    return _keychainUid;
}

- (void)setKeychainUid:(NSString *)newKeychainUid
{
    if (newKeychainUid == nil) {
        [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"uid"];
        _keychainUid = nil;
        return;
    }
    
    [CCSSKeychain setPassword:newKeychainUid forService:@"ChatCenter" account:@"uid"];
    _keychainUid = newKeychainUid;
}

- (NSString *)getKeychainToken
{
    if (_keychainToken == nil || [_keychainToken isEqualToString:@""]) {
        // load from SSKeyChain
        _keychainToken = [CCSSKeychain passwordForService:@"ChatCenter" account:@"token"];
        return _keychainToken;
    }
    return _keychainToken;
}

- (void)setKeychainToken:(NSString *)newKeychainToken
{
    if (newKeychainToken == nil) {
        [CCSSKeychain deletePasswordForService:@"ChatCenter" account:@"token"];
        _keychainToken = nil;
        return;
    }
    
    [CCSSKeychain setPassword:newKeychainToken forService:@"ChatCenter" account:@"token"];
    _keychainToken = newKeychainToken;
}

@end
