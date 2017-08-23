//
//  CCChatViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2014/12/26.
//  Copyright (c) 2014年 AppSocially Inc. All rights reserved.
//
#import "CCChatViewController.h"
#import "CCConnectionHelper.h"
#import "CCConstants.h"
#import "CCRSDFDatePickerViewController.h"
#import "CCCoredataBase.h"
#import "ChatCenterPrivate.h"
#import "CCSSKeychain.h"
#import "CCStickerCollectionViewCell.h"
#import "CCThumbCollectionViewCell.h"
#import "CCYesNoCollectionViewCell.h"
#import "CCChoiceButton.h"
#import "CCIDMPhoto.h"
#import "CCIDMPhotoBrowser.h"
#import "CCCalendarTimePickerController.h"
#import "CCSVProgressHUD.h"
#import "CCPhraseStickerViewController.h"
#import "CCPhraseStickerCollectionViewController.h"
#import "CCPropertyCollectionViewCell.h"
#import "CCCommonStickerCollectionViewCell.h"
#import "ChatCenterClient.h"
#import "CCLocationPreviewViewController.h"
#import "CCLiveLocationStickerViewController.h"
#import "CCConstants.h"
#import "CCYesNoQuestionCreatorViewController.h"
#import "CCImagePickerViewController.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CCImageHelper.h"
#import "UIImage+fixOrientation.h"

#import "CCChannelDetailViewController.h"
#import "CCCommonStickerCollectionViewCellSuggestion.h"
#import "CCPhoneStickerCollectionViewCell.h"
#import <SafariServices/SafariServices.h>
#import "CCWebViewController.h"
#import "CCQuestionWidgetEditorViewController.h"
#import "CCWidgetMenuView.h"
#import "CCOpenTokVideoCallViewController.h"
#import "CCIncomingCallViewController.h"
#import "CCSuggestionInputView.h"
#import "CCFixedPhraseInputView.h"
#import "CCCommonWidgetPreviewViewController.h"
#import "CCLiveLocationWebviewController.h"
#import "CCPickerViewController.h"
#import "CCStripePaymentWidgetViewController.h"
#import "UIImage+CCSDKImage.h"
#import "CCLiveLocationTask.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CCParseUtils.h"
#import "CCChatViewHelper.h"

NSString *kCCCommonStickerCollectionViewCell_Incoming = @"CCCommonStickerCollectionViewCellIncoming";
NSString *kCCCommonStickerCollectionViewCell_Outgoing = @"CCCommonStickerCollectionViewCellOutgoing";
NSString *kCCCommonStickerCollectionViewCellSuggestion = @"CCCommonStickerCollectionViewCellSuggestion";
NSString *kCCPhoneStickerCollectionViewCell_Incoming = @"CCPhoneStickerCollectionViewCellIncoming";
NSString *kCCPhoneStickerCollectionViewCell_Outgoing = @"CCPhoneStickerCollectionViewCellOutgoing";

int kInputKeyboardMode = 0;
int kInputStickerMenuMode = 1;
int kInputFixedPhraseMenuMode = 2;

#define CC_COLOCATION_PREFERRED_INTERVAL    30.0
#define CC_INPUT_TOOLBAR_HEIGHT 44.0

@interface CCChatViewController ()<UIAlertViewDelegate>{
    CLLocationManager *locationManager;
    CLLocation *lastUpdatedLocation;
    NSTimer *colocationTimer;
    int liveColocationShareDuration;
    int liveColocationShareTimer;
    int preferredTimeInterval;
    UIBackgroundTaskIdentifier colocationBackgroundTask;
    CCJSQMessage *colocationMessage;

    BOOL fullScreen;
    BOOL loadPreviousMessage;
    int loadPreviousMessageNum;
    BOOL isInitializedJSQMessange;
    BOOL isInitViewLocked;
    UIView *stickerMenuView;
    NSMutableArray *stickerBtns;
    float circleAvatarSize;
    float randomCircleAvatarFontSize;
    float randomCircleAvatarTextOffset;
    UIBarButtonItem *voiceCallButton;
    UIBarButtonItem *videoCallButton;
    UIBarButtonItem *rightSpacer;
    UIBarButtonItem *rightMenuButton;
    NSMutableArray *readMessageUids;
    NSArray *channelUsers;
    NSArray *filteredChannelUsers;
    int currentInputMode;
    UIView *newMessageView;
    BOOL isKeyboardShowing;
    long lastTextLenght;
    float keyboardHeight;
    NSDictionary *cellNibNames;
    CCChatViewNavigationTitle *navigationTitleView;
    UIView *navigationBottomBorder;
    UILabel *typingLabel;
    BOOL isTyping;
    BOOL isDisplayingSuggestionView;
    BOOL isAlreadyDisplaySuggestionView;
    BOOL isDisplayingAlert;
    BOOL isEditingFreewordTextView;
}

@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* subtitleLabel;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* familyName;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSDictionary* channelInformations;
@property (nonatomic, strong) NSString* deviceToken;
@property (nonatomic, strong) NSString* assigneeUid;
@property (nonatomic, strong) NSMutableArray *fixedPhrases;
@property BOOL recieved;
@property BOOL isReturnFromWebBrowser;
@property BOOL isReturnFromInteractingWithURL;
@property BOOL isAbleToPressCall;
@property (nonatomic, strong) NSMutableArray *answeringStickers;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
@property (nonatomic, weak) UIAlertController *incomingAlertController;
#endif
@property (nonatomic, weak) UIAlertView *incomingAlert;
@end

@implementation CCChatViewController

#pragma mark - View lifecycle

/**
 *  Override point for customization.
 *
 *  Customize your view.
 *  Look at the properties on `JSQMessagesViewController` and `JSQMessagesCollectionView` to see what is possible.
 *
 *  Customize your layout.
 *  Look at the properties on `JSQMessagesCollectionViewFlowLayout` to see what is possible.
 */

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
     completionHandler:(void (^)(void))completionHandler
{
    self = [super init];
    if (self) {
        self.orgUid = orgUid;
        self.firstName = firstName;
        self.familyName = familyName;
        self.email = email;
        self.deviceToken = deviceToken;
        
        if ([CCSSKeychain passwordForService:@"ChatCenter" account:@"providerCreatedAt"])
        {
            [CCConnectionHelper sharedClient].providerOldCreatedAt = [CCSSKeychain passwordForService:@"ChatCenter" account:@"providerCreatedAt"];
        }
        if ([CCSSKeychain passwordForService:@"ChatCenter" account:@"providerExpiresAt"])
        {
            [CCConnectionHelper sharedClient].providerOldExpiresAt = [CCSSKeychain passwordForService:@"ChatCenter" account:@"providerExpiresAt"];
        }
        self.channelInformations = channelInformations;
        
        [CCConnectionHelper sharedClient].provider = provider;
        [CCConnectionHelper sharedClient].providerToken = providerToken;
        [CCConnectionHelper sharedClient].providerTokenSecret = providerTokenSecret;
        [CCConnectionHelper sharedClient].providerRefreshToken = providerRefreshToken;
        
        if (providerCreatedAt != nil)
        {
            double providerCreatedAtDouble = [providerCreatedAt timeIntervalSince1970];
            NSString *providerCreatedAtString = [NSString stringWithFormat:@"%f", providerCreatedAtDouble];
            [CCConnectionHelper sharedClient].providerCreatedAt = providerCreatedAtString;
        }
        if (providerExpiresAt != nil)
        {
            double providerExpiresAtDouble = [providerExpiresAt timeIntervalSince1970];
            NSString *providerExpiresAtString = [NSString stringWithFormat:@"%f", providerExpiresAtDouble];
            [CCConnectionHelper sharedClient].providerExpiresAt = providerExpiresAtString;
        }
        if (completionHandler != nil) self.closeChatViewCallback = completionHandler;
    }
    return self;
}

- (void)viewDidLoad
{
    isInitializedJSQMessange = NO;
    isInitViewLocked = NO;
    self.onResendingFailedMessages = NO;
    lastTextLenght = 0;
    self.sendingMessages = [NSMutableArray array];
    self.senderId = @"";
    self.senderDisplayName = @"";
    self.showLoadEarlierMessagesHeader = NO;
    self.showTypingIndicator = YES;
    isTyping = NO;
    self.isAbleToPressCall = YES;
    [super viewDidLoad];
    // This setting have to call after super.viewDidLoad is called.
    self.automaticallyScrollsToMostRecentMessage = NO;
    [self viewSetUp];
    [self customNibsSetUp];
    [[CCConnectionHelper sharedClient] isSupportVideoChat];
    if(self.channelId != nil) {
        [self loadChannelInfo:self.channelId];
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self reloadCollectionViewData];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reinstateBackgroundTask)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)reloadCollectionViewData {
    [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == NO) {
        [[CCConnectionHelper sharedClient] setCurrentView:self]; ////To display online/offline alert
        [[CCConnectionHelper sharedClient] setDelegate:self]; ///Retry reload is included
    }
    ///Initialize (Create user or Create channel or Load channel)
    if (self.isReturnFromStickerView) {
        self.isReturnFromStickerView = NO;
    } else if (self.isReturnFromWebBrowser) {
        self.isReturnFromWebBrowser = NO;
    } else if (self.isReturnFromRightMenuView) {
        [self loadLocalMessages:self.channelId];
        self.isReturnFromRightMenuView = NO;
    } else if (self.isReturnFromVideoCallView) {
        self.isReturnFromVideoCallView = NO;
        self.delegateCall = nil;
        [self loadLocalMessages:self.channelId];
    } else if (self.isReturnFromInteractingWithURL) {
        self.isReturnFromInteractingWithURL = NO;
        [self displayFixedPhraseOrSuggestionIfNeed];
    } else {
        [self setNavigationBarStyles];
        if ([CCConnectionHelper sharedClient].isLoadingUserToken == YES || [CCConnectionHelper sharedClient].isRefreshingData == YES) {
            [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading...")];
        }else{
            [self initView];
        }
    }
    if (self.senderId != nil && self.senderDisplayName != nil) {
        [super viewWillAppear:NO];
    } else {
        [super viewWillAppear:animated];
    }
    
    if ([CCConnectionHelper sharedClient].datepicker.count > 0) {
        [self sendCalendar:[CCConnectionHelper sharedClient].datepicker];
    }
    
    // register observer to notification center
    [self registerObservers];
    
    // reload manifest data
    [[CCConnectionHelper sharedClient] getAppManifest:NO completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task) {
        // update left of input toolbar
        [self updateLeftOfInputToolbar];
        [self displayWidgetMenu];
    }];
    
    CCLiveLocationTask *task = [[CCConnectionHelper sharedClient].shareLocationTasks objectForKey:self.channelId];
    if (task != nil) {
        liveColocationShareTimer = task.liveColocationShareTimer;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    [self.collectionView reloadData];
    
    // set pendding fixed phrase
    if(self.pendingFixedPhrase != nil && self.pendingFixedPhrase.length > 0) {
        [self.inputToolbar.contentView.textView setText:self.pendingFixedPhrase];
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        [self.inputToolbar toggleSendButtonEnabled];
        self.pendingFixedPhrase = nil;
    }
    
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
        self.topContentAdditionalInset = 0;
    }

    // update user info
    [[ChatCenter sharedInstance] isTokenVailid:^(BOOL result) {
        
    }];
    if ( self.inputToolbar.contentView.textView.text.length > CCInputTextLimit) {
        self.inputToolbar.contentView.rightBarButtonItem.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Remove observer
    [self removeObservers];
    
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == NO && !self.isReturnFromVideoCallView) {
        [[CCConnectionHelper sharedClient] setDelegate:nil];
        [[CCConnectionHelper sharedClient] setCurrentView:nil];
    }
    
    [super viewWillDisappear:animated];
    isDisplayingSuggestionView = NO;
    if (self.inputToolbarMenuView.shouldShowSuggestion) {
        UIButton *button = self.inputToolbarMenuView.buttons[1];
        [button setTintColor:[UIColor lightGrayColor]];
    }
    self.inputToolbar.contentView.textView.text = @"";
    [self.inputToolbar.contentView.textView resignFirstResponder];
    [self.inputToolbar.contentView.textView setHidden:YES];
}

- (void)updateViewOrientation {
    if(newMessageView != nil) {
        newMessageView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height - self.inputToolbar.bounds.size.height - newMessageView.bounds.size.height/2);
    }
}

#pragma mark - Notification Center
- (void)registerObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserReactionToSticker:) name:kCCNoti_UserReactionToSticker object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserReactToStickerContent:) name:kCCNoti_UserReactionToStickerContent object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFreeWordTextviewDidBeginEditing:) name:kCCNoti_TextViewDidBeginEditing object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserDidReactPulldownWidget:) name:kCCNoti_UserReactionToPulldownWidget object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserSelectionToPulldownWidget:) name:kCCNoti_UserSelectionToPulldownWidget object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCCNoti_UserReactionToSticker object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCCNoti_UserReactionToStickerContent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCCNoti_TextViewDidBeginEditing object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCCNoti_UserReactionToPulldownWidget object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCCNoti_UserSelectionToPulldownWidget object:nil];
}

#pragma mark - Setup
-(void)setUidAndToken{
    if ([[CCConstants sharedInstance] getKeychainUid] && [[CCConstants sharedInstance] getKeychainToken]) {
        self.uid                = [[CCConstants sharedInstance] getKeychainUid];
        self.senderId           = self.uid;
        self.senderDisplayName  = self.uid;
        self.token              = [[CCConstants sharedInstance] getKeychainToken];
    }
}

- (BOOL)hideNaviShadowWithView:(UIView *)view
{
    if ([view isKindOfClass:[UIImageView class]] && view.frame.size.height <= 1) {
        view.hidden = YES;
        return YES;
    }
    for (UIView *sub in view.subviews) {
        if ([self hideNaviShadowWithView:sub]) {
            return YES;
        }
    }
    return NO;
}

-(void)viewSetUp{
    ///Initialize
    self.isReturnFromStickerView = NO;
    self.isReturnFromRightMenuView = NO;
    self.isReturnFromVideoCallView = NO;
    [self hideNaviShadowWithView:self.navigationController.navigationBar];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.inputToolbar.maximumHeight = 80;
    self.inputToolbar.maximumNumberOfLine = 4;
    [self.inputToolbar.contentView.leftBarButtonItem setHidden:YES];
    keyboardHeight = 216;
    self.inputTextView.delegate = self;
    currentInputMode = kInputKeyboardMode;
    self.fixedPhrases = [[NSMutableArray alloc] init];
    loadPreviousMessage = NO;
    fullScreen = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self findConstraints];
    ///Date
    UIColor *color = [UIColor lightGrayColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    float datetimeFontSize;
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
        datetimeFontSize = 12.0f;
    }else{
        datetimeFontSize = 10.0f;
    }
    [CCJSQMessagesTimestampFormatter sharedFormatter].dateTextAttributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:datetimeFontSize],
                                                                              NSForegroundColorAttributeName : color,
                                                                              NSParagraphStyleAttributeName : paragraphStyle };
    [CCJSQMessagesTimestampFormatter sharedFormatter].timeTextAttributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:datetimeFontSize],
                            NSForegroundColorAttributeName : color,
                            NSParagraphStyleAttributeName : paragraphStyle };
    [self.inputToolbar.contentView.textView setTintColor:[UIColor blueColor]];
    ///toolBar
    /**
     *  Customize your toolbar buttons
     *
     *  self.inputToolbar.contentView.leftBarButtonItem = custom button or nil to remove
     *  self.inputToolbar.contentView.rightBarButtonItem = custom button or nil to remove
     */

    // update left of input toolbar
    [self updateLeftOfInputToolbar];
    
    self.inputToolbar.contentView.backgroundColor = [UIColor whiteColor];
    self.inputToolbar.contentView.textView.layer.borderWidth = 0.0;
    self.inputToolbar.contentView.textView.placeHolder = CCLocalizedString(@"Compose your message");
    self.inputToolbar.contentView.textView.textColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.0];
    self.inputToolbar.contentView.textView.font = [UIFont systemFontOfSize:14.0f];
    [self.inputToolbar.contentView.textView setUserInteractionEnabled:YES];
    ///sendButton
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendButton setTitle:CCLocalizedString(@"Send") forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    sendButton.tintColor = [[CCConstants sharedInstance] baseColor];
    self.inputToolbar.contentView.rightBarButtonItem = sendButton;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    ///Circle avatar
    circleAvatarSize = [[CCConstants sharedInstance] chatViewCircleAvatarSize];
    randomCircleAvatarFontSize = circleAvatarSize*0.75;
    randomCircleAvatarTextOffset = 1.0f + (circleAvatarSize-24.0f)*0.0625;
    self.avatars = [[NSDictionary alloc] init];
    ///An image without tail is used for image sticker and jsq_bubbleCompactTaillessImage is an image with tail
    CCJSQMessagesBubbleImageFactory *bubbleFactory = [[CCJSQMessagesBubbleImageFactory alloc] initWithBubbleImage: [UIImage jsq_bubbleCompactTaillessImage] capInsets:UIEdgeInsetsZero];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[[CCConstants sharedInstance] baseColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]];
    
    [self navigationBarSetup];
}

- (void)navigationBarSetup{
    ///Navigation Items
    if ([CCConstants sharedInstance].backBtnNormal == nil && [CCConstants sharedInstance].backBtnHilighted == nil && [CCConstants sharedInstance].backBtnDisable == nil) {
        [CCConstants sharedInstance].backBtnNormal = CC_BUTTON_PRESS_BACK;
    }
    
    //--------------------------------------------------------------------
    //
    // Title View
    //
    //--------------------------------------------------------------------
    navigationTitleView = [[CCChatViewNavigationTitle alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 80 * [UIScreen mainScreen].nativeScale, self.navigationController.navigationBar.frame.size.height)];
    navigationTitleView.delegate = self;
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == NO){
        self.navigationItem.titleView = navigationTitleView;
    }
    
    //--------------------------------------------------------------------
    //
    // Right menu buttons init
    //
    //--------------------------------------------------------------------
    UIButton* voiceCallButtonView = [self barButtonItemWithImageName:[CCConstants sharedInstance].voiceCallBtnNormal
                                                  hilightedImageName:[CCConstants sharedInstance].voiceCallBtnHilighted
                                                    disableImageName:[CCConstants sharedInstance].voiceCallBtnDisable
                                                              target:self
                                                            selector:@selector(pressVoiceCall)];
    if ([CCConstants sharedInstance].headerItemColor == nil) {
        voiceCallButtonView.tintColor = [CCConstants sharedInstance].baseColor;
    }
    voiceCallButton = [[UIBarButtonItem alloc] initWithCustomView:voiceCallButtonView];
    UIButton* videoCallButtonView = [self barButtonItemWithImageName:[CCConstants sharedInstance].videoCallBtnNormal
                                                  hilightedImageName:[CCConstants sharedInstance].videoCallBtnHilighted
                                                    disableImageName:[CCConstants sharedInstance].videoCallBtnDisable
                                                              target:self
                                                            selector:@selector(pressVideoCall)];
    if ([CCConstants sharedInstance].headerItemColor == nil) {
        videoCallButtonView.tintColor = [CCConstants sharedInstance].baseColor;
    }
    videoCallButton = [[UIBarButtonItem alloc] initWithCustomView:videoCallButtonView];
    
    UIButton* rightMenuButtonView = [self barButtonItemWithImageName:[CCConstants sharedInstance].infoBtnNormal
                                                  hilightedImageName:[CCConstants sharedInstance].infoBtnHilighted
                                                    disableImageName:[CCConstants sharedInstance].infoBtnDisable
                                                              target:self
                                                            selector:@selector(pressInfo:)];
    rightMenuButton = [[UIBarButtonItem alloc] initWithCustomView:rightMenuButtonView];
    
    rightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightSpacer.width = 10;
    
    //--------------------------------------------------------------------
    //
    //  Buttons
    //
    //--------------------------------------------------------------------
    if ([CCConstants sharedInstance].isAgent == NO) {
        //--------------------------------------------------------------------
        //
        // Guest
        //
        // We have supported two cases for displaying ChatView
        // 1. With Navigation Controller
        // 2. Without Navigation Controller(ex. Customer wants to manage controller by their own)
        // 3. From HistoryView
        //
        //--------------------------------------------------------------------
        
        //--------------------------------------------------------------------
        //
        //  Left buttons
        //
        //--------------------------------------------------------------------
        UIBarButtonItem *leftBarButton;
        UIButton* leftButton;
        if (self.navigationController.viewControllers.count == 1){
            //--------------------------------------------------------------------
            // 1. With Navigation Controller(Show close button)
            //--------------------------------------------------------------------
            if ([CCConstants sharedInstance].closeBtnNormal != nil
                || [CCConstants sharedInstance].closeBtnHilighted != nil
                || [CCConstants sharedInstance].closeBtnDisable != nil) {
                leftButton = [self barButtonItemWithImageName:[CCConstants sharedInstance].closeBtnNormal
                                           hilightedImageName:[CCConstants sharedInstance].closeBtnHilighted
                                             disableImageName:[CCConstants sharedInstance].closeBtnDisable
                                                       target:self
                                                     selector:@selector(pressClose:)];
                leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            }else{
                leftBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                              target:self
                                                                              action:@selector(pressClose:)];
                
            }
        }else{
            //--------------------------------------------------------------------
            // 2. Without Navigation Controller(Show back arrow button)
            // 3. From HistoryView
            //--------------------------------------------------------------------
            if ([CCConstants sharedInstance].backBtnNormal != nil
                || [CCConstants sharedInstance].backBtnHilighted != nil
                || [CCConstants sharedInstance].backBtnDisable != nil) {
                ///Use custom back button
                leftButton = [self barButtonItemWithImageName:[CCConstants sharedInstance].backBtnNormal
                                           hilightedImageName:[CCConstants sharedInstance].backBtnHilighted
                                             disableImageName:[CCConstants sharedInstance].backBtnDisable
                                                       target:self
                                                     selector:@selector(pressBack:)];
                
                //--------------------------------------------------------------------
                // Without this UIBarButtonItem was not changed
                //--------------------------------------------------------------------
                if ([CCConstants sharedInstance].headerItemColor == nil) {
                    leftButton.tintColor = [UIColor colorWithRed:41/255.0 green:59/255.0 blue:84/255.0 alpha:1.0];
                }
                
                leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            }
        }
        if ([CCConstants sharedInstance].headerItemColor == nil) {
            leftBarButton.tintColor = [UIColor colorWithRed:41/255.0 green:59/255.0 blue:84/255.0 alpha:1.0];
        }
        if ([CCConstants sharedInstance].hideChatViewCloseBtn == YES) {
            //--------------------------------------------------------------------
            // hideChatViewCloseBtn is old function
            //--------------------------------------------------------------------
            self.navigationItem.leftBarButtonItem = nil;
            [self.navigationItem setHidesBackButton:YES];
        }else{
            self.navigationItem.leftBarButtonItem = leftBarButton;
        }
        
        //--------------------------------------------------------------------
        //
        //  Right buttons
        //
        //--------------------------------------------------------------------
        if([self isVideocallEnabled]) {
            self.navigationItem.rightBarButtonItems = @[rightSpacer,videoCallButton, voiceCallButton];
        } else {
            self.navigationItem.rightBarButtonItems = nil;
        }
    } else {
        //--------------------------------------------------------------------
        //
        //  Agent
        //
        //--------------------------------------------------------------------
        
        //--------------------------------------------------------------------
        //
        //  Left buttons
        //
        //--------------------------------------------------------------------
        if ([CCConstants sharedInstance].backBtnNormal != nil
            || [CCConstants sharedInstance].backBtnHilighted != nil
            || [CCConstants sharedInstance].backBtnDisable != nil) {
            ///Use custom back button
            UIButton *leftButton = [self barButtonItemWithImageName:[CCConstants sharedInstance].backBtnNormal
                                       hilightedImageName:[CCConstants sharedInstance].backBtnHilighted
                                         disableImageName:[CCConstants sharedInstance].backBtnDisable
                                                   target:self
                                                 selector:@selector(pressBack:)];
            if ([CCConstants sharedInstance].headerItemColor == nil) {
                leftButton.tintColor = [UIColor colorWithRed:41/255.0 green:59/255.0 blue:84/255.0 alpha:1.0];
            }
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            if ([CCConstants sharedInstance].headerItemColor == nil) {
                self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:41/255.0 green:59/255.0 blue:84/255.0 alpha:1.0];
            }
        }
        
        //--------------------------------------------------------------------
        //
        //  Right button
        //
        //--------------------------------------------------------------------
        if([self isVideocallEnabled]) {
            self.navigationItem.rightBarButtonItems = @[rightSpacer, videoCallButton, voiceCallButton];
        } else {
            self.navigationItem.rightBarButtonItems = nil;
        }
    }
}

- (void)setNavigationBarStyles{
    //--------------------------------------------------------------------
    //
    // Navigation Color, barStyles
    //
    //--------------------------------------------------------------------
    self.navigationController.navigationBar.translucent = [[CCConstants sharedInstance] headerTranslucent];
    self.navigationController.navigationBar.barStyle = [[CCConstants sharedInstance] headerBarStyle];
    if ([CCConstants sharedInstance].headerBackgroundColor != nil) {
        self.navigationController.navigationBar.barTintColor = [[CCConstants sharedInstance] headerBackgroundColor];
    }else{
        self.navigationController.navigationBar.barTintColor = [[CCConstants sharedInstance] chatHeaderBackgroundColor];
    }
    if ([CCConstants sharedInstance].headerItemColor != nil) {
        self.navigationController.navigationBar.tintColor = [[CCConstants sharedInstance] headerItemColor];
    }
    [self addNavigationBottomBorder];
}

- (void)addNavigationBottomBorder{
    CGRect bottomBorderRect = CGRectMake(0, CGRectGetHeight(self.navigationController.navigationBar.frame), CGRectGetWidth(self.navigationController.navigationBar.frame), 1.0f);
    navigationBottomBorder = [[UIView alloc] initWithFrame:bottomBorderRect];
    [navigationBottomBorder setBackgroundColor:[[CCConstants sharedInstance] headerBottomLineColor]];
    [self.navigationController.navigationBar addSubview:navigationBottomBorder];
}

- (void)removeNavigationBottomBorder{
    [navigationBottomBorder removeFromSuperview];
    navigationBottomBorder = nil;
}

- (void) updateLeftOfInputToolbar {
    [self.inputToolbar.contentView.leftBarButtonItem setHidden:NO];
    UIButton *switchToToolbarMenuButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [switchToToolbarMenuButton setImage:[UIImage SDKImageNamed:@"CCcancel_btn"] forState:UIControlStateNormal];
    switchToToolbarMenuButton.tintColor = [[CCConstants sharedInstance] baseColor];
    self.inputToolbar.contentView.leftBarButtonItem = switchToToolbarMenuButton;
}

- (UIButton *)barButtonItemWithImageName:(NSString *)imageName hilightedImageName:(NSString *)hilightedImageName disableImageName:(NSString*)disableImageName target:(id)target selector:(SEL)action
{
    UIImage *imageOriginal = [UIImage SDKImageNamed:imageName];
    UIImage *image = [imageOriginal imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = (CGRect){0,0,image.size.width, image.size.height};
    [btn setImage:image forState:UIControlStateNormal];
    if(hilightedImageName != nil) {[btn setImage:[UIImage SDKImageNamed:hilightedImageName] forState:UIControlStateHighlighted];}
    if(disableImageName != nil)   {[btn setImage:[UIImage SDKImageNamed:disableImageName] forState:UIControlStateDisabled];}
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(void)setChannelId:(NSString *)channelId{
    _channelId              = channelId;
    if([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES){
        self.inputTextView.text = @"";
        [self setUidAndToken];
        if (isInitializedJSQMessange == YES) [self loadLocalMessages:channelId]; ///before loading message and creating avatar, must initialize JSQMessangeLibrary
    }
}

-(void)customNibsSetUp{ ///for calender sticker
    /**
     *  These for stickers
     */
    
    cellNibNames = @{
                     CC_RESPONSETYPECALL       : @{ @"in" :@"CCPhoneStickerCollectionViewCellIncoming",
                                                    @"out":@"CCPhoneStickerCollectionViewCellOutgoing"},
                     CC_RESPONSETYPEQUESTION   : @{ @"in" :@"CCYesNoCollectionViewCellIncoming",
                                                    @"out":@"CCYesNoCollectionViewCellOutgoing"},
                     CC_RESPONSETYPEPDF        : @{ @"in" :@"CCPDFCollectionViewCellIncoming",
                                                    @"out":@"CCPDFCollectionViewCellOutgoing"},
                     CC_RESPONSETYPEINFORMATION: @{ @"in" :@"CCInformationCollectionViewCell",
                                                    @"out":@"CCInformationCollectionViewCell"},
                     CC_RESPONSETYPEIMAGE      : @{ @"in" :@"CCCommonStickerCollectionViewCellIncoming",
                                                    @"out":@"CCCommonStickerCollectionViewCellOutgoing"},
                     CC_STICKERTYPEIMAGE       : @{ @"in" :@"CCCommonStickerCollectionViewCellIncoming",
                                                    @"out":@"CCCommonStickerCollectionViewCellOutgoing"},
                     CC_RESPONSETYPESTICKER    : @{ @"in" :@"CCCommonStickerCollectionViewCellIncoming",
                                                    @"out":@"CCCommonStickerCollectionViewCellOutgoing"},
                     CC_RESPONSETYPESUGGESTION : @{ @"in" :@"CCCommonStickerCollectionViewCellSuggestion",
                                                    @"out":@"CCCommonStickerCollectionViewCellSuggestion"},
                     CC_RESPONSETYPEPROPERTY   : @{ @"in" :@"CCPropertyCollectionViewCell",
                                                    @"out":@"CCPropertyCollectionViewCell"},
                     CC_RESPONSETYPEDATETIMEAVAILABILITY :@{ @"in" :@"CCDateTimeCollectionViewCellIncoming",
                                                             @"out":@"CCDateTimeCollectionViewCellOutgoing"},
                     CC_WIDGETTYPECALENDER     : @{ @"in": @"CCCalendarCollectionViewCellIncoming",
                                                    @"out":@"CCCalendarCollectionViewCellOutgoing"},
                     CC_RESPONSETYPETHUMB      : @{ @"in" :@"CCThumbCollectionViewCellIncoming",
                                                    @"out":@"CCThumbCollectionViewCellOutgoing"},
                     CC_RESPONSETYPEMESSAGE    : @{ @"in" :@"CCCommonStickerCollectionViewCellIncoming",
                                                    @"out":@"CCCommonStickerCollectionViewCellOutgoing"}
                        };

    for(NSString *key in cellNibNames) {
        for(NSString *inOutIndex in @[@"in", @"out"]) {
            NSString *keyWithIO  = [NSString stringWithFormat:@"%@_%@", key, inOutIndex];
            NSString *nibName = cellNibNames[key][inOutIndex];


            UINib *nib = [UINib nibWithNibName:nibName bundle:SDK_BUNDLE];
            [self.collectionView registerNib:nib forCellWithReuseIdentifier:keyWithIO];
        }
    }
    
    
    //
    // Other Nibs
    //
    
    // TODO: Not used?
    UINib *nib1 = [UINib nibWithNibName:@"CCCalendarCollectionViewCellFullWidthOutgoing" bundle:SDK_BUNDLE];
    [self.collectionView registerNib:nib1 forCellWithReuseIdentifier:@"CCCalendarCollectionViewCellFullWidthOutgoing"];
    
    UINib *nib2 = [UINib nibWithNibName:@"CCCalendarTimePicker" bundle:SDK_BUNDLE];
    [self.collectionView registerNib:nib2 forCellWithReuseIdentifier:@"CCCalendarTimePicker"];
    
    
}

-(void) registerNibWithName:(NSString *)nibName {
    UINib *nib = [UINib nibWithNibName:nibName bundle:SDK_BUNDLE];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:nibName];
}

#pragma mark - Actions

-(void)pressBack:(id)sender {
    [self removeNavigationBottomBorder];
    [self.navigationController popViewControllerAnimated:YES];
    [[CCConnectionHelper sharedClient] setDelegate:nil];
    [[CCConnectionHelper sharedClient] setCurrentView:nil];
}

-(void)pressClose:(id)sender {
    [self removeNavigationBottomBorder];
    self.parentViewController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
    [self dismissViewControllerAnimated:YES completion:self.closeChatViewCallback];
    [[CCConnectionHelper sharedClient] setDelegate:nil];
    [[CCConnectionHelper sharedClient] setCurrentView:nil];
}

-(void)pressInfo:(id)sender {
    self.isReturnFromRightMenuView = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter" bundle:SDK_BUNDLE];
    CCChannelDetailViewController *channelInfoView = [storyboard  instantiateViewControllerWithIdentifier:@"channelDetailViewController"];;
    channelInfoView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    channelInfoView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    channelInfoView.channelId = self.channelId;
    channelInfoView.orgUid = self.orgUid;
    channelInfoView.uid = self.uid;
    if(!(self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.frame.size.height))) {
        [self scrollToBottomAnimated:YES];
        newMessageView.hidden = YES;
    }
    [self.navigationController pushViewController:channelInfoView animated:YES];
}

//--------------------------------------------------------------------
// Video Call, Voice Call
//--------------------------------------------------------------------
-(void)pressVideoCall {
    if (!_isAbleToPressCall) {
        return;
    }
    //
    // Call from Guest
    //
    if(!([CCConstants sharedInstance].isAgent== YES)) {
        [self processVideoCall:self.channelUid callerInfo:@{@"user_id": @([self.uid intValue])} receiverInfo:@[] actionCall:CC_ACTIONTYPE_VIDEOCALL];
        return;
    }
    
    //
    // Call from Agent
    //
    NSArray *guests = [CCChatViewHelper filteredGuestFrom:self.userVideoChat];
    if(guests.count == 0) {
        return;
    } else if (guests.count == 1) {
        [self processVideoCall:self.channelUid callerInfo:@{@"user_id": @([self.uid intValue])} receiverInfo:guests actionCall:CC_ACTIONTYPE_VIDEOCALL];
    } else {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Select a user to call") message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        for(NSDictionary * guest in guests) {
            NSString *guestName = [guest valueForKey:@"display_name"];
            if (guestName != nil) {
                UIAlertAction *action = [UIAlertAction actionWithTitle:guestName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self processVideoCall:self.channelUid callerInfo:@{@"user_id": self.uid} receiverInfo:@[guest] actionCall:CC_ACTIONTYPE_VIDEOCALL];
                }];
                [alertVC addAction:action];
            }
        }
        
        // Cancel action
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:cancelAction];
        
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

-(void)pressVoiceCall {
    if (!_isAbleToPressCall) {
        return;
    }
    //
    // Call from Guest
    //
    if(!([CCConstants sharedInstance].isAgent== YES)) {
        [self processVideoCall:self.channelUid callerInfo:@{@"user_id": @([self.uid intValue])} receiverInfo:@[] actionCall:CC_ACTIONTYPE_VOICECALL];
        return;
    }
    
    //
    // Call from Agent
    //
    NSArray *guests = [CCChatViewHelper filteredGuestFrom:self.userVideoChat];
    if(guests.count == 0) {
        return;
    } else if (guests.count == 1) {
        [self processVideoCall:self.channelUid callerInfo:@{@"user_id": @([self.uid intValue])} receiverInfo:guests actionCall:CC_ACTIONTYPE_VOICECALL];
    } else {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Select a user to call") message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        for(NSDictionary * guest in guests) {
            NSString *guestName = [guest valueForKey:@"display_name"];
            if (guestName != nil) {
                UIAlertAction *action = [UIAlertAction actionWithTitle:guestName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self processVideoCall:self.channelUid callerInfo:@{@"user_id": @([self.uid intValue])} receiverInfo:@[guest] actionCall:CC_ACTIONTYPE_VOICECALL];
                }];
                [alertVC addAction:action];
            }
        }
        
        // Cancel action
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:cancelAction];
        
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

-(void)processVideoCall:(NSString *) channelId callerInfo:(NSDictionary *) callerInfo receiverInfo:(NSArray *) receiverInfo actionCall:(NSString *)actionCall {
    _isAbleToPressCall = NO;
    [[CCConnectionHelper sharedClient] getCallIdentity:self.channelId callerInfo:@{@"user_id": @([self.uid intValue])} receiverInfo:@[] actionCall:actionCall completeHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
        _isAbleToPressCall = YES;
        if (error == nil && result != nil) {
            NSString *messageId = result[@"id"];
            [self handleCall:messageId result:result];
        }
    }];
}

- (void)handleCall:(NSString *)messageId result:(NSDictionary *)result {
    if (result[@"content"] != nil) {
        NSDictionary *content = result[@"content"];
        NSDictionary *callerInfo = content[@"caller"];
        NSString *videoAction = content[@"action"];
        NSString *apiKey = content[@"api_key"];
        NSString *sessionId = content[@"session"];
        CCOpenTokVideoCallViewController *videoCallVC = [[CCOpenTokVideoCallViewController alloc] initWithNibName:@"CCOpenTokVideoCallViewController" bundle:SDK_BUNDLE];
        videoCallVC.isCaller = YES;
        videoCallVC.channelUid = self.channelId;
        videoCallVC.messageId = messageId;
        videoCallVC.publisherInfor = callerInfo;
        videoCallVC.videoAction = videoAction;
        videoCallVC.apiKey = apiKey;
        videoCallVC.sessionId = sessionId;
        if ([videoAction isEqualToString:CC_ACTIONTYPE_VOICECALL]) {
            videoCallVC.publishVideo = NO;
        } else {
            videoCallVC.publishVideo = YES;
        }
        videoCallVC.publishAudio = YES;
        
        self.delegateCall = videoCallVC;
        NSArray *viewControllers = self.navigationController.viewControllers;
        for (int i = 0; i < viewControllers.count; i++) {
            if([[viewControllers objectAtIndex:i] isKindOfClass:[CCOpenTokVideoCallViewController class]]) {
                return;
            }
        }
        self.isReturnFromVideoCallView = YES;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:videoCallVC];
        [self presentViewController:navController animated:YES completion:nil];
    }
}

//--------------------------------------------------------------------
// Input modes
//--------------------------------------------------------------------
- (void)switchToInputTextMode {
    isKeyboardShowing = YES;
    [self.inputToolbar.contentView.textView setHidden:NO];
    [self.inputToolbar.contentView.textView becomeFirstResponder];
    self.inputToolbar.contentView.textView.inputView = nil;
    [self.inputToolbar.contentView.textView reloadInputViews];
    [self loadDraftMessage];
    [self.inputToolbarMenuView setHidden:YES];
    [self scrollToBottomAnimated:YES];
}

- (void)switchToSuggestionMode {
    [self displaySuggestionWithActionData:self.suggestionActionData];
}

- (void)switchToSaveWidget {
    if (self.fixedPhrases != nil){
        [self displayFixedPhrase:self.fixedPhrases];
    }
}

//--------------------------------------------------------------------
// Location, Live Location widgets
//--------------------------------------------------------------------
-(void)pressLocationWidget {
    UIAlertController *alertVC;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        alertVC = [UIAlertController alertControllerWithTitle:@"" message:CCLocalizedString(@"What kind of Location do you want to share?") preferredStyle:UIAlertControllerStyleAlert];
    } else {
        alertVC = [UIAlertController alertControllerWithTitle:@"" message:CCLocalizedString(@"What kind of Location do you want to share?") preferredStyle:UIAlertControllerStyleActionSheet];
    }
    UIAlertAction *venueLocationAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Send Venue") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        isDisplayingAlert = NO;
        [self pressLocation];
    }];
    
    UIAlertAction *liveLocationAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Share Live Location") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        isDisplayingAlert = NO;
        [self pressLivelocation];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        isDisplayingAlert = NO;
        if (!isDisplayingSuggestionView) {
            [self displayFixedPhraseOrSuggestionIfNeed];
        } else {
            [self displaySuggestionIfNeed];
        }
    }];
    
    [alertVC addAction:venueLocationAction];
    [alertVC addAction:liveLocationAction];
    [alertVC addAction:cancelAction];
    isDisplayingAlert = YES;
    [self.inputToolbar.contentView.textView resignFirstResponder];
    [self presentViewController:alertVC animated:YES completion:nil];
}

///
/// Location widget editor
///
-(void)pressLocation{
    if ([CLLocationManager locationServicesEnabled] == NO) {
        // Display alert to the user.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Location services")
                                                                       message:CCLocalizedString(@"Location services are not enabled on this device. Please enable location services in settings.")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Dismiss") style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return ;
    }
    
    [self openLocationPicker:nil msgId:nil callbackHandler:nil];
}

- (void) openLocationPicker:(NSDictionary*)stickerAction msgId:(NSNumber*)msgId {
    [self openLocationPicker:stickerAction msgId:msgId callbackHandler:^{
        [[CCConnectionHelper sharedClient] sendMessageResponseForChannel:self.channelId msgUid:[self generateMessageUniqueId] answer:stickerAction answerLabel:stickerAction[@"label"] replyTo:[msgId stringValue] completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task) {
        }];
    }];
}

- (void)openLocationPicker:(NSDictionary*)stickerAction msgId:(NSNumber*)msgId callbackHandler: (void (^)(void)) callbackHandler {
    if (([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable && [CCConnectionHelper sharedClient].webSocketStatus == CCCWebSocketOpened) || CCLocalDevelopmentMode) {
        CCLocationStickerViewController *locationStickerViewController = [[CCLocationStickerViewController alloc] initWithNibName:@"CCLocationStickerViewController" bundle:SDK_BUNDLE];
        [locationStickerViewController setDelegate:self];
        if (callbackHandler != nil) {
            [locationStickerViewController setCloseLocationStickerCallback:callbackHandler];
        }
        UINavigationController *rootNC = [[UINavigationController alloc] initWithRootViewController:locationStickerViewController];
        [self presentViewController:rootNC animated:YES completion:^{
            self.isReturnFromStickerView = YES;
        }];
        
    }else{
        [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
    }
}

///
/// Live location widget
///
-(void)pressLivelocation{
    [self openLiveLocationWidgetEditor:nil msgId:nil callbackHandler:nil];
}

- (void)openCoLocationPicker:(NSDictionary*)stickerAction msgId:(NSNumber*)msgId {
    [self openLiveLocationWidgetEditor:stickerAction msgId:msgId callbackHandler:^{
        [[CCConnectionHelper sharedClient] sendMessageResponseForChannel:self.channelId msgUid:[self generateMessageUniqueId] answer:stickerAction answerLabel:stickerAction[@"label"] replyTo:[msgId stringValue] completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task) {
        }];
    }];
}

- (void) openLiveLocationWidgetEditor:(NSDictionary*)stickerAction msgId:(NSNumber*)msgId callbackHandler:(void (^)(void)) callbackHandler{
    [self locationSetup];
    if (([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable && [CCConnectionHelper sharedClient].webSocketStatus == CCCWebSocketOpened) || CCLocalDevelopmentMode) {
        CCLiveLocationStickerViewController *locationStickerViewController = [[CCLiveLocationStickerViewController alloc] initWithNibName:@"CCLiveLocationStickerViewController" bundle:SDK_BUNDLE];
        [locationStickerViewController setDelegate:self];
        locationStickerViewController.isOpenedFromWidgetMessage = NO;
        if (callbackHandler != nil) {
            [locationStickerViewController setCloseCoLocationStickerCallback:callbackHandler];
        }
        UINavigationController *rootNC = [[UINavigationController alloc] initWithRootViewController:locationStickerViewController];
        [self presentViewController:rootNC animated:YES completion:^{
            self.isReturnFromStickerView = YES;
        }];
        return;
    }else{
        [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
    }
}

-(void)pressCalendar{
    CCCalendarTimePickerController *calendarView = [[CCCalendarTimePickerController alloc] initWithNibName:@"CCCalendarTimePicker" bundle:SDK_BUNDLE];
    calendarView.delegate = self;
    [calendarView setCloseCalendarTimePickerCallback:^(NSArray *dateTimes) {
        if (dateTimes != nil) {
            [self sendDateTime:dateTimes];
        }
    }];
    UINavigationController *rootNC = [[UINavigationController alloc] initWithRootViewController:calendarView];
    [self presentViewController:rootNC animated:YES completion:^{
        self.isReturnFromStickerView = YES;
    }];
}

- (void)proposeOtherSlots:(NSDictionary*)stickerAction msgId:(NSNumber*)msgId {
    CCCalendarTimePickerController *calendarView = [[CCCalendarTimePickerController alloc] initWithDelegate:self];
    [calendarView setCloseWidgetCalendarCallback:^{
        [[CCConnectionHelper sharedClient] sendMessageResponseForChannel:self.channelId msgUid:[self generateMessageUniqueId] answer:stickerAction answerLabel:stickerAction[@"label"] replyTo:[msgId stringValue] completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task) {
        }];
    }];
    UINavigationController *rootNC = [[UINavigationController alloc] initWithRootViewController:calendarView];
    [self presentViewController:rootNC animated:YES completion:^{
        self.isReturnFromStickerView = YES;
    }];
}

-(void)pressCalendarChoiceBtn:(CCChoiceButton*)btn{
    self.inputToolbar.contentView.textView.text = [btn.answerText stringByAppendingFormat:@" %@", CCLocalizedString(@"works!")];
    self.inputToolbar.contentView.rightBarButtonItem.enabled = YES;
}

-(void)pressChoiceBtn:(CCChoiceButton*)btn{
    NSLog(@"pressChoiceBtn");
    CCJSQMessage *msg = [self.messages objectAtIndex:btn.index.item];
    if(msg.answer != nil && ![msg.answer isEqual:[NSNull null]]){
        return;
    }
    
    if ([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable || CCLocalDevelopmentMode) {
        [[CCConnectionHelper sharedClient] sendMessageAnswer:self.channelId
                                                   messageId:msg.uid
                                                 answer_type:btn.answerType
                                                 question_id:btn.questionId
                                           completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
                                               if (result != nil) {
                                                   msg.answer = @{@"answer_type":btn.answerType,
                                                                  @"question_id":btn.questionId};
                                                   [self finishSendingMessageAnimated:NO];
                                                   [self.collectionView reloadData];
                                               }else{
                                                   [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];                                                   
                                               }
                                           }];
    }else{
        [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
    }
}

///
/// Question widget editor
///
- (void)openQuestionWidgetEditor:(NSDictionary*)stickerAction msgId:(NSNumber*)msgId {
    [self openQuestionWidgetEditor:stickerAction msgId:msgId callbackHandler:^{
        [[CCConnectionHelper sharedClient] sendMessageResponseForChannel:self.channelId msgUid:[self generateMessageUniqueId] answer:stickerAction answerLabel:stickerAction[@"label"] replyTo:[msgId stringValue] completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task) {
        }];
    }];
}

-(void)openQuestionWidgetEditor:(NSDictionary*)stickerAction msgId:(NSNumber*)msgId callbackHandler:(void (^)(void))callbackHandler {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CCQuestionWidgetEditor" bundle:SDK_BUNDLE];
    CCQuestionWidgetEditorViewController *questionWidgetEditorViewController = [sb instantiateViewControllerWithIdentifier:@"CCQuestionWidgetEditorViewController"];
    [questionWidgetEditorViewController setDelegate: self];
    if (callbackHandler != nil) {
        [questionWidgetEditorViewController setCloseQuestionCallback:callbackHandler];
    }
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:questionWidgetEditorViewController];
    [self presentViewController:navController animated:YES completion:^{
        self.isReturnFromStickerView = YES;
    }];

}

-(void)pressThumb{
    [self openQuestionWidgetEditor:nil msgId:nil callbackHandler:nil];
    return;
}

-(void)pressPdfLinkBtn:(CCChoiceButton*)btn{
    NSLog(@"pressPdfLinkBtn");
    NSURL *url = [NSURL URLWithString:btn.questionId];
    [self openURL:url];
    
}

///
/// Image picker
///
-(void)pressImage{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    if (([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable && [CCConnectionHelper sharedClient].webSocketStatus == CCCWebSocketOpened)|| CCLocalDevelopmentMode) {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
            UIImagePickerController *picker;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                picker = [[CCImagePickerViewController alloc] init];
            } else {
                picker = [[UIImagePickerController alloc] init];
            }
            picker.navigationBar.tintColor = [[CCConstants sharedInstance] baseColor];
            picker.modalPresentationStyle = UIModalPresentationCurrentContext;
            picker.sourceType = sourceType;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:^{
                self.isReturnFromStickerView = YES;
            }];
        }
    }else{
        [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
    }
}

- (void)openImagePicker:(NSDictionary*)stickerAction msgId:(NSNumber*)msgId {
    if (([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable && [CCConnectionHelper sharedClient].webSocketStatus == CCCWebSocketOpened)|| CCLocalDevelopmentMode) {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
            UIImagePickerController *picker;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                picker = [[CCImagePickerViewController alloc] init];
            } else {
                picker = [[UIImagePickerController alloc] init];
            }
            picker.navigationBar.tintColor = [[CCConstants sharedInstance] baseColor];
            picker.modalPresentationStyle = UIModalPresentationCurrentContext;
            picker.sourceType = sourceType;
            picker.delegate = self;
            [[CCConnectionHelper sharedClient] sendMessageResponseForChannel:self.channelId msgUid:[self generateMessageUniqueId] answer:stickerAction answerLabel:stickerAction[@"label"] replyTo:[msgId stringValue] completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task) {
            }];
            [self presentViewController:picker animated:YES completion:^{
                self.isReturnFromStickerView = YES;
            }];
        }
    }else{
        [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
    }
}

-(void)takePhoto{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    if (([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable && [CCConnectionHelper sharedClient].webSocketStatus == CCCWebSocketOpened)|| CCLocalDevelopmentMode) {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
            UIImagePickerController *picker;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                picker = [[CCImagePickerViewController alloc] init];
            } else {
                picker = [[UIImagePickerController alloc] init];
            }
            picker.navigationBar.tintColor = [[CCConstants sharedInstance] baseColor];
            picker.modalPresentationStyle = UIModalPresentationCurrentContext;
            picker.sourceType = sourceType;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:^{
                self.isReturnFromStickerView = YES;
            }];
        }
        NSLog(@"pressssss");
        
    }else{
        [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)pressPhrase{
    if (([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable && [CCConnectionHelper sharedClient].webSocketStatus == CCCWebSocketOpened)|| CCLocalDevelopmentMode) {
    
        // show phrase sticker view controller
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter" bundle:SDK_BUNDLE];
        CCPhraseStickerCollectionViewController *phraseCollectionViewController = [storyboard instantiateViewControllerWithIdentifier:@"CCPhraseStickerCollectionViewController"];
        phraseCollectionViewController.delegate = self;
        phraseCollectionViewController.orgUid = self.orgUid;
        phraseCollectionViewController.channelId = self.channelId;
        phraseCollectionViewController.userId = self.uid;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:phraseCollectionViewController];
        [self presentViewController:navController animated:YES completion:^{
            self.isReturnFromStickerView = YES;
        }];
    }else{
        [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
    }
}

- (void)pressStripePayment {
    CCStripePaymentWidgetViewController *paymentVC = [[CCStripePaymentWidgetViewController alloc] initWithNibName:@"CCStripePaymentWidgetViewController" bundle:nil];
    paymentVC.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:paymentVC];
    [self presentViewController:navController animated:YES completion:^{
        self.isReturnFromStickerView = YES;
    }];
}

-(void)pressLandingPage {
    UIAlertController *alertVC;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        alertVC = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Landing Page") message:nil preferredStyle:UIAlertControllerStyleAlert];
    } else {
        alertVC = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Landing Page") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    }

    UIAlertAction *sendUrlAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Send URL") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sendLandingPageURL];
    }];
    UIAlertAction *sendQRCodeAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Send QR Code") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sendLandingPageQRCode];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVC addAction:sendUrlAction];
    [alertVC addAction:sendQRCodeAction];
    [alertVC addAction:cancelAction];
    [self.inputToolbar.contentView.textView resignFirstResponder];
    [self presentViewController:alertVC animated:YES completion:^{
    }];
}

- (void) pressConfirmWidget {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter" bundle:SDK_BUNDLE];
    CCConfirmWidgetViewController *confirmWidgetEditor = [storyboard  instantiateViewControllerWithIdentifier:@"CCConfirmWidgetViewController"];;
    [confirmWidgetEditor setDelegate:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:confirmWidgetEditor];
    [self presentViewController:navController animated:YES completion:^{
        self.isReturnFromStickerView = YES;
    }];
}

- (void) sendLandingPageURL {
    [[CCConnectionHelper sharedClient] sendLandingPageUrl:self.channelId userId:self.currentGuestId completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
        NSString *url = result[@"url"];
        self.inputToolbar.contentView.textView.text = [NSString stringWithFormat:CCLocalizedString(@"You can go to this link to continue talking to us: %@"), url];
        isKeyboardShowing = YES;
        [self.inputToolbar.contentView.textView setHidden:NO];
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        self.inputToolbar.contentView.textView.inputView = nil;
        [self.inputToolbar.contentView.textView reloadInputViews];
        [self.inputToolbar toggleSendButtonEnabled];
        [self.inputToolbarMenuView setHidden:YES];
    }];
}

- (void) sendLandingPageQRCode {
    [[CCConnectionHelper sharedClient] sendLandingPageQRCode:self.channelId userId:self.currentGuestId completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
        // Do nothing
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __block UIImage *selectedImage;
    selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        // create data from assets
        NSData *data = nil;
        NSString *mimeType = nil;
        NSURL *assetURL;
        // Upload image from Camera
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            mimeType = @"image/jpeg";
            data = UIImageJPEGRepresentation(selectedImage, 0.9f);
            // check file size limit
            if(data.length > CCUploadFileSizeLimit) {
                // show error
                CCAlertView *alert = [[CCAlertView alloc] initWithController:self title:nil message:CCLocalizedString(@"Please size of the file is in the 20MB or less.")];
                [alert addActionWithTitle:CCLocalizedString(@"OK") handler:nil];
                [alert show];
                return;
            }
            
            // Save image
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            selectedImage = [selectedImage fixOrientation];
            [library writeImageToSavedPhotosAlbum:[selectedImage CGImage] orientation:(ALAssetOrientation) UIImageOrientationUp completionBlock:^(NSURL *assetURL, NSError *error){
                if (error) {
                    NSLog(@"Save image failed");
                } else {
                    NSDictionary *content = @{
                                              @"text":@"",
                                              @"uid":[self generateMessageUniqueId],
                                              @"url": assetURL,
                                              CC_STICKERCONTENT: @{
                                                      CC_THUMBNAILURL:@""
                                                      }
                                              };
                    CCCommonWidgetPreviewViewController *vc = [[CCCommonWidgetPreviewViewController alloc] initWithNibName:@"CCCommonWidgetPreviewViewController" bundle:SDK_BUNDLE];
                    CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:@""];
                    msg.type = CC_STICKERTYPEIMAGE;
                    msg.content = content;
                    [vc setDelegate:self];
                    [vc setMessage:msg];
                    [self.navigationController pushViewController:vc animated:YES];
                    return;
                }
            }];
        }
        // Upload image from folder
        else {
            assetURL = info[UIImagePickerControllerReferenceURL];
            NSDictionary *content = @{
                                      @"text":@"",
                                      @"uid":[self generateMessageUniqueId],
                                      @"url": assetURL,
                                      CC_STICKERCONTENT: @{
                                              CC_THUMBNAILURL:@""
                                              }
                                      };
            CCCommonWidgetPreviewViewController *vc = [[CCCommonWidgetPreviewViewController alloc] initWithNibName:@"CCCommonWidgetPreviewViewController" bundle:SDK_BUNDLE];
            CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:@""];
            msg.type = CC_STICKERTYPEIMAGE;
            msg.content = content;
            [vc setDelegate:self];
            [vc setMessage:msg];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        };
    }];
}

-(void)sendCalendar:(NSMutableArray *)datepicker{
    NSMutableString *message = [[NSMutableString alloc] init];
    NSMutableArray  *choices = [[NSMutableArray alloc] init];
    [message appendString:@"Here are some dates that work for me:\n"];
    for (NSString *date in datepicker) {
        [choices addObject:date];
    }
    NSDictionary *content = @{@"text":message, CC_RESPONSETYPEDATETIMEAVAILABILITY:choices, @"uid":[self generateMessageUniqueId]};
    [[CCConnectionHelper sharedClient] setDatepicker:nil];
    
    [self sendMessage:CC_RESPONSETYPEDATETIMEAVAILABILITY content:content];
}

-(void)sendDateTime:(NSArray *)dateTimes{
    NSMutableArray *actionsDatas = [NSMutableArray array];
    for(int i=0; i<dateTimes.count; i++) {
        long start = [[dateTimes objectAtIndex:i][@"from"] integerValue];
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:start];
        
        long end = [[dateTimes objectAtIndex:i][@"to"] integerValue];
        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:end];
        
        NSDateFormatter *formaterFrom = [[NSDateFormatter alloc] init];
        [formaterFrom setDateFormat:CCLocalizedString(@"calendar_sticker_time_format_from")];
        [formaterFrom setTimeZone:[NSTimeZone defaultTimeZone]];
        
        NSDateFormatter *formaterTo = [[NSDateFormatter alloc] init];
        [formaterTo setDateFormat:CCLocalizedString(@"calendar_sticker_time_format_to")];
        [formaterTo setTimeZone:[NSTimeZone defaultTimeZone]];
        
        NSString *label = [NSString stringWithFormat:CCLocalizedString(@"From %@ to %@ %@"), [formaterFrom stringFromDate:startDate], [formaterTo stringFromDate:endDate], [[NSTimeZone defaultTimeZone] abbreviation]];
        
        // set data
        [actionsDatas addObject:@{@"label":label,
                                  @"value":@{@"start":[NSNumber numberWithLong:start],
                                             @"end":[NSNumber numberWithLong:end]}}];
    }
    [actionsDatas addObject:@{@"label":CCLocalizedString(@"Propose other slots"), @"action":@[@"open:sticker/calender"]}];

    NSDictionary *content = @{@"message":@{@"text":CCLocalizedString(@"Please select date and time.")},
                              @"sticker-action":@{@"action-type":@"select",
                                                  @"action-data":actionsDatas},
                              @"sticker_type": @"schedule",
                              @"uid":[self generateMessageUniqueId]
                              };
    [self sendMessage:CC_RESPONSETYPESTICKER content:content];
}

-(void)sendThumb:(NSString *)message{
    if (([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable && [CCConnectionHelper sharedClient].webSocketStatus == CCCWebSocketOpened) || CCLocalDevelopmentMode) {
        NSMutableArray  *choices = [[NSMutableArray alloc] init];
        [choices addObject:CC_RESPONSETYPETHUMB];
        NSDictionary *content = @{@"text":message, CC_RESPONSETYPEDATETIMEAVAILABILITY:choices, @"uid":[self generateMessageUniqueId]};
        
        [self sendMessage:CC_RESPONSETYPEDATETIMEAVAILABILITY content:content];
    }else{
        [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
    }
}

-(void)sendLocationMessage:(NSDictionary *)locationContent {
    CCJSQMessage *message1 = [self appendTempMessage:CC_RESPONSETYPELOCATION content:locationContent];
    [[CCConnectionHelper sharedClient] sendMessage:locationContent channelId:self.channelId type:CC_RESPONSETYPESTICKER completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task){
        [self updateTempMessage:message1 withResult:result];
        if(result != nil){
            NSLog(@"Message POST Success!");
            [self loadMessages:self.channelId];
        }else{
            if ([[CCConnectionHelper sharedClient] isAuthenticationError:task] == YES){
                [[CCConnectionHelper sharedClient] displayAuthenticationErrorAlert];
            }else{
                NSLog(@"Message POST Failed!");
                [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
            }
        }
    }];
    [self reloadCollectionViewData];
}

#pragma mark - Sending Co-location message functions
-(void)sendUpdateColocationMessage {
    if(colocationMessage == nil || [colocationMessage isEqual:[NSNull null]] || lastUpdatedLocation == nil || ![self checkLocationEnabled]) {
        return;
    }
    
    liveColocationShareTimer += colocationTimer.timeInterval;
    CCLiveLocationTask *task = [[CCConnectionHelper sharedClient].shareLocationTasks objectForKey:self.channelId];
    task.liveColocationShareTimer = liveColocationShareTimer;
    [[CCConnectionHelper sharedClient].shareLocationTasks setObject:task forKey:self.channelId];
    //
    // Send "Stop" message if shared time is greater than configed time
    //
    if (liveColocationShareTimer >= liveColocationShareDuration * 60) {
        [self stopSharingLocation];
        return;
    }
    NSDictionary *locationContent = @{
                                      CC_STICKER_TYPE: CC_STICKERTYPECOLOCATION,
                                      CC_RESPONSETYPESTICKERCONTENT:
                                          @{CC_STICKER_DATA :
                                                @{
                                                    @"location" :
                                                        @{@"lat":[NSString stringWithFormat:@"%f", lastUpdatedLocation.coordinate.latitude],
                                                          @"lng":[NSString stringWithFormat:@"%f", lastUpdatedLocation.coordinate.longitude]}
                                                    }
                                            },
                                      @"reply_to": colocationMessage.uid
                                      };
    
    [[CCConnectionHelper sharedClient] sendMessage:locationContent channelId:self.channelId type:CC_RESPONSETYPERESPONSE completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task){
        if(result != nil){
            NSLog(@"Update co-location SUCCESS! %f, %f", lastUpdatedLocation.coordinate.latitude, lastUpdatedLocation.coordinate.longitude);
        }else{
            if ([[CCConnectionHelper sharedClient] isAuthenticationError:task] == YES){
                [[CCConnectionHelper sharedClient] displayAuthenticationErrorAlert];
            }else{
                NSLog(@"Update co-location Failed!");
                [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
            }
        }
    }];
}

-(void)stopSharingLocation {
    CCLiveLocationTask *task = [[CCConnectionHelper sharedClient].shareLocationTasks objectForKey:self.channelId];
    if (task == nil) {
        return;
    }
    colocationMessage = task.colocationMessage;
    colocationTimer = task.colocationTimer;
    if (colocationMessage == nil || colocationTimer == nil) {
        return;
    }
    
    [colocationTimer invalidate];
    colocationTimer = nil;
    colocationBackgroundTask = UIBackgroundTaskInvalid;
    if ([[CCConnectionHelper sharedClient].shareLocationTasks objectForKey:self.channelId] != nil) {
        [[CCConnectionHelper sharedClient].shareLocationTasks removeObjectForKey:self.channelId];
    }
    
    NSDictionary *locationContent = @{
                                      CC_STICKER_TYPE: CC_STICKERTYPECOLOCATION,
                                      CC_RESPONSETYPESTICKERCONTENT:
                                          @{CC_STICKER_DATA :
                                                @{
                                                    @"type": @"stop"
                                                    }
                                            },
                                      @"reply_to": colocationMessage.uid
                                      };
    [[CCConnectionHelper sharedClient] sendMessage:locationContent channelId:self.channelId type:CC_RESPONSETYPERESPONSE completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task){
        NSLog(@"Send stop sharing co-location");
        [self reloadCollectionViewData];
    }];
}

-(void) registerColocationBackgroundTask {
    CCLiveLocationTask *task = [[CCConnectionHelper sharedClient].shareLocationTasks objectForKey:self.channelId];
    ///
    /// If task already exists
    ///
    if (task != nil) {
        colocationBackgroundTask = task.colocationBackgroundTask;
    } else {
        ///
        /// Create new task
        ///
        colocationBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [self endColocationBackgroundTask];
        }];
        CCLiveLocationTask *newTask = [[CCLiveLocationTask alloc] init];
        newTask.colocationBackgroundTask = colocationBackgroundTask;
        ///
        /// Save task
        ///
        [[CCConnectionHelper sharedClient].shareLocationTasks setObject:newTask forKey:self.channelId];
        assert(colocationBackgroundTask != UIBackgroundTaskInvalid);
    }
}

-(void) reinstateBackgroundTask {
    if (colocationTimer != nil && colocationBackgroundTask == UIBackgroundTaskInvalid) {
        [self registerColocationBackgroundTask];
    }
}

-(void) endColocationBackgroundTask {
    [[UIApplication sharedApplication] endBackgroundTask:colocationBackgroundTask];
    colocationBackgroundTask = UIBackgroundTaskInvalid;
}


-(void)sendMessage:(NSString *)type content:(NSDictionary *)content{
    CCJSQMessage *message = [self appendTempMessage:type content:content];
    [self sendMsg:content channelId:self.channelId type:type message:message];
}

-(void)sendMessageFromInputToolbar:(NSDictionary *)content{
    CCJSQMessage *message = [self appendTempMessage:CC_RESPONSETYPEMESSAGE content:content];
    [self sendMsg:content channelId:self.channelId type:CC_RESPONSETYPEMESSAGE message:message];
}

- (void)sendMsg:(NSDictionary*)content channelId:(NSString*)channelId type:(NSString*)type message:(CCJSQMessage*)message {

    [[CCConnectionHelper sharedClient] sendMessage:content channelId:channelId type:type completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task){
        [self updateTempMessage:message withResult:result];
         if(result != nil){
             NSLog(@"Message POST Success!");
             self.inputToolbar.contentView.rightBarButtonItem.enabled = NO;
             [self processStartSharingLocationResponse:result message:message];
         }else{
            if ([[CCConnectionHelper sharedClient] isAuthenticationError:task] == YES){
                [[CCConnectionHelper sharedClient] displayAuthenticationErrorAlert];
            }else{
                NSLog(@"Message POST Failed!");
            }
        }
        [self reloadCollectionViewData];
    }];
}

-(void)processStartSharingLocationResponse: (NSDictionary *) result message:(CCJSQMessage *)message {
    if(result[@"content"] != nil && ![result[@"content"] isEqual:[NSNull null]]) {
        NSDictionary *stickerContent = result[@"content"][CC_STICKERCONTENT];
        if(stickerContent != nil && stickerContent[CC_STICKER_DATA] != nil && ![stickerContent[CC_STICKER_DATA] isEqual:[NSNull null]] && [result[@"content"][CC_STICKER_TYPE] isEqualToString:CC_STICKERTYPECOLOCATION]) {
            colocationMessage = [message copy];
            colocationMessage.uid = result[@"id"];
            NSDictionary *stickerData = stickerContent[CC_STICKER_DATA];
            float preferredInterval;
            if(stickerData[@"preferred_interval"] != nil) {
                preferredInterval = [stickerData[@"preferred_interval"] floatValue];
            } else {
                preferredInterval = CC_COLOCATION_PREFERRED_INTERVAL;
            }
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            liveColocationShareTimer = 0;
            liveColocationShareDuration = (int)[userDefaults integerForKey:kCCUserDefaults_liveLocationDuration];
            CCLiveLocationTask *task = [[CCConnectionHelper sharedClient].shareLocationTasks objectForKey:self.channelId];
            ///
            /// 1. Remove old task if exists
            ///
            if (task != nil) {
                [[CCConnectionHelper sharedClient].shareLocationTasks removeObjectForKey:self.channelId];
            }
            
            ///
            /// 2. Create new task
            ///
            colocationTimer = [NSTimer scheduledTimerWithTimeInterval:preferredInterval target:self selector:@selector(sendUpdateColocationMessage) userInfo:nil repeats:YES];
            preferredTimeInterval = preferredInterval;
            CCLiveLocationTask *newTask = [[CCLiveLocationTask alloc] init];
            newTask.colocationTimer = colocationTimer;
            newTask.liveColocationShareTimer = liveColocationShareTimer;
            newTask.liveColocationShareDuration = liveColocationShareDuration;
            newTask.colocationMessage = colocationMessage;
            [[CCConnectionHelper sharedClient].shareLocationTasks setObject:newTask forKey:self.channelId];
            
            [self registerColocationBackgroundTask];
        }
    }
}

-(void)pressSendButton:(UIButton*)button{
    if (self.inputTextView.text.length == 0) {
        return;
    }
    if (([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable && [CCConnectionHelper sharedClient].webSocketStatus == CCCWebSocketOpened)|| CCLocalDevelopmentMode) {
        NSDictionary *content = @{@"text":self.inputTextView.text, @"uid":[self generateMessageUniqueId]};
        [self sendMessage:CC_RESPONSETYPEMESSAGE content:content];
    }else{
        [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
    }
}

- (void)receiveMessageResponse:(NSDictionary *)content messageType:(NSString *)messageType userUid:(NSString *)userUid {
    if([messageType isEqualToString:CC_RESPONSETYPERESPONSE] && self.messages != nil) {
        
        NSNumber *replyTo = content[@"reply_to"];
        
        //
        // Search for the message to add the response data
        //
        for(int i=(int)self.messages.count-1; i>=0; i--) {
            CCJSQMessage *msg = self.messages[i];
            NSString *s; [s integerValue];
            if(msg.uid != nil && replyTo != nil && [msg.uid integerValue] == [replyTo integerValue]) {
                //
                // Found the message
                //
                NSMutableDictionary *newContent    = [NSMutableDictionary dictionaryWithDictionary:msg.content];
                NSMutableDictionary *stickerAction = [NSMutableDictionary dictionaryWithDictionary:[newContent objectForKey:@"sticker-action"]];
                NSMutableArray *actionResponseData = [NSMutableArray array];
                
                NSMutableDictionary *stickerContent = [NSMutableDictionary dictionaryWithDictionary:[content objectForKey:CC_STICKERCONTENT]];
                NSMutableDictionary *stickerData = [NSMutableDictionary dictionaryWithDictionary:[stickerContent objectForKey:CC_STICKER_DATA]];
                NSString *stickerType = [content objectForKey:@"sticker-type"];
                NSString *stickerDataType = [stickerData objectForKey:@"type"];
                if ([stickerType isEqualToString:CC_STICKERTYPECOLOCATION] && stickerDataType != nil && [stickerDataType isEqualToString:@"stop"]) {
                    NSMutableDictionary *oldStickerContent = [NSMutableDictionary dictionaryWithDictionary:[msg.content objectForKey:CC_STICKERCONTENT]];
                    NSMutableDictionary *oldStickerData = [NSMutableDictionary dictionaryWithDictionary:[oldStickerContent objectForKey:CC_STICKER_DATA]];
                    NSMutableArray *oldUsers = [[oldStickerData objectForKey:@"users"] mutableCopy];
                    for(NSDictionary *user in oldUsers) {
                        NSString *uid = [[user objectForKey:@"id"] stringValue];
                        if (uid!= nil && [uid isEqualToString:userUid]) {
                            [oldUsers removeObject:user];
                            break;
                        }
                    }
                    if (oldUsers != nil) {
                        [oldStickerData setObject:oldUsers forKey:@"users"];
                    }
                    [oldStickerContent setObject:oldStickerData forKey:CC_STICKER_DATA];
                    [newContent setObject:oldStickerContent forKey:CC_STICKERCONTENT];
                }
                //
                // Since version Moon the response comes in "answers", which accepts multiple choices.
                // On top of that, for backward compatibility we should also keep accepting conventional "answer" and "answer_label" format.
                //
                
                NSDictionary *answer = [content objectForKey:@"answer"];
                NSArray<NSDictionary*> *answers = [content objectForKey:@"answers"];
                
                if( answers != nil ) {
                    //
                    // The response is in Moon format
                    //
                    for (NSDictionary *anAnswer in answers) {
                        [actionResponseData addObject:anAnswer];
                    }
                    
                } else if ( answer != nil ) {
                    [actionResponseData addObject:answer];
                    
                } else { // No response data
                    
                }
                
                //
                // For backward compatibility action-response-data should be in this form
                // (Wrapped by an array and a dictionary with the key "action")
                //
                // (
                //    {
                //       "action" = (
                //                    {
                //                      "label" = label
                //                      "value" = {
                //                                     //Any specific key-values
                //                                 }
                //                    },
                //                    {
                //                      "label" = label
                //                      "value" = {
                //                                     //Any specific key-values
                //                                 }
                //                    },
                //                    ...
                //                 )
                //     }
                // )
                NSArray *wrapped = @[ @{ @"actions":actionResponseData } ];
                
                [stickerAction setValue:wrapped forKey:@"action-response-data"];
                [newContent setValue:stickerAction forKey:@"sticker-action"];
                msg.content = [newContent copy];
                break;
            }
        }
    }
}

- (void)addAvatarIfNeed:(NSString *)displayName messageType:(NSString *)messageType userIconUrl:(NSString *)userIconUrl userUid:(NSString *)userUid {
    if ([self.avatars objectForKey:userUid] == nil && ![messageType isEqualToString:CC_RESPONSETYPEINFORMATION] && ![messageType isEqualToString:CC_RESPONSETYPEPROPERTY]) {
        if (userIconUrl != nil && !([userIconUrl isEqual:[NSNull null]])) {
            if([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable) {
                dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_queue_t q_main   = dispatch_get_main_queue();
                dispatch_async(q_global, ^{
                    NSError *error = nil;
                    NSData *dt = [NSData dataWithContentsOfURL:[NSURL URLWithString:userIconUrl]
                                                       options:NSDataReadingUncached
                                                         error:&error];
                    dispatch_async(q_main, ^{
                        NSMutableDictionary *mutableAvatars = [self.avatars mutableCopy];
                        UIImage *newIconImage = [[UIImage alloc] initWithData:dt scale:[UIScreen mainScreen].scale];
                        if (newIconImage != nil) {
                            if([mutableAvatars objectForKey:userUid] != nil){
                                [mutableAvatars removeObjectForKey:userUid];
                            }
                            CCJSQMessagesAvatarImage *JSQMessagesAvatarImage
                            = [CCJSQMessagesAvatarImageFactory avatarImageWithImage:newIconImage
                                                                           diameter:circleAvatarSize];
                            [mutableAvatars setObject:JSQMessagesAvatarImage forKey:userUid];
                            self.avatars = [mutableAvatars copy];
                            [self.collectionView reloadData];
                        }
                    });
                });
            }
        }
        
        NSMutableDictionary *newAvatars;
        newAvatars = [self.avatars mutableCopy];
        NSString *firstCharacter = [displayName substringToIndex:1];
        UIImage *newIconImage = [[ChatCenter sharedInstance] createAvatarImage:firstCharacter width:circleAvatarSize height:circleAvatarSize color:[[ChatCenter sharedInstance] getRandomColor:userUid] fontSize:randomCircleAvatarFontSize textOffset:randomCircleAvatarTextOffset];
        if (newIconImage != nil) {
            [newAvatars setObject:[CCJSQMessagesAvatarImageFactory avatarImageWithImage:newIconImage diameter:circleAvatarSize]
                           forKey:userUid];
            self.avatars = [newAvatars copy];
        }
        
    }
}

- (void)showNewMessageView:(NSString *)buttonTitle userUid:(NSString *)userUid {
    if(self.uid != nil && [self.uid integerValue] != [userUid integerValue]) {
        // Show NewMessageView
        //
        [newMessageView removeFromSuperview];
        NSUInteger paddingMessageLabel = 10.0f;
        NSUInteger paddingMessageImage = 10.0f;
        NSInteger imageSize = 12.0f;
        NSUInteger MAX_WITH_MESSAGE = 165.0f;
        
        if(buttonTitle != nil) {
            NSDictionary *messageStringAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12.0f]};
            NSMutableAttributedString *messageAttributedString = [[NSMutableAttributedString alloc] initWithString:buttonTitle attributes:messageStringAttributes];
            NSUInteger messageWidth = messageAttributedString.size.width;
            messageWidth = MIN(messageWidth, MAX_WITH_MESSAGE);
            newMessageView = [[UIView alloc] initWithFrame: CGRectMake ( 0, 0,paddingMessageLabel + messageWidth + paddingMessageImage * 2 + imageSize, imageSize + paddingMessageImage * 2)];
            newMessageView.backgroundColor = [UIColor colorWithRed:132.0f/255.0f
                                                             green:132.0f/255.0f
                                                              blue:132.0f/255.0f
                                                             alpha:1.0f];
            // Create border (top-left and top-right)
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:newMessageView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(5.0, 5.0)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = newMessageView.bounds;
            maskLayer.path  = maskPath.CGPath;
            newMessageView.layer.mask = maskLayer;
            // Create button title label
            UILabel *buttonTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(paddingMessageLabel, 0, paddingMessageLabel + messageWidth, imageSize + paddingMessageImage * 2)];
            buttonTitleLabel.text = buttonTitle;
            buttonTitleLabel.font= [UIFont systemFontOfSize:12.0f];
            buttonTitleLabel.textColor=[UIColor whiteColor];
            buttonTitleLabel.backgroundColor=[UIColor clearColor];
            [newMessageView addSubview:buttonTitleLabel];
            // Create icon button
            UIButton *checkmarkButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
            [checkmarkButton setImage:[UIImage SDKImageNamed:@"CCarrow-down"] forState:UIControlStateNormal];
            checkmarkButton.tintColor = [UIColor whiteColor];
            UIImageView *imageNewMessageView = [[UIImageView alloc] init];
            checkmarkButton.frame = CGRectMake(paddingMessageLabel + messageWidth + paddingMessageImage, paddingMessageImage, imageSize, imageSize);
            checkmarkButton.layer.cornerRadius = checkmarkButton.frame.size.height/2;
            [imageNewMessageView addSubview:checkmarkButton];
            [newMessageView addSubview:imageNewMessageView];
            // Add new message view to super view
            newMessageView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height - self.inputToolbar.bounds.size.height - newMessageView.bounds.size.height/2);
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickNewMessageButton:)];
            [newMessageView addGestureRecognizer:tapGesture];
            [self.view addSubview:newMessageView];
            [self.view bringSubviewToFront:newMessageView];
        }
    }
    else{
        [self scrollToBottomAnimated:YES];
    }
}

//
//
// Message received
//
//
-(void)receiveMessage:(NSString *)messageType
                  uid:(NSNumber *)uid
              content:(NSDictionary *)content
           fromSender:(NSString *)userUid
               onDate:(NSDate *)date
          displayName:(NSString *)displayName
          userIconUrl:(NSString *)userIconUrl
            userAdmin:(BOOL)userAdmin
               answer:(NSDictionary *)answer
{
    //
    ///duplicate check
    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@",uid];
    NSArray *duplicates = [self.messages filteredArrayUsingPredicate: predicate];
    if ([duplicates count] > 0) {
        if ([messageType isEqualToString:CC_RESPONSETYPECALL] || [messageType isEqualToString:CC_RESPONSETYPESTICKER]) {
            for(int i=(int)self.messages.count-1; i>=0; i--) {
                CCJSQMessage *msg = self.messages[i];
                if(msg.uid != nil && [msg.uid integerValue] == [uid integerValue]) {
                    NSMutableDictionary *newContent    = [NSMutableDictionary dictionaryWithDictionary:content];
                    msg.content = [newContent copy];
                    [self.collectionView reloadData];
                    break;
                }
            }
        }
        return;
    }
    
    //
    // update message:sticker if received message:response
    //
    [self receiveMessageResponse:content messageType:messageType userUid:userUid];
    
    [CCJSQSystemSoundPlayer jsq_playMessageReceivedSound];
    
    //
    ///add avatar-image
    //
    [self addAvatarIfNeed:displayName messageType:messageType userIconUrl:userIconUrl userUid:userUid];
    
    //
    // Message object
    //
    NSArray *newMessages = [self createMessageObjects:messageType
                                                  uid:uid
                                              content:content
                                     usersReadMessage:@[]
                                           fromSender:userUid
                                               onDate:date
                                          displayName:displayName
                                          userIconUrl:userIconUrl
                                            userAdmin:userAdmin
                                               answer:answer
                                               status:CC_MESSAGE_STATUS_SEND_SUCCESS];
    BOOL foundDuplicate = NO;
    for (CCJSQMessage *newMessage in newMessages) {
        //
        // find duplicate and remove temp from self.messages
        //
        for (int i=(int)[self.messages count]-1; i>=0; i--) {
            CCJSQMessage *message = [self.messages objectAtIndex:i];
            
            //
            // Note: This "uid" is msg->content->uid, not msg->uid.
            //       It is used specificly for matching the temp message and the one just received from server
            //       This id is generated with CCChatViewController#generateMessageUniqueId (and some duplicated methods)
            //
            NSString *uniqueId = (message.content != nil) ? [message.content objectForKey:@"uid"] : @"unique-id";
            NSString *newUniqueId = (content != nil) ? [CCParseUtils getStringAtPath:@"uid" fromObject:content] : @"new-unique-id";
            if (uniqueId != nil && ![uniqueId isEqual:[NSNull null]]
                && uniqueId != nil && ![uniqueId isEqual:[NSNull null]]
                && [uniqueId respondsToSelector:@selector(isEqualToString:)]
                && [uniqueId isEqualToString:newUniqueId]) {
                [self.messages removeObject:message];
                [[CCCoredataBase sharedClient] deleteTempMessage:message.uid];
                foundDuplicate = YES;
                // break;
            }
        }
        [self.messages addObject:newMessage];
    }
    self.automaticallyScrollsToMostRecentMessage = NO;
    [self finishSendingMessageAnimated:!foundDuplicate];
    
    NSMutableArray *messageIds = [[NSMutableArray alloc] init];
    [messageIds addObject:uid];
    NSArray *arrayAnswerAction = nil;
    if (content[@"answer"] != nil) {
        arrayAnswerAction= content[@"answer"][@"action"];
    }
    NSString *replySuggestion = @"";
    if (arrayAnswerAction !=nil){
        replySuggestion = [arrayAnswerAction objectAtIndex:0];
    }
    if (![userUid isEqualToString:self.uid] || [replySuggestion hasPrefix:@"reply:suggestion/message"])
    {
        if ([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable || CCLocalDevelopmentMode) {
            [[CCConnectionHelper sharedClient] sendMessageReceivedStatus:self.channelId messageIds:messageIds];
            [self updateLocalChannelClearUnreadMessages];
        }
    }
    
    CCJSQMessage *newMsg;
    BOOL shouldHideSuggestion = NO;
    if (newMessages.count > 0) {
        newMsg = [newMessages lastObject];
    }
    CGSize previewCellSize = [CCCommonStickerCollectionViewCell estimateSizeForMessage:newMsg atIndexPath:nil hasPreviousMessage:nil options:0 withListUser:nil];
    NSString *buttonTitle;
    
    [self displayFixedPhraseOrSuggestionIfNeed];
    
    if([messageType isEqualToString:CC_RESPONSETYPEMESSAGE]){
        buttonTitle = newMsg.text;
        shouldHideSuggestion = YES;
    }
    else if ([messageType isEqualToString:CC_RESPONSETYPESTICKER]){
        buttonTitle = [NSString stringWithFormat:@"%@:%@", newMsg.senderDisplayName, CCLocalizedString(@"Sent a sticker")];
        shouldHideSuggestion = YES;
    }
    else if([messageType isEqualToString:CC_RESPONSETYPECALL]){
        buttonTitle = [NSString stringWithFormat:@"%@:%@", newMsg.senderDisplayName, CCLocalizedString(@"Missed call")];
        shouldHideSuggestion = YES;
    }
    else if ([messageType isEqualToString:CC_RESPONSETYPESUGGESTION]) {
        buttonTitle = [NSString stringWithFormat:@"%@", CCLocalizedString(@"New suggestion")];
        isAlreadyDisplaySuggestionView = NO;
        shouldHideSuggestion = NO;
        NSArray<NSDictionary*> *actionData = [[content objectForKey:@"sticker-action"] objectForKey:@"action-data"];
        self.suggestionActionData = [actionData mutableCopy];
    }
    
    if (shouldHideSuggestion && self.inputToolbarMenuView.shouldShowSuggestion && !isKeyboardShowing) {
        if (self.inputToolbarMenuView.shouldShowSuggestion) {
            UIButton *button = self.inputToolbarMenuView.buttons[1];
            [button setTintColor:[UIColor lightGrayColor]];
        }
    }
    
    if(self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.frame.size.height - previewCellSize.height)) {
        [self scrollToBottomAnimated:YES];
        newMessageView.hidden = YES;
    }
    else{
        [self showNewMessageView:buttonTitle userUid:userUid];
    }
    if(isKeyboardShowing == TRUE){
        [self scrollToBottomAnimated:YES];
        newMessageView.hidden = YES;
    }
}

- (void)updateLocalChannelClearUnreadMessages{
    ///update Coredata UnreadMessageNum
    if ([[CCCoredataBase sharedClient] updateChannelWithUnreadMessage:self.channelId unreadMessage:@"0"]){
        NSLog(@"updateChannelWithUnreadMessage Success!");
    }else{
        NSLog(@"updateChannelWithUnreadMessage Error!");
    }
    /// post Unread Message Count Changed Notification
    [[ChatCenter sharedInstance] clearUnreadMessage:self.channelId];
}

-(void)calendarChoicePressed:(UIButton*)button{
    self.inputToolbar.contentView.textView.text = [button.titleLabel.text stringByAppendingString:@" works!"];
    self.inputToolbar.contentView.rightBarButtonItem.enabled = YES;
}

-(void)thumbChoicePressed:(UIButton*)button{
    self.inputToolbar.contentView.textView.text = [button.titleLabel.text stringByAppendingString:@"!"];
    self.inputToolbar.contentView.rightBarButtonItem.enabled = YES;
}

-(void)updateProviderToken{
    NSDate *providerCreatedAtDate;
    NSDate *providerExpiresAtDate;
    if ([CCConnectionHelper sharedClient].providerCreatedAt != nil) {
        NSString *providerCreatedAt = [CCConnectionHelper sharedClient].providerCreatedAt;
        double providerCreatedAtDouble = providerCreatedAt.doubleValue;
        providerCreatedAtDate = [NSDate dateWithTimeIntervalSince1970:providerCreatedAtDouble];
    }
    if ([CCConnectionHelper sharedClient].providerExpiresAt != nil) {
        NSString *providerExpiresAt = [CCConnectionHelper sharedClient].providerExpiresAt;
        double providerExpiresAtDouble = providerExpiresAt.doubleValue;
        providerExpiresAtDate = [NSDate dateWithTimeIntervalSince1970:providerExpiresAtDouble];
    }
    [[CCConnectionHelper sharedClient] loadUserToken:(NSString *)nil
                                            password:nil
                                            provider:[CCConnectionHelper sharedClient].provider
                                       providerToken:[CCConnectionHelper sharedClient].providerToken
                                 providerTokenSecret:[CCConnectionHelper sharedClient].providerTokenSecret
                                providerRefreshToken:[CCConnectionHelper sharedClient].providerRefreshToken
                                   providerCreatedAt:providerCreatedAtDate
                                   providerExpiresAt:providerExpiresAtDate
                                         deviceToken:nil
                                        showProgress:YES
                                   completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
        if (error != nil) {
            [[CCConnectionHelper sharedClient] displyAlert:nil message:CCLocalizedString(@"You are logout, please login") alertType:SingleButtonAlert];
            [self pressClose:nil]; //If provider auth fails, close window and back to original app.
            isInitViewLocked = NO;
        }
    }];
}

- (void)saveDraftMessage {
    if (self.inputToolbar.contentView.textView.text != nil && ![self.inputToolbar.contentView.textView.text isEqualToString:@""]){
        NSNumber *uid = [NSNumber numberWithInteger:([[CCCoredataBase sharedClient] getSmallestMessageId] - 1)];
        if ([uid integerValue] >= 0) {
            uid = [NSNumber numberWithInteger:-1];
        }
        if (self.uid == nil) {
            return;
        }
        NSDate *date = [NSDate date];
        NSString *channelUid = self.channelId;
        NSNumber *channelId = nil;
        NSDictionary *user = @{@"id":self.uid};
        NSArray *usersReadMessage = @[];
        NSDictionary *answer = nil;
        NSDictionary *question = nil;
        NSDictionary *content = @{@"text":self.inputToolbar.contentView.textView.text, @"uid":[self generateMessageUniqueId]};
        NSArray *arrayMessage = [[CCCoredataBase sharedClient] selectDraftMessageWithChannel:self.channelId];
        if (arrayMessage.count > 0) {
            [[CCCoredataBase sharedClient] deleteDraftMessagesWithChannel:self.channelId];
        }
        [[CCCoredataBase sharedClient] insertMessage:uid
                                                type:CC_RESPONSETYPEMESSAGE
                                             content:content
                                                date:date
                                          channelUid:channelUid
                                           channelId:channelId
                                                user:user
                                    usersReadMessage:usersReadMessage
                                              answer:answer
                                            question:question
                                              status:CC_MESSAGE_STATUS_DRAFT];
    } else {
        [[CCCoredataBase sharedClient] deleteDraftMessagesWithChannel:self.channelId];
    }
}

- (void) loadDraftMessage {
    NSArray *arrayMessage = [[CCCoredataBase sharedClient] selectDraftMessageWithChannel:self.channelId];
    if (arrayMessage != nil && arrayMessage.count > 0) {
        NSManagedObject *object = [arrayMessage objectAtIndex:0];
        NSData *contentData          = [object valueForKey:@"content"];
        NSDictionary *content        = [NSKeyedUnarchiver unarchiveObjectWithData:contentData];
        if (content !=nil && content[@"text"] != nil ) {
            self.inputToolbar.contentView.textView.text     = content[@"text"];
            if (content[@"text"] != nil && ![content[@"text"] isEqualToString:@""]) {
                [self.inputToolbar toggleSendButtonEnabled];
            }
            NSString *inputText = self.inputToolbar.contentView.textView.text;
            lastTextLenght = inputText.length;
        }
    }
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<CCJSQMessageData>)collectionView:(CCJSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (id<CCJSQMessageBubbleImageDataSource>)collectionView:(CCJSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    CCJSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    ///bubble image
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
    
    ///no bubble image
//    return nil;
}

- (id<CCJSQMessageAvatarImageDataSource>)collectionView:(CCJSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    if ([CCConstants sharedInstance].hideOutGoingCircleAvatar == YES) {
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(0, 0);
    }else{
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(circleAvatarSize, circleAvatarSize);
    }
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(circleAvatarSize, circleAvatarSize);
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    CCJSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    return [self.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(CCJSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if ([self checkShowDateForMessageAtIndexPath:indexPath]) {
        CCJSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[CCJSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(CCJSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    CCJSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        CCJSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(CCJSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    CCJSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    if([self canShowStatusForMessage:msg]) {
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[self getStatusForMessage:msg]];
        return attributedString;
    }
    
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (void)longPressTap:(UILongPressGestureRecognizer *)sender
{
}


- (CCStickerCollectionViewCellOptions)getStickerCellOptionsForIndexPath:(NSIndexPath*)indexPath message:(CCJSQMessage*)msg previousMessage:(CCJSQMessage*)preMsg {
    
    CCStickerCollectionViewCellOptions options = 0;
    
    //--------------------------------------------------------------------
    //
    // Cell options
    //
    //--------------------------------------------------------------------
    
    ///Display name?
    if (preMsg != nil || msg.senderDisplayName != nil) {
        options |= CCStickerCollectionViewCellOptionShowName;
    }
    ///Display date?
    if ([self checkShowDateForMessageAtIndexPath:indexPath]) {
        options |= CCStickerCollectionViewCellOptionShowDate;
    }
    ///display status?
    if([self canShowStatusForMessage:msg]) {
        options |= CCStickerCollectionViewCellOptionShowStatus;
    }
    ///is myself?
    if ([msg.senderId isEqual:self.uid]){
        options |= CCStickerCollectionViewCellOptionShowAsMyself;
    }
    ///Is Widget?
    if ([msg.content objectForKey:@"sticker-action"] || [msg.content objectForKey:@"sticker-content"]) {
        options |= CCStickerCollectionViewCellOptionShowAsWidget;
    }
    ///Is Agent?
    if (msg.isAgent) {
        options |= CCStickerCollectionViewCellOptionShowAsAgent;
    }
    
    return options;
}

- (UICollectionViewCell *)collectionView:(CCJSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCJSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    CCJSQMessage *preMsg;
    if(indexPath.item > 1) preMsg = [self.messages objectAtIndex:indexPath.item-1];
    
    NSLog(@"Index: %ld - type: %@", (long)indexPath.item, msg.type);
    
    //
    // Get cell options
    //
    CCStickerCollectionViewCellOptions options = [self getStickerCellOptionsForIndexPath:indexPath message:msg previousMessage:preMsg];
    
    CCLiveLocationTask *task = [[CCConnectionHelper sharedClient].shareLocationTasks objectForKey:self.channelId];
    if (task != nil) {
        options |= CCStickerCollectionViewCellOptionShowLiveIcon;
    }

    //
    // Prepare avatar image
    //
    CCJSQMessagesAvatarImage *jSQMessagesAvatarImage;
    if ([self.avatars objectForKey:msg.senderId] != nil){
        jSQMessagesAvatarImage = (CCJSQMessagesAvatarImage *)[self.avatars objectForKey:msg.senderId];
    }


    //--------------------------------------------------------------------
    //
    // Init cell
    //
    //--------------------------------------------------------------------
    
    //
    // Specify identifier
    //
    CCStickerCollectionViewCell *cell;

    NSString *widgetType = msg.type; // Basic
    
    /// Override messageType if necessary
    if ([msg.type isEqualToString:CC_RESPONSETYPEDATETIMEAVAILABILITY]) {
        ///Content contains CC_RESPONSETYPETIMEAVAILABILITY
        if(msg.content[CC_CONTENTKEYDATETIMEAVAILABILITY] != nil){
            // No override
        } else {
            //Content contains CC_RESPONSETYPEDATEAVAILABILITY
            if(msg.content[CC_RESPONSETYPEDATETIMEAVAILABILITY] != nil){
                NSArray *choices = msg.content[CC_RESPONSETYPEDATETIMEAVAILABILITY];
                if ([choices[0] isEqualToString:CC_RESPONSETYPETHUMB]) {
                    widgetType = CC_RESPONSETYPETHUMB;
                } else {
                    widgetType = CC_WIDGETTYPECALENDER;
                }
            }
        }
    }

    NSString *inOutPostfix;
    if (([CCConstants sharedInstance].isAgent && (options & CCStickerCollectionViewCellOptionShowAsAgent))
        || (![CCConstants sharedInstance].isAgent && !(options & CCStickerCollectionViewCellOptionShowAsAgent))) {
        inOutPostfix = @"out";
    } else {
        inOutPostfix = @"in";
    }
    NSString *identifier = [NSString stringWithFormat:@"%@_%@", widgetType, inOutPostfix];
    
    
//  cell.titleViewHeight.constant = 0; TODO: set specific title height for CC_STICKERTYPEIMAGE

    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    
    //
    // Handle special case
    //
    //// Special case : Phone call sticker
    if([msg.type isEqualToString:CC_RESPONSETYPECALL]) {
        NSAssert([cell isKindOfClass:[CCPhoneStickerCollectionViewCell class]], @"The cell instance supporsed to be CCPhoneStickerCollectionViewCell");
        // call specific init method
        [(CCPhoneStickerCollectionViewCell*)cell setupWithIndex:indexPath message:msg avatar:jSQMessagesAvatarImage textviewDelegate:nil delegate:self options:options userList:channelUsers];
        
        return cell;
    }
    
    
    //
    // Initialization
    //
    if (cell) {
        BOOL success = [cell setupWithIndex:indexPath message:msg avatar:jSQMessagesAvatarImage textviewDelegate:self delegate:self options:options];
        if(success) {
            if ([msg.type isEqualToString: CC_RESPONSETYPESUGGESTION]) {
                NSInteger lastIndex = self.messages.count - 1;
                if ( lastIndex == indexPath.item) {
                    NSString *inputText = [self.inputToolbar.contentView.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    NSArray<NSDictionary*> *actionData = [[[msg content] objectForKey:@"sticker-action"] objectForKey:@"action-data"];
                    if (inputText.length == 0 && actionData != nil && actionData.count > 0 && self.inputToolbar.contentView.textView != nil && !isKeyboardShowing && !isDisplayingSuggestionView) {
                        [self displaySuggestionWithActionData:actionData];
                    }
                }
            }
            return cell;
        } else {
            NSLog(@"Had an issue in cell initialization at indexPath %@. Try creating generic cell", indexPath);
        }
    }
    
        cell.discriptionView.delegate = self;

    //--------------------------------------------------------------------
    //
    // Unknown cell type
    //
    //--------------------------------------------------------------------
    CCJSQMessagesCollectionViewCell *cell_general = (CCJSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    cell.textView.delegate = self;
    if (![msg.senderId isEqualToString:self.senderId]) {
        CGFloat leftMargin = 10.0f + [[CCConstants sharedInstance] chatViewCircleAvatarSize];
        cell_general.messageBubbleTopLabel.textInsets = UIEdgeInsetsMake(0.0f, leftMargin, 0.0f, 0.0f);
    }
    ///bubble image
    if (!msg.isMediaMessage) {
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell_general.textView.textColor = [UIColor whiteColor];
        }else{
            cell_general.textView.textColor = [UIColor blackColor];
        }
        cell_general.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    [cell_general.cellBottomLabel setTextInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(CCJSQMessagesCollectionView *)collectionView
                   layout:(CCJSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if ([self checkShowDateForMessageAtIndexPath:indexPath]) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(CCJSQMessagesCollectionView *)collectionView
                   layout:(CCJSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    CCJSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        CCJSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(CCJSQMessagesCollectionView *)collectionView
                   layout:(CCJSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    CCJSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    if ([self canShowStatusForMessage:msg]) {
        return 20.0f;
    }
    
    return 0.0f;
}

#pragma mark - Responding to collection view tap events
- (void)collectionView:(CCJSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
}

- (void)collectionView:(CCJSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
    CCJSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    if ([msg.type isEqualToString:CC_RESPONSETYPEIMAGE] && msg.content[@"imageUrl"][@"original"] != nil) {
        /// URLs array
        NSString *urlString = [[CCConnectionHelper sharedClient] addAuthToUrl:msg.content[@"imageUrl"][@"original"]];
        [self openImageWithURLString:urlString];
    }
}

- (void)collectionView:(CCJSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - CCConectionHelper delegate
- (void)openURL:(NSURL *) URL{

    self.isReturnFromWebBrowser = YES;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    if([URL.absoluteString hasPrefix:@"http://"] || [URL.absoluteString hasPrefix:@"https://"]) {
        float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if(osVersion >= 9.0) {
            SFSafariViewController *webViewController = [[SFSafariViewController alloc] initWithURL:URL];
            webViewController.view.tintColor = [[CCConstants sharedInstance] headerItemColor];
            [self presentViewController:webViewController animated:YES completion:nil];
            return;
        }
    } else {
        [[UIApplication sharedApplication] openURL:URL];
        return;
    }
#endif
    [[UIApplication sharedApplication] openURL:URL];
}

- (void)closeChatView{
    [self pressClose:nil];
}

-(void)loadLocalData:(BOOL)isOrgChange{
    [CCSVProgressHUD dismiss];
    if (self.channelId != nil && self.deviceToken == nil) {
        [self loadMessagesIfNeeded:self.channelId];
    }else{
        [self initView];
    }
}

- (NSString *)getConnectedNames:(NSArray *)users{
    NSMutableString *names = [NSMutableString stringWithString:@""];
    int nameCount = 0;
    for (int i=0; i < users.count; i++) {
        if (![users[i][@"id"] isKindOfClass:[NSNumber class]]){
            continue;
        }
        if ([[users[i][@"id"] stringValue] isEqualToString:[[CCConstants sharedInstance] getKeychainUid]]){
            continue;
        }
        if(users[i][@"display_name"] == nil || [users[i][@"display_name"] isEqual:[NSNull null]]){
            continue;
        }
        if (![[CCConstants sharedInstance].businessType isEqualToString:CC_BUSINESSTYPETEAM]) {
            ///BtoC or BtoBtoC
            if(users[i][@"admin"] == nil || [users[i][@"admin"] isEqual:[NSNull null]]){
                continue;
            }
            if([users[i][@"admin"] boolValue] == YES){
                continue;
            }
        }
        
        if (nameCount > 0) {
            [names appendString:@", "];
        }
        [names appendString:users[i][@"display_name"]];
        nameCount++;
    }
    return [names copy];
}

-(void)loadLocalDisplayname:(NSString *)channelId{
    if (![[CCConstants sharedInstance] getKeychainUid]) {
        return;
    }
    NSArray *channelArray = [[CCCoredataBase sharedClient] selectChannelWithUid:CCloadLoacalChannelLimit uid:channelId];
    if(channelArray != nil && channelArray.count > 0){
        NSManagedObject *object   = [channelArray objectAtIndex:0];
        NSData *usersData         = [object valueForKey:@"users"];
        NSString *orgName         = [object valueForKey:@"org_name"];
        NSString *orgUid          = [object valueForKey:@"org_uid"];
        NSString *groupName       = [object valueForKey:@"name"]; ///Group name
        NSArray *users            = [NSKeyedUnarchiver unarchiveObjectWithData:usersData];
        channelUsers = users; // save channel users list
        self.orgName = orgName;
        self.orgUid = orgUid;
        ///Display name
        if ([CCConstants sharedInstance].isAgent== YES) {
            ///Agent
            if ([[CCConstants sharedInstance].businessType isEqualToString:CC_BUSINESSTYPETEAM]) {
                ///TEAM
                if ([groupName isEqualToString:@""]) {
                    ///Display names of chat members
                    self.navigationItem.title = [self getConnectedNames:users];
                }else{
                    ///Display group name
                    self.navigationItem.title = groupName;
                }
            }else{
                ///BtoC or BtoBtoC
                NSString *names = [self getConnectedNames:users];
                if([names isEqualToString:@""]){
                    ///No user name
                    names = CCLocalizedString(@"Guest");
                }
                
                ///Display names of chat members
                float screenWidth = [UIScreen mainScreen].bounds.size.width;
                // Estimate navigation title width
                CGSize maximumLabelSize = CGSizeMake(screenWidth, MAXFLOAT);
                NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine |
                NSStringDrawingUsesLineFragmentOrigin;
                
                NSDictionary *attr = @{NSFontAttributeName: navigationTitleView.title.font};
                CGRect labelBounds = [names boundingRectWithSize:maximumLabelSize
                                                          options:options
                                                       attributes:attr
                                                          context:nil];
                float padding = navigationTitleView.rightArrow.frame.size.width + 16;
                if (labelBounds.size.width > navigationTitleView.frame.size.width - padding) {
                    navigationTitleView.titleWidthConstraint.constant = navigationTitleView.frame.size.width - padding;
                } else {
                    navigationTitleView.titleWidthConstraint.constant = labelBounds.size.width + 5; //5 for content inset
                }
                
                navigationTitleView.title.text = names;
            }
        }else{
            ///Guest
            self.assigneeUid = nil;
            if([self isVideocallEnabled]) {
                self.navigationItem.rightBarButtonItems = @[rightSpacer, videoCallButton, voiceCallButton];
            } else {
                self.navigationItem.rightBarButtonItems = nil;
            }
            float screenWidth = [UIScreen mainScreen].bounds.size.width;
            // Estimate navigation title width
            CGSize maximumLabelSize = CGSizeMake(screenWidth, MAXFLOAT);
            NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine |
            NSStringDrawingUsesLineFragmentOrigin;
            
            NSDictionary *attr = @{NSFontAttributeName: navigationTitleView.title.font};
            CGRect labelBounds = [self.orgName boundingRectWithSize:maximumLabelSize
                                                     options:options
                                                  attributes:attr
                                                     context:nil];
            float padding = navigationTitleView.rightArrow.frame.size.width;
            if (labelBounds.size.width > navigationTitleView.frame.size.width - padding) {
                navigationTitleView.titleWidthConstraint.constant = navigationTitleView.frame.size.width - padding;
            } else {
                navigationTitleView.titleWidthConstraint.constant = labelBounds.size.width + 5;//5 for content inset
            }
            navigationTitleView.title.text = self.orgName;
        }
        
        ///
        /// Update right button items
        ///
        if([self isVideocallEnabled]) {
            self.navigationItem.rightBarButtonItems = @[rightSpacer,videoCallButton, voiceCallButton];
        } else {
            self.navigationItem.rightBarButtonItems = nil;
        }
    }
}

- (void) loadAllFixedPhrases: (NSString *)orgId {
    [[CCConnectionHelper sharedClient] loadFixedPhrase:orgId showProgress:NO
                                     completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *operation)
     {
         if(result != nil) {
             NSMutableArray *fixedPhrases = [[NSMutableArray alloc] init];
             
             // App fixed phrase
             NSArray *appFixedPhrases = [[NSMutableArray alloc] initWithArray:[result objectForKey:@"app"]];
             if (appFixedPhrases != nil) {
                 for (NSDictionary *fixedPhrase in appFixedPhrases) {
                     [fixedPhrases addObject:fixedPhrase];
                 }
             }
             
             // Org fixed phrase
             NSArray *orgFixedPhrases = [[NSMutableArray alloc] initWithArray:[result objectForKey:@"org"]];
             if (orgFixedPhrases != nil) {
                 for (NSDictionary *fixedPhrase in orgFixedPhrases) {
                     [fixedPhrases addObject:fixedPhrase];
                 }
             }

             // Mine fixed phrase
             NSArray *mineFixedPhrases = [[NSMutableArray alloc] initWithArray:[result objectForKey:@"mine"]];
             if (mineFixedPhrases != nil) {
                 for (NSDictionary *fixedPhrase in mineFixedPhrases) {
                     [fixedPhrases addObject:fixedPhrase];
                 }
             }
             
             self.fixedPhrases = fixedPhrases;
             if (!isDisplayingAlert && self.fixedPhrases != nil && [self.fixedPhrases count] > 0 && !isDisplayingSuggestionView) {
                 _shouldDisplayFixedPhraseMenu = YES;
                 [self updateLeftOfInputToolbar];
                 [self displayFixedPhraseOrSuggestionIfNeed];
             }
         }else{
             NSLog(@"Can not Get Fixed Phrases");
             
         }
     }];
}

- (void)receiveChannelJoinFromWebSocket:(NSString *)channelId newChannel:(BOOL)newChannel{
    NSLog(@"receiveChannelJoinFromWebSocket");
}


// Update "can_user_video_chat" property of latest user who joined the chanel
- (void)receiveChannelOnlineFromWebSocket:(NSString *)channelUid user:(NSDictionary *)user {
    if (user == nil) {
        return;
    }
    NSInteger currentUserId = [[user valueForKey:@"id"] integerValue];
    NSMutableArray *tempUserVideoChat = [self.userVideoChat mutableCopy];
    NSLog(@"tempUserVideoChat original: %lu", (unsigned long)tempUserVideoChat.count);
    for (int i = 0; i < tempUserVideoChat.count; i++) {
        NSDictionary *user = [tempUserVideoChat objectAtIndex:i];
        NSInteger userId = [[user valueForKey:@"id"] integerValue];
        if(currentUserId == userId) {
            [tempUserVideoChat removeObjectAtIndex:i]; // remove old object
            NSLog(@"remove old object!");
        }
    }
    NSLog(@"tempUserVideoChat modified: %lu", (unsigned long)tempUserVideoChat.count);
    [tempUserVideoChat addObject:user]; // add new object
    NSLog(@"add new object!");
    // update user video chat info
    self.userVideoChat = tempUserVideoChat;
    //--------------------------------------------------------------------
    //
    //  Right button
    //
    //--------------------------------------------------------------------
    if([self isVideocallEnabled]) {
        self.navigationItem.rightBarButtonItems = @[rightSpacer, videoCallButton, voiceCallButton];
    } else {
        self.navigationItem.rightBarButtonItems = nil;
    }
    [self updateLeftOfInputToolbar];
}

- (void)receiveMessageFromWebSocket:(NSString *)messageType uid:(NSNumber *)uid
                            content:(NSDictionary *)content
                          channelId:(NSString *)channelId
                            userUid:(NSString *)userUid date:(NSDate *)date
                        displayName:(NSString *)displayName
                        userIconUrl:(NSString *)userIconUrl
                          userAdmin:(BOOL)userAdmin
                             answer:(NSDictionary *)answer
{
    if ([channelId isEqualToString:self.channelId]){
        [self receiveMessage:messageType
                         uid:uid
                     content:content
                  fromSender:userUid
                      onDate:date
                 displayName:displayName
                 userIconUrl:userIconUrl
                   userAdmin:userAdmin
                      answer:answer];
    }
}

- (void) onClickNewMessageButton:(UITapGestureRecognizer *) recognizer {
    [self scrollToBottomAnimated:YES];
    [self displayFixedPhraseOrSuggestionIfNeed];
    if (![[CCConstants sharedInstance] isAgent] && self.messages.count > 0) {
        NSInteger lastIndex = self.messages.count - 1;
        CCJSQMessage *msg = [self.messages objectAtIndex:lastIndex];
        if (!isDisplayingSuggestionView) {
            NSString *inputText = [self.inputToolbar.contentView.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSArray<NSDictionary*> *actionData = [[[msg content] objectForKey:@"sticker-action"] objectForKey:@"action-data"];
            if (inputText.length == 0 && actionData != nil && actionData.count > 0 && self.inputToolbar.contentView.textView != nil && !isKeyboardShowing) {
                [self displaySuggestionWithActionData:actionData];
            }
        }
    }
    newMessageView.hidden = YES;
}

- (void)receiveReceiptFromWebSocket:(NSString *)channelUid messages:(NSArray *)messages userUid:(NSString *)userUid userAdmin:(BOOL)userAdmin {
    if ([channelUid isEqualToString:self.channelId]){
        if (messages != nil && userUid != nil) {
            for (int i=0; i<messages.count; i++) {
                for (int j=0; j<self.messages.count; j++) {
                    CCJSQMessage *msg = [self.messages objectAtIndex:j];
                    if ([msg.uid isEqualToNumber:[messages objectAtIndex:i]]) {
                        //OK
                        NSMutableDictionary *newContent;
                        NSMutableArray *usersReadMessage;
                        if (msg.content == nil) {
                            newContent = [NSMutableDictionary dictionary];
                        } else {
                            newContent = [NSMutableDictionary dictionaryWithDictionary:msg.content];
                        }
                        if ([newContent objectForKey:@"usersReadMessage"] == nil) {
                            usersReadMessage = [NSMutableArray array];
                        } else {
                            usersReadMessage = [NSMutableArray arrayWithArray:[newContent objectForKey:@"usersReadMessage"]];
                        }
                        [usersReadMessage addObject:@{@"id":userUid, @"admin":[NSNumber numberWithBool:userAdmin]}];
                        newContent[@"usersReadMessage"] = usersReadMessage;
                        msg.content = [newContent copy];
                        break;
                    } else {
                        
                    }
                } // end for: self.messages
            } // end for: message
            
            // re-display data
            [self.collectionView reloadData];
        }
    }
    NSLog(@"receiveReceiptFromWebSocket in ChatView");
}

- (void)receiveAssignFromWebSocket:(NSString *)channelUid{
    if ([channelUid isEqualToString:self.channelId]){
        [self loadChannelInfo:self.channelId callbackHandler:^(void) {
            [self loadLocalDisplayname:self.channelId];
            [self updateLeftOfInputToolbar];
        }];
    }
}

- (void)receiveUnassignFromWebSocket:(NSString *)channelUid{
    if ([channelUid isEqualToString:self.channelId]){
        [self loadChannelInfo:self.channelId callbackHandler:^(void) {
            [self loadLocalDisplayname:self.channelId];
            [self updateLeftOfInputToolbar];
        }];
    }
}

- (void)receiveFollowFromWebSocket:(NSString *)channelUid{
    if ([channelUid isEqualToString:self.channelId]){
        [self loadChannelInfo:self.channelId callbackHandler:^(void) {
            [self loadLocalDisplayname:self.channelId];
            [self updateLeftOfInputToolbar];
        }];
    }
}

- (void)receiveUnfollowFromWebSocket:(NSString *)channelUid{
    if ([channelUid isEqualToString:self.channelId]){
        [self loadChannelInfo:self.channelId callbackHandler:^(void) {
            [self loadLocalDisplayname:self.channelId];
            [self updateLeftOfInputToolbar];
        }];
    }
}

- (void)receivedChoosenPhrase : (NSString *) choosenPhrase {
    // set pendding fixed phrase. This phrase will be updated in viewDidAppear
    self.pendingFixedPhrase = choosenPhrase;
}

- (void)receiveInviteCall:(NSString *)messageId channelId:(NSString *)channelId content:(NSDictionary *)content {
    NSString *apiKey = content[@"api_key"];
    NSString *sessionId = content[@"session"];
    NSString *actionCall = content[@"action"];
    NSMutableDictionary *callerInfo = [content[@"caller"] mutableCopy];
    NSArray *receiversList = content[@"receivers"];
    if (channelId != nil && ![channelId isEqualToString:self.channelId]) {
        return;
    }
        
    if (callerInfo != nil && receiversList != nil && receiversList.count > 0) {
        for (int i = 0; i < receiversList.count; i++) {
            NSString *userId = [receiversList[i][@"user_id"] stringValue];
            if ([userId isEqualToString:self.uid]) {
                // Load caller information
                [[CCConnectionHelper sharedClient] loadUser:NO userUid:callerInfo[@"user_id"] completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
                    if (error == nil && result != nil) {
                        callerInfo[@"display_name"] = result[@"display_name"];
                        callerInfo[@"icon_url"] = result[@"icon_url"];
                        // Process call invitation
                        CCIncomingCallViewController *incomingVideoVC = [[CCIncomingCallViewController alloc] initWithNibName:@"CCIncomingCallViewController" bundle:SDK_BUNDLE];
                        incomingVideoVC.messageId = messageId;
                        incomingVideoVC.channelUid = self.channelId;
                        incomingVideoVC.callerInfo = callerInfo;
                        incomingVideoVC.receiverInfo = receiversList[i];
                        incomingVideoVC.actionCall = actionCall;
                        incomingVideoVC.apiKey = apiKey;
                        incomingVideoVC.sessionId = sessionId;
                        incomingVideoVC.chatViewController = self;
                        self.delegateCall = incomingVideoVC;
                        self.isReturnFromVideoCallView = YES;
                        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:incomingVideoVC];
                        [self presentViewController:navController animated:YES completion:nil];
                    }
                }];
                return;
            }
        }
    }
}

- (void)receiveDeleteChannelFromWebSocket:(NSString *)channelUid {
}

- (void)receiveDeleteChannelFromWebSocket {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:CCLocalizedString(@"Connection Failed") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:CCLocalizedString(@"OK")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   [self closeChatViewWhenDeleteChannelCallback];
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)receiveMessageTypingFromWebSocket:(NSString *)channelUid user:(NSDictionary *)user {
    if ([user[@"id"] isEqual:[NSNull null]]
        || [user[@"display_name"] isEqual:[NSNull null]]) {
        return;
    }
    NSString *userId = [user[@"id"] respondsToSelector:@selector(stringValue)] ? [user[@"id"] stringValue]: user[@"id"];
    NSString *displayName = user[@"display_name"];
    if(!([channelUid isEqualToString:self.channelId] && ![self.uid isEqualToString:userId])) {
        return;
    }
    ///
    /// Display typing indicator
    ///
    if (typingLabel != nil) {
        [typingLabel removeFromSuperview];
    }
    if (![self.uid isEqualToString:userId]) {
        typingLabel = [[UILabel alloc] init];
        typingLabel.frame = CGRectMake(0, - 21, self.view.frame.size.width, 20);
        typingLabel.font = [UIFont systemFontOfSize:12];
        typingLabel.textColor = [UIColor lightGrayColor];
        typingLabel.backgroundColor = [UIColor whiteColor];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.headIndent = 10;
        paragraphStyle.firstLineHeadIndent = 10;
        NSDictionary *attrsDictionary = @{NSParagraphStyleAttributeName: paragraphStyle};
        typingLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", displayName, CCLocalizedString(@"is typing")] attributes:attrsDictionary];
        [self.inputToolbar addSubview:typingLabel];
        [self.inputToolbar sendSubviewToBack:typingLabel];
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(removeTypingLabel) userInfo:nil repeats:NO];
    }
}

- (void) removeTypingLabel {
    [typingLabel removeFromSuperview];
}

- (void) findConstraints {
    for (NSLayoutConstraint *constraint in self.inputToolbar.superview.constraints) {
        if ((constraint.firstItem == self.inputToolbar && constraint.firstAttribute == NSLayoutAttributeBottom) || (constraint.secondItem == self.inputToolbar && constraint.secondAttribute == NSLayoutAttributeBottom)) {
            self.marginBottomInputToolbar = constraint;
            break;
        }
    }
}

- (void)receiveCloseChannelFromWebSocket:(NSString *)channelUid {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:CCLocalizedString(@"Connection Failed") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:CCLocalizedString(@"OK")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   [self closeChatViewWhenDeleteChannelCallback];
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)closeChatViewWhenDeleteChannelCallback {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        self.parentViewController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
        [self dismissViewControllerAnimated:YES completion:self.closeChatViewCallback];
    }
    [[CCConnectionHelper sharedClient] setDelegate:nil];
    [[CCConnectionHelper sharedClient] setCurrentView:nil];
}

- (void) reloadLocalDataWhenComeOnline {
}

-(void)initView{
    if(isInitViewLocked == YES) return;
    isInitViewLocked = YES;
    
    if (self.channelId == nil) {
        ///Set ChannelId(load ChannelId or Create User)
        [self loadChannelId];
    }else{
        [self setUidAndToken];
        [[CCConnectionHelper sharedClient] refreshData];
        [self loadMessagesIfNeeded:self.channelId];
        isInitializedJSQMessange = YES;
        isInitViewLocked = NO;
        [self loadChannelInfo:self.channelId];
        
        [CCChatViewHelper sendChannelActive:self.channelId];
    }
}

- (void)loadChannelInfo:(NSString *)channelId {
    [[CCConnectionHelper sharedClient] loadChannel:NO channelUid:channelId completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
        if(error) {
            NSLog(@"error: %@", [error description]);
        } else if(result != nil) {
            NSLog(@"Result loadChannelInfo: %@", [result description]);
            if([result valueForKey:@"users"] != nil && [result valueForKey:@"users"] != [NSNull null]) {
                self.userVideoChat = [result valueForKey:@"users"];
                [self updateLeftOfInputToolbar];
            }
            [self loadLocalDisplayname:channelId];
            [self loadAllFixedPhrases:self.orgUid];
            NSArray *guests = [CCChatViewHelper filteredGuestFrom:self.userVideoChat];
            if(guests.count == 0) {
                return;
            } else {
                for(NSDictionary * guest in guests) {
                    NSString *guestId = [guest valueForKey:@"id"];
                    if (guestId != nil) {
                        self.currentGuestId = guestId;
                        break;
                    }
                }
                
            }
        }
    }];
}

- (void)loadChannelInfo:(NSString *)channelId callbackHandler:(void (^)(void)) callbackHandler{
    NSArray *results = [[CCCoredataBase sharedClient] selectChannelWithUid:1 uid:channelId];
    if(results != nil && results.count > 0) {
        NSManagedObject *channelInfo = [results objectAtIndex:0];
        NSLog(@"Result loadChannelInfo: %@", [channelInfo description]);
        if([channelInfo valueForKey:@"users"] != nil && [channelInfo valueForKey:@"users"] != [NSNull null]) {
            NSData *usersData       = [channelInfo valueForKey:@"users"];
            self.userVideoChat      = [NSKeyedUnarchiver unarchiveObjectWithData:usersData];
        }
    }
    callbackHandler();
}

-(void)loadChannelId{
    NSDate *providerCreatedAtDate;
    NSDate *providerExpiresAtDate;
    if ([CCConnectionHelper sharedClient].providerCreatedAt != nil) {
        NSString *providerCreatedAt = [CCConnectionHelper sharedClient].providerCreatedAt;
        double providerCreatedAtDouble = providerCreatedAt.doubleValue;
        providerCreatedAtDate = [NSDate dateWithTimeIntervalSince1970:providerCreatedAtDouble];
    }
    if ([CCConnectionHelper sharedClient].providerExpiresAt != nil) {
        NSString *providerExpiresAt = [CCConnectionHelper sharedClient].providerExpiresAt;
        double providerExpiresAtDouble = providerExpiresAt.doubleValue;
        providerExpiresAtDate = [NSDate dateWithTimeIntervalSince1970:providerExpiresAtDouble];
    }
    [[CCConnectionHelper sharedClient] loadChannelId:self.orgUid
                                           firstName:self.firstName
                                          familyName:self.familyName
                                               email:self.email
                                            provider:[CCConnectionHelper sharedClient].provider
                                       providerToken:[CCConnectionHelper sharedClient].providerToken
                                 providerTokenSecret:[CCConnectionHelper sharedClient].providerTokenSecret
                                providerRefreshToken:[CCConnectionHelper sharedClient].providerRefreshToken
                                   providerCreatedAt:providerCreatedAtDate
                                   providerExpiresAt:providerExpiresAtDate
                                 channelInformations:self.channelInformations
                                         deviceToken:self.deviceToken
                                        showProgress:YES
                                   completionHandler:^(NSString *channelId, NSError *error, NSURLSessionDataTask *task)
    {
        if (channelId != nil) {
            NSLog(@"initChatView Success");
            self.channelId = channelId;
            [CCChatViewHelper sendChannelActive:self.channelId];

            ///init chat data
            self.messages  = [[NSMutableArray alloc] init];
            loadPreviousMessageNum = 0;
            [self setUidAndToken];
            if (self.senderId != nil && self.senderDisplayName != nil) [super viewWillAppear:NO]; ///viewWillAppear: initilizing chatView
            ///To display channel information from sever(the message may be received before connecting websocket)
            [[CCConnectionHelper sharedClient] updateChannel:YES
                                                  channelUid:channelId
                                           completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task)
             {
                [[CCConnectionHelper sharedClient] loadMessages:channelId
                                                   showProgress:YES
                                                          limit:CCloadLoacalMessageLimit
                                                         lastId:nil
                                              completionHandler:^(NSString *result, NSError *error, NSURLSessionDataTask *task)
                 {
                     [self loadLocalMessages:channelId];
                 }];
                 
                 [self loadLocalDisplayname:channelId];
            }];
            isInitializedJSQMessange = YES;
            isInitViewLocked = NO;
            self.deviceToken = nil; ///To prevent recalling create user
            [self loadChannelInfo:self.channelId];
        }else{
            if ([[CCConnectionHelper sharedClient] isAuthenticationError:task] == YES){
                [[CCConnectionHelper sharedClient] displayAuthenticationErrorAlert];
                NSLog(@"initChatView Error");
                isInitViewLocked = NO;
            }else{
                [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
                isInitViewLocked = NO;
            }
        }
    }];
}

-(void)finishedLoadingUserToken{
    [CCSVProgressHUD dismiss];
    ///Initialize (Create user or Create channel or Load channel)
    [self initView];
}

- (BOOL)isVideocallEnabled {
    if ([ChatCenter isVideoEnabled] && [self isAppVideocallEnabled] && [[CCConnectionHelper sharedClient] isSupportVideoChat] && [self processChannelUserVideoChatInfo]){
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)isAppVideocallEnabled {
    NSArray *stickers = [[CCConstants sharedInstance].stickers copy];
    NSLog(@"stickers = %@", stickers);
    for (int i = 0;i < stickers.count; i++) {
        if([stickers[i] isEqualToString:CC_STICKERTYPEVIDEOCHAT] || [stickers[i] isEqualToString:CC_STICKERTYPEVOICECHAT]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)processChannelUserVideoChatInfo {
    if(self.userVideoChat == nil || self.userVideoChat.count <= 0) {
        return NO;
    }
    for (NSDictionary *videoChat in self.userVideoChat) {
        NSLog(@"videoChatUser: %@(%@, %@) == %@",[videoChat objectForKey:@"id"],[videoChat objectForKey:@"display_name"], [videoChat objectForKey:@"can_use_video_chat"], self.uid);
        if([[videoChat objectForKey:@"id"] integerValue] != [self.uid integerValue] &&
           [[videoChat objectForKey:@"can_use_video_chat"] boolValue] == YES) {
            return YES; // at least one user can video chat
        }
    }
    return NO;
}

#pragma mark - Load message
-(void)loadAvatar:(NSString *)userUid user:(NSDictionary *)user{
    if (user[@"icon_url"] != nil && !([user[@"icon_url"] isEqual:[NSNull null]])) {
        if([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable) {
            dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_queue_t q_main   = dispatch_get_main_queue();
            dispatch_async(q_global, ^{
                NSError *error = nil;
                NSData *dt = [NSData dataWithContentsOfURL:[NSURL URLWithString:user[@"icon_url"]]
                                                   options:NSDataReadingUncached
                                                     error:&error];
                dispatch_async(q_main, ^{
                    NSMutableDictionary *mutableAvatars = [self.avatars mutableCopy];
                    UIImage *newIconImage = [[UIImage alloc] initWithData:dt scale:[UIScreen mainScreen].scale];
                    if (newIconImage != nil) {
                        if([mutableAvatars objectForKey:userUid] != nil){
                            [mutableAvatars removeObjectForKey:userUid];
                        }
                        CCJSQMessagesAvatarImage *JSQMessagesAvatarImage = [CCJSQMessagesAvatarImageFactory avatarImageWithImage:newIconImage
                                                                                              diameter:circleAvatarSize];
                        [mutableAvatars setObject:JSQMessagesAvatarImage forKey:userUid];
                        self.avatars = [mutableAvatars copy];
                        [self.collectionView reloadData];
                    }
                });
            });
        }
    }
    NSMutableDictionary *newAvatars = [self.avatars mutableCopy];
    NSString *firstCharacter = [user[@"display_name"] substringToIndex:1];
    UIImage *textIconImage = [[ChatCenter sharedInstance] createAvatarImage:firstCharacter width:circleAvatarSize height:circleAvatarSize color:[[ChatCenter sharedInstance] getRandomColor:user[@"id"]] fontSize:randomCircleAvatarFontSize textOffset:randomCircleAvatarTextOffset];
    if (textIconImage != nil) {
        [newAvatars setObject:[CCJSQMessagesAvatarImageFactory avatarImageWithImage:textIconImage diameter:circleAvatarSize]
                       forKey:userUid];
        self.avatars = [newAvatars copy];
    }
    
}

-(NSArray *)createMessageObjectsFromNSMagedObject:(NSManagedObject *)object reloadImage:(BOOL)isReload{
    
    //
    // Extract data from NSManagedObject
    //
    NSNumber *uid                = [object valueForKey:@"id"];
    NSString *type               = [object valueForKey:@"type"];
    NSData *contentData          = [object valueForKey:@"content"];
    NSDictionary *content        = [NSKeyedUnarchiver unarchiveObjectWithData:contentData];
    NSData *usersReadMessageData = [object valueForKey:@"users_read_message"];
    NSArray *usersReadMessage    = [NSKeyedUnarchiver unarchiveObjectWithData:usersReadMessageData];
    NSDate *date                 = [object valueForKey:@"created"];
    NSDictionary *answer;
    NSDictionary *user;
    NSString *userUid,*userDisplayName,*userIconUrl;
    BOOL userAdmin;
    
    
    if ([type isEqualToString:CC_RESPONSETYPEINFORMATION] || [type isEqualToString:CC_RESPONSETYPEPROPERTY]){
        user = nil;
        userDisplayName = nil;
        userIconUrl = nil;
    }else{
        //
        // Extract user data
        //
        if ([object valueForKey:@"user"] == nil || [[object valueForKey:@"user"] isEqual:[NSNull null]]) {
            return nil;
        }
        NSData *userData = [object valueForKey:@"user"];
        user  = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        if (user[@"id"] == nil
            || user[@"id"] == [NSNull null]
            || user[@"display_name"] == nil
            || user[@"display_name"] == [NSNull null]
            || user[@"icon_url"] == nil)
        {
            return nil;
        }
        userUid = [user[@"id"] respondsToSelector:@selector(stringValue)] ? [user[@"id"] stringValue] : user[@"id"];
        userDisplayName = user[@"display_name"];
        userIconUrl = user[@"icon_url"];
        int admin = [user[@"admin"] intValue];
        userAdmin = (admin == 1)? YES: NO;
        ///
        ///add avatar-image
        ///
        if ([self.avatars objectForKey:userUid] == nil){
            [self loadAvatar:userUid user:user];
        }
        if (isReload) {
            [self loadAvatar:userUid user:user];
        }
    }
    if ([object valueForKey:@"answer"] != nil) {
        NSData *answerData = [object valueForKey:@"answer"];
        answer = [NSKeyedUnarchiver unarchiveObjectWithData:answerData];
    }
    if (usersReadMessage == nil) {
        return nil;
    }
    ///send "Read" receipt
    if ([type isEqualToString:CC_RESPONSETYPEINFORMATION] || [type isEqualToString:CC_RESPONSETYPEPROPERTY]
        || ![userUid isEqualToString:self.uid]) {
        if ([usersReadMessage indexOfObject:self.uid] == NSNotFound) {
            [readMessageUids addObject:uid];
        }
    }
    NSNumber *status = [object valueForKey:@"status"];
    NSArray *messageObjects = [self createMessageObjects:type
                                                     uid:uid
                                                 content:content
                                        usersReadMessage:usersReadMessage
                                              fromSender:userUid
                                                  onDate:date
                                             displayName:userDisplayName
                                             userIconUrl:userIconUrl
                                               userAdmin:userAdmin
                                                  answer:answer
                                                  status:[status integerValue]];
    
    return messageObjects;
}

-(NSArray *)createMessageObjects:(NSString *)messageType
                             uid:(NSNumber *)uid
                         content:(NSDictionary *)content
                usersReadMessage:(NSArray *)usersReadMessage
                      fromSender:(NSString *)userUid
                          onDate:(NSDate *)date
                     displayName:(NSString *)displayName
                     userIconUrl:(NSString *)userIconUrl
                       userAdmin:(BOOL) userAdmin
                          answer:(NSDictionary *)answer
                          status:(NSInteger)status
{
    if (messageType == nil){
        return nil;
    }    
    ///duplicate check
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@",uid];
    NSArray *duplicates = [self.messages filteredArrayUsingPredicate: predicate];
    if ([duplicates count] > 0) {
        return nil;
    }
    
    //
    // Create message objects
    //
    NSArray<CCJSQMessage*> *retArray = [CCJSQMessage messageObjectsOfType:messageType
                                                                      uid:uid
                                                                  content:content
                                                         usersReadMessage:usersReadMessage
                                                               fromSender:userUid
                                                                   onDate:date
                                                              displayName:displayName
                                                              userIconUrl:userIconUrl
                                                                userAdmin:userAdmin
                                                                   answer:answer
                                                                   status:status];
    


    //
    // Load image if the type is Image
    //
    if([messageType isEqualToString:CC_RESPONSETYPEIMAGE]
       && content[@"files"] != nil)
    {
        for (NSDictionary *file in content[@"files"]) {
            
            __block NSNumber *blockUid = uid;
            dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_queue_t q_main   = dispatch_get_main_queue();
            dispatch_async(q_global, ^{
                NSString *url = [[CCConnectionHelper sharedClient] addAuthToUrl:file[@"url"][@"medium"]];
                NSError *error = nil;
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:NSDataReadingUncached error:&error];
                dispatch_async(q_main, ^{
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    CCJSQPhotoMediaItem *photoItem = [[CCJSQPhotoMediaItem alloc] initWithImage:image];
                    CCJSQMessage *newMessage = [CCJSQMessage messageWithSenderId:userUid
                                                                     displayName:displayName
                                                                           media:photoItem];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@",blockUid];
                    NSIndexSet* indexes = [self.messages indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                        return [predicate evaluateWithObject:obj];
                    }];
                    if (indexes == nil || indexes.firstIndex == NSNotFound) {
                        return;
                    }
                    NSUInteger index = indexes.firstIndex;
                    if (self.messages.count < index) {
                        return;
                    }
                    CCJSQMessage *oldMessage = (CCJSQMessage *)self.messages[index];
                    newMessage.content = oldMessage.content;
                    newMessage.uid = oldMessage.uid;
                    newMessage.type = oldMessage.type;
                    newMessage.status = oldMessage.status;
                    newMessage.isAgent = oldMessage.isAgent;
                    [self.messages removeObjectAtIndex:index];
                    [self.messages insertObject:newMessage atIndex:index];
                    [self.collectionView reloadData];
                });
            });
        }
    }
    
    return retArray;
    
}

-(void)loadLocalMessages:(NSString *)channelId{

    //
    // Load from local DB
    //
    NSArray *messageArray = [[CCCoredataBase sharedClient] selectMessageWithChannel:channelId lastId:nil limit:CCloadLoacalMessageLimit];
    
    self.messages   = [[NSMutableArray alloc] init];
    readMessageUids = [[NSMutableArray alloc] init];
    
    int startMessage;
    if (messageArray.count >= CCloadLoacalMessageLimit) {
        startMessage = (int)messageArray.count - (CCloadLoacalMessageLimit - 1);
    }else{
        startMessage = 0;
    }
    for (int i = startMessage; i < (int)messageArray.count; i++) {
        NSManagedObject *object      = [messageArray objectAtIndex:i];
        NSArray *messages = [self createMessageObjectsFromNSMagedObject:object reloadImage:YES];
        for (CCJSQMessage *message in messages) {
            if ([message.type isEqualToString:CC_RESPONSETYPESUGGESTION]) {
                NSArray<NSDictionary*> *actionData = [[[message content] objectForKey:@"sticker-action"] objectForKey:@"action-data"];
                self.suggestionActionData = [actionData mutableCopy];
            }
            
            [self.messages addObject:message];
        }
    }

    if (readMessageUids != nil && readMessageUids.count>0) {
        if ([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable || CCLocalDevelopmentMode) {
            [[CCConnectionHelper sharedClient] sendMessageReceivedStatus:self.channelId messageIds:readMessageUids];
            [self updateLocalChannelClearUnreadMessages];
        }
    }
    [self finishSendingMessageAnimated:NO];
    /*
     * This "reloadData" is temporary repairs. "finishSendingMessageAnimated" already included "reloadData". However,if content size on Collection View was changed, it can not scroll to bottom propery. This problem can be occured when Agent switches channel on iPad.
     */
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:YES];
    if (!self.isReturnFromRightMenuView) {
        [self displayFixedPhraseOrSuggestionIfNeed];
    }
    newMessageView.hidden = YES;
    // try to resend failed message
    [self resendFailedMessage:self.channelId resendDelivering:NO];
    [self sendStopSharingLocationIfNeed];
}

-(void)loadMessagesIfNeeded:(NSString *)channelId{
    ///TODO:Need to improve reducing load
    if([CCConnectionHelper sharedClient].currentView != nil) {
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading Messages...")];
    }
    if(!([[CCConnectionHelper sharedClient] getNetworkStatus] == CCNotReachable && CCLocalDevelopmentMode == NO)) {
        [[CCConnectionHelper sharedClient] loadMessages:channelId
                                           showProgress:NO
                                                  limit:CCloadLoacalMessageLimit
                                                 lastId:nil
                                      completionHandler:^(NSString *result, NSError *error, NSURLSessionDataTask *task)
         {
             if (result != nil) {
                 if([CCConnectionHelper sharedClient].currentView != nil) {
                     [CCSVProgressHUD dismiss];
                 }
                 [self loadLocalMessages:channelId];
             } else {
                 [[CCConnectionHelper sharedClient] loadChannels:NO getChennelType:CCGetChannelsMine org_uid:nil limit:CCloadChannelFirstLimit lastUpdatedAt:nil completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task){
                     NSArray *channelArray = [[CCCoredataBase sharedClient] selectChannelWithUid:CCloadLoacalChannelLimit uid:self.channelId];
                     if (channelArray.count == 0) {
                         [self receiveDeleteChannelFromWebSocket];
                     } else {
                         if([CCConnectionHelper sharedClient].currentView != nil) {
                             [CCSVProgressHUD showErrorWithStatus:CCLocalizedString(@"Load Message Failed")];
                         }
                     }
                 }];
             }
         }];
    } else {
        [self loadLocalMessages:channelId];
    }
}

-(void)loadMessages:(NSString *)channelId{
    NSArray *messageArray = [[CCCoredataBase sharedClient] selectMessageWithChannel:channelId lastId:nil limit:CCloadLoacalMessageLimit];
    if (messageArray.count > 0
        || ([[CCConnectionHelper sharedClient] getNetworkStatus] == CCNotReachable && CCLocalDevelopmentMode == NO)) {
        [self loadLocalMessages:channelId];
    }else{
        [[CCConnectionHelper sharedClient] loadMessages:channelId
                                           showProgress:YES
                                                  limit:CCloadLoacalMessageLimit
                                                 lastId:nil
                                      completionHandler:^(NSString *result, NSError *error, NSURLSessionDataTask *task)
         {
             [self loadLocalMessages:channelId];
         }];
    }
}

-(void)loadPreviousLocalMessages:(NSString *)channelId limit:(int)limit lastId:(NSNumber *)lastId completionHandler:(void (^)(void))completionHandler{
    ///TODO:select oldest message and id, load previous messages from the id
    NSArray *messageArray = [[CCCoredataBase sharedClient] selectMessageWithChannel:channelId lastId:lastId limit:limit];
    if (self.messages == nil)  self.messages  = [[NSMutableArray alloc] init];
    readMessageUids = [[NSMutableArray alloc] init];
    int endMessageIndex;
    if (messageArray.count >= limit) { ///coredata's setFetchBatchSize is not accurate, it may select more than it's limit
        endMessageIndex = (int)messageArray.count-(limit-1);
    }else{
        endMessageIndex = 0;
    }
    for (int i = (int)messageArray.count-1; endMessageIndex <= i ; i--) {
        NSManagedObject *object      = [messageArray objectAtIndex:i];
        NSArray *messages = [self createMessageObjectsFromNSMagedObject:object reloadImage:NO];
        for (CCJSQMessage *message in messages) {
            [self.messages insertObject:message atIndex:0];
        }
    }
    //Load display name from channel
    [self loadLocalDisplayname:channelId];
    if (readMessageUids != nil && readMessageUids.count>0) {
        if ([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable || CCLocalDevelopmentMode) {
            [[CCConnectionHelper sharedClient] sendMessageReceivedStatus:self.channelId messageIds:readMessageUids];
        }
    }
    [self.collectionView reloadData];

    loadPreviousMessageNum++;
    
    if(completionHandler != nil) completionHandler();
}



-(void)loadPreviousMessages:(BOOL)showProgress lastId:(NSNumber *)lastId{
    if ([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable || CCLocalDevelopmentMode) {
        
        [[CCConnectionHelper sharedClient] loadMessages:self.channelId
                                           showProgress:showProgress
                                                  limit:CCloadMessageFirstLimit
                                                 lastId:lastId
                                      completionHandler:^(NSString *result, NSError *error, NSURLSessionDataTask *task)
        {
            if (result != nil) {
                [self loadPreviousLocalMessages:self.channelId limit:CCloadLoacalMessageLimit lastId:lastId completionHandler:^{
                    loadPreviousMessage = NO;
                }];
            }else{
                if ([[CCConnectionHelper sharedClient] isAuthenticationError:task] == YES){
                    [[CCConnectionHelper sharedClient] displayAuthenticationErrorAlert];
                }else{
                    [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
                }
            }
        }];
    }else{
        [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
    }
}

- (void)addLocationLatitude:(double)latitude longitude:(double)longitude address:(NSString*)address MediaMessageCompletion:(CCJSQLocationMediaItemCompletionBlock)completion
{
    NSDictionary *locationContent = @{@"message":@{@"text":address},
                                      CC_RESPONSETYPESTICKERCONTENT:
                                          @{@"sticker-data" :
                                                @{@"location" :
                                                      @{@"lat":[NSString stringWithFormat:@"%f", latitude],
                                                        @"lng":[NSString stringWithFormat:@"%f", longitude]}
                                                  }
                                            }
                                      };
    [self sendLocationMessage:locationContent];
}

#pragma mark - CClocationStickerViewDelegate
- (void)didSelectLocationWithLatitude:(double)latitude longitude:(double)longitude address:(NSString *)address {
    __weak UICollectionView *weakView = self.collectionView;
    [self addLocationLatitude:latitude longitude:longitude address:address MediaMessageCompletion:^{
        [weakView reloadData];
    }];
}

#pragma mark - LocationManagerDelegate

-(void)locationSetup { // for colocation widget
    colocationBackgroundTask = UIBackgroundTaskInvalid;
    locationManager = [[CLLocationManager alloc] init];
    lastUpdatedLocation = [[CLLocation alloc] init];
    locationManager.delegate = self;
    if ([self checkLocationEnabled]) {
        [locationManager requestWhenInUseAuthorization];
        [locationManager startUpdatingLocation];
    }
}

-(BOOL)checkLocationEnabled {
    // Check if location services are available
    if ([CLLocationManager locationServicesEnabled] == NO) {
        
        // Display alert to the user.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Location services")
                                                                       message:CCLocalizedString(@"Location services are not enabled on this device. Please enable location services in settings.")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Dismiss") style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
        
    }
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) { //requestWhenInUseAuthorization can be used in iOS8
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusNotDetermined: {
                [locationManager requestWhenInUseAuthorization];
                return NO;
            }
                
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse: {
                return YES;
            }
                
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted: {
                // Display alert to the user.
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Location services")
                                                                               message:CCLocalizedString(@"Location services are not enabled on this device. Please enable location services in settings.")
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Dismiss") style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                NSLog(@"Location is denied");
                return NO;
            }
        }
    }
    
    return YES;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"Location is denied");
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [locationManager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            NSLog(@"Location is denied");
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *lastLocation = [locations lastObject];
    lastUpdatedLocation = lastLocation;
}

#pragma mark - Live Location Widget Delegate
- (void)didStopSharingLiveLocation {
    [self stopSharingLocation];
}

- (void)didStartSharingLiveLocation {
    NSString *text = CCLocalizedString(@"Location");
    
    NSDictionary *locationContent = @{@"uid":[self generateMessageUniqueId],
                                      @"message":@{@"text":text},
                                      @"sticker-type": CC_STICKERTYPECOLOCATION,
                                      CC_RESPONSETYPESTICKERCONTENT:
                                          @{@"sticker-data" :
                                                @{
                                                    @"type": @"start",
                                                    @"location" :
                                                        @{@"lat":[NSString stringWithFormat:@"%f", lastUpdatedLocation.coordinate.latitude],
                                                          @"lng":[NSString stringWithFormat:@"%f", lastUpdatedLocation.coordinate.longitude]}
                                                    }
                                            }
                                      };
    
    CCJSQMessage *message = [self appendTempMessage:CC_RESPONSETYPESTICKER content:locationContent];
    [[CCConnectionHelper sharedClient] sendMessage:message.content channelId:self.channelId type:CC_RESPONSETYPESTICKER completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task){
        if(result != nil){
            [self updateTempMessage:message withResult:result];
            colocationMessage = [message copy];
            colocationMessage.uid = result[@"id"];
            [self.collectionView reloadData];
            [self loadLocalData:NO];
            [CCSVProgressHUD dismiss];
            if(result[@"content"] != nil && ![result[@"content"] isEqual:[NSNull null]]) {
                NSDictionary *stickerContent = result[@"content"][CC_STICKERCONTENT];
                if(stickerContent != nil && stickerContent[CC_STICKER_DATA] != nil && ![stickerContent[CC_STICKER_DATA] isEqual:[NSNull null]]) {
                    NSDictionary *stickerData = stickerContent[CC_STICKER_DATA];
                    float preferredInterval;
                    if(stickerData[@"preferred_interval"] != nil) {
                        preferredInterval = [stickerData[@"preferred_interval"] floatValue];
                    } else {
                        preferredInterval = CC_COLOCATION_PREFERRED_INTERVAL;
                    }
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    liveColocationShareTimer = 0;
                    liveColocationShareDuration = (int)[userDefaults integerForKey:kCCUserDefaults_liveLocationDuration];
                    CCLiveLocationTask *task = [[CCConnectionHelper sharedClient].shareLocationTasks objectForKey:self.channelId];
                    ///
                    /// 1. Remove old task if exists
                    ///
                    if (task != nil) {
                        [[CCConnectionHelper sharedClient].shareLocationTasks removeObjectForKey:self.channelId];
                    }
                    
                    ///
                    /// 2. Create new task
                    ///
                    colocationTimer = [NSTimer scheduledTimerWithTimeInterval:preferredInterval target:self selector:@selector(sendUpdateColocationMessage) userInfo:nil repeats:YES];
                    preferredTimeInterval = preferredInterval;
                    CCLiveLocationTask *newTask = [[CCLiveLocationTask alloc] init];
                    newTask.colocationTimer = colocationTimer;
                    newTask.liveColocationShareTimer = liveColocationShareTimer;
                    newTask.liveColocationShareDuration = liveColocationShareDuration;
                    newTask.colocationMessage = colocationMessage;
                    
                    [[CCConnectionHelper sharedClient].shareLocationTasks setObject:newTask forKey:self.channelId];
                    [self registerColocationBackgroundTask];
                    ///
                    /// Reload collection data
                    ///
                    [self reloadCollectionViewData];
                    if(stickerContent[CC_STICKERCONTENT_ACTION] != nil && [stickerContent[CC_STICKERCONTENT_ACTION] count] > 0) {
                        ///
                        /// Open webview after share location
                        ///
                        NSString *urlString = [stickerContent[CC_STICKERCONTENT_ACTION] objectAtIndex:0];
                        CCLiveLocationWebviewController *liveLocationWebviewController = [[CCLiveLocationWebviewController alloc] initWithNibName:@"CCLiveLocationWebviewController" bundle:SDK_BUNDLE];
                        liveLocationWebviewController.urlString = urlString;
                        liveLocationWebviewController.channelID = self.channelId;
                        if ([[CCConnectionHelper sharedClient].shareLocationTasks objectForKey:self.channelId] != nil) {
                            liveLocationWebviewController.isSharingLocation = YES;
                        } else {
                            liveLocationWebviewController.isSharingLocation = NO;
                        }
                        liveLocationWebviewController.delegate = self;
                        liveLocationWebviewController.isOpenedFromWidgetMessage = YES;
                        NSMutableArray *viewControllers = [[self.navigationController viewControllers] mutableCopy];
                        [viewControllers removeLastObject];
                        [viewControllers addObject:liveLocationWebviewController];
                        [self.navigationController setViewControllers:viewControllers animated:YES];
                    }
                }
            }
            
        }else{
            //            [self updateStatusForMessage:message sendSuccess:NO];
            if ([[CCConnectionHelper sharedClient] isAuthenticationError:task] == YES){
                [[CCConnectionHelper sharedClient] displayAuthenticationErrorAlert];
            }else{
                NSLog(@"Message POST Failed!");
            }
        }
        [self reloadCollectionViewData];
    }];
}

#pragma mark - Keyboard Control For MenuBar

-(void)keyboardWillShow:(NSNotification*)notification
{
    keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    isEditingFreewordTextView = NO;
    
    if (newMessageView != nil) {
        newMessageView.hidden = YES;
    }
}

- (BOOL)keyboardWillHide:(NSNotification*)notification
{
    isKeyboardShowing = NO;
    if (isEditingFreewordTextView) {
        isEditingFreewordTextView = NO;
    }

    [self.view setNeedsLayout];
    [self.view endEditing:YES];
    self.inputToolbar.contentView.textView.inputView = nil;
    [self.inputToolbar.contentView.textView reloadInputViews];
    [self showInputToolbarMenu];
    if (self.inputToolbarMenuView.shouldShowSuggestion) {
        UIButton *button = self.inputToolbarMenuView.buttons[1];
        [button setTintColor:[UIColor lightGrayColor]];
    }
    currentInputMode = kInputKeyboardMode;
    if (isKeyboardShowing) {
        [self.inputToolbar.contentView.textView resignFirstResponder];
    }
    isKeyboardShowing = NO;
    // Hide suggestion if latest message is not suggestion
    if (!isDisplayingAlert) {
        isDisplayingSuggestionView = NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [super textViewDidChange:textView];
    [self saveDraftMessage];
    NSString *inputText = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    long textLenght = inputText.length;
    if (textLenght > CCInputTextLimit) {
        if (self.inputToolbar.contentView.rightBarButtonItem.enabled || (lastTextLenght == 0 && !self.inputToolbar.contentView.rightBarButtonItem.enabled)) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:CCLocalizedString(@"Please input 2000 characters or less.") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:CCLocalizedString(@"OK")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                       }];
            [alertController addAction:okAction];
            [self.inputToolbar.contentView.textView resignFirstResponder];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        self.inputToolbar.contentView.rightBarButtonItem.enabled = NO;
        lastTextLenght = textLenght;
    } else if (textLenght > 0) {
        self.inputToolbar.contentView.rightBarButtonItem.enabled = YES;
        lastTextLenght = 0;
    } else {
        lastTextLenght = 0;
        self.inputToolbar.contentView.rightBarButtonItem.enabled = NO;
    }
    
    //
    // Send typing message if need
    //
    if (!isTyping) {
        isTyping = YES;
        NSString *content = [NSString stringWithFormat:@"{\"channel_uid\":\"%@\", \"user\": {\"id\":\"%@\"}}", self.channelId, self.uid];
        [[CCConnectionHelper sharedClient] sendMessageViaWebsocket:@"message:typing" content:content];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTypingStatus) userInfo:nil repeats:NO];
    }
}

- (void) updateTypingStatus {
    isTyping = NO;
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    ///Prevent crash without channelId
    if (self.channelId == nil) {
        [self initView];
        return;
    }
    
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    NSDictionary *content = @{@"text":text, @"uid":[self generateMessageUniqueId]};
    self.inputToolbar.contentView.textView.text = @"";
    [self saveDraftMessage];
    self.inputToolbar.contentView.rightBarButtonItem.enabled = NO;
    [self sendMessageFromInputToolbar:content];
    [self scrollToBottomAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    ///Prevent crash without channelId
    if (self.channelId == nil) {
        [self initView];
        return;
    }
    isDisplayingSuggestionView = NO;
    [self showInputToolbarMenu];
}

- (void) showInputToolbarMenu {
    self.inputToolbar.contentView.textView.text = @"";
    [self.inputToolbar.contentView.textView endEditing:YES];
    [self.inputToolbar.contentView.textView setHidden:YES];
    [self.inputToolbarMenuView setHidden:NO];
    CGRect oldFrame = self.inputToolbar.frame;
    CGRect newFrame = oldFrame;
    newFrame.size.height = CC_INPUT_TOOLBAR_HEIGHT;
    [self.inputToolbar setFrame:newFrame];
    [self.inputToolbar setNeedsUpdateConstraints];
    [self.inputToolbar updateConstraints];
}

- (CCWidgetMenuView *)createInputToolbarMenuView {
    UIScreen *screen = [UIScreen mainScreen];
 
    CGRect stickersMenuFrame = CGRectMake(0.0, 0.0, screen.bounds.size.width, CC_INPUT_TOOLBAR_HEIGHT);
    
    CCWidgetMenuView *inputAccessoryView = [[CCWidgetMenuView alloc] initWithFrame:stickersMenuFrame owner:self];
    
    return inputAccessoryView;

}

- (void)displaySuggestionWithActionData:(NSArray<NSDictionary*> *)actionData {
    if (self.isPulldownSelectBoxDisplayed || ![self isTopMostViewController]) {
        return;
    }
    
    [self.inputToolbarMenuView removeFromSuperview];
    self.inputToolbarMenuView = [self createInputToolbarMenuView];
    [self.inputToolbar.contentView addSubview:self.inputToolbarMenuView];
    
    self.suggestionActionData = actionData;
    isDisplayingSuggestionView = YES;
    isAlreadyDisplaySuggestionView = YES;
    CGRect frame = CGRectMake(10.0, 0.0, 520, keyboardHeight);
    
    NSArray *nibs = [SDK_BUNDLE loadNibNamed:@"CCSuggestionInputView" owner:nil options:0];
    CCSuggestionInputView *inputAccessoryView = [nibs lastObject];
    
    inputAccessoryView.autoresizingMask = UIViewAutoresizingNone;
    inputAccessoryView.frame = frame;
    [inputAccessoryView setupWithData:actionData owner:self];
    
    self.inputToolbar.contentView.textView.inputView = inputAccessoryView;
    UIButton *switchToToolbarMenuButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [switchToToolbarMenuButton setImage:[UIImage SDKImageNamed:@"CCcancel_btn"] forState:UIControlStateNormal];
    switchToToolbarMenuButton.tintColor = [[CCConstants sharedInstance] baseColor];
    self.inputToolbar.contentView.leftBarButtonItem = switchToToolbarMenuButton;
    [self.inputToolbar.contentView.textView becomeFirstResponder];
    [self.inputToolbar.contentView.textView reloadInputViews];
    
    return;
}

- (void)displayWidgetMenu {
    if (self.inputToolbarMenuView != nil) {
        [self.inputToolbarMenuView removeFromSuperview];
    }

    // create input toolbar menu view
    self.inputToolbarMenuView = [self createInputToolbarMenuView];
    if (self.inputToolbarMenuView.shouldShowSuggestion) {
        if (self.inputToolbarMenuView.buttons.count > 1) {
            UIButton *button = self.inputToolbarMenuView.buttons[1];
            [button setTintColor:[UIColor lightGrayColor]];
        }
    }
    [self.inputToolbar.contentView addSubview:self.inputToolbarMenuView];
    [self showInputToolbarMenu];
}

- (void)displayFixedPhrase: (NSArray<NSDictionary*> *)contents {
    if (self.isPulldownSelectBoxDisplayed) {
        return;
    }

    if (self.inputToolbarMenuView.shouldShowSuggestion) {
        UIButton *button = self.inputToolbarMenuView.buttons[1];
        [button setTintColor:[UIColor lightGrayColor]];
    }
    // Display fixed phrase menu
    UIScreen *screen = [UIScreen mainScreen];
    CGRect frame = CGRectMake(0.0, 0.0, screen.bounds.size.width, keyboardHeight);
    
    NSArray *nibs = [SDK_BUNDLE loadNibNamed:@"CCFixedPhraseInputView" owner:nil options:0];
    CCFixedPhraseInputView *inputAccessoryView = [nibs lastObject];
    
    inputAccessoryView.autoresizingMask = UIViewAutoresizingNone;
    inputAccessoryView.frame = frame;
    [inputAccessoryView setupWithData:contents owner:self];
    
    self.inputToolbar.contentView.textView.inputView = inputAccessoryView;
    [self.inputToolbar.contentView.textView setHidden:NO];
    [self.inputToolbar.contentView.textView becomeFirstResponder];
    [self.inputToolbar.contentView.textView reloadInputViews];
    [self.view setNeedsLayout];
    isDisplayingSuggestionView = NO;
    [self scrollToBottomAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            /**
             *  These for calendar sticker
             */
            [self pressCalendar];
            NSLog(@"Tapped avatar!");
            break;
            
        case 1:
        {
            [self pressLocation];
        }
            break;
            
        case 2:
            break;
    }
    [self finishSendingMessageAnimated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if([URL.absoluteString hasPrefix:@"http://"] || [URL.absoluteString hasPrefix:@"https://"]) {
        [self openURL:URL];
        return NO;
    }
    self.isReturnFromInteractingWithURL = YES;
    return YES;
}

- (void) resendFailedMessage:(NSString*) channelUid resendDelivering:(BOOL) resendDelivering
{
    if (self.onResendingFailedMessages) {
        return;
    }
    self.onResendingFailedMessages = YES;
    
    NSMutableArray *failedMessages = [NSMutableArray array];
    
    // Get all failed message from Database
    NSArray *messageArray = [[CCCoredataBase sharedClient] selectFailedMessageWithChannel:channelUid];
    for (int i = 0; i < (int)messageArray.count; i++) {
        NSManagedObject *object      = [messageArray objectAtIndex:i];
        NSArray *messages = [self createMessageObjectsFromNSMagedObject:object reloadImage:NO];
        for (CCJSQMessage *message in messages) {
            if(![self isMessageInListSending:message]) {
                [failedMessages addObject:message];
            }
        }
    }
    
    // Resend all failed message on Current List Message
    if (self.messages != nil || self.messages.count > 0) {
        for (int i = 0; i< self.messages.count; i++) {
            CCJSQMessage *message = [self.messages objectAtIndex:i];
            if(message.status == CC_MESSAGE_STATUS_SEND_FAILED || (message.status == CC_MESSAGE_STATUS_DELIVERING && resendDelivering)) {
                if(![self isMessageInListSending:message]) {
                    [failedMessages addObject: message];
                }
            }
        }
    }
    
    [self checkResendMessage:failedMessages];
    
    [self resendListMessage:failedMessages];
}

- (void) checkResendMessage: (NSMutableArray *) failedMessages {
    for (CCJSQMessage *message in failedMessages ) {
        NSString *msgFailedUid = [CCParseUtils getStringAtPath:@"uid" fromObject:message.content];
        BOOL isSendMsgSuccess = NO;
        for (CCJSQMessage *msg in self.messages ){
            NSString *msgUid = [CCParseUtils getStringAtPath:@"uid" fromObject:msg.content];
            if ([msgFailedUid isEqualToString:msgUid] && msg.status == CC_MESSAGE_STATUS_SEND_SUCCESS) {
                message.status = CC_MESSAGE_STATUS_SEND_SUCCESS;
                [failedMessages removeObject:message];
                [[CCCoredataBase sharedClient] deleteTempMessage:message.uid];
                
                isSendMsgSuccess = YES;
                for (CCJSQMessage *msgFaild in self.messages) {
                    if ([message.uid doubleValue] == [msgFaild.uid doubleValue]) {
                        [self.messages removeObject:msgFaild];
                        [self.collectionView reloadData];
                        break;
                    }
                }
                break;
            }
        }
        if (isSendMsgSuccess) {
            [self checkResendMessage:failedMessages];
            break;
        }
    }
}

-(void) sendStopSharingLocationIfNeed {
    CCLiveLocationTask *task = [[CCConnectionHelper sharedClient].shareLocationTasks objectForKey:self.channelId];
    if (task != nil) {
        return;
    }
    ///
    /// Try to send stop sharing location request if need
    ///
    for (CCJSQMessage *message in self.messages) {
        NSString *stickerType = [message getStringAtPath:@"sticker-type"];
        if(stickerType != nil && [stickerType isEqualToString:CC_STICKERTYPECOLOCATION]) {
            NSDictionary *stickerData = [message getDictionaryAtPath:@"sticker-content/sticker-data"];
            if (stickerData != nil) {
                NSArray *users = stickerData[@"users"];
                if (users != nil && users.count > 0) {
                    for(int i = 0; i < users.count; i++) {
                        NSDictionary *user = users[i];
                        if (user[@"id"] != nil && [[user[@"id"] stringValue] isEqualToString:self.uid]) {
                            NSDictionary *locationContent = @{
                                                              CC_STICKER_TYPE: CC_STICKERTYPECOLOCATION,
                                                              CC_RESPONSETYPESTICKERCONTENT:
                                                                  @{CC_STICKER_DATA :
                                                                        @{
                                                                            @"type": @"stop"
                                                                            }
                                                                    },
                                                              @"reply_to": message.uid
                                                              };
                            [[CCConnectionHelper sharedClient] sendMessage:locationContent channelId:self.channelId type:CC_RESPONSETYPERESPONSE completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task){
                                NSLog(@"Send stop sharing co-location");
                                [self reloadCollectionViewData];
                            }];
                        }
                        break;
                    }
                }
            }
        }
    }
}

- (void) resendListMessage:(NSMutableArray *) messages
{
    if (messages == nil || messages.count == 0) {
        self.onResendingFailedMessages = NO;
        return;
    }
    
    CCJSQMessage *message = [messages objectAtIndex:0];
    // check duplicate sendding message
    BOOL foundDuplicate = [self isMessageInListSending:message];
    [self.sendingMessages addObject:message];
    
    if (!foundDuplicate) {
        if ([message.type isEqualToString:CC_STICKERTYPEIMAGE]) {
            if (message.content[@"url"] != nil) {
                [[CCImageHelper sharedInstance] loadLocalImage:message.content[@"url"] completionHandler:^(UIImage *imagelocal) {
                    if (imagelocal != nil) {
                        NSURL *assetURL = message.content[@"url"];
                        NSString *extension = [assetURL pathExtension];
                        CFStringRef imageUTI = (UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(__bridge CFStringRef)extension , NULL));
                        message.status = CC_MESSAGE_STATUS_DELIVERING;
                        NSString *uid = [CCParseUtils getStringAtPath:@"uid" fromObject:message.content];
                        [self sendImage:imagelocal imageUTI:imageUTI isShowAlert:NO uid:uid completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
                            [self updateTempMessage:message withResult:result];
                            if (result != nil) {
                                [[CCCoredataBase sharedClient] deleteTempMessage:message.uid];
                                message.status = CC_MESSAGE_STATUS_SEND_SUCCESS;
                                [messages removeObject:message];
                                [self.sendingMessages removeObject:message];
                                [self resendListMessage:messages];
                                NSNumber *uid = [result valueForKey:@"id"];
                                for (CCJSQMessage * msg in self.messages) {
                                    if ([msg.type isEqualToString:CC_STICKERTYPEIMAGE]){
                                        if ([msg.uid integerValue] == [message.uid integerValue]) {
                                            if (uid == nil) {
                                                [self.messages removeObject:msg];
                                            } else {
                                                msg.uid = uid;
                                                msg.status = CC_MESSAGE_STATUS_SEND_SUCCESS;
                                            }
                                            break;
                                        }
                                    }
                                }
                                
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@",message.uid];
                                NSArray *checkExistMsgTmp = [self.messages filteredArrayUsingPredicate: predicate];
                                if (checkExistMsgTmp.count > 0) {
                                    for (CCJSQMessage * msg in self.messages) {
                                        if ([msg.type isEqualToString:CC_STICKERTYPEIMAGE]){
                                            if ([msg.uid integerValue] == [message.uid integerValue]) {
                                                [self.messages removeObject:msg];
                                                break;
                                            }
                                        }
                                    }
                                }
                                
                                [self.collectionView reloadData];
                            } else {
                                self.onResendingFailedMessages = NO;
                                message.status = CC_MESSAGE_STATUS_SEND_FAILED;
                                // Resend this image
                                [self.collectionView reloadData];
                            }
                        }];
                    } else {
                        [[CCCoredataBase sharedClient] deleteTempMessage:message.uid];
                        message.status = CC_MESSAGE_STATUS_SEND_SUCCESS;
                        [messages removeObject:message];
                        [self.sendingMessages removeObject:message];
                        [self resendListMessage:messages];
                        [self.messages removeObject:message];
                        [self.collectionView reloadData];
                    }
                }];
            }
        } else {
        [[CCConnectionHelper sharedClient] sendMessage:message.content channelId:self.channelId type:message.type completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task){
            [self updateTempMessage:message withResult:result];
            if(result != nil){
                NSLog(@"Message POST Success!");
                [[CCCoredataBase sharedClient] updateChannelUpdateAtAndStatusWithUid:self.channelId updateAt:[NSDate date] status:@"unassigned"];
                // delete temp message from db & update status for message
                [[CCCoredataBase sharedClient] deleteTempMessage:message.uid];
                message.status = CC_MESSAGE_STATUS_SEND_SUCCESS;
                
                // resend other failed messages
                [messages removeObject:message];
                [self resendListMessage:messages];
                [self loadMessages:self.channelId];
                
                [self processStartSharingLocationResponse:result message:message];
            }else{
                if ([[CCConnectionHelper sharedClient] isAuthenticationError:task] == YES){
                    [[CCConnectionHelper sharedClient] displayAuthenticationErrorAlert];
                }else{
                    NSLog(@"Message POST Failed!");
                }
                
                // stop resend failed messages
                [self resendListMessage:nil];
            }
            [self reloadCollectionViewData];
        }];
        }
    } else {
        [messages removeObject:message];
        [self resendListMessage:messages];
    }
}

- (BOOL) isMessageInListSending:(CCJSQMessage *) message {
    for (int j = 0; j < self.sendingMessages.count; j++) {
        CCJSQMessage *sendingMessage = [self.sendingMessages objectAtIndex:j];
        NSString *sendingMessageUid = (sendingMessage.content != nil && [sendingMessage.content objectForKey:@"uid"] != nil) ? [sendingMessage.content objectForKey:@"uid"] : @"";
        NSString *messageUid = (message.content != nil && [message.content objectForKey:@"uid"] != nil) ? [message.content objectForKey:@"uid"] : @"";
        if ([sendingMessageUid isEqualToString:messageUid]) {
            return YES;
        }
    }
    
    return NO;
}

- (void) sendImage:(UIImage *)selectedImage imageUTI:(CFStringRef)imageUTI isShowAlert:(BOOL)isShowAlert uid:(NSString *)uid
 completionHandler:(void (^)(NSDictionary *result, NSError *error, NSURLSessionDataTask *task))completionHandler {
    [self scrollToBottomAnimated:YES];
    NSData *data = nil;
    NSString *mimeType = nil;
   
    if (UTTypeConformsTo(imageUTI, kUTTypePNG)) {
        data = UIImagePNGRepresentation(selectedImage);
        mimeType = @"image/png";
    } else {
        data = UIImageJPEGRepresentation(selectedImage, 0.9f);
        mimeType = @"image/jpeg";
    }
    CFRelease(imageUTI);
    if (data.length > CCUploadFileSizeLimit) {
        // show error
        if (isShowAlert) {
            CCAlertView *alert = [[CCAlertView alloc] initWithController:self title:nil message:CCLocalizedString(@"Please size of the file is in the 20MB or less.")];
            [alert addActionWithTitle:CCLocalizedString(@"OK") handler:nil];
            [alert show];
        }
        return;
    }
    
    if (data.length > CCImageMaxSize) {
        data = [[CCImageHelper sharedInstance] compress:selectedImage targetSize:CCImageMaxSize];
    }

    NSArray *files = @[@{@"data":data,
                         @"name":@"test",
                         @"mimeType":mimeType}];
    
    [[CCConnectionHelper sharedClient] sendFile:self.channelId uid:uid files:files completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
        if (result != nil) {
            if (completionHandler != nil) completionHandler(result,nil, task);
        } else {
            if (completionHandler != nil) completionHandler(nil,error, task);
        }
    }];
}

/*
 * Customize for richdata sticker
 */

#pragma mark - Collection view delegate flow layout overrides

- (CGSize)collectionView:(CCJSQMessagesCollectionView *)collectionView
                  layout:(CCJSQMessagesCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCJSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    CCJSQMessage *preMsg;
    if (indexPath.item > 1) {
        preMsg = [self.messages objectAtIndex:indexPath.item - 1];
    }
    
    CCStickerCollectionViewCellOptions options = [self getStickerCellOptionsForIndexPath:indexPath message:msg previousMessage:preMsg];

    //
    // Sticker
    //
    if (   [msg.type isEqualToString:CC_RESPONSETYPESTICKER]
        || [msg.type isEqualToString:CC_STICKERTYPEIMAGE]) {
        float width = [collectionViewLayout sizeForItemAtIndexPath:indexPath].width;
        float height = [CCCommonStickerCollectionViewCell estimateSizeForMessage:msg
                                                                     atIndexPath:indexPath
                                                              hasPreviousMessage:preMsg
                                                                         options:options
                                                                    withListUser:channelUsers
                        ].height ;
        
        if ([self canShowStatusForMessage:msg]) {
            height += 20;
        }
        return CGSizeMake(width, height);
    }
    
    //
    // Call
    //
    if ([msg.type isEqualToString:CC_RESPONSETYPECALL]) {
        float width = [collectionViewLayout sizeForItemAtIndexPath:indexPath].width;
        float height = [CCPhoneStickerCollectionViewCell estimateSizeForMessage:msg
                                                                     atIndexPath:indexPath
                                                              hasPreviousMessage:preMsg
                                                                         options:options
                                                                    withListUser:channelUsers
                        ].height ;
        
        if ([self canShowStatusForMessage:msg]) {
            height += 20;
        }
        return CGSizeMake(width, height);
    }

    //
    // Suggestion
    //
    if ([msg.type isEqualToString:CC_RESPONSETYPESUGGESTION]) {
        float width = [collectionViewLayout sizeForItemAtIndexPath:indexPath].width;
        return CGSizeMake(width, 80);
    }

    //
    // Property
    //
    if([msg.type isEqualToString:CC_RESPONSETYPEPROPERTY]) {
        int height = 0;
        const int CELL_TOP_LABEL_HEIGHT = 20;
        const int STICKER_CONTAINER_MARGIN = 10;
        const int STICKER_CONTAINER_PADDING_LEFT_RIGHT = 10;
        const int STICKER_CONTAINER_PADDING_TOP = 10;
        const int STICKER_CONTAINER_PADDING_BOTTOM = 20;
        const int STICKER_TOP_LABEL_HEIGHT = 30;
        const int STICKER_IMAGE_WIDTH = 100;
        const int ContainerInsetTopBottomMargin = 12;
        const int ContainerInsetLeftRightMargin = 10;
        CGRect screenRect = [UIScreen mainScreen].bounds;
        float width = screenRect.size.width - STICKER_IMAGE_WIDTH - STICKER_CONTAINER_MARGIN * 2 - STICKER_CONTAINER_PADDING_LEFT_RIGHT * 2 - ContainerInsetLeftRightMargin;
        
        // add sticker top label height
        height += STICKER_TOP_LABEL_HEIGHT;
        
        // add sticker content view height
        NSAttributedString *attributedText = [msg.content objectForKey:@"attributedText"];
        CGRect discriptionViewFrame = [attributedText boundingRectWithSize:CGSizeMake(width, 1800)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                   context:nil];
        float discriptionViewHeight = discriptionViewFrame.size.height + STICKER_CONTAINER_PADDING_TOP + STICKER_CONTAINER_PADDING_BOTTOM;
        height += discriptionViewHeight - ContainerInsetTopBottomMargin;
        
        ///date label
        if (indexPath.item % 3 == 0) {
            height += CELL_TOP_LABEL_HEIGHT;
        }
        
        return CGSizeMake(screenRect.size.width - STICKER_CONTAINER_MARGIN * 2, height);
    }
    //
    // Information
    //
    if([msg.type isEqualToString:CC_RESPONSETYPEINFORMATION]) {
        int height = 0;
        const int CELL_TOP_LABEL_HEIGHT = 20;
        const int STICKER_TOP_LABEL_HEIGHT = 20;
        const int STICKER_CONTAINER_MARGIN = 10;
        const int STICKER_CONTAINER_PADDING_TOP = 5;
        CGRect screenRect = self.view.frame;
        float width = screenRect.size.width - STICKER_CONTAINER_MARGIN * 2;
        
        // add sticker top label height
        height += STICKER_TOP_LABEL_HEIGHT;
        
        // add sticker content view height
        NSAttributedString *attributedText = [msg.content objectForKey:@"attributedText"];
        CGRect discriptionViewFrame = [attributedText boundingRectWithSize:CGSizeMake(width, 1800)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                   context:nil];
        float discriptionViewHeight = discriptionViewFrame.size.height + STICKER_CONTAINER_PADDING_TOP;
        height += discriptionViewHeight;
        
        ///date label
        if (indexPath.item % 3 == 0) {
            height += CELL_TOP_LABEL_HEIGHT;
        }
        
        return CGSizeMake(screenRect.size.width - STICKER_CONTAINER_MARGIN * 2, height);

    }
    
    //
    // Phone call
    //
    if([msg.type isEqualToString:CC_RESPONSETYPECALL]) {
        float width = [collectionViewLayout sizeForItemAtIndexPath:indexPath].width;
        float height = [CCPhoneStickerCollectionViewCell estimateSizeForMessage:msg
                                                                    atIndexPath:indexPath
                                                             hasPreviousMessage:preMsg
                                                                        options:options
                                                                   withListUser:channelUsers].height;
        ///date label
        if ([self checkShowDateForMessageAtIndexPath:indexPath]) {
            if(indexPath.item % 3 != 0) {
                height += 20;
            }
        }
        
        NSLog(@"canShowStatus: %d - canShowDate: %d", [self canShowStatusForMessage:msg], [self checkShowDateForMessageAtIndexPath:indexPath]);
        
        // button "Call again" height
        // 20160624 AppSocially Inc. hide "call again" of call message (temporary)
        
        NSLog(@"CALL Index: %ld height: %f", (long)indexPath.row, height);
        NSLog(@"*****");
        return CGSizeMake(width, height);
    }
    
    //
    // Normal message
    //
    if([msg.type isEqualToString:CC_RESPONSETYPEMESSAGE]) {
        float width = [collectionViewLayout sizeForItemAtIndexPath:indexPath].width;
        CGSize calculatedSize = [CCCommonStickerCollectionViewCell estimateSizeForMessage:msg
                                                                               atIndexPath:indexPath
                                                                        hasPreviousMessage:preMsg
                                                                                   options:options
                                                                              withListUser:channelUsers];
        float height = calculatedSize.height;
        
        ///date label
        if ([self checkShowDateForMessageAtIndexPath:indexPath]) {
            if(indexPath.item % 3 != 0) {
                height += 20;
            }
        }

        return CGSizeMake(width, height);
    }
    
    ///Normal(Production)
    ///bubble image
    self.collectionView.collectionViewLayout.messageBubbleTextViewTextContainerInsets = UIEdgeInsetsMake(7.0f, 10.0f, 6.0f, 6.0f); //The default value is `{7.0f, 14.0f, 7.0f, 14.0f}`.
    self.collectionView.collectionViewLayout.messageBubbleFont  = [UIFont systemFontOfSize:15.0f];
    
    return [collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

- (CCJSQMessagesAvatarImage *) getAvatarOfUser:(NSString *)userId {
    if (userId != nil && [self.avatars objectForKey:userId] != nil && ![userId isEqual:self.uid]){
        CCJSQMessagesAvatarImage *jSQMessagesAvatarImage = (CCJSQMessagesAvatarImage *)[self.avatars objectForKey:userId];
        return jSQMessagesAvatarImage;
    } else {
        return nil;
    }
}

//
// Sending the reaction
//
- (void)onUserReactionToSticker:(NSNotification *)notification {
    NSDictionary *data = notification.userInfo;
    CCCommonStickerCollectionViewCell *cell = (CCCommonStickerCollectionViewCell*)[notification object];
    
    if (data != nil) {
        NSNumber *msgId = [data objectForKey:@"msgId"];
        NSString *actionType = [data objectForKey:@"action-type"];
        
        // Extracted from "sticker-action" -> "action-data" :array
        NSDictionary *stickerAction = [data objectForKey:@"stickerAction"];
        
        // From Version Moon using this value is encouraged because it allows multiple selection
        NSArray<NSDictionary*> *stickerActions = [data objectForKey:@"stickerActions"];
        
        NSString *stickerType = [data objectForKey:@"sticker_type"];
        NSString *reacted = [data objectForKey:@"reacted"];
        
        if(_answeringStickers == nil) {
            _answeringStickers = [[NSMutableArray alloc] init];
        }
        [_answeringStickers addObject:data];
        
        //--------------------------------------------------------------------
        //
        // Freeword widget
        //
        //--------------------------------------------------------------------
        if ([actionType isEqualToString:@"input"] && stickerActions != nil && stickerActions.count > 0) {
            [self.view endEditing:YES];
            NSDictionary *stkAction = stickerActions[0];
            NSString *message = stkAction[@"input"];
            //
            // Append temp message
            //
            NSString *uid = [self generateMessageUniqueId];
            NSDictionary *content = @{@"text":message, @"uid": uid};
            CCJSQMessage *msg = [self appendTempMessage:CC_RESPONSETYPEMESSAGE content:content];
            
            [[ChatCenterClient sharedClient] sendMessageResponseForChannel:self.channelId
                                                                    msgUid:uid
                                                                    answer:stkAction
                                                               answerLabel:stkAction[@"input"]
                                                                   replyTo:[msgId stringValue]
                                                         completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task) {
                                                             [_answeringStickers removeObject:data];
                                                             [self updateTempMessage:msg withResult:result];
                                                         }];
            return;
        }
        
        //--------------------------------------------------------------------
        //
        // Moon-style : Accepts multiple reactions
        //
        //--------------------------------------------------------------------
        if(stickerActions && stickerActions.count==0) { // Cancelled all selections(on Checkbox Widget)
            // Build dialog
            [[ChatCenterClient sharedClient] sendMessageResponseForChannel:self.channelId
                                                                    msgUid:[self generateMessageUniqueId]
                                                                   answers:stickerActions
                                                                   replyTo:[msgId stringValue]
                                                         completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task) {
                                                             [_answeringStickers removeObject:data];
                                                         }];
            [self scrollToBottomAnimated:YES];
            return;

        }
        
        if(stickerActions && stickerActions.count>0) {
            //
            // *** sticker action item type A : Opening URLs, other views, image etc. ***
            // {
            //   "label" : label
            //   "action" : URL with specific scheme
            // }
            //
            if (stickerActions[0][@"action"] != nil) { // You cannot make multiple choice for "Open" type sticker, so in that case the data should be in stickerActions[0]
                [self performOpenAction:stickerActions[0]
                            stickerType:stickerType
                              messageId:msgId
                                reacted:reacted
                              reactedOn:cell];
                return;
            }
        
            //
            // *** sticker action item type B : Just sending back a string from the provided list ***
            //
            // * type B-1 : Simple value
            // {
            //   "label" : label
            //   "value" : number
            // }
            //
            // * type B-2 : Time range value
            // {
            //   "label" : label
            //   "value" : {
            //       "start" : time
            //       "end" : time
            //    }
            // }
            //
            // (You don't have to care about B-1 or B-2 here though, because you can just throw it as object)
            //

            for (CCJSQMessage * msg in self.messages) {
                if ([msg.uid integerValue] == [msgId integerValue]) {
                    NSMutableDictionary *messageContent = [msg.content mutableCopy];
                    NSMutableArray<NSDictionary*> *actionResponse = [[NSMutableArray alloc] init];
                    NSMutableDictionary *stickerAction = [[messageContent valueForKey:@"sticker-action"] mutableCopy];
                    NSDictionary *action = @{@"action":[[NSDictionary alloc] init],
                                   @"actions":stickerActions};
                    [actionResponse addObject:action];
                    
                    stickerAction[@"action-response-data"] = actionResponse;
                    messageContent[@"sticker-action"] = stickerAction;
                    msg.content = [messageContent mutableCopy];
                    break;
                }
            }

            NSMutableString *message = [NSMutableString new];
            
            // Make dialog message with multiple labels
            for (NSDictionary *actionItem in stickerActions) {
                [message appendString:actionItem[@"label"]];
                if(![actionItem isEqual:[stickerActions lastObject]]) {
                    [message appendString:@" ,"];
                }
            }
            
            //
            // Do send - multiple
            //
            
            //
            // Append temp message
            //
            NSString *uid = [self generateMessageUniqueId];
            NSDictionary *content = @{@"text":message, @"uid":uid};
            CCJSQMessage *msg = [self appendTempMessage:CC_RESPONSETYPEMESSAGE content:content];
            
            [[ChatCenterClient sharedClient] sendMessageResponseForChannel:self.channelId
                                                                    msgUid:uid
                                                                   answers:stickerActions
                                                                   replyTo:[msgId stringValue]
                                                         completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task) {
                                                             [self updateTempMessage:msg withResult:result];
                                                             [_answeringStickers removeObject:data];
                                                         }];
            [self scrollToBottomAnimated:YES];
            return;
        }
        
        
        //--------------------------------------------------------------------
        //
        // Conventional style : Accepts only one reaction
        //
        //--------------------------------------------------------------------
        if ([actionType isEqualToString:@"select"]) {
            
            // *** sticker action item type A : Opening URLs, other views, image etc. ***
            
            if (stickerAction[@"action"] != nil) {
                [self performOpenAction:stickerAction
                            stickerType:stickerType
                              messageId:msgId
                                reacted:reacted
                              reactedOn:nil];
            }
            
            // *** sticker action item type B : Just sending back a string from the provided list ***

            //
            // Do send - single
            //
            [[ChatCenterClient sharedClient] sendMessageResponseForChannel:self.channelId
                                                                    msgUid:[self generateMessageUniqueId]
                                                                    answer:stickerAction
                                                               answerLabel:stickerAction[@"label"]
                                                                   replyTo:[msgId stringValue]
                                                         completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task) {
                                                             [_answeringStickers removeObject:data];
                                                         }];
            [self scrollToBottomAnimated:YES];
        } else if ([actionType isEqualToString:@"confirm"]) {
            //
            // Only for yes-no question
            //
            if (stickerAction[@"value"] != nil) {
                [[ChatCenterClient sharedClient]
                 sendMessageResponseForChannel:self.channelId
                 msgUid:[self generateMessageUniqueId]
                 answer:stickerAction
                 answerLabel:stickerAction[@"label"]
                 replyTo:[msgId stringValue]
                 completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task) {
                     [_answeringStickers removeObject:data];
                 }];
                [self scrollToBottomAnimated:YES];
                return;
            }
        }
    }
}

- (void)onUserSelectionToPulldownWidget:(NSNotification *)notification {
    NSDictionary *data = notification.userInfo;
    if (data != nil) {
        NSNumber *msgId = [data objectForKey:@"msgId"];
        
        // From Version Moon using this value is encouraged because it allows multiple selection
        NSArray<NSDictionary*> *stickerActions = [data objectForKey:@"stickerActions"];
        
        NSString *stickerType = [data objectForKey:@"sticker_type"];
        NSString *reacted = [data objectForKey:@"reacted"];
        
        if(_answeringStickers == nil) {
            _answeringStickers = [[NSMutableArray alloc] init];
        }
        [_answeringStickers addObject:data];
        
        if(stickerActions && stickerActions.count>0) {
            if (stickerActions[0][@"action"] != nil) {
                [self performOpenAction:stickerActions[0]
                            stickerType:stickerType
                              messageId:msgId
                                reacted:reacted
                              reactedOn:nil];
                return;
            }

            NSMutableString *message = [NSMutableString new];
            
            // Make dialog message with multiple labels
            for (NSDictionary *actionItem in stickerActions) {
                [message appendString:actionItem[@"label"]];
                if(![actionItem isEqual:[stickerActions lastObject]]) {
                    [message appendString:@"\n"];
                }
            }
            
            CCCommonStickerCollectionViewCell *cell;
            CCJSQMessage *msg;
            // Find cell by message id
            for (int index = 0; index < self.messages.count; index ++) {
                msg = self.messages[index];
                if ([[msgId stringValue] isEqualToString:[msg.uid stringValue]]) {
                    cell = (CCCommonStickerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
                    NSMutableDictionary *newContent = [msg.content mutableCopy];
                    NSMutableDictionary *newStickerAction = [[newContent objectForKey:@"sticker-action"] mutableCopy];
                    NSMutableArray *actionResponseData = [[NSMutableArray alloc] init];
                    NSMutableDictionary *actions = [[NSMutableDictionary alloc] init];
                    [actions setObject:stickerActions forKey:@"actions"];
                    [actionResponseData addObject:actions];
                    [newStickerAction setObject:actionResponseData forKey:@"action-response-data"];
                    [newContent setObject:newStickerAction forKey:@"sticker-action"];
                    msg.content = newContent;
                    if (cell != nil) {
                        [cell setupQuestionComponentWithMessage:msg needRecreateSubviews:NO];
                    }
                    break;
                }
            }
            
            //
            // Do send - multiple
            //
            [[ChatCenterClient sharedClient] sendMessageResponseForChannel:self.channelId
                                                                    msgUid:[self generateMessageUniqueId]
                                                                   answers:stickerActions
                                                                   replyTo:[msgId stringValue]
                                                         completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task) {
                                                             [_answeringStickers removeObject:data];
                                                         }];
            [self scrollToBottomAnimated:YES];
            return;
        }
    }
}

- (void)performOpenAction:(NSDictionary*)stickerAction
              stickerType:(NSString*)stickerType
                messageId:(NSNumber*)msgId
                  reacted:(NSString*)reacted
                reactedOn:(CCCommonStickerCollectionViewCell *)cell{
    
    NSString *type = [stickerAction objectForKey:@"type"];
    if (![type isEqual:[NSNull null]]) {
        if ([type isEqualToString:@"file"]) {
            [self openImagePicker:stickerAction msgId:msgId];
            return;
        } else if ([type isEqualToString:@"location"]) {
            [self openLocationPicker:stickerAction msgId:msgId];
            return;
        } else if ([type isEqualToString:@"colocation"]) {
            [self openCoLocationPicker:stickerAction msgId:msgId];
            return;
        } else if ([type isEqualToString:@"question"]) {
            [self openQuestionWidgetEditor:stickerAction msgId:msgId];
            return;
        } else if ([type isEqualToString:@"calendar"]) {
            //
            // "open calendar" is specified
            //
            [self proposeOtherSlots:stickerAction msgId:msgId];
            return;
        } else if ([type isEqualToString:@"url"] && stickerAction[@"action"] != nil
                   && [stickerAction[@"action"] isKindOfClass:[NSString class]]
                   && ![stickerAction[@"action"] isEqual:[NSNull null]]) {
            NSString *urlString = [stickerAction[@"action"] objectAtIndex:0];
            [self openURL:[NSURL URLWithString:urlString]];
            return;
        }
    }
    if (stickerAction[@"action"] != nil ) {
        if ([stickerAction[@"action"] isKindOfClass:[NSString class]] && ![stickerAction[@"action"] isEqual:[NSNull null]]) {
            //
            // "action" is string and is specifying "open:sticker/calender"
            //
            if ([stickerAction[@"action"] isEqualToString:@"open:sticker/calender"] && [type isEqualToString:@"calendar"]) {
                [self proposeOtherSlots:stickerAction msgId:msgId];
                return;
            } else {
                [self openURL:[NSURL URLWithString:stickerAction[@"action"]]];
            }
        } else if ([stickerAction[@"action"] isKindOfClass:[NSArray class]]) {
            //
            // if "action" is an array, process it one by one
            //
            NSUInteger count = [stickerAction[@"action"] count];
            for (int i=0; i<count; i++) {
                NSString *urlString = [stickerAction[@"action"] objectAtIndex:i];
                if (![urlString isEqual:[NSNull null]]) {
                    if ([urlString isEqualToString:@"open:sticker/calender"]) {
                        //
                        // "open calendar" is specified
                        //
                        [self proposeOtherSlots:stickerAction msgId:msgId];
                        return;
                    } else if ([urlString hasPrefix: @"open:sticker/image"]) {
                        //
                        // "open image" is specified
                        //
                        NSString *imageUrlString = [urlString substringFromIndex:[@"open:sticker/image?url=" length]];
                        [self openImageWithURLString:imageUrlString];
                        return;
                    } else if([urlString hasPrefix:@"reply:suggestion/message"]){
                        //
                        // "reply suggestion" is specified
                        //
                        NSMutableDictionary *stickerContentToPost = [stickerAction mutableCopy];

                        CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:@""];
                        msg.type = CC_RESPONSETYPEMESSAGE;
                        [stickerContentToPost setObject:[self generateMessageUniqueId] forKey:@"uid"];
                        [stickerContentToPost removeObjectForKey:@"message"];
                        [stickerContentToPost setObject:stickerAction[@"message"] forKey:@"text"];
                        msg.content = stickerContentToPost;
                        
                        CCCommonWidgetPreviewViewController *vc = [[CCCommonWidgetPreviewViewController alloc] initWithNibName:@"CCCommonWidgetPreviewViewController" bundle:SDK_BUNDLE];
                        [vc setMessage:msg];
                        [vc setDelegate:self];
                        vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Cancel")
                                                                                               style:UIBarButtonItemStylePlain target:vc action:@selector(cancelButtonPressed:)];
                        
                        UINavigationController *rootNC = [[UINavigationController alloc] initWithRootViewController:vc];
                        [self presentViewController:rootNC animated:YES completion:^{
                            self.isReturnFromStickerView = YES;
                        }];
                        return;
                    } else if([urlString hasPrefix:@"reply:suggestion/sticker"]) {
                        // TODO: prevent from sending when "reacted" is true
                        
                        //
                        // Make sticker object
                        //
                        NSMutableDictionary *stickerContentToPost = [[stickerAction objectForKey:@"sticker"] mutableCopy];

                        CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:@""];
                        msg.type = CC_RESPONSETYPESTICKER;
                        [stickerContentToPost setObject:[self generateMessageUniqueId] forKey:@"uid"];
                        msg.content = stickerContentToPost;
                        
                        CCCommonWidgetPreviewViewController *vc = [[CCCommonWidgetPreviewViewController alloc] initWithNibName:@"CCCommonWidgetPreviewViewController" bundle:SDK_BUNDLE];
                        [vc setMessage:msg];
                        [vc setDelegate:self];
                        vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Cancel")
                                                                                                  style:UIBarButtonItemStylePlain target:vc action:@selector(cancelButtonPressed:)];

                        UINavigationController *rootNC = [[UINavigationController alloc] initWithRootViewController:vc];
                        [self presentViewController:rootNC animated:YES completion:^{
                            self.isReturnFromStickerView = YES;
                        }];
                        return;
                    }
                    //
                    // If you couldn't handle the URL above, just try to open the URL as it is.
                    // (Possibly opens Safari)
                    //
                    else if([stickerType isEqualToString:CC_RESPONSETYPESUGGESTION]) {
                        //
                        // If it's a Suggestion Sticker just do it
                        //
                        [self.inputToolbar.contentView.textView resignFirstResponder];
                        [self openURL:[NSURL URLWithString:urlString]];
                        return;
                    }else if(i == count - 1) {
                        //
                        // Case: open payment webview
                        //
                        if ([urlString containsString:@"/payment/"]) {
                            if (![CCConstants sharedInstance].isAgent) {
                                CCWebViewController *webViewController = [[CCWebViewController alloc] initWithURL:urlString title:CCLocalizedString(@"Payment") needAuthentication: YES];
                                webViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                                webViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                                UINavigationController *rootNC = [[UINavigationController alloc] initWithRootViewController:webViewController];
                                [self presentViewController:rootNC animated:YES completion:nil];
                                return;
                            } else {
                                if ([cell respondsToSelector:@selector(resetSelection)]) {
                                    [cell resetSelection];
                                }
                                return;
                            }
                        }
                        
                        //
                        // Else do it only for the last item of the action item list
                        //
                        [self.inputToolbar.contentView.textView resignFirstResponder];
                        [self openURL:[NSURL URLWithString:urlString]];
                        return;
                    }
                }
            }
        }
    }


}

- (void)onUserReactToStickerContent:(NSNotification *)notification {
    NSDictionary *data = notification.userInfo;
    NSNumber *msgId = [data objectForKey:@"msgId"];
    if ([data[CC_STICKERCONTENT_ACTION] isKindOfClass:[NSArray class]]) {
        NSUInteger count = [data[CC_STICKERCONTENT_ACTION] count];
        for (int i=0; i<count; i++) {
            NSString *urlString = [data[CC_STICKERCONTENT_ACTION] objectAtIndex:i];
            if ([urlString isEqualToString:@"open:sticker/calender"]) {
                // open calendar with no-sticker-action
                [self proposeOtherSlots:@{@"label":@""} msgId:msgId];
                return;
            } else if ([urlString hasPrefix: @"open:sticker/image"]) {
                NSString *imageUrlString = [urlString substringFromIndex:[@"open:sticker/image?url=" length]];
                [self.inputToolbar.contentView.textView resignFirstResponder];
                [self openImageWithURLString:imageUrlString];
                return;
            } else if (data[CC_STICKER_TYPE] != nil && [data[CC_STICKER_TYPE] isEqualToString:CC_STICKERTYPECOLOCATION]) {
                [self locationSetup];
                _isReturnFromStickerView = YES;
                CCLiveLocationWebviewController *liveLocationWebviewController = [[CCLiveLocationWebviewController alloc] initWithNibName:@"CCLiveLocationWebviewController" bundle:SDK_BUNDLE];
                liveLocationWebviewController.urlString = urlString;
                liveLocationWebviewController.channelID = self.channelId;
                CCLiveLocationTask *task = [[CCConnectionHelper sharedClient].shareLocationTasks objectForKey:self.channelId];
                if (task != nil) {
                    liveLocationWebviewController.isSharingLocation = YES;
                } else {
                    liveLocationWebviewController.isSharingLocation = NO;
                }
                liveLocationWebviewController.delegate = self;
                liveLocationWebviewController.isOpenedFromWidgetMessage = YES;
                [self.navigationController pushViewController:liveLocationWebviewController animated:YES];
            }
            
            else if(i == count - 1) {
                // open last item in safari if needed
                [self.inputToolbar.contentView.textView resignFirstResponder];
                [self openURL:[NSURL URLWithString:urlString]];
            }
        }
    }
}

- (void) onFreeWordTextviewDidBeginEditing:(NSNotification *)notification {
    if (!isKeyboardShowing && self.inputToolbar.contentView.textView.inputView == nil) {
        //  workaround for the first few messages not scrolling
        //  when the collection view content size is too small, `scrollToItemAtIndexPath:` doesn't work properly
        //  this seems to be a UIKit bug, see #256 on GitHub
        self.marginBottomInputToolbar.constant = keyboardHeight;
        [self.view setNeedsLayout];
    }
    
    isEditingFreewordTextView = YES;
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo != nil) {
        NSString *msgId = [[userInfo valueForKey:@"msgId"] stringValue];
        if (msgId == nil) {
            return;
        }
        NSInteger index = [self indexOfMessageWithId:msgId];
        if (index >= self.messages.count) {
            return;
        }
        
        [self scrollToIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:YES];
    }
}

- (NSInteger) indexOfMessageWithId: (NSString *)msgId {
    if (self.messages == nil) {
        return 0;
    }
    
    for (int index = 0; index < self.messages.count; index++) {
        CCJSQMessage *message = self.messages[index];
        if ([[message.uid stringValue] isEqualToString:msgId]) {
            return index;
        }
    }
    
    return 0;
}

- (void) onUserDidReactPulldownWidget:(NSNotification *)notification {
    self.isPulldownSelectBoxDisplayed = YES;
    [self.view endEditing:YES];
    CCPickerViewController *pickerVC = [[CCPickerViewController alloc] init];
    pickerVC.chatViewController = self;
    NSLog(@"Notification data = %@", notification);
    NSString *msgId = [[notification.userInfo valueForKey:@"msgId"] stringValue];
    for (CCJSQMessage *message in self.messages) {
        if([[message.uid stringValue] isEqualToString:msgId]) {
            [pickerVC setupWithMessage:message];
            pickerVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            pickerVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self showDetailViewController:pickerVC sender:self];
            return;
        }
    }
}

- (void) openImageWithURLString:(NSString *) imageURLString
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(osVersion >= 9.0f)  {
        imageURLString = [[imageURLString stringByRemovingPercentEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    } else {
        imageURLString = [[imageURLString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    }
#else
    imageURLString = [[imageURLString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
#endif
    
    if(imageURLString == nil || [imageURLString length] == 0) {
        return;
    }
    
    NSArray *photosURL = @[[NSURL URLWithString:imageURLString]];
    
    /// Create an array to store IDMPhoto objects
    NSMutableArray *photos = [NSMutableArray new];
    for (NSURL *url in photosURL) {
        CCIDMPhoto *photo;
        photo = [CCIDMPhoto photoWithURL:url];
        [photos addObject:photo];
    }
    CCIDMPhotoBrowser *browser = [[CCIDMPhotoBrowser alloc] initWithPhotos:photos];
    if([CCConstants sharedInstance].closeBtnNormal != nil){
        browser.doneButtonImage = [UIImage SDKImageNamed:[CCConstants sharedInstance].closeBtnNormal];
    }
    browser.disableVerticalSwipe = YES;
    browser.view.tintColor = [UIColor whiteColor];
    browser.doneButtonBounds = CGRectMake(16, 26, 44, 32);
    [self presentViewController:browser animated:YES completion:nil];
}

- (BOOL)canShowStatusForMessage:(CCJSQMessage *)msg {
    return [self canShowReadStatusForMessage:msg] || [self canShowDeliveringStatusForMessage:msg] || [self canShowSendFailedStatusForMessage:msg];
}

- (NSString *)getStatusForMessage:(CCJSQMessage *)msg {
    if ([self canShowReadStatusForMessage:msg]) {
        return CCLocalizedString(@"Read");
    }else if ([self canShowDeliveringStatusForMessage:msg]) {
        return CCLocalizedString(@"Delivering");
    } else if ([self canShowSendFailedStatusForMessage:msg]) {
        return CCLocalizedString(@"Send failed");
    } else {
        return CCLocalizedString(@"Read");
    }
}

- (BOOL)canShowReadStatusForMessage:(CCJSQMessage *)msg {
    BOOL isAgent = [CCConstants sharedInstance].isAgent;
    if (msg.senderId != nil && [msg.senderId isEqualToString:self.uid] &&
        msg != nil && msg.content != nil && msg.content[@"usersReadMessage"]) {
        NSArray *usersReadMessage = msg.content[@"usersReadMessage"];
        BOOL foundAgentUserRead = NO;
        BOOL foundGuestUserRead = NO;
        for(int i=0; i<usersReadMessage.count; i++) {
            NSDictionary *dict = [usersReadMessage objectAtIndex:i];
            BOOL admin = ([dict objectForKey:@"admin"] != nil) ? [[dict objectForKey:@"admin"] boolValue] : NO;
            if(admin == YES) {
                foundAgentUserRead = YES;
            } else {
                foundGuestUserRead = YES;
            }
        }
        return (isAgent) ? foundGuestUserRead : (foundAgentUserRead && [[CCConstants sharedInstance] showReadStatusForGuest]);
    }
    
    return NO;
}

- (BOOL)canShowDeliveredStatusForMessage:(CCJSQMessage *)msg {
    if (msg.senderId != nil && [msg.senderId isEqualToString:self.uid] && msg.status == CC_MESSAGE_STATUS_SEND_SUCCESS) {
        return YES;
    }
    
    return NO;
}

- (BOOL)canShowDeliveringStatusForMessage:(CCJSQMessage *)msg {
    if (msg.senderId != nil && [msg.senderId isEqualToString:self.uid] && msg.status == CC_MESSAGE_STATUS_DELIVERING) {
        return YES;
    }
    
    return NO;
}

- (BOOL)canShowSendFailedStatusForMessage:(CCJSQMessage *)msg {
    if (msg.senderId != nil && [msg.senderId isEqualToString:self.uid] && msg.status == CC_MESSAGE_STATUS_SEND_FAILED) {
        return YES;
    }
    
    return NO;
}

- (CCJSQMessage *)appendTempMessage:(NSString *)type
                            content:(NSDictionary *)content {
    NSNumber *uid = [NSNumber numberWithInteger:([[CCCoredataBase sharedClient] getSmallestMessageId] - 1)];
    if ([uid integerValue] >= 0) {
        uid = [NSNumber numberWithInteger:-1];
    }
    if (self.uid == nil) {
        self.uid = [[CCConstants sharedInstance] getKeychainUid];
    }
    
    NSDate *date = [NSDate date];
    NSString *channelUid = self.channelId;
    NSNumber *channelId = nil;
    NSNumber *admin = [NSNumber numberWithBool:[[CCConstants sharedInstance] isAgent]];
    // add temp message to list
    NSString * displayName = [[NSUserDefaults standardUserDefaults] valueForKey:kCCUserDefaults_userDisplayName];
    NSDictionary *user = @{@"id":self.uid, @"display_name":displayName, @"icon_url":@"", @"admin": admin};
    NSArray *usersReadMessage = @[];
    NSDictionary *answer = nil;
    NSDictionary *question = nil;
    
    // insert to temp message db
    [[CCCoredataBase sharedClient] insertMessage:uid
                                            type:type
                                         content:content
                                            date:date
                                      channelUid:channelUid
                                       channelId:channelId
                                            user:user
                                usersReadMessage:usersReadMessage
                                          answer:answer
                                        question:question
                                          status:CC_MESSAGE_STATUS_DELIVERING];
    
    NSArray *messages = [self createMessageObjects:type
                                               uid:uid
                                           content:content
                                  usersReadMessage:usersReadMessage
                                        fromSender:self.uid
                                            onDate:date
                                       displayName:displayName
                                       userIconUrl:@""
                                         userAdmin:[CCConstants sharedInstance].isAgent
                                            answer:answer
                                            status:CC_MESSAGE_STATUS_DELIVERING];
    if (messages != nil && [messages count] > 0) {
        CCJSQMessage *message = [messages objectAtIndex:0];
        [self.messages addObject:message];
        [self.sendingMessages addObject:message];
        [self finishReceivingMessageAnimated:YES];
        return message;
    }
    
    return nil;
}

- (void)updateTempMessage:(CCJSQMessage *)tmpMessage withResult:(id)result {
    if (tmpMessage == nil) {
        return;
    }
    
    if (self.sendingMessages != nil && [self.sendingMessages containsObject:tmpMessage]) {
        [self.sendingMessages removeObject:tmpMessage];
    }
    
    if (result != nil) {
        [[CCCoredataBase sharedClient] updateMessageWithStatus:tmpMessage.uid status:CC_MESSAGE_STATUS_SEND_SUCCESS];
        tmpMessage.status = CC_MESSAGE_STATUS_SEND_SUCCESS;
    } else {
        NSLog(@"Update temp message id = %@", tmpMessage.uid);
        [[CCCoredataBase sharedClient] updateMessageWithStatus:tmpMessage.uid status:CC_MESSAGE_STATUS_SEND_FAILED];
        tmpMessage.status = CC_MESSAGE_STATUS_SEND_FAILED;
        [self finishReceivingMessageAnimated:NO];
        return;
    }
    
    [self finishReceivingMessageAnimated:NO];
}

- (NSString *)generateMessageUniqueId {
    NSString *generatedUniqueId = [NSString stringWithFormat:@"%@-%@-%f", self.channelId, self.uid, (double)([[NSDate date] timeIntervalSince1970] * 1000)];
    return generatedUniqueId;
}

- (void)sendWidgetWithType:(NSString *)msgType andContent:(NSDictionary *)content {
    if ([msgType isEqualToString:CC_STICKERTYPEIMAGE]) {
        [self sendImage:msgType content:content];
    } else {
        [self sendMessage:msgType content:content];
    }
}

- (void)sendImage:(NSString *)type content:(NSDictionary *)content {
    CCJSQMessage *message = [self appendTempMessage:type content:content];
    if (content[@"url"] != nil) {
        [[CCImageHelper sharedInstance] loadLocalImage:content[@"url"] completionHandler:^(UIImage *imagelocal) {
            if (imagelocal != nil) {
                NSURL *assetURL = content[@"url"];
                NSString *extension = [assetURL pathExtension];
                CFStringRef imageUTI = (UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(__bridge CFStringRef)extension , NULL));
                message.status = CC_MESSAGE_STATUS_DELIVERING;
                NSString *uid = [content objectForKey:@"uid"];
                [self sendImage:imagelocal imageUTI:imageUTI isShowAlert:NO uid:uid completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@",message.uid];
                    NSArray *checkDuplicates = [self.messages filteredArrayUsingPredicate: predicate];
                    if ([checkDuplicates count] == 0) {
                        if (message != nil && ![self.messages containsObject:message]) {
                            [self.messages addObject:message];
                        }
                    }
                    
                    [self updateTempMessage:message withResult:result];
                    if(result != nil){
                        NSLog(@"Message POST Success!");
                        NSNumber *uid = [result valueForKey:@"id"];
                        for (CCJSQMessage * msg in self.messages) {
                            if ([msg.type isEqualToString:CC_STICKERTYPEIMAGE]){
                                if ([msg.uid integerValue] == [message.uid integerValue]) {
                                    if (uid == nil) {
                                        [self.messages removeObject:msg];
                                    } else {
                                        msg.uid = uid;
                                        msg.status = CC_MESSAGE_STATUS_SEND_SUCCESS;
                                    }
                                    [self.collectionView reloadData];
                                    break;
                                }
                            }
                        }
                        
                        NSArray *checkExistMsgTmp = [self.messages filteredArrayUsingPredicate: predicate];
                        if (checkExistMsgTmp.count > 0) {
                            for (CCJSQMessage * msg in self.messages) {
                                if ([msg.type isEqualToString:CC_STICKERTYPEIMAGE]){
                                    if ([msg.uid integerValue] == [message.uid integerValue]) {
                                            [self.messages removeObject:msg];
                                        break;
                                    }
                                }
                            }
                        }
                        
                        [[CCCoredataBase sharedClient] deleteTempMessage:message.uid];
                        [self.collectionView reloadData];
                    }else{
                        if ([[CCConnectionHelper sharedClient] isAuthenticationError:task] == YES){
                            [[CCConnectionHelper sharedClient] displayAuthenticationErrorAlert];
                        }else{
                            NSLog(@"Message POST Failed!");
                            [self.sendingMessages removeObject:message];
                            // Resend this image
                            [self.collectionView reloadData];
                            [self resendFailedMessage:self.channelId resendDelivering:YES];
                        }
                    }
                }];
            } else {
                [[CCCoredataBase sharedClient] deleteTempMessage:message.uid];
                message.status = CC_MESSAGE_STATUS_SEND_SUCCESS;
                [self.collectionView reloadData];
            }
        }];
    }
}

- (void)sendStickerWithType:(NSString *)msgType andContent:(NSDictionary *)content {
    [self sendMessage:msgType content:content];
}

- (BOOL) checkShowDateForMessageAtIndexPath:(NSIndexPath *)indexPath {
    // check date of current message & previous message
    NSInteger startIndex = 0;
    if(indexPath.item > 1) {
        CCJSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
        CCJSQMessage *preMsg = [self.messages objectAtIndex:indexPath.item - 1];
        NSDate *msgDate = msg.date;
        NSDate *preMsgDate = preMsg.date;
        startIndex = [self checkStartMessageForDate:msgDate];
        if(msgDate == nil || preMsgDate == nil) {
            return YES;
        } else {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
            NSString *msgDateString = [formatter stringFromDate:msgDate];
            NSString *preMsgDateString = [formatter stringFromDate:preMsgDate];
            if(msgDateString != nil && ![msgDateString isEqualToString:preMsgDateString]) {
                return YES;
            }
        }
    }
    
    // other case
    return NO;
}

- (NSInteger) checkStartMessageForDate: (NSDate *) date {
    for(NSInteger i = 0; i < self.messages.count ; i++) {
        CCJSQMessage *msg = [self.messages objectAtIndex:i];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
        NSString *msgDateString = [formatter stringFromDate:msg.date];
        NSString *currentDateString = [formatter stringFromDate:date];
        if(msgDateString != nil && [msgDateString isEqualToString:currentDateString]) {
            return i;
        }
    }
    return 0;
}

#pragma mark -- Scroll Delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"*** scrollViewDidEndDragging");
//    NSLog(@"scrollView.contentOffset.y %f %f",scrollView.contentOffset.y, scrollView.contentSize.height);
    if(self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.frame.size.height)) {
        newMessageView.hidden = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        if (indexPath.item == 0) {
            [self loadEarlierMessages];
            break;
        }
    }
    if(self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.frame.size.height)) {
        newMessageView.hidden = YES;
    }
}

- (void)loadEarlierMessages
{
    if (self.channelId == nil) {
        [self initView];
        return;
    }
    if (loadPreviousMessage == YES) {
        return;
    }
    loadPreviousMessage = YES;
    // we are at the top
    
    if(self.messages.count > 0) { // check for valid messages in database, try to get message without checking can cause app crash in some case
        CCJSQMessage *lastMessageDic = self.messages[0];
        NSNumber *lastId = lastMessageDic.uid;
        [self loadPreviousMessages:NO lastId:lastId];
    } else {
        NSLog(@"No message to load!");
    }
}

#pragma mark - Video Call Delegate
- (void)receiveCallEvent:(NSString *)messageId content:(NSDictionary *)content {
    NSLog(@"receiveCallEvent = %@", content);
    if (self.delegateCall != nil && [self.delegateCall respondsToSelector:@selector(handleCallEvent:content:)]){
        [self.delegateCall handleCallEvent:messageId content:content];
    }
}

#pragma mark - CCChatViewNavigationTitleDelegate delegate.
- (void)pressNavigationTitleButton:(id)sender{
    [self pressInfo:sender];
}

#pragma mark - Suggestion and Fixed phrase
- (BOOL)isTopMostViewController {
    if ([[CCChatViewHelper topViewController] isKindOfClass:[CCChatViewController class]]) {
        return YES;
    } else if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES && [[CCChatViewHelper topViewController] isKindOfClass:[CCChatAndHistoryViewController class]]) {
        return YES;
    }
    return NO;
}

- (BOOL) needHideFixedPhrase {
    CCJSQMessage *lastMessage;
    if (self.messages != nil && self.messages.count > 0) {
        lastMessage = [self.messages lastObject];
    }
    
    if (lastMessage == nil || lastMessage.content == nil) {
        return NO;
    }
    //
    // Show suggestion if the type of latest message is suggestion and action-data is not null
    //
    if ([lastMessage.type isEqualToString:CC_RESPONSETYPESUGGESTION] && !isDisplayingSuggestionView) {
        NSArray<NSDictionary*> *actionData = [[lastMessage.content objectForKey:@"sticker-action"] objectForKey:@"action-data"];
        if (actionData != nil && !isDisplayingAlert && self.inputToolbar.contentView.textView.inputView != nil) {
            return YES;
        }
    }
    if (![lastMessage.type isEqualToString:CC_RESPONSETYPESUGGESTION]) {
        if ([lastMessage.type isEqualToString:CC_RESPONSETYPESTICKER]) {
            NSString *stickerType = [lastMessage.content objectForKey:@"sticker-type"];
            if ([stickerType isEqualToString:@"select"] ||
                [stickerType isEqualToString:@"schedule"] ||
                [stickerType isEqualToString:@"confirm"]) {
                if (![lastMessage.senderId isEqualToString:self.uid]) {
                    return YES;
                }
            } else {
                if ([stickerType isEqualToString:@"file"] ||
                    [stickerType isEqualToString:@"list"] ||
                    [stickerType isEqualToString:@"location"] ) {
                    NSDictionary * stickerAction = [lastMessage.content objectForKey:@"sticker-action"] ;
                    if (stickerAction != nil && ![stickerAction isEqual:[NSNull null]]) {
                        NSString *actionType = [[lastMessage.content objectForKey:@"sticker-action"] objectForKey:@"action-type"];
                        if ([actionType isEqualToString:@"confirm"]||[actionType isEqualToString:@"select"]) {
                            if (![lastMessage.senderId isEqualToString:self.uid]) {
                                return YES;
                            }
                        }
                    }
                }
            }
        }
    }
    return NO;
}

- (void) displayFixedPhraseOrSuggestionIfNeed {
    //
    // Don't display fixed phrase if other view controller is displayed on top.
    // Or the keyboard is showing
    //
    if (![self isTopMostViewController] || isKeyboardShowing) {
        return;
    }
    
    CCJSQMessage *lastMessage;
    if (self.messages != nil && self.messages.count > 0) {
        lastMessage = [self.messages lastObject];
        if ([self needHideFixedPhrase]) {
            //
            // Show suggestion if need
            //
            if (![lastMessage.type isEqualToString:CC_RESPONSETYPESUGGESTION]) {
                [self.inputToolbar.contentView.textView endEditing:YES];
                [self.inputToolbar.contentView.textView setHidden:YES];
            } else if ([lastMessage.type isEqualToString:CC_RESPONSETYPESUGGESTION]) {
                //
                // Show suggestion
                //
                [self displaySuggestionIfNeed];
            }
        } else {
            //
            // Show fixed phrase if need
            //
            [self displayFixedPhraseIfNeed];
        }
    } else {
        //
        // Show fixed phrase if no messages in chatview if need
        //
        [self displayFixedPhraseIfNeed];
    }
}

- (void) displayFixedPhraseIfNeed {
    if (!isDisplayingAlert && self.fixedPhrases != nil && self.fixedPhrases.count > 0 && self.inputToolbar.contentView.inputView == nil && !isKeyboardShowing) {
        [self displayFixedPhrase:self.fixedPhrases];
    }
}

- (void) displaySuggestionIfNeed {
    if (self.messages != nil && self.messages.count > 0) {
        CCJSQMessage *lastMessage = [self.messages objectAtIndex:self.messages.count - 1];
        if (lastMessage != nil && [lastMessage.type isEqualToString:CC_RESPONSETYPESUGGESTION]) {
            NSArray<NSDictionary*> *actionData = [[lastMessage.content objectForKey:@"sticker-action"] objectForKey:@"action-data"];
            if (actionData != nil) {
                [self displaySuggestionWithActionData:actionData];
            }
        }
    }
}
@end

