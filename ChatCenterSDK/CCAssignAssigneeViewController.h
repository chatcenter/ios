//
//  CCAssignAssigneeViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 7/6/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCAssignAssigneeViewController: UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *orgUid;
@property (nonatomic, strong) NSString *channelUid;
@property (nonatomic, strong) NSMutableArray *agents;
@property (nonatomic, strong) NSString *assigneeID;//assigned
@property (nonatomic, strong) NSDictionary *assigneeInfo;
@property (nonatomic, strong) NSMutableArray *followings;
-(void)setAssigneeID: (NSString *)channelId;
-(void)loadAgentWithOrgID: (NSString *) orgUid;
@end
