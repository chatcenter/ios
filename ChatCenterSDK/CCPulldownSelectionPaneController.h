//
//  CCPulldownSelectionPaneController.h
//  ChatCenterDemo
//
//  Created by VietHD on 2017/06/02.
//  Copyright © 2017年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCQuestionEditorCellDelegate.h"
#import "CCQuestionWidgetEditorViewController.h"
#import "CCBaseQuestionWidgetPaneViewController.h"
#import "CCConstants.h"

@interface CCPulldownSelectionPaneController : CCBaseQuestionWidgetPaneViewController<UITableViewDelegate, UITableViewDataSource, CCQuestionEditorCellDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
- (BOOL) validInput;
- (NSDictionary *) getStickerAction;
@end
