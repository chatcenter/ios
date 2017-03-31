//
//  THContactPickerViewControllerDemo.m
//  ContactPicker
//
//  Created by Vladislav Kovtash on 12.11.13.
//  Copyright (c) 2013 Tristan Himmelman. All rights reserved.
//

#import "CCContactPickerViewController.h"
#import "ChatCenterPrivate.h"
#import "CCConnectionHelper.h"
#import "CCSSKeychain.h"
#import "CCConstants.h"

@interface CCContactPickerViewController () <THContactPickerDelegate>{
    int randomCircleAvatarSize;
    int randomCircleAvatarFontSize;
    int randomCircleAvatarTextOffset;
}

@property (nonatomic, strong) NSMutableArray *privateSelectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;
@property (nonatomic, strong) UIBarButtonItem *createBtn;

@end

@implementation CCContactPickerViewController

static const CGFloat kPickerViewHeight = 100.0;

NSString *THContactPickerContactCellReuseID = @"THContactPickerContactCell";

@synthesize contactPickerView = _contactPickerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeBottom|UIRectEdgeLeft|UIRectEdgeRight];
    }
    randomCircleAvatarSize = 38;
    randomCircleAvatarFontSize = 24.0f;
    randomCircleAvatarTextOffset = 5;
    ///Loading users
    [self loadUsers];
    // Initialize and add Contact Picker View
    self.contactPickerView = [[CCTHContactPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kPickerViewHeight)];
    self.contactPickerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    self.contactPickerView.delegate = self;
    if (self.isDirectMessage == YES) {
        self.title = CCLocalizedString(@"Direct Message");
    }else{
        self.title = CCLocalizedString(@"Group");
    }
    [self.contactPickerView setPlaceholderLabelText:@""];
    [self.contactPickerView setPromptLabelText:CCLocalizedString(@"To:")];
    //[self.contactPickerView setLimitToOne:YES];
    [self.view addSubview:self.contactPickerView];
    
    CALayer *layer = [self.contactPickerView layer];
    [layer setShadowColor:[[UIColor colorWithRed:225.0/255.0 green:226.0/255.0 blue:228.0/255.0 alpha:1] CGColor]];
    [layer setShadowOffset:CGSizeMake(0, 2)];
    [layer setShadowOpacity:1];
    [layer setShadowRadius:1.0f];
    
    // Fill the rest of the view with the table view
    CGRect tableFrame = CGRectMake(0, self.contactPickerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView.frame.size.height);
    self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view insertSubview:self.tableView belowSubview:self.contactPickerView];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Cancel")
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(didTapCancelBtn)];
    self.createBtn = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Create")
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(didTapCreateBtn)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
}

- (void)viewDidLayoutSubviews {
    [self adjustTableFrame];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*Register for keyboard notifications*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)selectedContacts{
    return [self.privateSelectedContacts copy];
}

#pragma mark - Publick properties

- (NSArray *)filteredContacts {
    if (!_filteredContacts) {
        _filteredContacts = _contacts;
    }
    return _filteredContacts;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset bottom:(CGFloat)bottomInset {
    self.tableView.contentInset = UIEdgeInsetsMake(topInset,
                                                   self.tableView.contentInset.left,
                                                   bottomInset,
                                                   self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

- (NSInteger)selectedCount {
    return self.privateSelectedContacts.count;
}

#pragma mark - Private properties

- (NSMutableArray *)privateSelectedContacts {
    if (!_privateSelectedContacts) {
        _privateSelectedContacts = [NSMutableArray array];
    }
    return _privateSelectedContacts;
}

#pragma mark - Private methods

- (void)adjustTableFrame {
    CGFloat yOffset = self.contactPickerView.frame.origin.y + self.contactPickerView.frame.size.height;
    CGRect tableFrame;
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(osVersion >= 8.0f)  { ///iOS8
        tableFrame = CGRectMake(0, yOffset, self.view.frame.size.width, self.view.frame.size.height - yOffset);
    }else{ ///iOS7
        UIScreen *sc = [UIScreen mainScreen];
        CGRect rect = sc.bounds;
        tableFrame = CGRectMake(0, yOffset, self.view.frame.size.width, rect.size.height - yOffset);
    }
    self.tableView.frame = tableFrame;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset {
    [self adjustTableViewInsetTop:topInset bottom:self.tableView.contentInset.bottom];
}

- (void)adjustTableViewInsetBottom:(CGFloat)bottomInset {
    [self adjustTableViewInsetTop:self.tableView.contentInset.top bottom:bottomInset];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [self titleForRowAtIndexPath:indexPath];
    cell.imageView.image = [self imageForRowAtIndexPath:indexPath];
}

- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text {
    return [NSPredicate predicateWithFormat:@"(displayName contains[cd] %@)", text];
}

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *contact = [self.filteredContacts objectAtIndex:indexPath.row];
    return contact[@"displayName"];
}

- (UIImage *)imageForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *contact = [self.filteredContacts objectAtIndex:indexPath.row];
    if (contact[@"iconImage"] != [NSNull null]) {
        return contact[@"iconImage"];
    }else{
        return nil;
    }
}

- (void) didChangeSelectedItems {
    if(self.privateSelectedContacts.count > 0) {
        self.navigationItem.rightBarButtonItem = self.createBtn;
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void) didTapCancelBtn{
    self.parentViewController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) didTapCreateBtn{
    self.parentViewController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
    [self dismissViewControllerAnimated:YES completion:^{
        ///Create channels
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *orgUid = [ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"];
        NSMutableArray *userIds = [NSMutableArray array];
        [userIds addObject:[NSNumber numberWithInt:[[[CCConstants sharedInstance] getKeychainUid] intValue]]];
        for (int i = 0; i < self.privateSelectedContacts.count; i++) {
            NSDictionary *contact = self.privateSelectedContacts[i];
            [userIds addObject:contact[@"uid"]];
        }
        [[CCConnectionHelper sharedClient] createChannelWithUsers:orgUid
                                                          userIds:userIds
                                                    directMessage:self.isDirectMessage
                                                        groupName:nil
                                              channelInformations:nil
                                                completionHandler:^(NSString *channelId, NSError *error, NSURLSessionDataTask *task)
        {
            if (channelId != nil && self.closeContactPickerViewCallback != nil) {
                self.closeContactPickerViewCallback(channelId);
            }
        }];
    }];
}

- (void)loadUsers{
    [[CCConnectionHelper sharedClient] loadUsers:YES completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task) {
        NSLog(@"loadUsers");
        if (result != nil) {
            NSMutableArray *newContacts = [NSMutableArray array];
            for (int i = 0; i < result.count; i++) {
                NSDictionary *user = result[i];
                if (user[@"id"] != nil
                    && ![user[@"id"] isEqual:[NSNull null]]
                    && ![[user[@"id"] stringValue] isEqual:[[CCConstants sharedInstance] getKeychainUid]]
                    && user[@"display_name"] != nil
                    && ![user[@"display_name"] isEqual:[NSNull null]])
                {
                    NSNumber *uid = user[@"id"];
                    NSString *displayName = user[@"display_name"];
                    ///create avatar image if user has icon-image
                    UIImage *iconImage;
                    NSString *iconImageUrl;
                    if (user[@"icon_url"] != nil
                        && !([user[@"icon_url"] isEqual:[NSNull null]])
                        && ([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable))
                    {
                        iconImageUrl = user[@"icon_url"];
                        ///Loading image
                        __block NSNumber *blockUid = uid;
                        dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        dispatch_queue_t q_main   = dispatch_get_main_queue();
                        dispatch_async(q_global, ^{
                            NSError *error = nil;
                            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:iconImageUrl] options:NSDataReadingUncached error:&error];
                            dispatch_async(q_main, ^{
                                UIImage *image = [[UIImage alloc] initWithData:data];
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid = %@",blockUid];
                                NSIndexSet* indexes = [self.contacts indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                    return [predicate evaluateWithObject:obj];
                                }];
                                if (indexes == nil || indexes.firstIndex == NSNotFound) {
                                    return;
                                }
                                NSUInteger index = indexes.firstIndex;
                                if (self.contacts.count < index) {
                                    return;
                                }
                                NSMutableDictionary *newUser = [NSMutableDictionary dictionary];
                                NSMutableArray *newContacts = [self.contacts mutableCopy];
                                NSDictionary *oldUser = self.contacts[index];
                                newUser[@"uid"] = blockUid;
                                newUser[@"displayName"] = oldUser[@"displayName"];
                                newUser[@"iconImage"] = [self makeThumbnailOfSize:image];
                                [newContacts removeObjectAtIndex:index];
                                [newContacts insertObject:[newUser copy] atIndex:index];
                                if (self.contacts.count == self.filteredContacts.count
                                    && ![self.privateSelectedContacts containsObject:oldUser]) {
                                    self.filteredContacts = [newContacts copy];
                                }
                                self.contacts = [newContacts copy];
                                [self.tableView reloadData];
                            });
                        });
                    }
                    NSString *firstCharacter = [displayName substringToIndex:1];
                    iconImage = [[ChatCenter sharedInstance] createAvatarImage:firstCharacter
                                                                         width:randomCircleAvatarSize
                                                                        height:randomCircleAvatarSize
                                                                         color:[[ChatCenter sharedInstance] getRandomColor:[uid stringValue]]
                                                                      fontSize:randomCircleAvatarFontSize
                                                                    textOffset:randomCircleAvatarTextOffset];
                    if (iconImageUrl == nil) iconImageUrl  = (NSString *)[NSNull null];
                    NSDictionary *contact = @{@"uid":uid,
                                              @"displayName":displayName,
                                              @"iconImage":iconImage};
                    [newContacts addObject:contact];
                }
            }
            self.contacts = [newContacts copy];
            [self.tableView reloadData];
        }else{
            [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
        }
    }];
}

- (UIImage *) makeThumbnailOfSize:(UIImage *)image
{
    UIGraphicsBeginImageContext(CGSizeMake(randomCircleAvatarSize, randomCircleAvatarSize));
    // draw scaled image into thumbnail context
    [image drawInRect:CGRectMake(0, 0, randomCircleAvatarSize, randomCircleAvatarSize)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    // pop the context
    UIGraphicsEndImageContext();
    if(newThumbnail == nil) NSLog(@"could not scale image");
    return newThumbnail;
}

- (void)displayAlert:(NSString *)message{
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(osVersion >= 8.0f)  { ///iOS8
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{ ///iOS7
        UIAlertView *alertView;
        alertView = [[UIAlertView alloc] initWithTitle:message
                                               message:nil
                                              delegate:self
                                     cancelButtonTitle:CCLocalizedString(@"OK")
                                     otherButtonTitles:nil, nil];
        alertView.tag = normalAlertTag;
        [alertView show];
    }
}

#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THContactPickerContactCellReuseID];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THContactPickerContactCellReuseID];
        // Rounded Rect for cell image
        CALayer *cellImageLayer = cell.imageView.layer;
        [cellImageLayer setCornerRadius:randomCircleAvatarSize/2];
        [cellImageLayer setMasksToBounds:YES];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    if ([self.privateSelectedContacts containsObject:[self.filteredContacts objectAtIndex:indexPath.row]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    id contact = [self.filteredContacts objectAtIndex:indexPath.row];
    NSString *contactTilte = [self titleForRowAtIndexPath:indexPath];
    
    if ([self.privateSelectedContacts containsObject:contact]){ // contact is already selected so remove it from ContactPickerView
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.privateSelectedContacts removeObject:contact];
        [self.contactPickerView removeContact:contact];
    } else {
        // Contact has not been selected, add it to THContactPickerView
        if (self.isDirectMessage != YES || self.privateSelectedContacts.count == 0 ) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.privateSelectedContacts addObject:contact];
            [self.contactPickerView addContact:contact withName:contactTilte];
        }else{
            [self displayAlert:CCLocalizedString(@"Please select one contact")];
        }
    }
    if(self.privateSelectedContacts.count > 0) {
        self.navigationItem.rightBarButtonItem = self.createBtn;
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
    self.filteredContacts = self.contacts;
    [self didChangeSelectedItems];
    [self.tableView reloadData];
}

#pragma mark - THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.contacts;
    }else{
        NSPredicate *predicate = [self newFilteringPredicateWithText:textViewText];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)contactPickerDidResize:(CCTHContactPickerView *)contactPickerView {
    CGRect frame = self.tableView.frame;
    frame.origin.y = contactPickerView.frame.size.height + contactPickerView.frame.origin.y;
    self.tableView.frame = frame;
}

- (void)contactPickerDidRemoveContact:(id)contact {
    [self.privateSelectedContacts removeObject:contact];
    
    NSInteger index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [self didChangeSelectedItems];
}

- (BOOL)contactPickerTextFieldShouldReturn:(UITextField *)textField {
	if (textField.text.length > 0){
		NSString *contact = [[NSString alloc] initWithString:textField.text];
		[self.privateSelectedContacts addObject:contact];
		[self.contactPickerView addContact:contact withName:textField.text];
	}
	return YES;
}

#pragma  mark - NSNotificationCenter

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
}

@end
