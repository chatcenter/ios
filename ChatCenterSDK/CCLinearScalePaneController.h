//
//  CCLinearScalePaneController.h
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/09.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCQuestionWidgetEditorViewController.h"
#import "CCBaseQuestionWidgetPaneViewController.h"
#import "CCConstants.h"

@interface CCLinearScalePaneController : CCBaseQuestionWidgetPaneViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIButton *fromButton;
@property (strong, nonatomic) IBOutlet UILabel *fromValueLabel;
@property (strong, nonatomic) IBOutlet UITextField *fromLabelTextfield;

@property (strong, nonatomic) IBOutlet UIButton *toButton;
@property (strong, nonatomic) IBOutlet UILabel *toValueLabel;
@property (strong, nonatomic) IBOutlet UITextField *toLabelTextfield;
@property int fromValue;
@property int toValue;
- (BOOL) validInput;
- (NSDictionary *) getStickerAction;
@end
