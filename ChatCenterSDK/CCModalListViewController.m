//
//  CCModalListViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/02/06.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCModalListViewController.h"
#import "CCConstants.h"
#import "CCConnectionHelper.h"
#import "CCCoredataBase.h"
#import "ChatCenterPrivate.h"
#import "CCSSKeychain.h"
#import "ChatCenterClient.h"
#import "CCUserDefaultsUtil.h"
#import <SafariServices/SafariServices.h>
#import "CCWebViewController.h"
#import "UIImage+CCSDKImage.h"
#import "CCModalListHeader.h"
#import "CCAboutChatCenterViewController.h"

int const CCMaxLoadOrg = 10000;

@interface CCModalListViewController(){
    int selectedOrgPath;
    int selectedAppPath;
    float circleAvatarSize;
    float randomCircleAvatarFontSize;
    float randomCircleAvatarTextOffset;
    
    BOOL isInboxOpen;
}

@property (nonatomic, strong) NSMutableArray *orgLabels;
@property (nonatomic, strong) NSMutableArray *settingList;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UIView *slideView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideViewHorizontalSpace;

@property int spacePath;
@property int switchAppPath;
@property int signOutPath;
@property BOOL isAppSwitch;

@end

@implementation CCModalListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.tintColor = [UIColor blackColor];
    self.tableView.tintColor = [UIColor blackColor];
    self.tableView.rowHeight = 40;

    ///Remove the unnecessary space on top and bottom of the table
    [[self.tableView tableHeaderView] setFrame:CGRectZero];
    [[self.tableView tableFooterView] setFrame:CGRectZero];
    ///..
    [self.tableView registerNib:[UINib nibWithNibName:@"CCModalListHeader" bundle:SDK_BUNDLE] forHeaderFooterViewReuseIdentifier:@"Header"];
    
    self.header.text = CCLocalizedString(@"Menu");
    if ([[CCConstants sharedInstance].apps count] > 1) {
        self.isAppSwitch = YES;
    }else{
        self.isAppSwitch = NO;
    }
    circleAvatarSize = [[CCConstants sharedInstance] chatViewCircleAvatarSize];
    randomCircleAvatarFontSize = circleAvatarSize*0.75;
    randomCircleAvatarTextOffset = 1.0f + (circleAvatarSize-24.0f)*0.0625;
    UIImage *image = [[UIImage SDKImageNamed:@"CCsetting-menu-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.btnSetting setImage:image forState:UIControlStateNormal];
    self.btnSetting.imageView.tintColor = [UIColor lightGrayColor];
    [self.btnSetting setTitle:@"" forState:UIControlStateNormal];
    [self loadUserInfor];
    [self loadAppInfo];
    UITapGestureRecognizer *tapGeusture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSwithApp:)];
    [self.appInforView setUserInteractionEnabled:YES];
    [self.appInforView addGestureRecognizer:tapGeusture];
    
    isInboxOpen = [[NSUserDefaults standardUserDefaults] boolForKey:@"inboxOpen"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadSettingList];
    [self.tableView reloadData];
    
    // reload org
    [[CCConnectionHelper sharedClient] loadOrg:NO completionHandler:^(NSString *result, NSError *error, NSURLSessionDataTask *task) {
        [self loadSettingList];
        [self.tableView reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.view setNeedsUpdateConstraints];
    self.slideViewHorizontalSpace.constant = 0.0f;
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^ {
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) { // List of Inbox
        if (isInboxOpen) {
            return self.settingList.count;
        } else {
            return 0;
        }
    } else { // Settings or About
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCModalListCell *cell;
    UILabel *title;
    ///Labe: Setting
    NSDictionary *setting = self.settingList[indexPath.row];
    cell = (CCModalListCell*)[tableView dequeueReusableCellWithIdentifier:setting[@"identifier"]];
    if(![setting[@"image"] isEqualToString:@""]){
        cell.imageView.image = [UIImage SDKImageNamed:setting[@"image"]];
    }else{
        cell.imageView.image = nil;
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    title = cell.titleLabel;
    
    // set title-text and set font bold
    NSNumber *unreadChannelsCount = setting[@"unreadChannelsCount"];
    if(unreadChannelsCount != nil && unreadChannelsCount.intValue > 0) {
        title.font = [UIFont boldSystemFontOfSize:14.0];
        title.text = setting[@"label"];
        NSString *unreadStr;
        if(unreadChannelsCount.intValue > 999) {
            unreadStr = [NSString stringWithFormat:@"%@", @"999+"];
        } else {
            unreadStr = [NSString stringWithFormat:@"%@",unreadChannelsCount];
        }
        cell.unreadLabel.text = unreadStr;
    } else {
        title.font = [UIFont systemFontOfSize:14.0];
            title.text = setting[@"label"];
    }

    if(indexPath.row == selectedOrgPath){
        cell.backgroundColor = [CCConstants sharedInstance].leftMenuViewSelectColor;
    }else{
        cell.backgroundColor = [CCConstants sharedInstance].leftMenuViewNormalColor;
    }
    
    ///change highlight color
    UIView *selected_bg_view = [[UIView alloc] initWithFrame:cell.bounds];
    selected_bg_view.backgroundColor = [[CCConstants sharedInstance] baseColor];
    cell.selectedBackgroundView = selected_bg_view;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *setting = self.settingList[indexPath.row];
    if([setting[@"identifier"] isEqualToString:@"Org"]){
        [self pressOrg:setting];
    }else if([setting[@"identifier"] isEqualToString:@"SwitchApp"]){
        [self pressSwitchApp:setting[@"app"]];
    }else if([setting[@"identifier"] isEqualToString:@"SignOut"]){
        [self pressSignOut];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CCModalListHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
    
    UIImage *img;
    NSString *text;
    switch (section) {
        case 0:
        {
            img = [UIImage SDKImageNamed:@"LeftPanel-Inbox"];
            text = CCLocalizedString(@"Inbox");
            [header setArrowState: isInboxOpen?CCArrowStateOpen:CCArrowStateClose];
        }
            break;
        case 1:
        {
            img = [UIImage SDKImageNamed:@"LeftPanel-Settings"];
            text = CCLocalizedString(@"Settings");
            [header setArrowState: CCArrowStateHidden];
        }
            break;
        default:
            break;
    }
    
    [header setupWithSectionIndex:section
                            label:text
                            image:img
                      andDelegate:self];
    

    return header;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60.0;
}

# pragma mark - Private methods
-(void)loadSettingList{
    self.settingList = [[NSMutableArray alloc] init];
    ///Add orgs
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *currentOrgUid;
    currentOrgUid = [ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"];
    NSArray *orgArray = [[CCCoredataBase sharedClient] selectOrgAll:CCloadLoacalOrgLimit];
    for (int i = 0; i<(int)orgArray.count; i++) {
        NSManagedObject *object         = [orgArray objectAtIndex:i];
        NSString *uid                   = [object valueForKey:@"uid"];
        NSString *orgName               = [object valueForKey:@"name"];
        NSArray *unreadMessagesChannels = [NSKeyedUnarchiver unarchiveObjectWithData:[object valueForKey:@"unreadMessagesChannels"]];
        NSNumber *unreadChannelsCount;
        if(unreadMessagesChannels != nil && unreadMessagesChannels.count > 0) {
            unreadChannelsCount = [[NSNumber alloc] initWithLong:unreadMessagesChannels.count];
        } else {
            unreadChannelsCount = [[NSNumber alloc] initWithLong:0];
        }
        [self.settingList addObject:[self getSetting:@"Org"
                                               label:orgName
                                               image:@""
                                              orgUid:uid
                                                 app:@{}
                                 unreadChannelsCount:unreadChannelsCount]];
        if([uid isEqualToString:currentOrgUid]){
            selectedOrgPath = (int)self.settingList.count-1;
        }
    }
    
    if(self.isAppSwitch == YES){
        ///Add apps
        NSArray *apps = [CCConstants sharedInstance].apps;
        for (int i = 0; i<(int)apps.count; i++) {
            NSDictionary *app = apps[i];
                       if ([app[@"token"] isEqualToString:[ChatCenterClient sharedClient].appToken]) {
                selectedAppPath = (int)self.settingList.count-1;
            }
        }
    }
}

- (void)headerCellTapped:(CCModalListHeader *)header {
    switch (header.sectionIndex) {
        case 0: // Inbox
            [self showHideInbox:header];
            break;
        case 1: // Settings
            [self onClickSetting:nil];
            break;
        default:
            break;
    }
    
}

- (void)showHideInbox:(CCModalListHeader*)headerView {
    isInboxOpen = !isInboxOpen;
    
    NSMutableArray *targetRows = [NSMutableArray new];
    for(NSInteger i=0; i<self.settingList.count; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        [targetRows addObject:path];
    }
    
    if(isInboxOpen) {
        [self.tableView insertRowsAtIndexPaths:targetRows withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView deleteRowsAtIndexPaths:targetRows withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [headerView setArrowState: isInboxOpen?CCArrowStateOpen:CCArrowStateClose ];
    
    [[NSUserDefaults standardUserDefaults] setBool:isInboxOpen forKey:@"inboxOpen"];

}

-(NSDictionary *)getSetting:(NSString *)identifier
                      label:(NSString *)label
                      image:(NSString *)image
                     orgUid:(NSString *)orgUid
                        app:(NSDictionary *)app
{
    NSDictionary *setting = @{@"identifier":identifier,
                              @"label":label,
                              @"image":image,
                              @"orgUid":orgUid,
                              @"app":app};
    return setting;
}

-(NSDictionary *)getSetting:(NSString *)identifier
                      label:(NSString *)label
                      image:(NSString *)image
                     orgUid:(NSString *)orgUid
                        app:(NSDictionary *)app
        unreadChannelsCount:(NSNumber *)unreadChannelsCount
{
    NSDictionary *setting = @{@"identifier":identifier,
                              @"label":label,
                              @"image":image,
                              @"orgUid":orgUid,
                              @"app":app,
                              @"unreadChannelsCount":unreadChannelsCount};
    return setting;
}

- (void)reloadChannelsAndConnectWebSocket:(NSString *)orgUid{
    [[CCConnectionHelper sharedClient] loadChannelsAndConnectWebSocket:YES
                                                        getChennelType:CCGetChannels
                                                           isOrgChange:YES
                                                               org_uid:orgUid
                                                     completionHandler:^(NSString *result, NSError *error, NSURLSessionDataTask *task)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:orgUid forKey:@"ChatCenterUserdefaults_currentOrgUid"];
        if(self.didTapSwitchOrgCallback != nil) self.didTapSwitchOrgCallback();
    }];
}

-(void)pressOrg:(NSDictionary *)setting{
    /// selected cell is already selected or not
    NSString *orgUid = setting[@"orgUid"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([orgUid isEqualToString:[ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"]]) {
        return;
    }
    /// close animation
    self.slideViewHorizontalSpace.constant = -280.0f;
    [UIView animateWithDuration:0.25f delay:0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^ {
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        // Clear filter.
        [CCUserDefaultsUtil setFilterBusinessFunnel:nil];
        [CCUserDefaultsUtil setFilterMessageStatus:nil];
        
        [self reloadChannelsAndConnectWebSocket:orgUid];
    }];
}


-(IBAction)switchAppButtonPressed:(id)sender {
    [self onClickSwithApp:nil];
}

-(void)pressSwitchApp:(NSDictionary *)app{
    /// selected cell is already selected or not
        if ([app valueForKey:@"id"] == nil
        || [app[@"id"] isEqual:[NSNull null]]
        || ![app[@"id"] isKindOfClass:[NSNumber class]]
        || [app valueForKey:@"token"] == nil
        || [app[@"token"] isEqual:[NSNull null]]
        || ![app[@"token"] isKindOfClass:[NSString class]]
        || [app valueForKey:@"name"] == nil
        || [app[@"name"] isEqual:[NSNull null]]
        || ![app[@"name"] isKindOfClass:[NSString class]]
        || [app valueForKey:@"stickers"] == nil
        || [app[@"stickers"] isEqual:[NSNull null]]
        || ![app[@"stickers"] isKindOfClass:[NSArray class]]
        || [app valueForKey:@"business_type"] == nil
        || [app[@"business_type"] isEqual:[NSNull null]]
        || ![app[@"business_type"] isKindOfClass:[NSString class]]){
        return;
    }
    NSNumber *appId = app[@"id"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (appId == [ud objectForKey:@"ChatCenterUserdefaults_currentAppId"]) {
        return;
    }
    
    ///Swithc App
    [CCConstants sharedInstance].appName = app[@"name"];
    [CCConstants sharedInstance].stickers = app[@"stickers"];
    [CCConstants sharedInstance].businessType = app[@"business_type"];
    [ud setObject:appId forKey:@"ChatCenterUserdefaults_currentAppId"];
    [ud removeObjectForKey:@"ChatCenterUserdefaults_currentOrgUid"];
    [ud synchronize];
    [[CCCoredataBase sharedClient] deleteAllOrg];
    [ChatCenter setAppToken:app[@"token"] completionHandler:^{
#if CC_WATCH
    [[CCConnectionHelper sharedClient] switchApp:app[@"token"]];
#endif
        if(self.didTapSwitchAppCallback != nil) self.didTapSwitchAppCallback();
        ///close self
        [self.view setNeedsUpdateConstraints];
        self.slideViewHorizontalSpace.constant = -280.0f;
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^ {
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }];
}

-(void)pressSignOut{
   [self.view setNeedsUpdateConstraints];
    self.slideViewHorizontalSpace.constant = -280.0f;
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^ {
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    [self dismissViewControllerAnimated:YES completion:^{
        if(self.didTapLogoutCallback != nil) self.didTapLogoutCallback();
    }];
}

-(void) openDashboard {
    NSURL *dashboardURL = [[NSURL alloc] initWithString:[ChatCenter getWebDashboardUrl]];
    if (dashboardURL != nil) {
        [self openURL:dashboardURL];
    }
}

-(void) pressAbout {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter" bundle:SDK_BUNDLE];
    CCAboutChatCenterViewController *aboutAppView = [storyboard  instantiateViewControllerWithIdentifier:@"AboutChatCenterViewController"];
    aboutAppView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    aboutAppView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    aboutAppView.isOpenedFromRightMenu = NO;
    UINavigationController *rootNC = [[UINavigationController alloc] initWithRootViewController:aboutAppView];
    [self presentViewController:rootNC animated:YES completion:nil];
}

- (IBAction)closeModalDialog:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClickSetting:(id)sender {
    UIAlertController *actionSheet = nil;
    ///
    /// App name
    ///
    NSString *appName = CCLocalizedString(@"ChatCenter iO for iOS");
    
    ///
    /// App version
    ///
    NSString *appVersion = [NSString stringWithFormat:@"%@ %@", CCLocalizedString(@"Version"), [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
        actionSheet = [UIAlertController alertControllerWithTitle:appName
                                                          message:appVersion
                                                   preferredStyle:UIAlertControllerStyleAlert];
    } else {
        actionSheet = [UIAlertController alertControllerWithTitle:appName
                                                          message:appVersion
                                                   preferredStyle:UIAlertControllerStyleActionSheet];
    }
    
    ///
    /// Open dashboard
    ///
    UIAlertAction *openDashboardAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Open Dashboard") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openDashboard];
    }];
    [actionSheet addAction:openDashboardAction];
    
    ///
    /// About chatcenter
    ///
    UIAlertAction *aboutAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"About ChatCenter.iO") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pressAbout];
    }];
    [actionSheet addAction:aboutAction];
    
    ///
    /// Log out button
    ///
    [actionSheet addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"Log out")
                                                    style:UIAlertActionStyleDestructive
                                                  handler:^(UIAlertAction *action){
                                                      [self pressSignOut];
                                                  }]];
    

    ///
    /// Cancel button
    ///
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel")
                                                                                       style:UIAlertActionStyleCancel
                                                                                     handler:nil];
    [actionSheet addAction:cancelAction];
    
    actionSheet.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *pop = actionSheet.popoverPresentationController;
    pop.sourceView = self.view;
    pop.sourceRect = self.view.bounds;
    //avoid Snapshotting error
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)onClickSwithApp:(UIGestureRecognizer*)gestureRecognizer {
    UIAlertController *actionSheet = nil;
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
        actionSheet = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Change apps")
                                                          message:nil
                                                   preferredStyle:UIAlertControllerStyleAlert];
    } else {
        actionSheet = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Change apps")
                                                          message:nil
                                                   preferredStyle:UIAlertControllerStyleActionSheet];
    }
    NSArray *apps = [CCConstants sharedInstance].apps;
    for (int i = 0; i<(int)apps.count; i++) {
        NSString *appName = apps[i][@"name"];
        NSDictionary *app = apps[i];
        [actionSheet addAction:[UIAlertAction actionWithTitle:appName
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action){
                                                          [self pressSwitchApp:app];
                                                      }]];

    }
    [actionSheet addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel")
                                                    style:UIAlertActionStyleDestructive
                                                  handler:nil]];
    actionSheet.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *pop = actionSheet.popoverPresentationController;
    pop.sourceView = self.view;
    pop.sourceRect = self.view.bounds;
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view setNeedsUpdateConstraints];
    self.slideViewHorizontalSpace.constant = -280.0f;
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^ {
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadUserInfor {
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] valueForKey:kCCUserDefaults_userId];
    NSString *userIconUrl = [[NSUserDefaults standardUserDefaults] valueForKey:kCCUserDefaults_userIconUrl];
    NSString *userDisplayName = [[NSUserDefaults standardUserDefaults] valueForKey:kCCUserDefaults_userDisplayName];
    self.fullName.text = userDisplayName;
    self.email.text = [[NSUserDefaults standardUserDefaults] valueForKey:kCCUserDefaults_userEmail];
    NSString *firstCharacter = [userDisplayName substringToIndex:1];
    UIImage *textIconImage = [[ChatCenter sharedInstance] createAvatarImage:firstCharacter width:circleAvatarSize height:circleAvatarSize color:[[ChatCenter sharedInstance] getRandomColor:currentUserId] fontSize:randomCircleAvatarFontSize textOffset:randomCircleAvatarTextOffset];
    CCJSQMessagesAvatarImage *aImg = [CCJSQMessagesAvatarImageFactory avatarImageWithImage:textIconImage diameter:circleAvatarSize];
    if (textIconImage != nil) {
        self.avatar.image = aImg.avatarImage;
    }
    if (userIconUrl != nil && ![userIconUrl isEqualToString:@""]) {
        if([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable) {
            userIconUrl = [userIconUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_queue_t q_main   = dispatch_get_main_queue();
            dispatch_async(q_global, ^{
                NSError *error = nil;
                __block NSData *dt = [NSData dataWithContentsOfURL:[NSURL URLWithString:userIconUrl]
                                                   options:NSDataReadingUncached
                                                     error:&error];
                dispatch_async(q_main, ^{
                    UIImage *newIconImage = [[UIImage alloc] initWithData:dt scale:[UIScreen mainScreen].scale];
                    if (newIconImage != nil) {
                        CCJSQMessagesAvatarImage *newIconImageAvatar = [CCJSQMessagesAvatarImageFactory avatarImageWithImage:newIconImage diameter:circleAvatarSize];
                        if (newIconImageAvatar != nil) {
                            self.avatar.image = newIconImageAvatar.avatarImage;
                        }
                    }
                });
            });
        }
    }
}

- (void)loadAppInfo {
    NSArray *apps = [CCConstants sharedInstance].apps;
    for (int i = 0; i<(int)apps.count; i++) {
        NSString *appName = apps[i][@"name"];
        NSDictionary *app = apps[i];
        if ([app[@"token"] isEqualToString:[ChatCenterClient sharedClient].appToken]) {
            self.lablelSwithApp.text = appName;
            UIImage *imageApp = [UIImage SDKImageNamed:[CCConstants sharedInstance].appIconName];
            self.avatarApp.image = imageApp;
            if (app[@"app_icons"] != nil && [app[@"app_icons"] count] > 0 && app[@"app_icons"][0][@"icon_url"] != nil
                && ![app[@"app_icons"][0][@"icon_url"] isEqualToString:@""]) {
                dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_queue_t q_main   = dispatch_get_main_queue();
                dispatch_async(q_global, ^{
                    NSError *error = nil;
                    NSString* appIconUrl = [[app[@"app_icons"][0][@"icon_url"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
                    appIconUrl = [appIconUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
                    
                    NSURL * url = [NSURL URLWithString:appIconUrl];
                    if (url != nil) {
                        __block NSData *dt = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
                        dispatch_async(q_main, ^{
                            UIImage *newIconImage = [[UIImage alloc] initWithData:dt scale:[UIScreen mainScreen].scale];
                            if (newIconImage != nil) {
                                self.avatarApp.image = newIconImage;
                            }
                        });
                    }
                });
            }
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
    
    NSString *title = CCLocalizedString(@"ChatCenter iO for iOS");
    CCWebViewController *webViewController = [[CCWebViewController alloc] initWithURL:URL.absoluteString title:title needAuthentication: YES];
    webViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    webViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UINavigationController *rootNC = [[UINavigationController alloc] initWithRootViewController:webViewController];
    [self presentViewController:rootNC animated:YES completion:nil];
}

@end


@implementation CCModalListCell

@end
