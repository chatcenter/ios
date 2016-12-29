//
//  CCChatViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2014/12/26.
//  Copyright (c) 2014年 AppSocially Inc. All rights reserved.
//
// Import all the things

#import "CCConstants.h"
#import "CCJSQMessage.h"
#import "CCJSQMessages.h"
#import "CCConectionHelperDelegate.h"
#import "CCPhraseStickerViewController.h"
#import "CCLocationStickerViewController.h"
#import "CCCommonStickerCreatorDelegate.h"
#import "CCStickerCollectionViewCellActionProtocol.h"
#import "CCCommonWidgetEditorDelegate.h"
#import "CCChatViewNavigationTitle.h"
#import "CCVideoCallEventHandlerDelegate.h"

@class CCChatViewController;

@protocol JSQDemoViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(CCChatViewController *)vc;

@end

@protocol CCLiveLocationWidgetDelegate <NSObject>
@required
-(void)didStopSharingLiveLocation;
-(void)didStartSharingLiveLocation;
@end

@interface CCChatViewController : CCJSQMessagesViewController <UIActionSheetDelegate, CLLocationManagerDelegate, CCConectionHelperDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChoosedPhraseProtocol, CClocationStickerViewDelegate, CCCommonStickerCreatorDelegate, CCCommonWidgetEditorDelegate, CCChatViewNavigationTitleDelegate, CCStickerCollectionViewCellActionProtocol, CCLiveLocationWidgetDelegate>

@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *channelUid;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *orgUid;
@property (nonatomic, strong) NSString *orgName;
@property (nonatomic, copy) void (^closeChatViewCallback)(void);
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *sendingMessages;
@property (nonatomic, strong) NSMutableArray *responses;
@property (nonatomic, strong) NSDictionary *avatars;
@property (nonatomic, strong) NSArray *userVideoChat;
@property (nonatomic, strong) NSString *friend;
@property (nonatomic, weak)   id<JSQDemoViewControllerDelegate> delegateModal;
@property (nonatomic, strong) CCJSQMessagesBubbleImage *outgoingBubbleImageData;
@property (nonatomic, strong) CCJSQMessagesBubbleImage *incomingBubbleImageData;
@property BOOL onResendingFailedMessages;
@property BOOL isReturnFromRightMenuView;
@property BOOL isReturnFromVideoCallView;
@property (nonatomic, strong) NSArray *twilioInviteList;

@property (nonatomic, strong) NSString *pendingFixedPhrase;
@property (nonatomic, strong) UINavigationController *navigationHistoryView;
@property (nonatomic, weak)   id<CCVideoCallEventHandlerDelegate> delegateCall;
- (void)loadLocalData:(BOOL)isOrgChange;
-(void)receiveMessage:(NSString *)messageType
                  uid:(NSNumber *)uid
              content:(NSDictionary *)content
           fromSender:(NSString *)userUid
               onDate:(NSDate *)date
          displayName:(NSString *)displayName
          userIconUrl:(NSString *)userIconUrl
               answer:(NSDictionary *)answer;
- (void)receiveFollowFromWebSocket:(NSString *)channelUid;
- (void)receiveUnfollowFromWebSocket:(NSString *)channelUid;
///CCConectionHelperDelegate
- (void)loadLocalDisplayname:(NSString *)channelId;
- (id)initWithUserdata:(NSString *)orgUid
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
     completionHandler:(void (^)(void))completionHandler;
- (void)closeChatView;
- (void)updateViewOrientation;
- (void)saveDraftMessage;


//// Called from CCWidgetMenuView
- (void) pressCalendar;
- (void) pressLocationWidget;
- (void) pressThumb;
- (void) pressImage;
- (void) takePhoto;
- (void) pressPhrase;
#ifdef CC_VIDEO
- (void) pressVideoCall;
- (void) pressVoiceCall;
- (BOOL)processUserMeVideoChatInfo;
- (BOOL)processChannelUserVideoChatInfo;
#endif

//// Called locally and from CCSuggestionInputView
- (void)performOpenAction:(NSDictionary*)stickerAction
              stickerType:(NSString*)stickerType
                messageId:(NSNumber*)msgId
                  reacted:(NSString*)reacted;

@end
