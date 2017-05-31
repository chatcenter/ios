//
//  CCChannelDetailViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 7/4/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#define CC_MENU_PROFILE_SECTION             0
#define CC_MENU_ASSIGNEE_SECTION            1
#define CC_MENU_VIEWERS_SECTION             2
#define CC_MENU_FUNNEL_SECTION              3
#define CC_MENU_NOTE_SECTION                4
#define CC_MENU_FILE_WIDGET_SECTION         5
#define CC_MENU_SCHEDULE_SECTION            6
#define CC_MENU_QUESTION_SECTION            7
#define CC_MENU_INFORMATION_SECTION         8
#define CC_MENU_CLOSE_SECTION               9
#define CC_MENU_DELETE_SECTION              10
#define CC_MENU_DIRECTORIES_SECTION         11
#define CC_MENU_ABOUTAPP_CELL               0

#define CC_MENU_STICKER_TYPE_FILE_WIDGET    @"file"
#define CC_MENU_STICKER_TYPE_SCHEDULE       @"schedule"
#define CC_MENU_STICKER_TYPE_QUESTION  @"select"
#define CC_MENU_STICKER_TYPE_LOCATION   @"location"

@interface CCChannelDetailViewController : UITableViewController<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
// Menu Section Title
@property (strong, nonatomic) IBOutlet UILabel *titleMenuAsignee;
@property (strong, nonatomic) IBOutlet UILabel *titleMenuFollower;
@property (strong, nonatomic) IBOutlet UILabel *titleMenuFunnel;
@property (strong, nonatomic) IBOutlet UILabel *titleMenuNote;
@property (strong, nonatomic) IBOutlet UILabel *titleMenuAbout;
@property (strong, nonatomic) IBOutlet UILabel *titleMenuClose;
@property (strong, nonatomic) IBOutlet UILabel *titleMenuDelete;
@property (weak, nonatomic) IBOutlet UILabel *titleMenuFileWidget;
@property (weak, nonatomic) IBOutlet UILabel *titleMenuSchedule;
@property (weak, nonatomic) IBOutlet UILabel *titleMenuQuestion;


// Channel information (can be Guest, Assignee
@property (strong, nonatomic) IBOutlet UIImageView *channelAvatar;
@property (strong, nonatomic) IBOutlet UILabel *channelName;
@property (strong, nonatomic) IBOutlet UILabel *channelOnlineStatus;

@property (strong, nonatomic) IBOutlet UIImageView *assigneeAvatar;
@property (strong, nonatomic) IBOutlet UILabel *assigneeName;

@property (strong, nonatomic) IBOutlet UILabel *assigneeNotFound;
@property (strong, nonatomic) IBOutlet UILabel *followerNotFound;
@property (strong, nonatomic) IBOutlet UILabel *lbMenuAboutApp;

// Funnel
@property (strong, nonatomic) IBOutlet UILabel *funnelName;

// Channel information (full data)
@property (nonatomic, strong) NSDictionary *channelInfo;

@property (nonatomic, strong) NSString *uid;
// Assignee information
@property (nonatomic, strong) NSDictionary *assigneeInfo;
@property (nonatomic, strong) NSDictionary* profileUser;
@property (nonatomic, strong) NSString* guestUid;
@property (nonatomic, strong) NSString *orgUid;
@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSArray *channelUsers;
@property (nonatomic, strong) NSDictionary *avatars;
// Guest information
@property (weak, nonatomic) IBOutlet UIImageView *imageProfileInfor;
@property (weak, nonatomic) IBOutlet UIView *imageProfileTapAreaView;
@property (weak, nonatomic) IBOutlet UITextView *emailProfileInfo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *socalIconHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *socialIconTapAreaHeightConstraint;
// Funnel information
@property (weak, nonatomic) NSDictionary *funnelInfo;

// Note information
@property (weak, nonatomic) NSString *note;
@property (strong, nonatomic) IBOutlet UILabel *closeChannelLabel;

- (void)loadChannelInformation:(NSString *)channelId;
- (void) setupAvatar:(NSDictionary *) user;

@end
