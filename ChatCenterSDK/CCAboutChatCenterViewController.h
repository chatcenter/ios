//
//  CCAboutChatCenterViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 7/7/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCAboutChatCenterViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *deviceLanguage;
@property (nonatomic) BOOL isOpenedFromRightMenu;
@end
