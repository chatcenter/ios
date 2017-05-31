//
//  CCLinearScalePaneController.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/09.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCLinearScalePaneController.h"
#import "ChatCenterPrivate.h"

@interface CCLinearScalePaneController ()

@end

#define LINEAR_MIN_VALUE    1
#define LINEAR_MAX_VALUE    5

@implementation CCLinearScalePaneController
@synthesize fromValue, toValue;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fromButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.fromButton.layer.borderWidth = 1.0;
    self.fromButton.layer.cornerRadius = 5.0f;
    self.fromButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    [self setDefautStyleForTextfield:self.fromLabelTextfield];
    self.fromValue = LINEAR_MIN_VALUE;
    
    self.toButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.toButton.layer.borderWidth = 1.0f;
    self.toButton.layer.cornerRadius = 5.0f;
    self.toButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    [self setDefautStyleForTextfield:self.toLabelTextfield];
    self.toValue = LINEAR_MAX_VALUE;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateView];
}

- (void) setDefautStyleForTextfield: (UITextField *) textField {
    textField.layer.borderWidth = 1.0f;
    textField.layer.cornerRadius = 5.0f;
    textField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    textField.placeholder = CCLocalizedString(@"Label");
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onFromButtonClicked:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (int i = 1; i <= 5; i++) {
        if (i != self.toValue) {
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%d", i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.fromValue = i;
                [self updateView];
            }];
            [actionSheet addAction:alertAction];
        }
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleDestructive handler:nil];
    [actionSheet addAction:cancelAction];
    
    
    actionSheet.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *pop = actionSheet.popoverPresentationController;
    pop.sourceView = self.fromButton;
    pop.sourceRect = self.fromButton.bounds;
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)onToButtonClicked:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (int i = 1; i <= 5; i++) {
        if (i != self.fromValue) {
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%d", i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.toValue = i;
                [self updateView];
            }];
            [actionSheet addAction:alertAction];
        }
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleDestructive handler:nil];
    [actionSheet addAction:cancelAction];
    
    actionSheet.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *pop = actionSheet.popoverPresentationController;
    pop.sourceView = self.toButton;
    pop.sourceRect = self.toButton.bounds;
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void) updateView {
    [self.fromButton setTitle:[NSString stringWithFormat:@"%d", self.fromValue] forState:UIControlStateNormal];
    self.fromValueLabel.text = [NSString stringWithFormat:@"%d", self.fromValue];
    [self.toButton setTitle:[NSString stringWithFormat:@"%d", self.toValue] forState:UIControlStateNormal];
    self.toValueLabel.text = [NSString stringWithFormat:@"%d", self.toValue];
    [self.scrollViewDelegate setScrollviewContentHeight:SCROLLVIEW_MIN_HEIGHT];
}

- (BOOL)validInput {
    if (self.fromValue == self.toValue) {
        return NO;
    }
    
    if ([[self.fromLabelTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]
        || [[self.toLabelTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (NSDictionary *)getStickerAction {
    NSMutableArray *actionData = [[NSMutableArray alloc] init];
    if (self.fromValue > self.toValue) {
        for (int i = self.fromValue; i >= self.toValue; i--) {
            [actionData addObject:@{
                                    @"label": [NSString stringWithFormat:@"%d", i],
                                    @"value": @{
                                            @"answer": @(i)
                                            }
                                    }];
        }
    } else {
        for (int i = self.fromValue; i <= self.toValue; i++) {
            [actionData addObject:@{
                                    @"label": [NSString stringWithFormat:@"%d", i],
                                    @"value": @{
                                            @"answer": @(i)
                                            }
                                    }];
        }
    }
    NSDictionary *stickerAction = @{
                                    @"action-type": @"select",
                                    @"view-info":
                                        @{
                                            @"type": @"linear",
                                            @"min-label": self.fromLabelTextfield.text,
                                            @"max-label": self.toLabelTextfield.text
                                            },
                                    @"action-data": actionData
                                    };
    return stickerAction;
}

#pragma mark - Textview delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= CCWidgetInputChoiceTextLimit;
}
@end
