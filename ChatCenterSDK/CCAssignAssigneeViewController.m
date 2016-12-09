//
//  CCAssignAssigneeViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 7/6/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//
#import "CCAssignAssigneeViewController.h"
#import "CCAssignAgentViewCell.h"
#import "CCSVProgressHUD.h"
#import "CCConstants.h"
#import "ChatCenterPrivate.h"
#import "CCConnectionHelper.h"
#import "CCCoredataBase.h"
#import "ChatCenter.h"
#import "UIImageView+CCWebCache.h"

@interface CCAssignAssigneeViewController() {
    NSMutableArray *selectedAgentIndex;
    NSString *assignedAssigneeId;//assigned
}

@end

@implementation CCAssignAssigneeViewController

-(void)viewDidLoad{
    self.navigationItem.title = CCLocalizedString(@"Assignee");
    selectedAgentIndex = [NSMutableArray array];
    self.agents = [NSMutableArray array];
    [self viewSetup];
    [self loadAssigneeInformation:self.channelUid];
    [self loadAgentWithOrgID:self.orgUid];
    [super viewDidLoad];
}

-(void)viewSetup{
    UIBarButtonItem *rightMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(pressSave)];
    
    UIBarButtonItem *rightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightSpacer.width = 10;
    
    self.navigationItem.rightBarButtonItems = @[rightSpacer, rightMenuButton];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected agent at indexPath");
    if (![selectedAgentIndex containsObject:indexPath]) {
        [selectedAgentIndex removeAllObjects];
        [selectedAgentIndex addObject:indexPath];
    } else {
        [selectedAgentIndex removeObject:indexPath];
    }
    [tableView reloadData];
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
    [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Loading...") maskType:SVProgressHUDMaskTypeBlack];
    NSLog(@"Load agent with orgid");
    NSArray *agentArray = [[CCCoredataBase sharedClient] selectOrgWithUid:orgUid];
    if (agentArray != nil && agentArray.count > 0) {
        NSManagedObject *object = [agentArray objectAtIndex:0];
        NSData *agentData = [object valueForKey:@"users"];
        if (agentData != nil) {
            NSArray *users = [NSKeyedUnarchiver unarchiveObjectWithData:agentData];
            self.agents = [users mutableCopy];
            // Add asignee to selectable list
            int assigneeInAgents = 0;
            for(int i = 0; i < self.agents.count ; i++) {
                if(self.assigneeID != nil && [self.agents[i][@"id"] intValue] == [self.assigneeID intValue]) {
                    assigneeInAgents = 1;
                }
            }
            if(assigneeInAgents == 0 && self.assigneeID != nil) {
                [self.agents addObject:self.assigneeInfo];
            }
            for (int i = 0; i < self.agents.count; i++) {
                if (self.assigneeID != nil && [self.agents[i][@"id"] intValue] == [self.assigneeID intValue]) {
                    [selectedAgentIndex addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    self.assigneeID = nil;
                }
            }
            NSLog(@"Finish load agent list");
            [self.tableView reloadData];
        }
        [CCSVProgressHUD dismiss];
    } else {
        NSLog(@"Can not load agent list");
        [CCSVProgressHUD dismiss];
    }
}

#pragma mark - Do assign
-(void) pressSave {
    [CCSVProgressHUD showWithStatus:CCLocalizedString(@"Saving...") maskType:SVProgressHUDMaskTypeBlack];
    if (selectedAgentIndex == nil || selectedAgentIndex.count == 0) {
        if (assignedAssigneeId != nil) {
            [[CCConnectionHelper sharedClient] removeAssigneeFromChannel:self.channelUid agentID:assignedAssigneeId completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
                [self updateChannel:result];
                [CCSVProgressHUD dismiss];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            [CCSVProgressHUD dismiss];
        }
        return;
    }
    NSIndexPath *selectedIndexPath = selectedAgentIndex.firstObject;
    NSDictionary *agentData = self.agents[selectedIndexPath.row];
    NSString *agentId = agentData[@"id"];
    NSLog(@"Agent ID will be assigned is %@", agentId);
    [[CCConnectionHelper sharedClient] setAssigneeForChannel:self.channelUid agentID:agentId completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        [self updateChannel:result];
        [CCSVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void) updateChannel: (NSDictionary *) result {
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
            ///name and directmessage are only used for team now
            NSString *name = @"";
            BOOL directMessage = NO;
            if (result[@"name"] != nil && ![result[@"name"] isEqual:[NSNull null]]) name = result[@"name"];
            if (result[@"direct_message"] != nil && ![result[@"direct_message"] isEqual:[NSNull null]]) {
                directMessage = [result[@"direct_message"] boolValue];
            }
            if([[CCCoredataBase sharedClient] updateChannelUpdatedWithUid:channelUid
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
                                                                 assignee:assignee])
            {
                NSLog(@"updateChannel Success!");
            }else{
                NSLog(@"updateChannel Error!");
            }
        }
    }
}

-(void)loadAssigneeInformation:(NSString *)channelId{
    if (![[CCConstants sharedInstance] getKeychainUid]) {
        return;
    }
    NSArray *channelArray = [[CCCoredataBase sharedClient] selectChannelWithUid:CCloadLoacalChannelLimit uid:channelId];
    if(channelArray != nil && channelArray.count > 0){
        NSManagedObject *object   = [channelArray objectAtIndex:0];
        NSData *assigneeData      = [object valueForKey:@"assignee"];
        NSDictionary *assignee    = [NSKeyedUnarchiver unarchiveObjectWithData:assigneeData];
        // Assignee
        self.assigneeID = nil;
        assignedAssigneeId = nil;
        if (assignee != nil) {
            self.assigneeID = assignee[@"id"];
            self.assigneeInfo = assignee;
            assignedAssigneeId = self.assigneeID;
            NSLog(@"loadAssigneeInformation: %@", self.assigneeID);
            [self.tableView reloadData];
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
