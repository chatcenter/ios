//
//  CCAssignAssigneeViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 7/6/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCAsignFollowerViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *orgUid;
@property (nonatomic, strong) NSString *channelUid;
@property (nonatomic, strong) NSMutableArray *agents;
@property (nonatomic, strong) NSMutableArray *followings;
@property (nonatomic, strong) NSDictionary *assigneeInfo;
-(void)loadAgentWithOrgID: (NSString *) orgUid;
@end
