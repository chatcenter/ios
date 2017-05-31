//
//  CCAssignAssigneeViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 7/6/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//
#import "CCAssignFollowerViewController.h"
#import "CCAssignAgentViewCell.h"
#import "CCSVProgressHUD.h"
#import "CCConnectionHelper.h"
#import "ChatCenterPrivate.h"
#import "CCCoredataBase.h"
#import "CCConstants.h"
#import "UIImageView+CCWebCache.h"

@interface CCAsignFollowerViewController() {
    NSMutableArray *selectedAgentIndex;
    NSMutableArray *followingAgents;
    NSMutableArray * _followingAgents;
    NSArray *channelRoles;
}

@end

@implementation CCAsignFollowerViewController

-(void)viewDidLoad{
    self.navigationItem.title = CCLocalizedString(@"Followers");
    selectedAgentIndex = [NSMutableArray array];
    self.agents = [NSMutableArray array];
    _followingAgents = [NSMutableArray array];
    [self viewSetup];
    [self loadAgentWithOrgID:self.orgUid];
    [super viewDidLoad];
}

-(void)viewSetup{
    ///
    /// Channel roles
    ///
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *privelege = [ud dictionaryForKey:kCCUserDefaults_privilege];
    if(privelege[@"channel"] != nil) {
        channelRoles = privelege[@"channel"];
    }
    
    UIBarButtonItem *rightMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(pressSave)];
    
    UIBarButtonItem *rightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightSpacer.width = 10;
    
    if (channelRoles != nil && [channelRoles containsObject:@"follow"]) {
        self.navigationItem.rightBarButtonItems = @[rightSpacer, rightMenuButton];
    }
    
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CCBackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(closeModal)];
    self.navigationItem.leftBarButtonItem = closeBtn;
}

-(void)closeModal {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.agents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCAssignAgentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"assignAgentCell"];
    NSDictionary *agent = self.agents[indexPath.row];
    cell.agentName.text = agent[@"display_name"];
    [self setupAvatar:self.agents[indexPath.row] imageView:cell.agentAvatar];
    
    if ([selectedAgentIndex containsObject:indexPath]) {
        cell.checkmark.hidden = NO;
    } else {
        cell.checkmark.hidden = YES;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected agent at indexPath");
    if (![selectedAgentIndex containsObject:indexPath]) {
        [selectedAgentIndex addObject:indexPath];
    } else {
        [selectedAgentIndex removeObject:indexPath];
    }
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Deselected agent at indexPath");
    if ([selectedAgentIndex containsObject:indexPath]) {
        [selectedAgentIndex removeObject:indexPath];
    }
    [tableView reloadData];
}

#pragma mark - Load agents
- (void)loadAgentWithOrgID:(NSString *)orgUid{
    [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading...")];
    NSLog(@"Load agent with orgid");
    NSArray *agentArray = [[CCCoredataBase sharedClient] selectOrgWithUid:orgUid];
    if (agentArray != nil && agentArray.count > 0) {
        NSManagedObject *object = [agentArray objectAtIndex:0];
        NSData *agentData = [object valueForKey:@"users"];
        if (agentData != nil) {
            NSArray *users = [NSKeyedUnarchiver unarchiveObjectWithData:agentData];
            self.agents = [users mutableCopy];
            [self loadFollowingUser:self.channelUid];
            NSLog(@"Finish load agent list");
            [self.tableView reloadData];
        }
        [CCSVProgressHUD dismiss];
    } else {
        NSLog(@"Can not load agent list");
        [CCSVProgressHUD dismiss];
    }
}

-(void)loadFollowingUser:(NSString *)channelId{
    if (![[CCConstants sharedInstance] getKeychainUid]) {
        return;
    }
    NSArray *channelArray = [[CCCoredataBase sharedClient] selectChannelWithUid:CCloadLoacalChannelLimit uid:channelId];
    if(channelArray != nil && channelArray.count > 0){
        NSManagedObject *object   = [channelArray objectAtIndex:0];
        NSData *assigneeData      = [object valueForKey:@"assignee"];
        NSDictionary *assignee    = [NSKeyedUnarchiver unarchiveObjectWithData:assigneeData];
        NSMutableArray *channelUsers = [self.agents mutableCopy];
        // Add following user to selectable user
        if (self.followings != nil && self.followings.count > 0) {
            for (int i = 0; i < self.followings.count; i++) {
                [channelUsers addObject:self.followings[i]];
            }
        }
        NSMutableArray *optimizeAgents = [NSMutableArray array];
        for (int i = 0; i < channelUsers.count; i++) {
            // If already in optimize list
            int willBeAdded = 1;
            for (int j = 0; j < optimizeAgents.count; j++) {
                if([optimizeAgents[j][@"id"] intValue] == [channelUsers[i][@"id"] intValue]) {
                    willBeAdded = 0;
                    break;
                }
            }
            if (willBeAdded == 0) {
                break;
            }
            if (![optimizeAgents containsObject:channelUsers[i]]) {
                if (assignee != nil) {
                        [optimizeAgents addObject:channelUsers[i]];
                } else {
                    [optimizeAgents addObject:channelUsers[i]];
                }
            }
        }
        self.agents = [optimizeAgents mutableCopy];
        followingAgents = [self.followings mutableCopy]; // save channel users list
        _followingAgents = [followingAgents mutableCopy];
        for(int agentIdex = 0; agentIdex < self.agents.count; agentIdex ++) {
            if (_followingAgents != nil && _followingAgents.count > 0) {
                for (int i = 0; i < _followingAgents.count ; i++) {
                    if (_followingAgents[i] != nil && _followingAgents[i][@"id"] != nil &&[self.agents[agentIdex][@"id"] intValue] == [_followingAgents[i][@"id"] intValue]) {
                        if (![selectedAgentIndex containsObject:[NSIndexPath indexPathForRow:agentIdex inSection:0]]){
                            [selectedAgentIndex addObject:[NSIndexPath indexPathForRow:agentIdex inSection:0]];
                        }
                        [_followingAgents removeObject:_followingAgents[i]];
                        break;
                    }
                }
            }
        }
        [self.tableView reloadData];
    }
}

#pragma mark - Do assign
-(void) pressSave {
    [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Saving...")];
    
    for (int i = 0; i < followingAgents.count; i++) {
        BOOL remove = YES;
        for (int j = 0; j < selectedAgentIndex.count; j++) {
            NSIndexPath *selectedIndexPath = selectedAgentIndex[j];
            NSDictionary *agentData = self.agents[selectedIndexPath.row];

            if ([followingAgents[i][@"id"] intValue] == [agentData[@"id"] intValue]) {
                remove = NO;
            }
        }
        if (remove == YES) {
            NSString *agentId = followingAgents[i][@"id"];
            NSLog(@"Agent ID will be removed is %@", agentId);
            [[CCConnectionHelper sharedClient] removeFollowerFromChannel:self.channelUid agentID:agentId completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *operation) {
                if (selectedAgentIndex.count == 0 && i == followingAgents.count - 1) {
                    [CCSVProgressHUD dismiss];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    }
    
    for (int i = 0; i < selectedAgentIndex.count; i++) {
        NSIndexPath *selectedIndexPath = selectedAgentIndex[i];
        NSDictionary *agentData = self.agents[selectedIndexPath.row];
        NSString *agentId = agentData[@"id"];
        NSLog(@"Agent ID will be assigned is %@", agentId);
        [[CCConnectionHelper sharedClient] setFollowerForChannel:self.channelUid agentID:agentId completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *operation) {
            if (i == selectedAgentIndex.count - 1) {
                NSLog(@"Result === %@", result);
                [self updateData:result];
                [CCSVProgressHUD dismiss];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

-(void) updateData: (NSDictionary *) result {
    if (result != nil) {
        if (
            [result valueForKey:@"uid"] != nil
            && ![result[@"uid"] isEqual:[NSNull null]]
            && [result valueForKey:@"status"] != nil
            && ![result[@"status"] isEqual:[NSNull null]]
            && [result valueForKey:@"org_uid"] != nil
            && ![result[@"org_uid"] isEqual:[NSNull null]]
            && [result valueForKey:@"created"] != nil
            && ![result[@"created"] isEqual:[NSNull null]]
            && [result valueForKey:@"last_updated_at"] != nil
            && ![result[@"last_updated_at"] isEqual:[NSNull null]]
            && [result valueForKey:@"users"] != nil
            && ![result[@"users"] isEqual:[NSNull null]]
            && [result valueForKey:@"org_name"] != nil
            && ![result[@"org_name"] isEqual:[NSNull null]]
            && [result valueForKey:@"unread_messages"] != nil
            && ![result[@"unread_messages"] isEqual:[NSNull null]]
            && [result valueForKey:@"id"] != nil
            && ![result[@"id"] isEqual:[NSNull null]]
            && [result valueForKey:@"read"] != nil
            && ![result[@"read"] isEqual:[NSNull null]]
            && [result valueForKey:@"channel_informations"] != nil /// @"channel_informations" could be Null
            && [result valueForKey:@"icon_url"] != nil /// @"icon_url" could be Null
            )/// @"latest_message" could be Null
        {
            NSDictionary *assignee      = [result valueForKey:@"assignee"];
            NSNumber *uid               = [result valueForKey:@"id"];
            NSString *channelUid        = [result valueForKey:@"uid"];
            NSString *status            = [result valueForKey:@"status"];
            NSString *orgUid            = [result valueForKey:@"org_uid"];
            NSString *stringCreatedDate = [result valueForKey:@"created"];
            NSDate *createdDate         = [NSDate dateWithTimeIntervalSince1970:[stringCreatedDate doubleValue]];
            NSString *stringLastUpdatedAt = [result valueForKey:@"last_updated_at"];
            NSDate *lastUpdatedAt         = [NSDate dateWithTimeIntervalSince1970:[stringLastUpdatedAt doubleValue]];
            NSArray *users              = [result valueForKey:@"users"];
            NSString *orgName           = [result valueForKey:@"org_name"];
            NSString *unreadMessages    = [[result valueForKey:@"unread_messages"] stringValue];
            NSDictionary *latestMessage = [result valueForKey:@"latest_message"];
            NSString *iconUrl           = [result valueForKey:@"icon_url"];
            NSNumber *read              = [result valueForKey:@"read"];
            NSDictionary *channelInformations = result[@"channel_informations"];
            NSDictionary *displayName = result[@"display_name"];
            ///name and directmessage are only used for team now
            NSString *name = @"";
            BOOL directMessage = NO;
            if (result[@"name"] != nil && ![result[@"name"] isEqual:[NSNull null]]) name = result[@"name"];
            if (result[@"direct_message"] != nil && ![result[@"direct_message"] isEqual:[NSNull null]]) {
                directMessage = [result[@"direct_message"] boolValue];
            }
            [[CCCoredataBase sharedClient] deleteChannelWithUid:channelUid];
            if([[CCCoredataBase sharedClient] insertChannel:channelUid
                                                                createdAt:createdDate
                                                                 updateAt:nil
                                                                    users:users
                                                                  org_uid:orgUid
                                                                 org_name:orgName
                                                          unread_messages:unreadMessages
                                                           latest_message:latestMessage
                                                                      uid:uid
                                                                   status:status
                                                     channel_informations:channelInformations
                                                                 icon_url:iconUrl
                                                                     read:[read boolValue]
                                                            lastUpdatedAt:lastUpdatedAt
                                                                     name:name
                                                           direct_message:directMessage
                                                                 assignee:assignee
                                                             display_name:displayName])
            {
                NSLog(@"updateChannel Success!");
            }else{
                NSLog(@"updateChannel Error!");
            }
        }
    }
}

-(void)setupAvatar:(NSDictionary *)user imageView:(UIImageView *)imageView{
    NSString *userUid = user[@"id"];
    NSLog(@"Load avatar of user %@", userUid);
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
@end
