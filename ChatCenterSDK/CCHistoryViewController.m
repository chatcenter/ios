
//
//  CCHistoryViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2014/07/30.
//  Copyright (c) 2014年 AppSocially Inc. All rights reserved.
//

#import "CCConstants.h"
#import "CCHistoryViewController.h"
#import "CCConnectionHelper.h"
#import "CCConstants.h"
#import "CCUISplitViewController.h"
#import "CCCoredataBase.h"
#import "CCChatViewController.h"
#import "ChatCenterPrivate.h"
#import "CCSSKeychain.h"
#import "ChatCenter.h"
#import "UIImageView+CCWebCache.h"
#import "CCContactPickerViewController.h"
#import "CCModalListViewController.h"
#import "CCNavigationController.h"
#import "CCSettingViewController.h"
#import "CCChannelDetailViewController.h"
#import "CCSVProgressHUD.h"
#import "CCHistoryViewCell.h"
#import "UIImage+CCSDKImage.h"
#import "CCMGSwipeTableCell.h"
#import "CCMGSwipeButton.h"
#import "CCAssignAssigneeViewController.h"
#import "CCUserDefaultsUtil.h"

int const CCMaxLoadChannel = 10000;
int const CCRandomCircleAvatarSize = 128;
int const CCRandomCircleAvatarFontSize = 84.0f;
int const CCRandomCircleAvatarTextOffset = 15;
int const CCTopRowTableView = 0;

@interface CCHistoryViewController (){
    NSIndexPath *selectedIndexPath;
    NSString *navigationTitle;
    NSDate *cellForRowAtIndexPathTime;
    CCHistoryNavigationTitleView *navigationTitleView;
    UIView *navigationBottomBorder;
    UIView *newMessageView;
    NSString *currentOrgId;
    NSArray *channelRoles;
    UISearchBar *searchBar;
    NSString *lastSeachText;
    UIVisualEffectView *blurEffectView;
}

@property (weak, nonatomic) IBOutlet UITextView *noCellMessage;
@property (nonatomic, weak)   IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *ChatChannelIds;
@property (nonatomic, strong) NSMutableArray *ChannelDisplayNames;
@property (nonatomic, strong) NSMutableArray *ChannelLabels;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) CCChatViewController* detailViewController;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIBarButtonItem *closeButton;
@property (nonatomic, strong) UIBarButtonItem *rightBarButton;
@property (nonatomic, strong) UIBarButtonItem *inforButton;
@property (nonatomic, strong) UIBarButtonItem *voiceCallButton;
@property (nonatomic, strong) UIBarButtonItem *videoCallButton;
@property (nonatomic, strong) UIBarButtonItem *rightSpacer;
@property (nonatomic, strong) UIBarButtonItem *deleteButton;
@property (nonatomic) CCChannelType channelType;
@property (nonatomic, copy) void (^closeHistoryViewCallback)(void);
@property  int ChannelTotalUnreadMessageNum;
@property BOOL isReturnFromChatView;
@property BOOL isReturnFromRightMenuView;
@property BOOL isLoadingMore;
@end

@implementation CCHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUserdata:(int)channelType
              provider:(NSString *)provider
         providerToken:(NSString *)providerToken
   providerTokenSecret:(NSString *)providerTokenSecret
  providerRefreshToken:(NSString *)providerRefreshToken
     providerCreatedAt:(NSDate *)providerCreatedAt
     providerExpiresAt:(NSDate *)providerExpiresAt
     completionHandler:(void (^)(void))completionHandler
{
    CCHistoryViewController *instance;
    instance = [self init];
    if (self) {
        if ([CCSSKeychain passwordForService:@"ChatCenter" account:@"providerCreatedAt"])
        {
            [CCConnectionHelper sharedClient].providerOldCreatedAt = [CCSSKeychain passwordForService:@"ChatCenter" account:@"providerCreatedAt"];
        }
        if ([CCSSKeychain passwordForService:@"ChatCenter" account:@"providerExpiresAt"])
        {
            [CCConnectionHelper sharedClient].providerOldExpiresAt = [CCSSKeychain passwordForService:@"ChatCenter" account:@"providerExpiresAt"];
        }
        
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
        self.channelType = channelType;
        if (completionHandler != nil) self.closeHistoryViewCallback = completionHandler;
    }
    return instance;
}

- (id)init{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CCHistoryViewController" bundle:SDK_BUNDLE];
    CCHistoryViewController *instance = [storyboard  instantiateViewControllerWithIdentifier:@"CCHistoryViewController"];
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    currentOrgId = [ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"];
    NSDictionary *privelege = [ud dictionaryForKey:kCCUserDefaults_privilege];
    // Retry privelege information if need
    if (privelege == nil) {
        // update user info
        [[ChatCenter sharedInstance] isTokenVailid:^(BOOL result) {
            NSDictionary *privelege = [ud dictionaryForKey:kCCUserDefaults_privilege];
            if(privelege[@"channel"] != nil) {
                channelRoles = privelege[@"channel"];
            }
            [self.tableView reloadData];
        }];

    } else {
        if(privelege[@"channel"] != nil) {
            channelRoles = privelege[@"channel"];
        }
    }
    [self viewSetUp];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == NO) {
        [[CCConnectionHelper sharedClient] setCurrentView:self];
    }
    [[CCConnectionHelper sharedClient] setDelegate:self];
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    if (self.isReturnFromRightMenuView) {
        self.isReturnFromRightMenuView = NO;
    } else if ([CCConnectionHelper sharedClient].isLoadingUserToken == YES) {
        [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading...")];
    }else{
        [self initializingData];
        self.isReturnFromChatView = NO;
    }
    
    [self setNavigationBarStyles];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }

    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == NO) {
        [[CCConnectionHelper sharedClient] setCurrentView:nil];
        [[CCConnectionHelper sharedClient] setDelegate:nil];
    }
    
    [super viewWillDisappear:animated];
}

- (void)initializingData{
    ///Provider Auth
    if ([CCConnectionHelper sharedClient].provider != nil && [CCConnectionHelper sharedClient].isRefreshingData == NO) {
        if ([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable || CCLocalDevelopmentMode) {
            ///Compare providerCreatedAt
            if([[CCConnectionHelper sharedClient] isUpdatedProviderCreatedAt] == YES
               || [[CCConnectionHelper sharedClient] isUpdatedProviderCreatedAt] == YES
               || [[CCConstants sharedInstance] getKeychainToken] == nil
               || ([[CCConnectionHelper sharedClient].provider isEqualToString:@"twitter"] && self.isReturnFromChatView == NO))
            {
                [self updateProviderToken];
            }else{
                [[CCConnectionHelper sharedClient] refreshData];
            }
        }else{
            [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
            NSLog(@"initChatView Error");
        }
    }else{
        [[CCConnectionHelper sharedClient] refreshData];
    }
    
    [self loadLocalChannles:NO lastUpdatedAt:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - table view delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int number = CCMaxLoadChannel < self.ChatChannelIds.count ? CCMaxLoadChannel : (int)self.ChatChannelIds.count;
    self.tableView.alwaysBounceVertical = number == 0 ? NO : YES;
    if (number == 0) {
        self.noCellMessage.hidden = NO;
        if (self.closeButton != nil) {
            self.navigationItem.leftBarButtonItem = self.closeButton;
        }
        self.navigationItem.rightBarButtonItem = nil;
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        self.noCellMessage.hidden = YES;
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        self.navigationItem.rightBarButtonItem = self.rightBarButton;
    }
    
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCHistoryViewCell *cell = (CCHistoryViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UILabel *title          = (UILabel*)[cell viewWithTag:4];
    UILabel *lastMessage    = (UILabel*)[cell viewWithTag:1];
    UILabel *lastUpdateDate = (UILabel*)[cell viewWithTag:2];
    UIImageView *iconImage  = (UIImageView*)[cell viewWithTag:5];
    UILabel *unreadNumBack  = (UILabel*)[cell viewWithTag:6];
    UILabel *unreadNum      = (UILabel*)[cell viewWithTag:7];
    UILabel *statusBack     = (UILabel*)[cell viewWithTag:8];
    UILabel *status         = (UILabel*)[cell viewWithTag:9];
    NSDictionary *labels    = [self.ChannelLabels objectAtIndex:indexPath.row];
    title.text              = labels[@"title"];
    BOOL admin              = ([labels objectForKey:@"admin"] != nil) ? [[labels objectForKey:@"admin"] boolValue] : NO;
    // process lastMessage
    NSNumber *senderIdOfLastMessage = labels[@"senderId"];
    NSString *originalMessage = labels[@"message"];
    NSString *senderName = labels[@"senderName"];
    if(senderIdOfLastMessage == (NSNumber *)[NSNull null]) { // Not message yet
        lastMessage.text = originalMessage;
    } else {
            NSString *lastMessageText = [self processLastMessageWithSenderId:senderIdOfLastMessage senderName:senderName originalMessage:originalMessage];
            lastMessage.text = lastMessageText;
    }
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateCompareDF = [[NSDateFormatter alloc]init];
    NSDateFormatter *displayDF = [[NSDateFormatter alloc] init];
    dateCompareDF.dateFormat = CCLocalizedString(@"yyyy/MM/dd");
    NSString *str1 = [dateCompareDF stringFromDate:now];
    NSString *str2 = [dateCompareDF stringFromDate:labels[@"lastUpdatedAt"]];
    if ([str1 isEqualToString:str2]) {
        [displayDF setDateFormat:CCLocalizedString(@"HH:mm")];
    }else{
        [displayDF setDateFormat:CCLocalizedString(@"MM/dd")];
    }
        ///This is bug of NSDateFormatter
        ///https://stackoverflow.com/questions/6169074/nsdateformatter-does-not-respect-12-24-hour-am-pm-system-setting-in-some-cir
    displayDF.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    NSString *stringFromDate = [displayDF stringFromDate:labels[@"lastUpdatedAt"]];
    lastUpdateDate.text     = stringFromDate;
    ///icon_image
    if (labels[@"iconImageUrl"] != [NSNull null]) {
        if (labels[@"iconImage"] != [NSNull null]){
            [iconImage sd_setImageWithURL:labels[@"iconImageUrl"]
                         placeholderImage:labels[@"iconImage"]];
        }else{
            [iconImage sd_setImageWithURL:labels[@"iconImageUrl"]
                         placeholderImage:nil];
        }
    }else if (labels[@"iconImage"] != [NSNull null]) {
        iconImage.image = labels[@"iconImage"];
    }
    ///Change highlight color
    UIView *selected_bg_view = [[UIView alloc] initWithFrame:cell.bounds];
    selected_bg_view.backgroundColor = [[CCConstants sharedInstance] historySelectedCellBackgroundColor];
    cell.selectedBackgroundView = selected_bg_view;
    ///Change backgroundColor color
    if([indexPath isEqual:selectedIndexPath] && [CCConnectionHelper sharedClient].twoColumnLayoutMode == YES){
        cell.backgroundColor = [[CCConstants sharedInstance] historySelectedCellBackgroundColor];
    }else{
        cell.backgroundColor = [CCConstants defaultHistoryCellBackgroundColor];
    }
    
    UIImage *image = [[UIImage imageNamed:@"CCreply-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.imageReply setImage:image];
    cell.imageReply.tintColor = [UIColor lightGrayColor];
    if ([[CCConstants sharedInstance] isAgent] && admin) {
        [cell.imageReply setHidden:NO];
        cell.imageReplyLeftMargin.constant = 5.0f;
        cell.imageReplyWidth.constant = 20.0f;
    } else {
        [cell.imageReply setHidden:YES];
        cell.imageReplyWidth.constant = 0;
        cell.imageReplyLeftMargin.constant = 0;
    }
    
    ///Display status(Only for agent)
    if ([CCConstants sharedInstance].isAgent && [labels[@"status"] isEqualToString:@"unassigned"]){
        status.hidden = NO;
        statusBack.hidden = NO;
        status.text = CCLocalizedString(@"Unassigned");
        if ([[ChatCenter sharedInstance] isLocaleJapanese]) {
            cell.UnassignedWidth.constant = 61.0f;
        }else{
            cell.UnassignedWidth.constant = 81.0f;
        }
    }else{
        status.hidden = YES;
        statusBack.hidden = YES;
        cell.UnassignedWidth.constant = 0.0f;
    }

    ///Display unread message number
    if (![labels[@"unreadMessageNum"] isEqualToString:@"0"]
        && !([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES
             && [self.chatAndHistoryViewController.chatViewController.channelId isEqualToString:labels[@"channelId"]]))
    {
        /// Unread messages exist
        unreadNum.hidden = NO;
        unreadNumBack.hidden = NO;
        if ([labels[@"unreadMessageNum"] intValue] > 999) {
            unreadNum.text = @"+999";
            cell.UnreadNumWidth.constant = 41.0f;
        }else{
            unreadNum.text = labels[@"unreadMessageNum"];
            cell.UnreadNumWidth.constant = 31.0f;
        }
        cell.UnassignedRightMargin.constant = 6.0f;
    }else{
        ///No unread message
        unreadNum.hidden = YES;
        unreadNumBack.hidden = YES;
        cell.UnreadNumWidth.constant = 0.0f;
        cell.UnassignedRightMargin.constant = 0.0f;
    }
    
    //Adjust right margin of latest message
    if (statusBack.hidden && unreadNumBack.hidden) {
        cell.LastMessageRightMargin.constant = 0.0f;
    }else{
        cell.LastMessageRightMargin.constant = 2.0f;
    }

    //
    // Action buttons
    //
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"];
    NSString *channelID = [self.ChatChannelIds objectAtIndex:indexPath.row];
    // Delete button
    CCMGSwipeButton *deleteButton = [CCMGSwipeButton buttonWithTitle:CCLocalizedString(@"Delete") backgroundColor:[UIColor colorWithRed:254.0/255 green:63.0/255 blue:53.0/255 alpha:1] callback:^BOOL(CCMGSwipeTableCell *sender) {
        // handle delete
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:CCLocalizedString(@"チャットを削除しますか？") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self removeChannelAtIndexPath:indexPath];
            [[CCConnectionHelper sharedClient] deleteChannel:channelID completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
                if (error == nil) {
                    [cell hideSwipeAnimated:YES];
                }
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:cancelAction];
        [alertVC addAction:okAction];
        [self presentViewController:alertVC animated:YES completion:nil];
        return YES;
    }];
    UIImageView *deleteIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CCicon-delete"]];
    deleteIcon.contentMode = UIViewContentModeScaleAspectFit;
    deleteIcon.frame = CGRectMake(deleteButton.frame.size.width / 2 - 10, deleteButton.frame.size.height - 10, 20, 20);
    [deleteButton addSubview:deleteIcon];
    UILabel *deleteLabel = [[UILabel alloc] init];
    deleteLabel.text = CCLocalizedString(@"Delete");
    deleteLabel.textAlignment = NSTextAlignmentCenter;
    deleteLabel.textColor = [UIColor whiteColor];
    deleteLabel.font = [UIFont systemFontOfSize:14];
    deleteLabel.frame = CGRectMake(0, deleteButton.frame.size.height + 20, deleteButton.frame.size.width, 20);
    [deleteButton addSubview:deleteLabel];
    [deleteButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    // Assign button
    CCMGSwipeButton *assignButton = [CCMGSwipeButton buttonWithTitle:CCLocalizedString(@"Assign") backgroundColor:[UIColor colorWithRed:246.0/255 green:166.0/255 blue:35.0/255 alpha:1] callback:^BOOL(CCMGSwipeTableCell *sender) {
        // handle assign
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter" bundle:SDK_BUNDLE];
        CCAssignAssigneeViewController *vc = [storyboard  instantiateViewControllerWithIdentifier:@"assignAssigneeViewController"];;
        vc.orgUid = currentOrgId;
        vc.channelUid = [self.ChatChannelIds objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
        return YES;
    }];
    UIImageView *assignIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CCicon-assign"]];
    assignIcon.contentMode = UIViewContentModeScaleAspectFit;
    assignIcon.frame = CGRectMake(assignButton.frame.size.width / 2 - 10, assignButton.frame.size.height - 10, 20, 20);
    [assignButton addSubview:assignIcon];
    UILabel *assignLabel = [[UILabel alloc] init];
    assignLabel.text = CCLocalizedString(@"Assign");
    assignLabel.textAlignment = NSTextAlignmentCenter;
    assignLabel.textColor = [UIColor whiteColor];
    assignLabel.font = [UIFont systemFontOfSize:14];
    assignLabel.frame = CGRectMake(0, assignButton.frame.size.height + 20, assignButton.frame.size.width, 20);
    [assignButton addSubview:assignLabel];
    [assignButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];

    
    // Close button
    CCMGSwipeButton *closeButton = [CCMGSwipeButton buttonWithTitle:CCLocalizedString(@"Close") backgroundColor:[UIColor colorWithRed:126.0/255 green:211.0/255 blue:33.0/255 alpha:1] callback:^BOOL(CCMGSwipeTableCell *sender) {
        // handle close
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:CCLocalizedString(@"チャットをクローズしますか？") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self removeChannelAtIndexPath:indexPath];
            [[CCConnectionHelper sharedClient] closeChannels:@[channelID] completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
                if (error == nil) {
                    [cell hideSwipeAnimated:YES];
                }
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:cancelAction];
        [alertVC addAction:okAction];
        [self presentViewController:alertVC animated:YES completion:nil];
                return YES;
    }];
    UIImageView *closeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CCicon-close"]];
    closeIcon.contentMode = UIViewContentModeScaleAspectFit;
    closeIcon.frame = CGRectMake(closeButton.frame.size.width / 2 - 10, closeButton.frame.size.height - 10, 20, 20);
    [closeButton addSubview:closeIcon];
    UILabel *closeLabel = [[UILabel alloc] init];
    closeLabel.text = CCLocalizedString(@"Close");
    closeLabel.textAlignment = NSTextAlignmentCenter;
    closeLabel.textColor = [UIColor whiteColor];
    closeLabel.font = [UIFont systemFontOfSize:14];
    closeLabel.frame = CGRectMake(0, closeButton.frame.size.height + 20, closeButton.frame.size.width, 20);
    [closeButton addSubview:closeLabel];
    [closeButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];

    // Open button
    CCMGSwipeButton *openButton = [CCMGSwipeButton buttonWithTitle:CCLocalizedString(@"Reopen") backgroundColor:[UIColor colorWithRed:126.0/255 green:211.0/255 blue:33.0/255 alpha:1] callback:^BOOL(CCMGSwipeTableCell *sender) {
        [self removeChannelAtIndexPath:indexPath];
        // handle close
        [[CCConnectionHelper sharedClient] openChannels:@[channelID] completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
            if (error == nil) {
                [cell hideSwipeAnimated:YES];
            }
        }];
        return YES;
    }];
    UIImageView *openIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CCicon-reopen"]];
    openIcon.contentMode = UIViewContentModeScaleAspectFit;
    openIcon.frame = CGRectMake(openButton.frame.size.width / 2 - 10, openButton.frame.size.height - 10, 20, 20);
    [openButton addSubview:openIcon];
    UILabel *openLabel = [[UILabel alloc] init];
    openLabel.text = CCLocalizedString(@"Reopen");
    openLabel.textAlignment = NSTextAlignmentCenter;
    openLabel.textColor = [UIColor whiteColor];
    openLabel.font = [UIFont systemFontOfSize:14];
    openLabel.frame = CGRectMake(0, openButton.frame.size.height + 20, openButton.frame.size.width, 20);
    [openButton addSubview:openLabel];
    [openButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    

    NSMutableArray *btnArray = [NSMutableArray array];
    if (channelRoles != nil && [channelRoles containsObject:@"destroy"]) {
        [btnArray addObject:deleteButton];
    }
    
    if (channelRoles != nil && [channelRoles containsObject:@"close"] && (self.channelType == CCAllChannel || self.channelType == CCUnarchivedChannel)) {
        [btnArray addObject:closeButton];
    }

    if (channelRoles != nil && [channelRoles containsObject:@"close"] && self.channelType == CCArchivedChannel) {
        [btnArray addObject:openButton];
    }
    
    if (channelRoles != nil && [channelRoles containsObject:@"assign"]) {
        [btnArray addObject:assignButton];
    }
    
    if ([CCConstants sharedInstance].isAgent) {
        cell.rightButtons = btnArray;
        cell.leftSwipeSettings.transition = CCMGSwipeTransitionDrag;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableView.editing) return; ///During edit

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *labels = [self.ChannelLabels objectAtIndex:indexPath.row];
    
    ///Change backgroundColor color
    UITableViewCell *previousCell = [tableView cellForRowAtIndexPath:selectedIndexPath];
    previousCell.backgroundColor = [CCConstants defaultHistoryCellBackgroundColor];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [[CCConstants sharedInstance] historySelectedCellBackgroundColor];
    selectedIndexPath = indexPath;
    
    ///Update unread message num and toatal unread message num
    UILabel *title          = (UILabel*)[cell viewWithTag:4];
    UILabel *lastMessage    = (UILabel*)[cell viewWithTag:1];
    UILabel *lastUpdateDate = (UILabel*)[cell viewWithTag:2];
    title.font          = [UIFont systemFontOfSize:17.0];
    lastUpdateDate.font = [UIFont systemFontOfSize:14.0];
    lastMessage.font    = [UIFont systemFontOfSize:14.0];
    NSDictionary * channel = [self.ChannelLabels objectAtIndex:indexPath.row];
    NSNumber *admin = channel[@"admin"];
    [self.ChannelLabels removeObjectAtIndex:indexPath.row];
    NSDictionary *channelLabel = @{@"uid":labels[@"uid"],
                                   @"channelId":labels[@"channelId"],
                                   @"title":labels[@"title"],
                                   @"lastUpdatedAt":labels[@"lastUpdatedAt"],
                                   @"message":labels[@"message"],
                                   @"status":labels[@"status"],
                                   @"iconImage":labels[@"iconImage"],
                                   @"senderName":labels[@"senderName"],
                                   @"unreadMessageNum":@"0",
                                   @"admin":admin};
    [self.ChannelLabels insertObject:channelLabel atIndex:indexPath.row];
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) { ///SplitView
        // Show right side menu button
        if ([self isVideocallEnabled:labels[@"canUseVideoChat"]]){
            self.chatAndHistoryViewController.navigationItem.rightBarButtonItems = @[_rightSpacer, _inforButton, _videoCallButton, _voiceCallButton];
        } else {
            self.chatAndHistoryViewController.navigationItem.rightBarButtonItems = @[_rightSpacer, _inforButton];
        }
        self.chatAndHistoryViewController.chatViewController.navigationHistoryView = self.navigationController;
        [self.chatAndHistoryViewController.chatViewController saveDraftMessage];
        ///Display ChatView
        [self.chatAndHistoryViewController switchChannel:labels[@"channelId"]];
    }else{
        CCChatViewController *chatView = [[CCChatViewController alloc] init];
        [chatView setChannelUid:labels[@"uid"]];
        [chatView setChannelId:labels[@"channelId"]];
        [chatView setUserVideoChat:labels[@"canUseVideoChat"]];
        if ([CCConstants sharedInstance].isAgent == YES) {
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        }
        [self removeNavigationBottomBorder];
        [self.navigationController pushViewController:chatView animated:YES];
        self.isReturnFromChatView = YES;
#ifdef CC_WATCH
        [[CCConnectionHelper sharedClient] switchChannel:labels[@"channelId"]];
#endif
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *channelUid = [self.ChatChannelIds objectAtIndex:indexPath.row];
        NSArray *channelUids = [NSArray arrayWithObjects:[self.ChatChannelIds objectAtIndex:indexPath.row], nil];
        if ([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable || CCLocalDevelopmentMode) {
            [[CCConnectionHelper sharedClient] closeChannels:channelUids completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *operation) {
                if (result != nil) {
                    ///change status of channel in coredata
                    [[CCCoredataBase sharedClient] updateChannelUpdateAtAndStatusWithUid:channelUid updateAt:[NSDate date] status:@"closed"];
                    ///Clear Unread Message
                    [[ChatCenter sharedInstance] clearUnreadMessage:channelUid];
                    ///Reload channels
                    [self loadLocalChannles:NO lastUpdatedAt:nil];
                }else{
                    [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
                }
            }];
        }else{
            [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (self.channelType == CCUnarchivedChannel) {
        return YES;
    }else{
        return NO;
    }
}

- (NSString *)tableView:(UITableView *)tableVie
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  CCLocalizedString(@"Delete");
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == CCTopRowTableView) {
        if (newMessageView != nil) {
            [newMessageView removeFromSuperview];
        }
    }
}

#pragma mark - scroll view delegates

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height && !_isLoadingMore) {
        _isLoadingMore = TRUE;
        // we are at the end
        NSLog(@"scrollViewDidEndDeceleratingEnd");
        NSDate *lastUpdatedAt = self.ChannelLabels[(int)self.ChannelLabels.count-1][@"lastUpdatedAt"];
        int getChannelsType;
        NSString *orgUid;
        if ([CCConstants sharedInstance].isAgent == YES) {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            if ([ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"] == nil) return;
            getChannelsType = CCGetChannels;
            orgUid = [ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"];
        }else{
            getChannelsType = CCGetChannelsMine;
            orgUid = nil;
        }
//        [self loadChannels:getChannelsType orgUid:orgUid lastUpdatedAt:lastUpdatedAt];
        NSString *inputText = [self->searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (inputText == nil || [inputText isEqual:[NSNull null]] || [inputText isEqualToString:@""]) {
            [self loadChannels:getChannelsType orgUid:orgUid lastUpdatedAt:lastUpdatedAt];
        } else {
            NSString *channelName = self->searchBar.text;
            [self loadChannelsByChannelName:channelName lastUpdatedAt:lastUpdatedAt];
        }
    }else{
        // we are at the top
        NSLog(@"scrollViewDidEndDeceleratingTop");
    }
}

#pragma mark - View Setup
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
    self.isReturnFromChatView = NO;
    self.isReturnFromRightMenuView = NO;
    ///Initialize UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshOccured:) forControlEvents:UIControlEventValueChanged];
    
    ///Restriction gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.navigationController.interactivePopGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>)self;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    ///Normal separator settings
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    ///Displaying void view with no message
    self.noCellMessage.text = [[CCConstants sharedInstance] historyViewVoidMessage];
    self.noCellMessage.font = [UIFont systemFontOfSize:14.0f];
    self.noCellMessage.textAlignment = NSTextAlignmentCenter;
    self.noCellMessage.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    self.noCellMessage.hidden = YES;
    [self.noCellMessage setTextContainerInset:UIEdgeInsetsMake(0, 5.0, 0, 5.0)];
    [self hideNaviShadowWithView:self.navigationController.navigationBar];
    ///Disappearing boarder of void cells
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableHeaderView:v];
    [self.tableView setTableFooterView:v];
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
        self.tableView.scrollsToTop = NO;
    }
    ///Background color(as same as cell's background color)
    self.tableView.backgroundColor = [CCConstants defaultHistoryCellBackgroundColor];
    
    // Setting navigation title view.
    navigationTitleView = [[CCHistoryNavigationTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 120, self.navigationController.navigationBar.frame.size.height)];
    navigationTitleView.title = @"";
    navigationTitleView.delegate = self;
    [navigationTitleView setTitleButonEnabled:[CCConstants sharedInstance].isAgent];
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES){
        self.chatAndHistoryViewController.navigationController.navigationBar.topItem.titleView = navigationTitleView;
    } else {
        self.navigationItem.titleView = navigationTitleView;
    }
    [navigationTitleView updateSearchLabel];
    
    [self navigationBarSetup];
    if ([[CCConstants sharedInstance] isAgent]) {
        if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES){
            searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, self.chatAndHistoryViewController.navigationController.navigationBar.topItem.titleView.frame.size.height + 30, 320, 44)];
        } else {
            searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, self.navigationItem.titleView.frame.size.height + 20, self.view.frame.size.width, 44)];
        }
        searchBar.delegate = self;
        [self.view addSubview:searchBar];
        self.tableView.contentInset = UIEdgeInsetsMake(searchBar.frame.size.height, 0, 0, 0);
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = CGRectMake(self.view.bounds.origin.x, searchBar.frame.origin.y + searchBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
        blurEffectView.alpha = 0.9;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOverlayView)];
        [blurEffectView addGestureRecognizer:tapGes];
    }
}

- (UIButton *)barButtonItemWithImageName:(NSString *)imageName hilightedImageName:(NSString *)hilightedImageName disableImageName:(NSString*)disableImageName target:(id)target selector:(SEL)action
{
    UIImage *imageOriginal = [UIImage SDKImageNamed:imageName];
    UIImage *image = [imageOriginal imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = (CGRect){0,0,image.size.width, image.size.height};
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    if(hilightedImageName != nil) {[btn setBackgroundImage:[UIImage SDKImageNamed:hilightedImageName] forState:UIControlStateHighlighted];}
    if(disableImageName != nil)   {[btn setBackgroundImage:[UIImage SDKImageNamed:disableImageName] forState:UIControlStateDisabled];}
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)initChatData{
    self.ChatChannelIds = [[NSMutableArray alloc] init];
    self.ChannelLabels = [[NSMutableArray alloc] init];
    self.ChannelTotalUnreadMessageNum = 0;
}

- (void) initInputSearchBar {
    searchBar.text = @"";
    [self.view endEditing:YES];
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
        self.navigationController.navigationBar.barTintColor = [[CCConstants sharedInstance] historyHeaderBackgroundColor];
    }
    if ([CCConstants sharedInstance].headerItemColor != nil) {
        self.navigationController.navigationBar.tintColor = [[CCConstants sharedInstance] headerItemColor];
    }
    [self addNavigationBottomBorder];
}

- (void)navigationBarSetup{
    //--------------------------------------------------------------------
    //
    // Title
    //
    //--------------------------------------------------------------------
    if([CCConstants sharedInstance].isAgent == YES){
        navigationTitle = @"";
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *currentOrgUid = [ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"];
        NSArray *orgs = [[CCCoredataBase sharedClient] selectOrgAll:CCloadLoacalOrgLimit];
        for (NSManagedObject *org in orgs) {
            NSString *uid = [org valueForKey:@"uid"];
            if ([uid isEqualToString:currentOrgUid]) {
                NSString *orgName = [org valueForKey:@"name"];
                navigationTitle = orgName;
                break;
            }
        }
    }else{
        navigationTitle = [[CCConstants sharedInstance] historyViewTitle];
    }
    navigationTitleView.title = navigationTitle;
    
    //--------------------------------------------------------------------
    //
    // Left side button
    //
    //--------------------------------------------------------------------
    self.navigationItem.leftBarButtonItem = nil;
    if ([CCConstants sharedInstance].isAgent == YES) { //For Agent
        //menuButton
        UIBarButtonItem *menuButton =[[UIBarButtonItem alloc] initWithImage:[UIImage SDKImageNamed:@"CCmenu_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pressMenu:)];
        if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES){
            self.chatAndHistoryViewController.navigationItem.leftBarButtonItem = menuButton;
            if(self.chatAndHistoryViewController.chatViewController != nil) {
                ///Right bar button
                self.chatAndHistoryViewController.navigationItem.rightBarButtonItems = nil;
            }
        } else {
            self.navigationItem.leftBarButtonItem = menuButton;
        }
    }else{
        //--------------------------------------------------------------------
        //
        // We have supported two cases for displaying HistoryView
        // 1. With Navigation Controller
        // 2. Without Navigation Controller(ex. Customer wants to manage controller by their own)
        //
        //--------------------------------------------------------------------
        UIButton* leftButton;
        if ([CCConstants sharedInstance].isModal) {
            //--------------------------------------------------------------------
            // 1. With Navigation Controller(Show close button)
            //--------------------------------------------------------------------
            if ([CCConstants sharedInstance].closeBtnNormal != nil
                || [CCConstants sharedInstance].closeBtnHilighted != nil
                || [CCConstants sharedInstance].closeBtnDisable != nil)
            {
                ///Use custom close button
                leftButton = [self barButtonItemWithImageName:[CCConstants sharedInstance].closeBtnNormal
                                           hilightedImageName:[CCConstants sharedInstance].closeBtnHilighted
                                             disableImageName:[CCConstants sharedInstance].closeBtnDisable
                                                       target:self
                                                     selector:@selector(pressClose:)];
                self.closeButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
            }else{
                ///Use default close button in iOS
                self.closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                 target:self
                                                                                 action:@selector(pressClose:)];
            }
            if ([CCConstants sharedInstance].headerItemColor == nil) {
                self.closeButton.tintColor = [UIColor colorWithRed:41/255.0 green:59/255.0 blue:84/255.0 alpha:1.0];
            }
            self.navigationItem.leftBarButtonItem = self.closeButton;
            self.navigationItem.backBarButtonItem = nil;
        }else{
            //--------------------------------------------------------------------
            // 2. Without Navigation Controller(Show back arrow button)
            //--------------------------------------------------------------------
            if ([CCConstants sharedInstance].backBtnNormal != nil
                || [CCConstants sharedInstance].backBtnHilighted != nil
                || [CCConstants sharedInstance].backBtnDisable != nil)
            {
                ///Use custom back button
                leftButton = [self barButtonItemWithImageName:[CCConstants sharedInstance].backBtnNormal
                                           hilightedImageName:[CCConstants sharedInstance].backBtnHilighted
                                             disableImageName:[CCConstants sharedInstance].backBtnDisable
                                                       target:self
                                                     selector:@selector(pressBack:)];
                self.closeButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
                if ([CCConstants sharedInstance].headerItemColor == nil) {
                    self.closeButton.tintColor = [UIColor colorWithRed:41/255.0 green:59/255.0 blue:84/255.0 alpha:1.0];
                }
                self.navigationItem.leftBarButtonItem = self.closeButton;
                self.navigationItem.backBarButtonItem = nil;
            }else{
                ///Use default back button in iOS
                self.closeButton = nil;
            }
        }
    }
    
    
    
    //--------------------------------------------------------------------
    //
    // Right side button(Only for Two column layout mode)
    //
    //--------------------------------------------------------------------
    UIButton* rightMenuButtonView = [self barButtonItemWithImageName:[CCConstants sharedInstance].infoBtnNormal
                                                  hilightedImageName:[CCConstants sharedInstance].infoBtnHilighted
                                                    disableImageName:[CCConstants sharedInstance].infoBtnDisable
                                                              target:self
                                                            selector:@selector(pressInfo:)];
    if ([CCConstants sharedInstance].headerItemColor == nil) {
        rightMenuButtonView.tintColor = [CCConstants sharedInstance].baseColor;
    }
    self.inforButton = [[UIBarButtonItem alloc] initWithCustomView:rightMenuButtonView];
    
    UIButton* voiceCallButtonView = [self barButtonItemWithImageName:[CCConstants sharedInstance].voiceCallBtnNormal
                                                  hilightedImageName:[CCConstants sharedInstance].voiceCallBtnHilighted
                                                    disableImageName:[CCConstants sharedInstance].voiceCallBtnDisable
                                                              target:self
                                                            selector:@selector(pressVoiceCall)];
    if ([CCConstants sharedInstance].headerItemColor == nil) {
        voiceCallButtonView.tintColor = [CCConstants sharedInstance].baseColor;
    }
    self.voiceCallButton = [[UIBarButtonItem alloc] initWithCustomView:voiceCallButtonView];
    
    UIButton* videoCallButtonView = [self barButtonItemWithImageName:[CCConstants sharedInstance].videoCallBtnNormal
                                                  hilightedImageName:[CCConstants sharedInstance].videoCallBtnHilighted
                                                    disableImageName:[CCConstants sharedInstance].videoCallBtnDisable
                                                              target:self
                                                            selector:@selector(pressVideoCall)];
    if ([CCConstants sharedInstance].headerItemColor == nil) {
        videoCallButtonView.tintColor = [CCConstants sharedInstance].baseColor;
    }
    self.videoCallButton = [[UIBarButtonItem alloc] initWithCustomView:videoCallButtonView];
    self.rightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.rightSpacer.width = 10;

    
    
    //--------------------------------------------------------------------
    //
    // Edit channel button(Deprecated)
    // We don't use this now. 
    //
    //--------------------------------------------------------------------
    if ([[CCConstants sharedInstance].businessType isEqualToString:CC_BUSINESSTYPETEAM]) {
        self.rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                            target:self
                                                                            action:@selector(didTapCreateChannelBtn)];
        self.navigationItem.rightBarButtonItem = self.rightBarButton;
    }else{
        ///edit button
        if (self.channelType == CCUnarchivedChannel) {
            self.rightBarButton = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Edit")
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(didTapEditButton)];
            self.navigationItem.rightBarButtonItem = self.rightBarButton;
        }
        ///delete button
        self.deleteButton = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Delete")
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(didTapDeleteButton)];
    }
}

- (BOOL)isVideocallEnabled:(NSArray *)userVideoChat{
    if ([self isAppVideocallEnabled] && [[CCConnectionHelper sharedClient] isSupportVideoChat] && [self processChannelUserVideoChatInfo:userVideoChat]){
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)isAppVideocallEnabled {
    NSArray *stickers = [[CCConstants sharedInstance].stickers copy];
    for (int i = 0;i < stickers.count; i++) {
        if([stickers[i] isEqualToString:CC_STICKERTYPEVIDEOCHAT]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)processChannelUserVideoChatInfo:(NSArray *)userVideoChat{
    if(userVideoChat == nil || userVideoChat.count <= 0) {
        return NO;
    }
    
    for (NSDictionary *videoChat in userVideoChat) {
        NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:kCCUserDefaults_userId];
        if([[videoChat objectForKey:@"id"] integerValue] != [userId integerValue] &&
           [[videoChat objectForKey:@"can_use_video_chat"] boolValue] == YES) {
            return YES; // at least one user can video chat
        }
    }
    return NO;
}

#pragma mark - CCConectionHelper delegate

- (void)closeChatView{
    [self pressClose:nil];
}

-(void)loadLocalData:(BOOL)isOrgChange{
    [self navigationBarSetup];
    if ([CCConstants sharedInstance].isAgent == YES) {
        NSString *inputText = [self->searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (inputText.length > 0) {
                return;
        }
    }
    [self loadLocalChannles:isOrgChange lastUpdatedAt:nil];
}

- (void) reloadLocalDataWhenComeOnline {
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES && self.chatAndHistoryViewController.chatViewController.channelId !=nil) {
        [self.chatAndHistoryViewController.chatViewController loadLocalData:NO];
    }
}

-(void)loadLocalChannels{
    [self loadLocalChannles:NO lastUpdatedAt:nil];
}

- (void)receiveChannelJoinFromWebSocket:(NSString *)channelId newChannel:(BOOL)newChannel{
    if ([CCConstants sharedInstance].isAgent == YES) {
        NSString *inputText = [self->searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (inputText.length > 0) {
            if (![self.ChatChannelIds containsObject:channelId]) {
                return;
            }
        }
    }
    
    if ([CCConstants sharedInstance].isAgent == YES && newChannel == YES){
        [self loadLocalData:NO];
    }
    // Display new channel notification
    BOOL shouldShowNewMessageButton = YES;
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath.item == 0) {
            shouldShowNewMessageButton = NO;
            break;
        }
    }
    if (shouldShowNewMessageButton) {
        [self displayNotification:CCLocalizedString(@"New chat")];
    }
}

- (void)receiveChannelOnlineFromWebSocket:(NSString *)channelUid user:(NSDictionary *)user {
    
}

- (void)receiveMessageFromWebSocket:(NSString *)messageType
                                uid:(NSNumber *)uid
                            content:(NSDictionary *)content
                          channelId:(NSString *)channelId
                            userUid:(NSString *)userUid
                               date:(NSDate *)date
                        displayName:(NSString *)displayName
                        userIconUrl:(NSString *)userIconUrl
                          userAdmin:(BOOL)userAdmin
                             answer:(NSDictionary *)answer
{
    if ([CCConstants sharedInstance].isAgent == YES) {
        NSString *inputText = [self->searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (inputText.length > 0) {
            if (![self.ChatChannelIds containsObject:channelId]) {
                return;
            }
        }
    }
    
    BOOL shouldShowNewMessageButton = YES;
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath.item == 0) {
            shouldShowNewMessageButton = NO;
            break;
        }
    }
    
    if (![self.ChatChannelIds containsObject:channelId]) {
        shouldShowNewMessageButton = NO;
    }
    
    if (shouldShowNewMessageButton) {
        [self showNewMessageButton:messageType uid:uid content:content channelId:channelId userUid:userUid date:date displayName:displayName userIconUrl:userIconUrl userAdmin:userAdmin answer:answer];
    }
    
    [self loadLocalChannles:NO lastUpdatedAt:nil];
    if([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES)
    {
        if ([self.chatAndHistoryViewController.chatViewController.channelId isEqualToString:channelId]){
            [self.chatAndHistoryViewController.chatViewController receiveMessage:messageType
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
    if((self.chatAndHistoryViewController.chatViewController.collectionView.contentOffset.y >= (self.chatAndHistoryViewController.chatViewController.collectionView.contentSize.height - self.chatAndHistoryViewController.chatViewController.collectionView.frame.size.height))) {
        [self.chatAndHistoryViewController.chatViewController scrollToBottomAnimated:YES];
    }
}

- (void)receiveReceiptFromWebSocket:(NSString *)channelUid
                           messages:(NSArray *)messages
                            userUid:(NSString *)userUid
                          userAdmin:(BOOL)userAdmin{
    NSLog(@"receiveReceiptFromWebSocket in HistoryView");
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
        [self.chatAndHistoryViewController.chatViewController receiveReceiptFromWebSocket:channelUid messages:messages userUid:userUid userAdmin:userAdmin];
    }
}

- (void)receiveFollowFromWebSocket:(NSString *)channelUid{
    if (![self.ChatChannelIds containsObject:channelUid]) {
        return;
    }
    [self loadLocalChannles:NO lastUpdatedAt:nil];
    if([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES)
    {
        if ([self.chatAndHistoryViewController.chatViewController.channelId isEqualToString:channelUid]){
            [self.chatAndHistoryViewController.chatViewController receiveFollowFromWebSocket:channelUid];
        }
    }
}

- (void)receiveUnfollowFromWebSocket:(NSString *)channelUid{
    if (![self.ChatChannelIds containsObject:channelUid]) {
        return;
    }
    [self loadLocalChannles:NO lastUpdatedAt:nil];
    if([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES)
    {
        if ([self.chatAndHistoryViewController.chatViewController.channelId isEqualToString:channelUid]){
            [self.chatAndHistoryViewController.chatViewController receiveUnfollowFromWebSocket:channelUid];
        }
    }
}

-(void)finishedLoadingUserToken{
    [CCSVProgressHUD dismiss];
    ///Initialize (Create user or Create channel or Load channel)
    if ([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable || CCLocalDevelopmentMode) {
        [[CCConnectionHelper sharedClient] refreshData];
    }else{
        [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
        NSLog(@"initChatView Error");
    }
    [self loadLocalChannles:NO lastUpdatedAt:nil];
}

- (void)receiveInviteCall:(NSString *)messageId channelId:(NSString *)channelId content:(NSDictionary *)content{
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
        [self.chatAndHistoryViewController.chatViewController receiveInviteCall:messageId channelId:channelId content:content];
    }
}

- (void)receiveCallEvent:(NSString *)messageId content:(NSDictionary *)content {
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
        [self.chatAndHistoryViewController.chatViewController receiveCallEvent:messageId content:content];
    }
}

- (void)receiveDeleteChannelFromWebSocket:(NSString *)channelUid {
    if ([self.ChatChannelIds containsObject:channelUid]) {
        [self loadLocalChannles:NO lastUpdatedAt:nil];
    }
}

- (void)receiveCloseChannelFromWebSocket:(NSString *)channelUid {
    if ([self.ChatChannelIds containsObject:channelUid]) {
        [self loadLocalChannles:NO lastUpdatedAt:nil];
    }
}

- (void)receiveMessageTypingFromWebSocket:(NSString *)channelUid user:(NSDictionary *)user {
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
        [self.chatAndHistoryViewController.chatViewController receiveMessageTypingFromWebSocket:channelUid user:user];
    }
}

- (void)receiveAssignFromWebSocket:(NSString *)channelUid {
    [self loadLocalChannles:NO lastUpdatedAt:nil];
}

- (void)receiveUnassignFromWebSocket:(NSString *)channelUid {
    [self loadLocalChannles:NO lastUpdatedAt:nil];
}

#pragma mark - Load Data
-(void)loadLocalChannles:(BOOL)isOrgChange lastUpdatedAt:(NSDate *)lastUpdatedAt{
    if (lastUpdatedAt == nil) [self initChatData];

    NSArray *channelArray;
    if (lastUpdatedAt == nil) {
        channelArray = [[CCCoredataBase sharedClient] selectAllChannel:CCloadLoacalChannelLimit channelType:self.channelType];
    }else{
        channelArray = [[CCCoredataBase sharedClient] selectChannels:CCloadLoacalChannelLimit
                                                       lastUpdatedAt:lastUpdatedAt
                                                         channelType:self.channelType];
    }
        
    int endMessageIndex, loadChannelNum;
    if (channelArray.count > CCloadLoacalChannelLimit) { ///coredata's setFetchBatchSize is not accurate, it may select more than it's limit
        endMessageIndex = (int)channelArray.count-(CCloadLoacalChannelLimit-1);
        loadChannelNum = CCloadLoacalChannelLimit-1;
    }else{
        endMessageIndex = 0;
        loadChannelNum = (int)channelArray.count;
    }
    int startIndex = (int)self.ChannelLabels.count-1;
    
    NSArray *messageStatus = [CCUserDefaultsUtil filterMessageStatus];
    NSString *filteredStatus;
    if (messageStatus.count > 0) {
        for (NSString *status in messageStatus) {
            if ([status isEqualToString:CCHistoryFilterMessagesStatusTypeClosed]) {
                filteredStatus = @"closed";
                break;
            }
            if ([status isEqualToString:CCHistoryFilterMessagesStatusTypeUnassigned]) {
                filteredStatus = @"unassigned";
                break;
            }
        }
    }
    
    for (int i = (int)channelArray.count-1; endMessageIndex <= i ; i--) {
        NSString *channelId;
        NSString *ChannelDisplayNames = @"";
        NSString *lastUpdatedAt;
        NSString *message = CCLocalizedString(@"No Message yet");
        UIImage *iconImage;
        NSString *iconImageUrl;
        NSString *unreadMessageNum;
        NSNumber *senderId;
        NSString *senderName;
        NSString *callerId;
        NSString *callerName;
        
        NSManagedObject *object = [channelArray objectAtIndex:i];
        NSNumber *uid           = [object valueForKey:@"id"];
        channelId               = [object valueForKey:@"uid"];
        unreadMessageNum        = [object valueForKey:@"unread_messages"];
        NSString *orgName       = [object valueForKey:@"org_name"];
        NSString *groupName     = [object valueForKey:@"name"]; ///Group name
        lastUpdatedAt           = [object valueForKey:@"last_updated_at"];
        NSData *usersData       = [object valueForKey:@"users"];
        NSString *status       = [object valueForKey:@"status"];
        NSArray *users          = [NSKeyedUnarchiver unarchiveObjectWithData:usersData];
        NSDictionary *displayName = [NSKeyedUnarchiver unarchiveObjectWithData:[object valueForKey:@"display_name"]];
        NSMutableArray *usersVideoChat = [[NSMutableArray alloc] init];
        
        // filter status
        if (filteredStatus != nil && [filteredStatus isEqualToString:@"unassigned"] && ![status isEqualToString:filteredStatus]) {
            continue;
        }
        
        ///duplicate check
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@",uid];
        NSArray *duplicates = [self.ChannelLabels filteredArrayUsingPredicate: predicate];
        if ([duplicates count] > 0) {
            continue;
        }
        ///Display name And Avatar image
        NSMutableString *names = [NSMutableString stringWithString:@""];
        if (![[CCConstants sharedInstance] getKeychainUid]) {
            continue;
        }
        
        for (int j = 0; j < users.count; j++) {
            // video chat info
            if(users[j][@"can_use_video_chat"] != nil && users[j][@"can_use_video_chat"] != [NSNull null]) {
                NSDictionary *videoChatInfo = @{@"id" : users[j][@"id"], @"can_use_video_chat" : users[j][@"can_use_video_chat"]};
                [usersVideoChat addObject:videoChatInfo];
            }
        }
        
        int nameCount = 0;
        for (int i=0; i < users.count; i++) {
            if (![users[i][@"id"] isKindOfClass:[NSNumber class]]) {
                continue;
            }
            if ([[users[i][@"id"] stringValue] isEqualToString:[[CCConstants sharedInstance] getKeychainUid]]) {
                continue;
            }
            if(users[i][@"display_name"] == nil || [users[i][@"display_name"] isEqual:[NSNull null]]){
                continue;
            }
            
            
            
            if ([CCConstants sharedInstance].isAgent == YES
                && ![[CCConstants sharedInstance].businessType isEqualToString:CC_BUSINESSTYPETEAM]) {
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
            ///create avatar image if user has icon-image
            if (iconImage == nil && users[i][@"icon_url"] != nil
                && !([users[i][@"icon_url"] isEqual:[NSNull null]])
                && ([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable))
            {
                iconImageUrl = users[i][@"icon_url"];
            }
            
            if (iconImage == nil) {
                NSString *firstCharacter = [users[i][@"display_name"] substringToIndex:1];
                NSLog(@"create avatar image if user has icon-image1:%@", users[i][@"id"] );
                iconImage = [[ChatCenter sharedInstance] createAvatarImage:firstCharacter
                                                                     width:CCRandomCircleAvatarSize
                                                                    height:CCRandomCircleAvatarSize
                                                                     color:[[ChatCenter sharedInstance] getRandomColor:[users[i][@"id"] stringValue]]
                                                                  fontSize:CCRandomCircleAvatarFontSize textOffset:CCRandomCircleAvatarTextOffset];
            }
            
        }
        if ([[CCConstants sharedInstance].businessType isEqualToString:CC_BUSINESSTYPETEAM]) {
            ///TEAM
            if ([groupName isEqualToString:@""]) {
                ///Display names of chat members
                ChannelDisplayNames = names;
            }else{
                ///Display group name
                ChannelDisplayNames = groupName;
            }
        }else{
            ///BtoC or BtoBtoC
            if([names isEqualToString:@""]){
                ///No user name
                if ([CCConstants sharedInstance].isAgent == YES){
                    ChannelDisplayNames = CCLocalizedString(@"Guest");
                }else{
                    ChannelDisplayNames = orgName;
                }
            }else{
                ///Display names of chat members
                if ([CCConstants sharedInstance].isAgent == YES){
                    if (displayName == nil) {
                        ChannelDisplayNames = CCLocalizedString(@"Guest");
                    } else {
                        ChannelDisplayNames = displayName[@"admin"];
                    }
                }else{
                    if (displayName == nil) {
                        ChannelDisplayNames = orgName;
                    } else {
                        ChannelDisplayNames = displayName[@"guest"];
                    }
                }
            }
        }
        ///create avatar image if no avatar yet(Agent isn't assigned yet)
        if (iconImage == nil) {
            NSString *firstCharacter = [ChannelDisplayNames substringToIndex:1];
            UIColor *randomColor;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"channelUid", channelId];
            NSDictionary *resultDic = [[[[ChatCenter sharedInstance] channelColorList] filteredArrayUsingPredicate:predicate] firstObject];
            if (resultDic != nil) { ///Already has random color
                randomColor = resultDic[@"randomColor"];
            }else{ ///Create new random color
                randomColor = [[ChatCenter sharedInstance] getRandomColor:nil];
                NSDictionary *channelColor = @{@"channelUid":channelId, @"randomColor":randomColor};
                [[[ChatCenter sharedInstance] channelColorList] addObject:channelColor];
            }
            ///channelColorList
            iconImage = [[ChatCenter sharedInstance] createAvatarImage:firstCharacter
                                                                 width:CCRandomCircleAvatarSize
                                                                height:CCRandomCircleAvatarSize
                                                                 color:randomColor
                                                              fontSize:CCRandomCircleAvatarFontSize
                                                            textOffset:CCRandomCircleAvatarTextOffset];
        }
        NSNumber *admin = [[NSNumber alloc] initWithInt:0];
        NSString *messageType = @"";
        if ([object valueForKey:@"latest_message"] != nil && [object valueForKey:@"latest_message"] != [NSNull null]) {
            NSData *latestMessageData   = [object valueForKey:@"latest_message"];
            NSDictionary *latestMessage = [NSKeyedUnarchiver unarchiveObjectWithData:latestMessageData];
            if([latestMessage valueForKey:@"type"] != nil && [latestMessage valueForKey:@"type"] != [NSNull null]) {
                messageType = [latestMessage valueForKey:@"type"];
            }
            NSDictionary *content;
            if([latestMessage valueForKey:@"content"] != nil && [latestMessage valueForKey:@"content"] != [NSNull null]) {
                content = [latestMessage valueForKey:@"content"];
            }
            NSDictionary *sender;
            if([latestMessage valueForKey:@"user"] != nil && [latestMessage valueForKey:@"user"] != [NSNull null]) {
                sender = [latestMessage valueForKey:@"user"];
            }
            if([sender valueForKey:@"id"] != nil && [sender valueForKey:@"id"] != [NSNull null]) {
                senderId = [sender valueForKey:@"id"];
            }
            if([sender valueForKey:@"display_name"] != nil && [sender valueForKey:@"display_name"] != [NSNull null]) {
                senderName = [sender valueForKey:@"display_name"];
            }
            if([sender valueForKey:@"admin"] != nil && [sender valueForKey:@"admin"] != [NSNull null]) {
                admin = ([sender valueForKey:@"admin"] != nil) ? [sender valueForKey:@"admin"] : 0 ;
            }
            NSDictionary *caller;
            if([content valueForKey:@"caller"] != nil && [content valueForKey:@"caller"] != [NSNull null]) {
                caller = [content valueForKey:@"caller"];
            }
            if([caller valueForKey:@"caller_id"] != nil && [caller valueForKey:@"caller_id"] != [NSNull null]) {
                callerId = [caller valueForKey:@"caller_id"];
            }
            if(callerId != nil) {
                for (NSDictionary *callerInChannels in users) {
                    if([callerId integerValue] == [[callerInChannels valueForKey:@"id"] integerValue]) {
                        callerName = [callerInChannels valueForKey:@"display_name"];
                    }
                }
            }
            if (messageType != nil) {
                if (([messageType isEqualToString:CC_RESPONSETYPEMESSAGE] || [messageType isEqualToString:CC_RESPONSETYPEUNEXPECTED]) && content[@"text"] != nil) {
                    message = content[@"text"];
                }else if([messageType isEqualToString:CC_RESPONSETYPEIMAGE]){
                    message = CCLocalizedString(@"Sent an image.");
                }else if([messageType isEqualToString:CC_RESPONSETYPEPDF]){
                    message = CCLocalizedString(@"Sent a PDF.");
                }else if([messageType isEqualToString:CC_RESPONSETYPEDATETIMEAVAILABILITY]){
                    message = CCLocalizedString(@"Sent a sticker.");
                }else if([messageType isEqualToString:CC_RESPONSETYPELOCATION]){
                    message = CCLocalizedString(@"Sent a location.");
                }else if([messageType isEqualToString:CC_RESPONSETYPETHUMB]){
                    message = CCLocalizedString(@"Sent a sticker.");
                }else if([messageType isEqualToString:CC_RESPONSETYPEQUESTION]){
                    message = CCLocalizedString(@"Sent a question sticker.");
                }else if([messageType isEqualToString:CC_RESPONSETYPEINFORMATION]){
                    message = CCLocalizedString(@"Sent an inquiry.");
                }else if([messageType isEqualToString:CC_RESPONSETYPESTICKER]){
                    message = CCLocalizedString(@"Sent a sticker.");
                }else if([messageType isEqualToString:CC_RESPONSETYPERESPONSE]){
                    message = CCLocalizedString(@"XXX");
                }else if([messageType isEqualToString:CC_RESPONSETYPEPROPERTY]){
                    message = CCLocalizedString(@"Sent an inquiry.");
                } else if([messageType isEqualToString:CC_RESPONSETYPECALL]) {
                    message = CCLocalizedString(@"Called");
                }
            }
        }
        
        self.ChannelTotalUnreadMessageNum += [unreadMessageNum intValue];
        
        [self.ChatChannelIds addObject:channelId];
        if (uid == nil) uid = (NSNumber *)[NSNull null];
        if (iconImageUrl == nil) iconImageUrl  = (NSString *)[NSNull null];
        if (senderId == nil) senderId = (NSNumber *)[NSNull null];
        if (senderName == nil) senderName = @"";
        if(messageType == nil) messageType = @"";
        NSDictionary *channelLabel = @{@"uid":uid,
                                       @"channelId":channelId,
                                       @"title":ChannelDisplayNames,
                                       @"lastUpdatedAt":lastUpdatedAt,
                                       @"message":message,
                                       @"status":status,
                                       @"iconImage":iconImage,
                                       @"iconImageUrl":iconImageUrl,
                                       @"unreadMessageNum":unreadMessageNum,
                                       @"senderId":senderId,
                                       @"senderName":senderName,
                                       @"messageType":messageType,
                                       @"canUseVideoChat":usersVideoChat,
                                       @"admin":admin};
        [self.ChannelLabels addObject:channelLabel];
    }

    navigationTitleView.title = navigationTitle;
    cellForRowAtIndexPathTime = [NSDate date];
    [self.tableView reloadData];
    
    ///scrolling to the point where the loading occured
    if (lastUpdatedAt != nil && channelArray.count > 0) {
        if (startIndex + 1 < self.ChannelLabels.count) startIndex++; ///if there are new channel, scroll in advance
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:startIndex inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES && self.chatAndHistoryViewController.chatViewController != nil) {
        UITableViewCell *previousCell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
        previousCell.backgroundColor = [CCConstants defaultHistoryCellBackgroundColor];
        NSIndexPath *indexPath;
        NSUInteger index = [[self.ChannelLabels valueForKey:@"channelId"] indexOfObject:self.chatAndHistoryViewController.chatViewController.channelId];
        indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.backgroundColor = [[CCConstants sharedInstance] historySelectedCellBackgroundColor];
        selectedIndexPath = indexPath;
    }
    _isLoadingMore = FALSE;
}

- (NSString *)processLastMessageWithSenderId:(NSNumber *)senderId
                                  senderName:(NSString *)senderName
                             originalMessage:(NSString *)message {
    NSNumber *currentUserId = [[NSUserDefaults standardUserDefaults] valueForKey:kCCUserDefaults_userId];
    NSLog(@"*** current user: %d - sender: %d", currentUserId.intValue, senderId.intValue);
    if(currentUserId.intValue != senderId.intValue) { // If current user != sender of last message, display name of sender
        // escape space character in English version
        NSString *name = [[NSString stringWithFormat:@"%@%@", senderName, CCLocalizedString(@"Other")] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return [NSString stringWithFormat:@"%@: %@", name, message];
    } else { // else display "You" in English version and "あなた" in Japanese version
        return [NSString stringWithFormat:@"%@: %@", CCLocalizedString(@"You"), message];
    }
}

- (void) removeChannelAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    if (self.ChannelLabels.count > index) {
        [self.ChannelLabels removeObjectAtIndex:index];
    }
    if (self.ChannelDisplayNames.count > index) {
        [self.ChannelDisplayNames removeObjectAtIndex:index];
    }
    if (self.ChatChannelIds.count > index) {
        [self.ChatChannelIds removeObjectAtIndex:index];
    }
    [self.tableView reloadData];
}

- (void) loadChannelsByChannelName:(NSString *) channelName lastUpdatedAt:(NSDate *)lastUpdatedAt  {
    NSString *orgUid;
    if ([CCConstants sharedInstance].isAgent == YES) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"] == nil) return;
        orgUid = [ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"];
    }else{
        orgUid = nil;
    }
    lastSeachText = channelName;
    BOOL showProgress = NO;
    if (lastUpdatedAt == nil) {
        showProgress = YES;
    }
    [[CCConnectionHelper sharedClient] loadChannels:YES orgUid:orgUid channelName:channelName limit:CCloadChannelFirstLimit lastUpdatedAt:lastUpdatedAt completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task) {
        [self.refreshControl endRefreshing];
        if (result != nil) {
            [self loadLocalChannles:NO lastUpdatedAt:lastUpdatedAt];
        }
    }];
}

#pragma mark - Actions
-(void)pressSwitchApp{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [ud stringForKey:@"deviceToken"];
    [[ChatCenter sharedInstance] registerDeviceToken:deviceToken completionHandler:^(NSDictionary *result, NSError *error){
        [[CCConnectionHelper sharedClient] refreshData];
    }];
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES){
        [_chatAndHistoryViewController switchApp];
    }
    
    navigationTitle = @"";
    navigationTitleView.title = navigationTitle;
    self.chatAndHistoryViewController.navigationItem.rightBarButtonItems = nil;
    [self.ChatChannelIds removeAllObjects];
    [_tableView reloadData];
}

-(void)pressSwitchOrg{
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES){
        [_chatAndHistoryViewController switchOrg];
    }
    // Refresh title search label.
    self.chatAndHistoryViewController.navigationItem.rightBarButtonItems = nil;
    [navigationTitleView updateSearchLabel];
}

-(void)pressLogout{
    if (self.closeHistoryViewCallback != nil) {
        self.closeHistoryViewCallback();
    }
}

-(void)pressSetting{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter" bundle:SDK_BUNDLE];
    CCSettingViewController *settingViewController = [storyboard  instantiateViewControllerWithIdentifier:@"CCSettingViewController"];
    CCNavigationController *navChatViewController = [[CCNavigationController alloc] initWithRootViewController:settingViewController];
    navChatViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:navChatViewController animated:YES completion:nil];
}

-(void)pressBack:(id)sender {
    [self removeNavigationBottomBorder];
    [self.navigationController popViewControllerAnimated:YES];
    [[CCConnectionHelper sharedClient] setDelegate:nil];
    [[CCConnectionHelper sharedClient] setCurrentView:nil];
}

-(void)pressClose:(id)sender {
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
        [self.chatAndHistoryViewController close];
    }else{
        [self removeNavigationBottomBorder];
        self.parentViewController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
        [self dismissViewControllerAnimated:YES completion:self.closeHistoryViewCallback];
        [[CCConnectionHelper sharedClient] setCurrentView:nil];
        [[CCConnectionHelper sharedClient] setDelegate:nil];
    }
}

-(void)pressMenu:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter" bundle:SDK_BUNDLE];
    CCModalListViewController *modalLitView = [storyboard  instantiateViewControllerWithIdentifier:@"CCModalListViewController"];;
    modalLitView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    modalLitView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [modalLitView setDidTapAboutCallback:^{
        [self pressSetting];
    }];
    [modalLitView setDidTapLogoutCallback:^{
        [self pressLogout];
    }];
    [modalLitView setDidTapSwitchAppCallback:^{
        [self initInputSearchBar];
        [self pressSwitchApp];
    }];
    [modalLitView setDidTapSwitchOrgCallback:^{
        [self initInputSearchBar];
        [self pressSwitchOrg];
    }];
    
    [self presentViewController:modalLitView animated:YES completion:nil];
}

-(void)pressInfo:(id)sender {
    self.isReturnFromRightMenuView = YES;
    self.chatAndHistoryViewController.chatViewController.isReturnFromRightMenuView = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter" bundle:SDK_BUNDLE];
    CCChannelDetailViewController *channelInfoView = [storyboard  instantiateViewControllerWithIdentifier:@"channelDetailViewController"];;
    channelInfoView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    channelInfoView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    channelInfoView.channelId = self.chatAndHistoryViewController.chatViewController.channelId;
    channelInfoView.orgUid = self.chatAndHistoryViewController.chatViewController.orgUid;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:channelInfoView animated:YES];
}

-(void)pressVideoCall {
    if(self.chatAndHistoryViewController.chatViewController != nil) {
        [self.chatAndHistoryViewController.chatViewController pressVideoCall];
    }
}

-(void)pressVoiceCall {
    if(self.chatAndHistoryViewController.chatViewController != nil) {
        [self.chatAndHistoryViewController.chatViewController pressVoiceCall];
    }
}

- (IBAction)closeModalDialog:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshOccured:(id)sender
{
    
    if ([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable || CCLocalDevelopmentMode) {
        [self.refreshControl beginRefreshing];
        
        if ([CCConstants sharedInstance].isAgent== YES) {
            NSString *inputText = [self->searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (inputText.length > 0) {
                [self loadChannelsByChannelName:inputText lastUpdatedAt:nil];
            } else {
                [self reloadOrgsAndChannelsAndConnectWebSocket];
            }
        }else{
            [self reloadChannelsAndConnectWebSocket];
        }
    }else{
        [CCSVProgressHUD dismiss];
        [self.refreshControl endRefreshing];
        [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
    }
}

-(void)reloadChannelsAndConnectWebSocket{
    if ([CCConstants sharedInstance].isAgent == YES) {
        NSString *inputText = [self->searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (inputText.length > 0) {
                return;
        }
    }
    
    [[CCConnectionHelper sharedClient] loadChannelsAndConnectWebSocket:NO getChennelType:CCGetChannelsMine isOrgChange:NO org_uid:nil completionHandler:^(NSString *result,  NSError *error, NSURLSessionDataTask *operation) {
        if (result != nil) {
            [self.refreshControl endRefreshing];
            [self loadLocalChannles:NO lastUpdatedAt:nil];
            [self.tableView reloadData];
        }else{
            [self.refreshControl endRefreshing];
            if ([[CCConnectionHelper sharedClient] isAuthenticationError:operation] == YES){
                [[CCConnectionHelper sharedClient] displayAuthenticationErrorAlert];
            }else{
                [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
            }
        }
    }];
}

-(void)reloadOrgsAndChannelsAndConnectWebSocket{
    [[CCConnectionHelper sharedClient] loadOrgsAndChannelsAndConnectWebSocket:NO getChennelType:CCGetChannels isOrgChange:NO completionHandler:^(NSString *result, NSError *error, NSURLSessionDataTask *operation) {
        [CCSVProgressHUD dismiss];
        if (result != nil) {
            [self.refreshControl endRefreshing];
            [self loadLocalChannles:NO lastUpdatedAt:nil];
            [self.tableView reloadData];
            [self.detailViewController loadLocalData:NO];
        }else{
            if ([[CCConnectionHelper sharedClient] isAuthenticationError:operation] == YES){
                [[CCConnectionHelper sharedClient] displayAuthenticationErrorAlert];
            }
        }
    }];
}

- (void) loadChannels:(int)getChannelsType
               orgUid:(NSString *)orgUid
        lastUpdatedAt:(NSDate *)lastUpdatedAt{
    [[CCConnectionHelper sharedClient] loadChannels:NO
                                     getChennelType:getChannelsType
                                            org_uid:orgUid
                                              limit:CCloadChannelFirstLimit
                                      lastUpdatedAt:lastUpdatedAt
                                  completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *operation)
    {
        if (result != nil) {
            NSLog(@"loadChannels success!");
            [self loadLocalChannles:NO lastUpdatedAt:lastUpdatedAt];
        }else{
            if ([[CCConnectionHelper sharedClient] isAuthenticationError:operation] == YES){
                [[CCConnectionHelper sharedClient] displayAuthenticationErrorAlert];
            }
            NSLog(@"loadChannels failed!");
        }
    }];
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
                                providerRefreshToken:nil
                                   providerCreatedAt:providerCreatedAtDate
                                   providerExpiresAt:providerExpiresAtDate
                                         deviceToken:nil
                                        showProgress:YES
                                   completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *operation) {
        if (result != nil) {
            [[CCConnectionHelper sharedClient] refreshData];
        }else{
            if ([[CCConnectionHelper sharedClient] isAuthenticationError:operation] == YES) {
                [[CCConnectionHelper sharedClient] displayAuthenticationErrorAlert];
            }else{
                if ([[CCConnectionHelper sharedClient] isAuthenticationErrorWithEmptyuser:operation] == NO){
                    [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
                }
            }
        }
    }];
}

- (void)didTapDeleteButton
{
    if (!_tableView.editing) return;
    
    NSArray* selectList = [_tableView indexPathsForSelectedRows];
    
    if (selectList == 0) {
        [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Please select chat")
                                               message:nil
                                             alertType:SingleButtonAlert];
        return;
    }
    
    NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
    NSMutableArray *channelUids = [NSMutableArray new];
    for (NSIndexPath* indexPath in selectList)
    {
        [indicesOfItemsToDelete addIndex:indexPath.row];
        [channelUids addObject:[self.ChatChannelIds objectAtIndex:indexPath.row]];
    }
    if ([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable || CCLocalDevelopmentMode) {
        [[CCConnectionHelper sharedClient] closeChannels:channelUids completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *operation) { ///TODO: Use nwe API when the API is ready
            if (result != nil) {
                ///change status o channel in coredata
                for (NSString* channelUid in channelUids)
                {
                    [[CCCoredataBase sharedClient] updateChannelUpdateAtAndStatusWithUid:channelUid updateAt:[NSDate date] status:@"closed"];
                    ///Clear Unread Message
                    [[ChatCenter sharedInstance] clearUnreadMessage:channelUid];
                }
                ///delete dataSource
                [self.ChannelLabels removeObjectsAtIndexes:indicesOfItemsToDelete];
                [self.ChatChannelIds removeObjectsAtIndexes:indicesOfItemsToDelete];
                ///remove cell
                [_tableView deleteRowsAtIndexPaths:selectList withRowAnimation:UITableViewRowAnimationFade];
            }else{
                [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
            }
        }];
    }else{
        [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
    }
}

- (void)didTapEditButton
{
    [_tableView setEditing:!_tableView.editing animated:YES];
    if (_tableView.editing) {
        self.navigationItem.leftBarButtonItem = self.deleteButton;
        self.navigationItem.rightBarButtonItem.title = CCLocalizedString(@"Cancel");
        self.tableView.alwaysBounceVertical = NO;
    } else {
        if (self.closeButton != nil) {
            self.navigationItem.leftBarButtonItem = self.closeButton;
        }else{
            self.navigationItem.leftBarButtonItem = nil;
        }
        self.navigationItem.rightBarButtonItem.title = CCLocalizedString(@"Edit");
        self.tableView.alwaysBounceVertical = YES;
    }
}

- (void)didTapCreateChannelBtn{
    NSLog(@"didTapCreateChannelBtn");
    Class class = NSClassFromString(@"UIAlertController");
    if(class){
        UIAlertController *actionSheet = nil;
        actionSheet = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Create a chat")
                                                          message:nil
                                                   preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"Direct Message")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action){
                                                          [self displayContactPicker:YES];
                                                      }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"Group")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action){
                                                          [self displayContactPicker:NO];
                                                      }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel")
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
        ///Use UIPopoverPresentationController to prevent crash in iPad
        ///https://stackoverflow.com/questions/25644054/uiactivityviewcontroller-crashing-on-ios8-ipads
        actionSheet.modalPresentationStyle = UIModalPresentationPopover;
        UIPopoverPresentationController *pop = actionSheet.popoverPresentationController;
        pop.sourceView = self.view;
        pop.sourceRect = self.view.bounds;
        [self presentViewController:actionSheet
                           animated:YES
                         completion:nil];
    }else{
        UIActionSheet *as = [[UIActionSheet alloc] init];
        as.delegate = self;
        as.title = CCLocalizedString(@"Create a chat");
        [as addButtonWithTitle:CCLocalizedString(@"Direct Message")];
        [as addButtonWithTitle:CCLocalizedString(@"Group")];
        [as addButtonWithTitle:CCLocalizedString(@"Cancel")];
        as.cancelButtonIndex = 2;
        [as showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self displayContactPicker:YES];
            break;
        case 1:
            [self displayContactPicker:NO];
            break;
        default:
            break;
    }
}

- (void)displayContactPicker:(BOOL)isDirectMessage
{
    CCContactPickerViewController *contactPicker = [[CCContactPickerViewController alloc] init];
    contactPicker.isDirectMessage = isDirectMessage;
    [contactPicker setCloseContactPickerViewCallback:^(NSString *channelId) {
        if (channelId != nil) {
            [self loadLocalChannles:NO lastUpdatedAt:nil];
            CCChatViewController *chatView = [[CCChatViewController alloc] init];
            [chatView setChannelId:channelId];
            [self.navigationController pushViewController:chatView animated:YES];
        }
    }];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contactPicker];
    [self presentViewController:navigationController animated:YES completion:nil];
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

- (void)didTapOverlayView{
    [self.view endEditing:YES];
}

#pragma mark - Keyboard Control For MenuBar

-(void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    CGFloat offsetY = CGRectGetMaxY(_tableView.frame) - CGRectGetMinY(keyboardRect);
    
    UIEdgeInsets contentInsets;
    contentInsets = _tableView.contentInset;
    _tableView.contentInset = UIEdgeInsetsMake(contentInsets.top, contentInsets.left, offsetY, contentInsets.right);
    contentInsets = _tableView.scrollIndicatorInsets;
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(contentInsets.top, contentInsets.left, offsetY, contentInsets.right);
}

- (BOOL)keyboardWillHide:(NSNotification*)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    UIEdgeInsets contentInsets;
    contentInsets = _tableView.contentInset;
    _tableView.contentInset = UIEdgeInsetsMake(contentInsets.top, contentInsets.left, 0, contentInsets.right);
    contentInsets = _tableView.scrollIndicatorInsets;
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(contentInsets.top, contentInsets.left, 0, contentInsets.right);
    
    [UIView commitAnimations];
    return YES;
}

#pragma mark - CCHistoryFilterViewController delegate.

- (void)pressFilterButton {
    if (newMessageView != nil) {
        [newMessageView removeFromSuperview];
    }
    
    [navigationTitleView updateSearchLabel];
    
    // Update channel type
    NSArray *messageStatus = [CCUserDefaultsUtil filterMessageStatus];
    if (messageStatus.count > 0) {
        for (NSString *status in messageStatus) {
            if ([status isEqualToString:CCHistoryFilterMessagesStatusTypeAll] || [status isEqualToString:CCHistoryFilterMessagesStatusTypeUnassigned] || [status isEqualToString:CCHistoryFilterMessagesStatusTypeAssignedToMe]) {
                self.channelType = CCAllChannel;
                break;
            }
            if ([status isEqualToString:CCHistoryFilterMessagesStatusTypeClosed]) {
                self.channelType = CCArchivedChannel;
                break;
            }
        }
    }
    
    [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading...")];
    
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
        [_chatAndHistoryViewController displayVoidViewController];
    }
    
    // Refresh.
    [self refreshOccured:nil];
}

#pragma mark - CCHistoryNavigationTitleView delegate.

- (void)pressNavigationTitleButton:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([CCHistoryFilterViewController class]) bundle:SDK_BUNDLE];
    CCHistoryFilterViewController *vc = [storyboard instantiateInitialViewController];
    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)showNewMessageButton:(NSString *)messageType
                        uid:(NSNumber *)uid
                    content:(NSDictionary *)content
                  channelId:(NSString *)channelId
                    userUid:(NSString *)userUid
                       date:(NSDate *)date
                displayName:(NSString *)displayName
                userIconUrl:(NSString *)userIconUrl
                  userAdmin:(BOOL)userAdmin
                     answer:(NSDictionary *)answer {
    CCJSQMessage *newMsg = [[CCJSQMessage messageObjectsOfType:messageType uid:uid content:content usersReadMessage:nil fromSender:userUid onDate:date displayName:displayName userIconUrl:userIconUrl userAdmin:userAdmin answer:answer status:CC_MESSAGE_STATUS_SEND_SUCCESS] objectAtIndex:0];
    
    NSString *buttonTitle;
    if([messageType isEqualToString:CC_RESPONSETYPEMESSAGE]){
        buttonTitle = newMsg.text;
    }
    else if ([messageType isEqualToString:CC_RESPONSETYPESTICKER]){
        buttonTitle = [NSString stringWithFormat:@"%@:%@", newMsg.senderDisplayName, CCLocalizedString(@"Sent a sticker")];
    }
    else if([messageType isEqualToString:CC_RESPONSETYPECALL]){
        buttonTitle = [NSString stringWithFormat:@"%@:%@", newMsg.senderDisplayName, CCLocalizedString(@"Missed call")];
    } else if ([messageType isEqualToString:CC_RESPONSETYPESUGGESTION]) {
        buttonTitle = CCLocalizedString(@"New suggestion");
    }
    if(buttonTitle != nil) {
        [self displayNotification:buttonTitle];
    }
}

-(void)displayNotification:(NSString *)message {
    [newMessageView removeFromSuperview];
    NSUInteger paddingMessageLabel = 10.0f;
    NSUInteger paddingMessageImage = 10.0f;
    NSInteger imageSize = 12.0f;
    NSUInteger MAX_WITH_MESSAGE = 165.0f;

    NSDictionary *messageStringAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12.0f]};
    NSMutableAttributedString *messageAttributedString = [[NSMutableAttributedString alloc] initWithString:message attributes:messageStringAttributes];
    NSUInteger messageWidth = messageAttributedString.size.width;
    messageWidth = MIN(messageWidth, MAX_WITH_MESSAGE);
    newMessageView = [[UIView alloc] initWithFrame: CGRectMake ( 0, searchBar.frame.origin.y + searchBar.frame.size.height,paddingMessageLabel + messageWidth + paddingMessageImage * 2 + imageSize, imageSize + paddingMessageImage * 2)];
    newMessageView.backgroundColor = [UIColor colorWithRed:132.0f/255.0f
                                                     green:132.0f/255.0f
                                                      blue:132.0f/255.0f
                                                     alpha:1.0f];
    // Create border (bot-left and bot-right)
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:newMessageView.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = newMessageView.bounds;
    maskLayer.path  = maskPath.CGPath;
    newMessageView.layer.mask = maskLayer;
    // Create button title label
    UILabel *buttonTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(paddingMessageLabel, 0, paddingMessageLabel + messageWidth, imageSize + paddingMessageImage * 2)];
    buttonTitleLabel.text = message;
    buttonTitleLabel.font= [UIFont systemFontOfSize:12.0f];
    buttonTitleLabel.textColor=[UIColor whiteColor];
    buttonTitleLabel.backgroundColor=[UIColor clearColor];
    [newMessageView addSubview:buttonTitleLabel];
    // Create icon button
    UIButton *checkmarkButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *btnImage = [[UIImage alloc] initWithCGImage: [UIImage SDKImageNamed:@"CCarrow-down"].CGImage
                                                   scale: 1.0
                                             orientation: UIImageOrientationDown];
    [checkmarkButton setImage:btnImage forState:UIControlStateNormal];
    checkmarkButton.tintColor = [UIColor whiteColor];
    UIImageView *imageNewMessageView = [[UIImageView alloc] init];
    checkmarkButton.frame = CGRectMake(paddingMessageLabel + messageWidth + paddingMessageImage, paddingMessageImage, imageSize, imageSize);
    checkmarkButton.layer.cornerRadius = checkmarkButton.frame.size.height/2;
    [imageNewMessageView addSubview:checkmarkButton];
    [newMessageView addSubview:imageNewMessageView];
    // Add new message view to super view
    newMessageView.center = CGPointMake(self.view.bounds.size.width / 2, 64 + searchBar.frame.size.height + newMessageView.bounds.size.height/2);
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToTop)];
    [newMessageView addGestureRecognizer:tapGesture];
    [self.view addSubview:newMessageView];
    [self.view bringSubviewToFront:newMessageView];
    if ([self.view.subviews containsObject:blurEffectView]) {
        [self.view bringSubviewToFront:blurEffectView];
    }
}

-(void) scrollToTop {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [newMessageView removeFromSuperview];
}

#pragma mark - SearchBar delegate.

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.view addSubview:blurEffectView];
    [self.view bringSubviewToFront:blurEffectView];
}

- (void)searchBar:(UISearchBar *)bar textDidChange:(NSString *)searchText {
    NSString *inputText = self->searchBar.text;
    if (inputText.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
            [bar endEditing:YES];
        });
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [blurEffectView removeFromSuperview];
    NSString *inputText = [self->searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (inputText == nil || [inputText isEqual:[NSNull null]] || [inputText isEqualToString:@""]) {
        if (lastSeachText == nil || [lastSeachText isEqual:[NSNull null]] || [lastSeachText isEqualToString:@""]) {
            return;
        } else {
            int getChannelsType;
            NSString *orgUid;
            if ([CCConstants sharedInstance].isAgent == YES) {
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                if ([ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"] == nil) return;
                getChannelsType = CCGetChannels;
                orgUid = [ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"];
            }else{
                getChannelsType = CCGetChannelsMine;
                orgUid = nil;
            }
            lastSeachText = @"";
            [self initChatData];
            [self loadChannels:getChannelsType orgUid:orgUid lastUpdatedAt:nil];
        }
    } else {
        if (![inputText isEqualToString:lastSeachText]) {
            [self loadChannelsByChannelName:inputText lastUpdatedAt:nil];
        }
    }
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
}

@end
