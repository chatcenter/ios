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

int const CCMaxLoadOrg = 10000;

@interface CCModalListViewController(){
    int selectedOrgPath;
    int selectedAppPath;
    float circleAvatarSize;
    float randomCircleAvatarFontSize;
    float randomCircleAvatarTextOffset;
}

@property (nonatomic, strong) NSMutableArray *orgLabels;
@property (nonatomic, strong) NSMutableArray *settingList;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* tableViewHorizontalSpace;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHorizontalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spacerHorizontalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileHorizontalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *appInfohorizontalSpace;

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

    ///Disappearing boarder of void cells
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableHeaderView:v];
    [self.tableView setTableFooterView:v];
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadSettingList];
    [self.tableView reloadData];
    
    // reload org
    [[CCConnectionHelper sharedClient] loadOrg:NO completionHandler:^(NSString *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        [self loadSettingList];
        [self.tableView reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.view setNeedsUpdateConstraints];
    self.tableViewHorizontalSpace.constant = 0.0f;
    self.headerHorizontalSpace.constant = 0.0f;
    self.spacerHorizontalSpace.constant = 0.0f;
    self.profileHorizontalSpace.constant = 0.0f;
    self.appInfohorizontalSpace.constant = 0.0f;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.settingList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    UILabel *title;
    ///Labe: Setting
    NSDictionary *setting = self.settingList[indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:setting[@"identifier"]];
    if(![setting[@"image"] isEqualToString:@""]){
        cell.imageView.image = [UIImage SDKImageNamed:setting[@"image"]];
    }else{
        cell.imageView.image = nil;
        cell.separatorInset = UIEdgeInsetsMake(0, 52, 0, 0);
    }
    title = (UILabel*)[cell viewWithTag:0];
    
    // set title-text and set font bold
    NSNumber *unreadChannelsCount = setting[@"unreadChannelsCount"];
    if(unreadChannelsCount != nil && unreadChannelsCount.intValue > 0) {
        title.font = [UIFont boldSystemFontOfSize:14.0];
        if(unreadChannelsCount.intValue > 999) {
            title.text = [NSString stringWithFormat:@"%@ (%@)", setting[@"label"], @"999+"];
        } else {
            title.text = [NSString stringWithFormat:@"%@ (%@)", setting[@"label"], unreadChannelsCount];
        }
    } else {
        title.font = [UIFont systemFontOfSize:14.0];
            title.text = setting[@"label"];
    }

    if(indexPath.row == selectedOrgPath){
        cell.backgroundColor = [CCConstants sharedInstance].leftMenuViewSelectColor;
    }else{
        cell.backgroundColor = [UIColor whiteColor];
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
                                                     completionHandler:^(NSString *result, NSError *error, CCAFHTTPRequestOperation *operation)
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
    self.tableViewHorizontalSpace.constant = -270.0f;
    self.headerHorizontalSpace.constant = -270.0f;
    self.spacerHorizontalSpace.constant = -270.0f;
    self.profileHorizontalSpace.constant = -270.0f;
    self.appInfohorizontalSpace.constant = -270.0f;
    [UIView animateWithDuration:0.25f delay:0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^ {
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        // Clear filter.
        [CCUserDefaultsUtil setFilterBusinessFunnel:nil];
        [CCUserDefaultsUtil setFilterMessageStatus:nil];
        
        [self reloadChannelsAndConnectWebSocket:orgUid];
    }];
}

-(void)pressSwitchApp:(NSDictionary *)app{
    /// selected cell is already selected or not
    NSString *appUid = app[@"uid"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([appUid isEqualToString:[ud stringForKey:@"ChatCenterUserdefaults_currentAppUid"]]) {
        return;
    }
    
    ///Swithc App
    [CCConstants sharedInstance].appName = app[@"name"];
    [CCConstants sharedInstance].stickers = app[@"stickers"];
    [CCConstants sharedInstance].businessType = app[@"business_type"];
    [ud setObject:appUid forKey:@"ChatCenterUserdefaults_currentAppUid"];
    [ud removeObjectForKey:@"ChatCenterUserdefaults_currentOrgUid"];
    [ud synchronize];
    [[CCCoredataBase sharedClient] deleteAllOrg];
    [ChatCenter setAppToken:app[@"token"] completionHandler:^{
        if(self.didTapSwitchAppCallback != nil) self.didTapSwitchAppCallback();
        ///close self
        [self.view setNeedsUpdateConstraints];
        self.tableViewHorizontalSpace.constant = -270.0f;
        self.headerHorizontalSpace.constant = -270.0f;
        self.spacerHorizontalSpace.constant = -270.0f;
        self.profileHorizontalSpace.constant = -270.0f;
        self.appInfohorizontalSpace.constant = -270.0f;
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
    self.tableViewHorizontalSpace.constant = -270.0f;
    self.headerHorizontalSpace.constant = -270.0f;
    self.spacerHorizontalSpace.constant = -270.0f;
    self.profileHorizontalSpace.constant = -270.0f;
    self.appInfohorizontalSpace.constant = -270.0f;
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^ {
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    [self dismissViewControllerAnimated:YES completion:^{
        if(self.didTapLogoutCallback != nil) self.didTapLogoutCallback();
    }];
}

- (IBAction)closeModalDialog:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClickSetting:(id)sender {
    UIAlertController *actionSheet = nil;
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];;
    NSString *title = [NSString stringWithFormat:@"%@ %@",appName, appVersion];
    if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
        actionSheet = [UIAlertController alertControllerWithTitle:title
                                                          message:nil
                                                   preferredStyle:UIAlertControllerStyleAlert];
    } else {
        actionSheet = [UIAlertController alertControllerWithTitle:title
                                                          message:nil
                                                   preferredStyle:UIAlertControllerStyleActionSheet];
    }
    [actionSheet addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"Log out")
                                                    style:UIAlertActionStyleDestructive
                                                  handler:^(UIAlertAction *action){
                                                      [self pressSignOut];
                                                  }]];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel")
                                                                                       style:UIAlertActionStyleDefault
                                                                                     handler:nil];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        [cancelAction setValue:[UIColor lightGrayColor] forKey:@"titleTextColor"];
    }
    [actionSheet addAction:cancelAction];
    actionSheet.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *pop = actionSheet.popoverPresentationController;
    pop.sourceView = self.view;
    pop.sourceRect = self.view.bounds;
    actionSheet.view.tintColor = [UIColor lightGrayColor];
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
    self.tableViewHorizontalSpace.constant = -270.0f;
    self.headerHorizontalSpace.constant = -270.0f;
    self.spacerHorizontalSpace.constant = -270.0f;
    self.profileHorizontalSpace.constant = -270.0f;
    self.appInfohorizontalSpace.constant = -270.0f;
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
                    CCJSQMessagesAvatarImage *newIconImageAvatar = [CCJSQMessagesAvatarImageFactory avatarImageWithImage:newIconImage diameter:circleAvatarSize];
                    if (newIconImageAvatar != nil) {
                        self.avatar.image = newIconImageAvatar.avatarImage;
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
            CCJSQMessagesAvatarImage *newIconImageAvatar = [CCJSQMessagesAvatarImageFactory avatarImageWithImage:imageApp diameter:circleAvatarSize];
            self.avatarApp.image = newIconImageAvatar.avatarImage;
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
                            CCJSQMessagesAvatarImage *newIconImageAvatar = [CCJSQMessagesAvatarImageFactory avatarImageWithImage:newIconImage diameter:circleAvatarSize];
                            if (newIconImageAvatar != nil) {
                                self.avatarApp.image = newIconImageAvatar.avatarImage;
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
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(osVersion >= 9.0) {
        SFSafariViewController *webViewController = [[SFSafariViewController alloc] initWithURL:URL entersReaderIfAvailable:YES];
        webViewController.view.tintColor = [[CCConstants sharedInstance] headerItemColor];
        [self presentViewController:webViewController animated:YES completion:nil];
        return;
    }
#endif
    [[UIApplication sharedApplication] openURL:URL];
}

@end
