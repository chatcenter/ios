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
#import "CCCommonStickerCollectionViewCell.h"
#import "CCWidgetMenuView.h"
#import "CCConfirmWidgetViewController.h"

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
@property (nonatomic, strong) NSString *currentGuestId;
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
@property BOOL isReturnFromStickerView;
@property BOOL isPulldownSelectBoxDisplayed;
@property BOOL shouldDisplayFixedPhraseMenu;
@property (nonatomic, strong) NSArray *twilioInviteList;
//@property (nonatomic, strong) NSLayoutConstraint *marginBottomCollectionView;
@property (nonatomic, strong) NSLayoutConstraint *marginBottomInputToolbar;

@property (nonatomic, strong) NSString *pendingFixedPhrase;
@property (nonatomic, strong) UINavigationController *navigationHistoryView;
@property (nonatomic, weak)   id<CCVideoCallEventHandlerDelegate> delegateCall;

///
/// Input toolbar
///
@property (nonatomic, strong) UIView *inputToolbarContainerView;
@property (nonatomic, strong) CCWidgetMenuView *inputToolbarMenuView;

///
/// Suggestion
///
@property (nonatomic, strong) NSArray<NSDictionary*> *suggestionActionData;


- (void)loadLocalData:(BOOL)isOrgChange;
-(void)receiveMessage:(NSString *)messageType
                  uid:(NSNumber *)uid
              content:(NSDictionary *)content
           fromSender:(NSString *)userUid
               onDate:(NSDate *)date
          displayName:(NSString *)displayName
          userIconUrl:(NSString *)userIconUrl
            userAdmin:(BOOL)userAdmin
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
- (void) switchToInputTextMode;
- (void) switchToSuggestionMode;
- (void) switchToSaveWidget;
- (void) pressCalendar;
- (void) pressLocationWidget;
- (void) pressThumb;
- (void) pressImage;
- (void) takePhoto;
- (void) pressPhrase;
- (void) pressStripePayment;
- (void) pressLandingPage;
- (void) pressVideoCall;
- (void) pressVoiceCall;
- (void) pressConfirmWidget;
- (BOOL)processChannelUserVideoChatInfo;

//// Called locally and from CCSuggestionInputView
- (void)performOpenAction:(NSDictionary*)stickerAction
              stickerType:(NSString*)stickerType
                messageId:(NSNumber*)msgId
                  reacted:(NSString*)reacted
                reactedOn:(CCCommonStickerCollectionViewCell *)cell;

@end
