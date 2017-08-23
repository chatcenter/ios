//
//  CCChannelDetailViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 7/1/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCChannelDetailViewController.h"
#import "CCChannelViewerCollectionViewCell.h"
#import "CCAssignAssigneeViewController.h"
#import "CCAssignFollowerViewController.h"
#import "CCAboutChatCenterViewController.h"
#import "CCConnectionHelper.h"
#import "ChatCenterPrivate.h"
#import "CCConstants.h"
#import "CCCoredataBase.h"
#import <SafariServices/SafariServices.h>
#import "CCNoteEditorViewController.h"
#import "CCStickerWidgetViewController.h"
#import "UIView+CCToast.h"
#import "UIImageView+CCWebCache.h"
#import "UIImage+CCSDKImage.h"
#import "CCSVProgressHUD.h"

@interface CCChannelDetailViewController(){
    float circleAvatarSize;
    float randomCircleAvatarFontSize;
    float randomCircleAvatarTextOffset;
    NSArray *channelRoles;
}
@end

@implementation CCChannelDetailViewController

-(void)viewDidLoad {
    self.navigationItem.title = CCLocalizedString(@"Info");
    self.lbMenuAboutApp.text = CCLocalizedString(@"About ChatCenter.iO");
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAssigneeFollower:)];
    UIView *collectionViewBg = [[UIView alloc] initWithFrame:self.collectionView.bounds];
    self.collectionView.backgroundView = collectionViewBg;
    [self.collectionView.backgroundView addGestureRecognizer:tapGesture];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    
    ///
    /// Channel roles
    ///
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *privelege = [ud dictionaryForKey:kCCUserDefaults_privilege];
    if(privelege[@"channel"] != nil) {
        channelRoles = privelege[@"channel"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CCSVProgressHUD show];
    self.profileUser = nil;
    [self viewSetup];
    [self loadChannelInformation:self.channelId];
    if ([CCConstants sharedInstance].headerItemColor != nil) {
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [[CCConstants sharedInstance] headerItemColor]};
    }else{
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:41/255.0 green:59/255.0 blue:84/255.0 alpha:1.0]};
    }
}

#pragma mark - Update view information
-(void)viewSetup {
    // Update menu title
    self.assigneeNotFound.hidden = true;
    self.followerNotFound.hidden = true;
    circleAvatarSize = 48.0f;
    randomCircleAvatarFontSize = circleAvatarSize*0.75;
    randomCircleAvatarTextOffset = 1.0f + (circleAvatarSize-24.0f)*0.0625;
    self.avatars = [[NSDictionary alloc] init];
    
    self.emailProfileInfo.textContainerInset = UIEdgeInsetsZero;
    self.emailProfileInfo.textContainer.lineFragmentPadding = 0;
    UITapGestureRecognizer *tapEmailGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMail:)];
    [self.emailProfileInfo addGestureRecognizer:tapEmailGesture];
    UITapGestureRecognizer *tapIconGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGuestInfor:)];
    [self.imageProfileTapAreaView addGestureRecognizer:tapIconGesture];
    
    
    //--------------------------------------------------------------------
    // Display custom back button
    //--------------------------------------------------------------------
    if ([CCConstants sharedInstance].backBtnNormal != nil
        || [CCConstants sharedInstance].backBtnHilighted != nil
        || [CCConstants sharedInstance].backBtnDisable != nil)
    {
        UIButton *leftButton = [self barButtonItemWithImageName:[CCConstants sharedInstance].backBtnNormal
                                   hilightedImageName:[CCConstants sharedInstance].backBtnHilighted
                                     disableImageName:[CCConstants sharedInstance].backBtnDisable
                                               target:self
                                             selector:@selector(pressBack:)];
        if ([CCConstants sharedInstance].headerItemColor != nil) {
            leftButton.tintColor = [[CCConstants sharedInstance] headerItemColor];
        }else{
            leftButton.tintColor = [UIColor colorWithRed:41/255.0 green:59/255.0 blue:84/255.0 alpha:1.0];
        }
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        self.navigationItem.backBarButtonItem = nil;
    } else {
        UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CCBackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(pressBack:)];
        self.navigationItem.leftBarButtonItem = closeBtn;
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

-(void) updateView {
    [self.tableView reloadData];
    if ([CCConstants sharedInstance].isAgent) {
        [self setupChannelProfileView: YES];
        
        // Agent
        if (self.assigneeInfo != nil) {
            [self setupAsigneeView:YES];
        } else {
            [self setupAsigneeView:NO];
        }
    } else {
        // Guest
        [self setupChannelProfileView:NO];
    }
    
    // funnel
    if (self.funnelInfo != nil) {
        self.funnelName.text = self.funnelInfo[@"name"];
    }
    
    if (self.channelInfo != nil) {
        NSString *channelStatus = self.channelInfo[@"status"];
        if (channelStatus != nil && [channelStatus isEqualToString:@"closed"]) {
            self.closeChannelLabel.text = CCLocalizedString(@"Open Conversation");
        } else {
            self.closeChannelLabel.text = CCLocalizedString(@"Close Conversation");
        }
    }
    
    if (self.channelUsers == nil || self.channelUsers.count == 0) {
        self.followerNotFound.hidden = false;
        self.collectionView.hidden = true;
    } else {
        self.followerNotFound.hidden = true;
        self.collectionView.hidden = false;
        [self.collectionView reloadData];
    }
}

-(void) setupChannelProfileView:(BOOL) isAgent {
    //
    // Guest
    //
    if (!isAgent) {
        if (self.assigneeInfo != nil) {
            BOOL shoudDisplaySocialIcon = NO;
            [self setupAvatar:self.assigneeInfo imageView:self.channelAvatar];
            self.channelName.text = self.profileUser[@"display_name"];
            self.emailHeightConstraint.constant = 19.0f;
            self.socalIconHeightConstraint.constant = 19.0f;
            self.socialIconTapAreaHeightConstraint.constant = 40.0f;

            ///
            /// Email
            ///
            if (self.profileUser[@"email"] != nil && ![self.profileUser[@"email"] isEqual:[NSNull null]] && ![self.profileUser[@"email"] isEqualToString:@""]) {
                self.emailProfileInfo.text = [self.profileUser[@"email"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [self.imageProfileInfor setUserInteractionEnabled:NO];
                [self.imageProfileTapAreaView setUserInteractionEnabled:YES];
                self.imageProfileInfor.image = [UIImage SDKImageNamed:@"CCicon-mail"];
                shoudDisplaySocialIcon = YES;
            }
            
            if (!shoudDisplaySocialIcon) {
                self.socalIconHeightConstraint.constant = 0;
                self.socialIconTapAreaHeightConstraint.constant = 0;
                self.emailHeightConstraint.constant = 0;
            }

            [self setupOnlineStatus:self.profileUser];
        } else {
            [self setOrgProfile:self.orgUid];
        }
        return;
    }
    //
    // Agent
    //
    if (self.guestUid != nil && isAgent) {
        [self setupAvatar:self.profileUser];
        if (self.profileUser[@"display_name"] != nil && ![self.profileUser[@"display_name"] isEqual:[NSNull null]]) {
            self.channelName.text = self.profileUser[@"display_name"];
        }
        BOOL shoudDisplaySocialIcon = NO;
        
        self.emailHeightConstraint.constant = 19.0f;
        self.socalIconHeightConstraint.constant = 19.0f;
        self.socialIconTapAreaHeightConstraint.constant = 40.0f;
        ///
        /// Email
        ///
        if (self.profileUser[@"email"] != nil && ![self.profileUser[@"email"] isEqual:[NSNull null]] && ![self.profileUser[@"email"] isEqualToString:@""]) {
            self.emailProfileInfo.text = [self.profileUser[@"email"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self.imageProfileInfor setUserInteractionEnabled:NO];
            [self.imageProfileTapAreaView setUserInteractionEnabled:YES];
            self.imageProfileInfor.image = [UIImage SDKImageNamed:@"CCicon-mail"];
            shoudDisplaySocialIcon = YES;
        }
        ///
        /// Facebook
        ///
        if(self.profileUser[@"facebook_id"] != nil && ![self.profileUser[@"facebook_id"] isEqual:[NSNull null]]) {
            self.imageProfileInfor.image = [UIImage SDKImageNamed:@"CCicon-facebook"];
            [self.imageProfileInfor setUserInteractionEnabled:YES];
            [self.imageProfileTapAreaView setUserInteractionEnabled:YES];
            self.emailHeightConstraint.constant = 0;
            shoudDisplaySocialIcon = YES;
        }
        ///
        /// Twitter
        ///
        if (self.profileUser[@"twitter_id"] != nil && ![self.profileUser[@"twitter_id"] isEqual:[NSNull null]]) {
            self.imageProfileInfor.image = [UIImage SDKImageNamed:@"CCicon-twitter"];
            [self.imageProfileInfor setUserInteractionEnabled:YES];
            [self.imageProfileTapAreaView setUserInteractionEnabled:YES];
            self.emailHeightConstraint.constant = 0;
            shoudDisplaySocialIcon = YES;
        }
        
        if (!shoudDisplaySocialIcon) {
            self.socalIconHeightConstraint.constant = 0;
            self.socialIconTapAreaHeightConstraint.constant = 0;
            self.emailHeightConstraint.constant = 0;
        }
        
        [self setupOnlineStatus:self.profileUser];
    } else {
        [self setOrgProfile:self.orgUid];
    }
}

-(void) setupAsigneeView:(BOOL)shouldDisplay {
    if (shouldDisplay) {
        self.assigneeAvatar.hidden = false;
        self.assigneeName.hidden = false;
        self.assigneeNotFound.hidden = true;
        [self setupAvatar:self.assigneeInfo imageView:self.assigneeAvatar];
        self.assigneeName.text = self.assigneeInfo[@"display_name"];
    } else {
        self.assigneeAvatar.hidden = true;
        self.assigneeName.hidden = true;
        self.assigneeNotFound.hidden = false;
    }
}

-(void) setupAvatar: (NSDictionary *) user{
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
                    UIImage *newIconImage = [[UIImage alloc] initWithData:dt scale:[UIScreen mainScreen].scale];
                    if (newIconImage != nil) {
                        self.channelAvatar.image = newIconImage;
                    }
                });
            });
        }
    } else {
        NSString *firstCharacter = [user[@"display_name"] substringToIndex:1];
        UIImage *textIconImage = [[ChatCenter sharedInstance] createAvatarImage:firstCharacter width:circleAvatarSize height:circleAvatarSize color:[[ChatCenter sharedInstance] getRandomColor:user[@"id"]] fontSize:randomCircleAvatarFontSize textOffset:randomCircleAvatarTextOffset];
        if (textIconImage != nil) {
            self.channelAvatar.image = textIconImage;
        }
    }
}

-(void) setOrgAvatar:(NSString *) orgId orgName:(NSString *) orgName {
    NSString *firstCharacter = [orgName substringToIndex:1];
    UIImage *textIconImage = [[ChatCenter sharedInstance] createAvatarImage:firstCharacter width:circleAvatarSize height:circleAvatarSize color:[[ChatCenter sharedInstance] getRandomColor:orgId] fontSize:randomCircleAvatarFontSize textOffset:randomCircleAvatarTextOffset];
    if (textIconImage != nil) {
        self.channelAvatar.image = textIconImage;
    }
}

-(void) setupOnlineStatus: (NSDictionary *) user {
    self.channelOnlineStatus.hidden = YES;
    if (user != nil) {
        if (user[@"online_at"] != nil && !([user[@"online_at"] isEqual:[NSNull null]])) {
            if([[user[@"online"] stringValue] isEqualToString:@"true"]) {
                self.channelOnlineStatus.hidden = NO;
                self.channelOnlineStatus.text =CCLocalizedString(@"Online");
            } else {
                long onlineAt = [user[@"online_at"] longValue];
                long offlineAt = 0;
                if (user[@"offline_at"] != nil && !([user[@"offline_at"] isEqual:[NSNull null]])) {
                    offlineAt = [user[@"offline_at"] longValue];
                }
                [self setOnlineStatus:onlineAt offlineAt:offlineAt];
            }
        } else {
            // Retry if missing information
            [[CCConnectionHelper sharedClient] loadUser:NO userUid:user[@"id"] completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
                if (result != nil) {
                    if (result[@"online_at"] != nil && !([result[@"online_at"] isEqual:[NSNull null]])) {
                        if([[result[@"online"] stringValue] isEqualToString:@"true"]) {
                            self.channelOnlineStatus.hidden = NO;
                            self.channelOnlineStatus.text =CCLocalizedString(@"Online");
                        } else {
                            long onlineAt = [result[@"online_at"] longValue];
                            long offlineAt = [result[@"offline_at"] longValue];
                            
                            [self setOnlineStatus:onlineAt offlineAt:offlineAt];
                        }
                    }
                }
            }];
        }
    } else {
        self.channelOnlineStatus.text =CCLocalizedString(@"Offline");
    }
}

-(void) setOnlineStatus: (long) onlineAt offlineAt: (long)offlineAt {
    if (onlineAt == 0) {
        self.channelOnlineStatus.hidden = YES;
        return;
    }
    self.channelOnlineStatus.hidden = NO;
    if(onlineAt > offlineAt) {
        self.channelOnlineStatus.text = CCLocalizedString(@"Online");
        return;
    }
    NSDate *offlineDate = [NSDate dateWithTimeIntervalSince1970:offlineAt];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear| NSCalendarUnitMonth| NSCalendarUnitDay| NSCalendarUnitHour| NSCalendarUnitMinute;
    NSDateComponents *dateComponent = [calendar components:calendarUnit fromDate:offlineDate toDate:now options:0];
    NSLog(@"Amount = %@", dateComponent);
    NSInteger year = dateComponent.year;
    NSInteger month = dateComponent.year * 12 + dateComponent.month;
    NSInteger day = dateComponent.day;
    NSInteger hour = dateComponent.hour;
    NSInteger minute = dateComponent.minute;
    if (year > 0) {
        if (year == 1) {
            self.channelOnlineStatus.text = [NSString stringWithFormat:CCLocalizedString(@"Online at %d %@ ago"), year, CCLocalizedString(@"year")];
        } else {
            self.channelOnlineStatus.text = [NSString stringWithFormat:CCLocalizedString(@"Online at %d %@ ago"), year, CCLocalizedString(@"years")];
        }
    } else if (month > 0) {
        if (month == 1) {
            self.channelOnlineStatus.text = [NSString stringWithFormat:CCLocalizedString(@"Online at %d %@ ago"), month, CCLocalizedString(@"month")];
        } else {
            self.channelOnlineStatus.text = [NSString stringWithFormat:CCLocalizedString(@"Online at %d %@ ago"), month, CCLocalizedString(@"months")];
        }
    } else if (day > 0) {
        if (day == 1) {
            self.channelOnlineStatus.text = [NSString stringWithFormat:CCLocalizedString(@"Online at %d %@ ago"), day, CCLocalizedString(@"day")];
        } else {
            self.channelOnlineStatus.text = [NSString stringWithFormat:CCLocalizedString(@"Online at %d %@ ago"), day, CCLocalizedString(@"days")];
        }
    } else if (hour > 0) {
        if (hour == 1) {
            self.channelOnlineStatus.text = [NSString stringWithFormat:CCLocalizedString(@"Online at %d %@ ago"), hour, CCLocalizedString(@"hour")];
        } else {
            self.channelOnlineStatus.text = [NSString stringWithFormat:CCLocalizedString(@"Online at %d %@ ago"), hour, CCLocalizedString(@"hours")];
        }
    } else if (minute >= 0) {
        if (minute == 0) {
            minute = 1;
        }
        if (minute == 1) {
            self.channelOnlineStatus.text = [NSString stringWithFormat:CCLocalizedString(@"Online at %d %@ ago"), minute, CCLocalizedString(@"minute")];
        } else {
            self.channelOnlineStatus.text = [NSString stringWithFormat:CCLocalizedString(@"Online at %d %@ ago"), minute, CCLocalizedString(@"minutes")];
        }
    }
}

#pragma mark - Tableview delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    if ([CCConstants sharedInstance].isAgent== NO) {
        if (section == CC_MENU_ASSIGNEE_SECTION || section == CC_MENU_VIEWERS_SECTION || section == CC_MENU_FUNNEL_SECTION || section == CC_MENU_NOTE_SECTION || section == CC_MENU_CLOSE_SECTION || section == CC_MENU_DELETE_SECTION) {
            return 0;
        }
        if (section == CC_MENU_PROFILE_SECTION) {
            return 105;
        }
    } else {
        if (section == CC_MENU_INFORMATION_SECTION) {
            return 0;
        }
    }
    
    // Hide directories, show it in future
    if (section == CC_MENU_DIRECTORIES_SECTION) {
        return 0;
    }
    
    // Hide close conversation
    if (section == CC_MENU_CLOSE_SECTION && !(channelRoles != nil && [channelRoles containsObject:@"close"])) {
        return 0;
    }
    
    // Hide delete conversation
    if (section == CC_MENU_DELETE_SECTION && !(channelRoles != nil && [channelRoles containsObject:@"destroy"]))
    {
        return 0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (section == CC_MENU_ASSIGNEE_SECTION) {
//        return CCLocalizedString(@"Assignee");
//    } else if (section == CC_MENU_VIEWERS_SECTION) {
//        return CCLocalizedString(@"Follower");
//    }else if (section == CC_MENU_INFORMATION_SECTION) {
//        return CCLocalizedString(@"Information");
//    }
//    return [super tableView:tableView titleForHeaderInSection:section];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    if (section == CC_MENU_ASSIGNEE_SECTION) {
        // Assign assignee
        [self pressAssignAsignee];
    } else if (section == CC_MENU_VIEWERS_SECTION){
        // Assign followers
        [self pressAssignFollower];
    } else if (section == CC_MENU_FUNNEL_SECTION) {
        [self pressSelectFunnel];
    } else if (section == CC_MENU_NOTE_SECTION) {
        [self pressNote];
    } else if (section == CC_MENU_CLOSE_SECTION) {
        [self pressCloseChannel];
    } else if (section == CC_MENU_DELETE_SECTION) {
        [self pressDeleteChannel];
    }else if (section == CC_MENU_FILE_WIDGET_SECTION) {
        NSString *title = CCLocalizedString(@"File");
        [self pressesWidgetSticker:CC_MENU_STICKER_TYPE_FILE_WIDGET title:title];
    } else if (section == CC_MENU_SCHEDULE_SECTION) {
        NSString *title = CCLocalizedString(@"Schedule");
        [self pressesWidgetSticker:CC_MENU_STICKER_TYPE_SCHEDULE title:title];
    } else if (section == CC_MENU_QUESTION_SECTION) {
        NSString *title = CCLocalizedString(@"Question");
        [self pressesWidgetSticker:CC_MENU_STICKER_TYPE_QUESTION title:title];
    } else if (section == CC_MENU_INFORMATION_SECTION && row == CC_MENU_ABOUTAPP_CELL) {
        // About chat center
        [self pressAbout];
    }
}

#pragma mark - Handle action
-(void) handleAssigneeFollower: (UITapGestureRecognizer *) recognizer {
    [self pressAssignFollower];
}

- (void) pressAssignAsignee {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter" bundle:SDK_BUNDLE];
    CCAssignAssigneeViewController *assignAssigneeView = [storyboard  instantiateViewControllerWithIdentifier:@"assignAssigneeViewController"];;
    assignAssigneeView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    assignAssigneeView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    assignAssigneeView.channelUid = self.channelId;
    assignAssigneeView.orgUid = self.orgUid;
    assignAssigneeView.followings = [self.channelUsers mutableCopy];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:assignAssigneeView animated:YES];
}

-(void) pressAssignFollower {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter" bundle:SDK_BUNDLE];
    CCAsignFollowerViewController *assignFollowerView = [storyboard  instantiateViewControllerWithIdentifier:@"assignFollowerViewController"];;
    assignFollowerView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    assignFollowerView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    assignFollowerView.channelUid = self.channelId;
    assignFollowerView.orgUid = self.orgUid;
    assignFollowerView.followings = [self.channelUsers mutableCopy];
    assignFollowerView.assigneeInfo = self.assigneeInfo;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:assignFollowerView animated:YES];
}

-(void) pressSelectFunnel {
    NSArray *funnels = [CCConstants sharedInstance].businessFunnels;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Select a funnel") message:nil preferredStyle:UIAlertControllerStyleAlert];
    BOOL shouldShowAlert = NO;
    for (NSDictionary *funnel in funnels) {
        if (funnel[@"id"] != nil && ![funnel[@"id"] isEqual:[NSNull null]]) {
            shouldShowAlert = YES;
            UIAlertAction *action = [UIAlertAction actionWithTitle:funnel[@"name"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[CCConnectionHelper sharedClient] setBusinessFunnelToChannel:self.channelId funnelId:funnel[@"id"] showProgress:NO completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
                    if (error == nil) {
                        [self loadChannelInformation:self.channelId];
                    }
                }];
            }];
            [alertVC addAction:action];
        }
    }
    if (shouldShowAlert) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            // Do nothing
        }];
        [alertVC addAction:cancelAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

-(void) pressNote {
    CCNoteEditorViewController *noteVC = [[CCNoteEditorViewController alloc] init];
    noteVC.channelId = self.channelId;
    noteVC.noteContent = self.note;
    [self.navigationController pushViewController:noteVC animated:YES];
}

-(void) pressesWidgetSticker: (NSString *) stickerType title: (NSString *) title {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter" bundle:SDK_BUNDLE];
    CCStickerWidgetViewController *stickerWidgetView = [storyboard  instantiateViewControllerWithIdentifier:@"stickerWidgetViewController"];
    stickerWidgetView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    stickerWidgetView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    stickerWidgetView.channelId = self.channelId;
    stickerWidgetView.stickerType = stickerType;
    stickerWidgetView.titleNavigation = title;
    stickerWidgetView.uid = self.uid;
    [self.navigationController pushViewController:stickerWidgetView animated:YES];
}

-(void) pressCloseChannel {
    NSString *channelStatus = self.channelInfo[@"status"];
    if (channelStatus != nil && [channelStatus isEqualToString:@"closed"]) {
        [[CCConnectionHelper sharedClient] openChannels:@[self.channelId] completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
            if (error == nil) {
                self.closeChannelLabel.text = CCLocalizedString(@"Close Conversation");
                NSString *saveImageString = CCLocalizedString(@"Conversation Opened");
                [[UIApplication sharedApplication].keyWindow makeToast:saveImageString duration:1.0f position:CSToastPositionCenter];
                [self loadChannelInformation:self.channelId];
            }
        }];
    } else {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:CCLocalizedString(@"チャットをクローズしますか？") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[CCConnectionHelper sharedClient] closeChannels:@[self.channelId] completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
                if (error == nil) {
                    self.closeChannelLabel.text = CCLocalizedString(@"Open Conversation");
                    NSString *saveImageString = CCLocalizedString(@"Conversation Closed");
                    [[UIApplication sharedApplication].keyWindow makeToast:saveImageString duration:1.0f position:CSToastPositionCenter];
                    [self loadChannelInformation:self.channelId];
                }
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:cancelAction];
        [alertVC addAction:okAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

-(void) pressDeleteChannel {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:CCLocalizedString(@"チャットを削除しますか？") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[CCConnectionHelper sharedClient] deleteChannel:self.channelId completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
            if (error == nil) {
                if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    NSMutableArray *viewControllers = [[self.navigationController viewControllers] mutableCopy];
                    [viewControllers removeLastObject];
                    [viewControllers removeLastObject];
                    [self.navigationController setViewControllers:viewControllers animated:YES];
                }
            }
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:okAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

-(void) pressAbout {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter" bundle:SDK_BUNDLE];
    CCAboutChatCenterViewController *aboutAppView = [storyboard  instantiateViewControllerWithIdentifier:@"AboutChatCenterViewController"];;
    aboutAppView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    aboutAppView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:aboutAppView animated:YES];
}

- (void)showGuestInfor:(UIGestureRecognizer*)gestureRecognizer {
    NSURL *url = nil;
    if (self.profileUser[@"facebook_url"] != nil && ![self.profileUser[@"facebook_url"] isEqual:[NSNull null]]) {
        url = [NSURL URLWithString:self.profileUser[@"facebook_url"]];
        [self openURL:url];
    } else if (self.profileUser[@"twitter_url"] != nil && ![self.profileUser[@"twitter_url"] isEqual:[NSNull null]]) {
        url = [NSURL URLWithString:self.profileUser[@"twitter_url"]];
        [self openURL:url];
    } else {
        if (self.profileUser[@"email"] != nil && ![self.profileUser[@"email"] isEqual:[NSNull null]]) {
            NSString *email = [self.profileUser[@"email"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *url = [@"mailto:" stringByAppendingString:email];
            [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
        }
    }
}

- (void)openMail:(UIGestureRecognizer*)gestureRecognizer {
    if (self.profileUser[@"email"] != nil && ![self.profileUser[@"email"] isEqual:[NSNull null]]) {
        NSString *email = [self.profileUser[@"email"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *url = [@"mailto:" stringByAppendingString:email];
        [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
    }
}

- (void)setOrgProfile:(NSString *)orgUid{
    NSLog(@"SetOrgProfile %@", orgUid);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSArray *agentArray = [[CCCoredataBase sharedClient] selectOrgWithUid:orgUid];
        if (agentArray != nil && agentArray.count > 0) {
            NSManagedObject *object = [agentArray objectAtIndex:0];
            NSString *orgId = [object valueForKey:@"uid"];
            NSString *orgName = [object valueForKey:@"name"];
            [self setOrgAvatar:orgId orgName:orgName];
            self.channelName.text = orgName;
            self.channelOnlineStatus.hidden = true;
        } else {
            [self setOrgAvatar:orgUid orgName:orgUid];
            self.channelName.text = orgUid;
            self.channelOnlineStatus.hidden = true;
        }
    }];
}

- (void)pressBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - viewers collection
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.channelUsers.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    CCChannelViewerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"viewerCollectionCell" forIndexPath:indexPath];
    [self setupAvatar:self.channelUsers[row] imageView:cell.viewerAvatar];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self pressAssignFollower];
}



#pragma mark - Load message
- (NSDictionary *) loadFunnelInformation:(int) funnelId {
    NSArray *funnels = [CCConstants sharedInstance].businessFunnels;
    for(NSDictionary *funnel in funnels) {
        if ([funnel[@"id"] intValue] == funnelId) {
            return funnel;
        }
    }
    return nil;
}

-(void)loadChannelInformation:(NSString *)channelId{
    if (![[CCConstants sharedInstance] getKeychainUid]) {
        [CCSVProgressHUD dismiss];
        return;
    }
    // Load channel
    [[CCConnectionHelper sharedClient] loadChannel:NO channelUid:self.channelId completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
        [CCSVProgressHUD dismiss];
        if(result != nil){
            self.channelInfo = result;
            // Funnel information
            if ([result valueForKey:@"funnel_id"] != nil && ![[result valueForKey:@"funnel_id"] isEqual:[NSNull null]]) {
                int funnelId = [[result valueForKey:@"funnel_id"] intValue];
                self.funnelInfo = [self loadFunnelInformation:funnelId];
            }
            
            // Note information
            self.note = nil;
            if ([result valueForKey:@"note"] != nil && ![[result valueForKey:@"note"] isEqual:[NSNull null]]) {
                self.note = [result valueForKey:@"note"][@"content"];
            }
            
            NSArray *users            = [result valueForKey:@"users"];
            NSDictionary *assignee    = [result valueForKey:@"assignee"];
            // Optimize data
            NSMutableArray  *optimizedUsers = [NSMutableArray array];
            for (int i = 0; i < users.count; i++) {
                if (![optimizedUsers containsObject:users[i]]) {
                    // Ignore guest and assignee
                    if ([users[i][@"admin"] intValue] == 1) {
                        // If assignee is assigned, ignore the assignee
                        if (assignee != nil) {
                            if ([assignee[@"id"] intValue] != [users[i][@"id"] intValue]) {
                                [optimizedUsers addObject:users[i]];
                            }
                        } else {
                            [optimizedUsers addObject:users[i]];
                        }
                    }
                }
            }
            self.channelUsers = [optimizedUsers mutableCopy];
            
            // Assignee
            self.assigneeInfo = assignee;
            ///
            /// For Guest
            ///
            if (assignee != nil) {
                if ([CCConstants sharedInstance].isAgent== NO) {
                    for (int i = 0; i < optimizedUsers.count; i++) {
                        if ([optimizedUsers[i][@"id"] intValue] == [self.assigneeInfo[@"id"] intValue]) {
                            self.profileUser = optimizedUsers[i];
                            [self setupAvatar:assignee imageView:self.channelAvatar];
                            [self updateView];
                        }
                    }
                    if (self.profileUser == nil) {
                        // Get full infor of assignee
                        [[CCConnectionHelper sharedClient] loadUser:NO userUid:self.assigneeInfo[@"id"] completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
                            if (result != nil) {
                                self.profileUser = result;
                                [self setupAvatar:assignee imageView:self.channelAvatar];
                                [self updateView];
                            }
                        }];
                    }
                } else {
                    [self setupAvatar:assignee imageView:self.assigneeAvatar];
                }
            }
            
            // Guest ID
            self.guestUid = nil;
            for (int i=0; i < users.count; i++) {
                if (![users[i][@"id"] isKindOfClass:[NSNumber class]]){
                    continue;
                }
                if ([[users[i][@"id"] stringValue] isEqualToString:[[CCConstants sharedInstance] getKeychainUid]]){
                    continue;
                }
                
                int isAdmin = [users[i][@"admin"] intValue];
                if (isAdmin == 0) {
                    // Guest id
                    self.guestUid = [users[i][@"id"] stringValue];
                    if ([CCConstants sharedInstance].isAgent== YES) {
                        self.profileUser = users[i];
                    }
                }
            }
            
            ///
            /// For Agent
            ///
            [self updateView];
        }
    }];
}

-(void)setupAvatar:(NSDictionary *)user imageView:(UIImageView *)imageView{
    NSString *firstCharacter = [user[@"display_name"] substringToIndex:1];
    UIImage *textImage = [[ChatCenter sharedInstance] createAvatarImage:firstCharacter width:32.0 height:32.0 color:[[ChatCenter sharedInstance] getRandomColor:user[@"id"]] fontSize:24 textOffset:1.5];
    if (textImage != nil) {
        imageView.image = textImage;
    }
    
    if (user[@"icon_url"] != nil && !([user[@"icon_url"] isEqual:[NSNull null]])) {
        if([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:user[@"icon_url"]]];
        }
    }
}

- (void)openURL:(NSURL *) URL{
    // Invalid URL
    if(!([URL.absoluteString hasPrefix:@"http://"] || [URL.absoluteString hasPrefix:@"https://"])) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:CCLocalizedString(@"Invalid URL") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:CCLocalizedString(@"OK")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(osVersion >= 9.0) {
        SFSafariViewController *webViewController = [[SFSafariViewController alloc] initWithURL:URL];
        if ([CCConstants sharedInstance].headerItemColor != nil) {
            webViewController.view.tintColor = [[CCConstants sharedInstance] headerItemColor];
        }else{
            webViewController.view.tintColor = [UIColor colorWithRed:41/255.0 green:59/255.0 blue:84/255.0 alpha:1.0];
        }
        [self presentViewController:webViewController animated:YES completion:nil];
        return;
    }
#endif
    [[UIApplication sharedApplication] openURL:URL];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self updateView];
}
@end
