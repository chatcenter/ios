//
//  CCConfirmWidgetViewController.h
//  ChatCenterDemo
//
//  Created by VietHD on 6/29/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCConfirmWidgetViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate> {
    id delegate;
}

@property (weak, nonatomic) IBOutlet UITextView *confirmWidgetContent;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *customTextContent;

@property NSInteger selectedLabelIndex;
@property (nonatomic, strong) NSArray *actionLabel;
@property BOOL isCustomTextEditing;
@property (nullable, nonatomic, copy) void (^closeConfirmCallback)(void);
- (void)setDelegate: (id _Nullable )newDelegate;

@end
