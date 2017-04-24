//
//  CCConstants.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/01/17.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CCAlertView.h"

#define CC_SDK_VERSION                    @"1.1.2"
#define CC_SDK_SUPPORT_VIDEO_CHAT_VERSION @"1.0.8"

#define CC_DEFAULT_VIDEO_ENABLED        1
#define CC_DEFAULT_API_BASE_URL         @"https://api.chatcenter.io/"
#define CC_DEFAULT_WEBSOCKET_BASE_URL   @"wss://api.chatcenter.io/"
#define CC_DEFAULT_WEB_DASHBOARD_URL    @"https://app.chatcenter.io"


#define kBundleResourceName         @"ChatCenter"
#define SDK_BUNDLE  [NSBundle bundleForClass:[CCConstants class]]

#define CC_AVATAR_SATURATION 0.6
#define CC_AVATAR_BRIGHTNESS 0.71

#define CC_RESPONSETYPEMESSAGE          @"message"
#define CC_RESPONSETYPEDATETIMEAVAILABILITY @"datetime"
#define CC_RESPONSETYPEIMAGE            @"image"
#define CC_RESPONSETYPEPDF              @"pdf"
#define CC_RESPONSETYPELOCATION         @"location"
#define CC_RESPONSETYPECOLOCATION       @"co-location"
#define CC_RESPONSETYPETHUMB            @"yes_no"
#define CC_RESPONSETYPEPAYMENT          @"payment"
#define CC_RESPONSETYPEEMOTION          @"emotion"
#define CC_RESPONSETYPELINK             @"link"
#define CC_RESPONSETYPEQUESTION         @"question"
#define CC_RESPONSETYPEUNEXPECTED       @"unexpected"
#define CC_CONTENTKEYDATETIMEAVAILABILITY @"datetimes"
#define CC_RESPONSETYPEINFORMATION      @"information"
#define CC_RESPONSETYPESTICKER          @"sticker"
#define CC_RESPONSETYPERESPONSE         @"response"
#define CC_RESPONSETYPEPROPERTY         @"property"
#define CC_RESPONSETYPESTICKERCONTENT   @"sticker-content"
#define CC_RESPONSETYPEMAP              @"map"
#define CC_RESPONSETYPECALL             @"call"
#define CC_RESPONSETYPESUGGESTION       @"suggestion"
#define CC_RESPONSETYPECALLINVITE       @"call-invite"

#define CC_STICKERCONTENT               @"sticker-content"
#define CC_STICKER_DATA                  @"sticker-data"
#define CC_STICKER_TYPE                 @"sticker-type"
#define CC_STICKERCONTENT_ACTION        @"action"
#define CC_CONTENTACTION                @"content-action"
#define CC_ACTIONTYPE                   @"action-type"
#define CC_ACTIONDATA                   @"action-data"
#define CC_THUMBNAILURL                 @"thumbnail-url"
#define CC_ACTIONTYPE_OPEN              @"open"
#define CC_ACTIONTYPE_VIDEOCALL         @"video_call"
#define CC_ACTIONTYPE_VOICECALL         @"voice_call"

#define CC_STICKERTYPEDATETIMEAVAILABILITY @"datetime"
#define CC_STICKERTYPEFILE                 @"file_upload"
#define CC_STICKERTYPELOCATION             @"location"
#define CC_STICKERTYPECOLOCATION           @"co-location"
#define CC_STICKERTYPETHUMB                @"yes_no"
#define CC_STICKERTYPEFIXEDPHRASE          @"fixed_phrase"
#define CC_STICKERTYPEVIDEOCHAT            @"video_chat"
#define CC_STICKERTYPEVOICECHAT            @"voice_chat"
#define CC_STICKERTYPEIMAGE                @"sticker_image"
#define CC_STICKERTYPECAMERA               @"camera_upload"

#define CC_LATITUDE                     @"lat"
#define CC_LONGITUDE                    @"lng"

#define CC_BUSINESSTYPETEAM    @"team"
#define CC_BUSINESSTYPEBTOBTOC @"btobtoc"
#define CC_BUSINESSTYPEBTOC    @"btoc"

#define CC_VOICECALL_ICON_NORMAL    @"CCmenu_icon_phone.png"
#define CC_VIDEOCALL_ICON_NOMAL     @"CCmenu_icon_videocall.png"

#define CC_INFO_ICON_NORMAL     @"CCinfo-icon.png"
#define CC_BUTTON_PRESS_BACK @"CCleft.png"
#define CC_APP_ICON_DEFAULT_NAME             @"CCshuffle-icon.png"

#define CC_MESSAGE_STATUS_SEND_SUCCESS  0
#define CC_MESSAGE_STATUS_SEND_FAILED   1
#define CC_MESSAGE_STATUS_DELIVERING    2
#define CC_MESSAGE_STATUS_DRAFT         3

// key for notification center
FOUNDATION_EXPORT NSString * const kCCNoti_UserReactionToSticker;
FOUNDATION_EXPORT NSString * const kCCNoti_UserReactionToStickerContent;
FOUNDATION_EXPORT NSString * const kCCNoti_UserReactionToCallAgain;

// key for user information
extern NSString *const kCCUserDefaults_userDisplayName;
extern NSString *const kCCUserDefaults_userIconUrl;
extern NSString *const kCCUserDefaults_userId;
extern NSString *const kCCUserDefaults_userEmail;
extern NSString *const kCCUserDefaults_liveLocationDuration;
extern NSString *const kCCUserDefaults_privilege;

typedef enum {
    CCGetChannels,
    CCGetChannelsMine
} CCGetChannelsType;

enum {
    CCStickerCollectionViewCellOptionShowName  = (1 << 0),
    CCStickerCollectionViewCellOptionShowDate  = (1 << 1),
    CCStickerCollectionViewCellOptionShowStatus  = (1 << 2),
    CCStickerCollectionViewCellOptionShowAsMyself  = (1 << 3),
    CCStickerCollectionViewCellOptionShowAsWidget  = (1 << 4),
    CCStickerCollectionViewCellOptionShowAsAgent  = (1 << 5),
    CCStickerCollectionViewCellOptionShowLiveIcon = (1 << 6)
};
typedef uint32_t CCStickerCollectionViewCellOptions;


@interface CCConstants : NSObject
{
    /** For store valued in KeyChain */
    NSString *_keychainUid;
    NSString *_keychainToken;
}

@property (nonatomic, strong) NSArray *apps;
@property (nonatomic, strong) NSString *videoAccessToken;
@property (nonatomic, strong) NSString *userIdentity;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSArray *stickers;
@property (nonatomic, strong) NSString *businessType;
@property BOOL showReadStatusForGuest;
@property (nonatomic, strong) UIColor *baseColor;
@property (nonatomic, readonly) UIColor *defaultChatTextColor;
@property (nonatomic, strong) UIColor *headerBackgroundColor;
@property (nonatomic, strong) UIColor *historyCellBackgroundColor;
@property (nonatomic, strong) UIColor *historySelectedCellBackgroundColor;
@property (nonatomic, strong) UIColor *headerBottomLineColor;
@property (nonatomic, strong) UIColor *historyHeaderBackgroundColor;
@property (nonatomic, strong) UIColor *chatHeaderBackgroundColor;
@property (nonatomic, strong) UIColor *headerItemColor;
@property (nonatomic, strong) UIColor *sendButtonColor;
@property (nonatomic, strong) UIColor *historyViewSelectColor;
@property (nonatomic, strong) UIColor *leftMenuViewSelectColor;
@property (nonatomic, strong) UIColor *leftMenuViewNormalColor;
@property (nonatomic, strong) NSString *historyViewTitle;
@property (nonatomic, strong) NSString *historyViewVoidMessage;
@property (nonatomic, strong) NSString *chatViewLinkURL;
@property (nonatomic, strong) NSString *closeBtnNormal;
@property (nonatomic, strong) NSString *closeBtnHilighted;
@property (nonatomic, strong) NSString *closeBtnDisable;
@property (nonatomic, strong) NSString *backBtnNormal;
@property (nonatomic, strong) NSString *backBtnHilighted;
@property (nonatomic, strong) NSString *backBtnDisable;
@property (nonatomic, strong) NSString *voiceCallBtnNormal;
@property (nonatomic, strong) NSString *voiceCallBtnHilighted;
@property (nonatomic, strong) NSString *voiceCallBtnDisable;
@property (nonatomic, strong) NSString *infoBtnNormal;
@property (nonatomic, strong) NSString *infoBtnHilighted;
@property (nonatomic, strong) NSString *infoBtnDisable;
@property (nonatomic, strong) NSString *videoCallBtnNormal;
@property (nonatomic, strong) NSString *videoCallBtnHilighted;
@property (nonatomic, strong) NSString *videoCallBtnDisable;
@property (nonatomic, strong) NSString *appIconName;
@property (nonatomic, strong) NSString *googleApiKey;
@property (nonatomic, strong) NSString *apiBaseUrl;
@property (nonatomic, strong) NSString *webDashboardUrl;
@property (nonatomic, strong) NSString *websocketBaseUrl;
@property (nonatomic) BOOL enableVideoCall;

@property CGFloat chatViewCircleAvatarSize;
@property BOOL hideOutGoingCircleAvatar;
@property BOOL hideChatViewPhoneBtn;
@property BOOL hideChatViewCloseBtn;
@property BOOL isAgent;
@property BOOL isModal;
@property BOOL headerTranslucent;
@property UIBarStyle headerBarStyle;
@property (nonatomic, strong) NSArray *businessFunnels;

extern const BOOL CCLocalDevelopmentMode;
extern const int CCProviderAuthPeriod;
extern const int CCloadMessageFirstLimit;
extern const int CCloadChannelFirstLimit;
extern const int CCloadLoacalMessageLimit;
extern const int CCloadLoacalMessageSelectLimit;
extern const int CCupdateMessageUsersReadMessageLimit;
extern const int CCloadLoacalMessageForLabelLimit;
extern const int CCloadLoacalChannelLimit;
extern const int CCloadLoacalUserLimit;
extern const int CCloadLoacalOrgLimit;
extern const int CCdeleteLoacalLimit;
extern const int CCUploadFileSizeLimit;
extern const int CCInputTextLimit;
extern const int CCWidgetInputTitleLimit;
extern const int CCWidgetInputChoiceTextLimit;
extern const int CCWidgetInputNumberChoiceLimit;
extern const int CCNoteInputtextLimit;
extern const int CCImageMaxSize;
+ (CCConstants *)sharedInstance;
+ (UIColor *)defaultBaseColor;
+ (UIColor *)defaultHeaderBackgroundColor;
+ (UIColor *)defaultHeaderItemColor;
+ (BOOL)defaultHeaderTranslucent;
+ (UIBarStyle)defaultHeaderBarStyle;
+ (UIColor *)defaultSendButtonColor;
+ (UIColor *)defaultHistoryViewSelectColor;
+ (NSString *)defaultHistoryViewTitle;
+ (NSString *)defaultHistoryViewVoidMessage;
+ (UIColor *)defaultHistoryCellBackgroundColor;
+ (UIColor *)defaultHistorySelectedCellBackgroundColor;
+ (UIColor *)defaultHeaderBottomLineColor;
+ (UIColor *)defaultChatHeaderBackgroundColor;
+ (UIColor *)defaultHistoryHeaderBackgroundColor;
+ (CGFloat)defaultChatViewCircleAvatarSize;
+ (BOOL)defaultHideOutGoingCircleAvatar;
+ (BOOL)defaultHideChatViewPhoneBtn;
+ (BOOL)defaultHideChatViewCloseBtn;
+ (NSString *)defaultBackButtonPointer;
+ (NSArray *)weekDayArray;
+ (NSArray *)weekDayArrayMiddle;

- (NSString *)getKeychainUid;
- (void)setKeychainUid:(NSString *)newKeychainUid;
- (NSString *)getKeychainToken;
- (void)setKeychainToken:(NSString *)newKeychainToken;

@end
