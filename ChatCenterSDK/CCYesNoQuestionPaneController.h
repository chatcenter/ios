//
//  CCYesNoQuestionPaneController.h
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/09.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCQuestionWidgetEditorViewController.h"
#import "CCBaseQuestionWidgetPaneViewController.h"

@interface CCYesNoQuestionPaneController : CCBaseQuestionWidgetPaneViewController<UITableViewDataSource, UITableViewDelegate>
- (NSDictionary *) getStickerAction;
- (BOOL) validInput;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
