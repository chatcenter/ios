//
//  CCCheckboxPaneController.h
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/09.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCQuestionEditorCellDelegate.h"
#import "CCQuestionWidgetEditorViewController.h"
#import "CCBaseQuestionWidgetPaneViewController.h"

@interface CCCheckboxPaneController : CCBaseQuestionWidgetPaneViewController<UITableViewDelegate, UITableViewDataSource, CCQuestionEditorCellDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
- (BOOL) validInput;
- (NSDictionary *) getStickerAction;
@end
