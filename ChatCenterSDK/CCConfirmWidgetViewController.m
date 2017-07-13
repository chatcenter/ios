//
//  CCConfirmWidgetViewController.m
//  ChatCenterDemo
//
//  Created by VietHD on 6/29/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import "CCConfirmWidgetViewController.h"
#import "CCConfirmWidgetEditorCell.h"
#import "CCConstants.h"
#import "ChatCenterPrivate.h"
#import "UIImage+CCSDKImage.h"
#import "CCCommonWidgetPreviewViewController.h"

@interface CCConfirmWidgetViewController ()

@end

@implementation CCConfirmWidgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    UIView *leftViewModel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, self.customTextContent.frame.size.height)];
    self.customTextContent.leftView = leftViewModel;
    self.customTextContent.leftViewMode = UITextFieldViewModeAlways;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) setUp {
    _actionLabel = @[
                     @[CCLocalizedString(@"YES"),@"positive"],
                     @[CCLocalizedString(@"I got it"),@"aware"],
                     @[@"👍", @"thumbs-up"],
                     @[CCLocalizedString(@"Custom text"),@"custom"]
                     ];
    _selectedLabelIndex = 0;
    self.isCustomTextEditing = NO;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CCcancel_btn"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    cancelButton.tintColor = [[CCConstants sharedInstance] baseColor];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    self.navigationItem.rightBarButtonItem.tintColor = [[CCConstants sharedInstance] baseColor];
    self.navigationItem.title = CCLocalizedString(@"Confirm widget");
}

- (void) keyboardWillHide: (NSNotification *)notification{
    if (self.view.frame.origin.y < 0) {
        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        [UIView animateWithDuration:0.25 animations:^
         {
             CGRect newFrame = self.view.frame;
             newFrame.origin.y += keyboardSize.height;
             [self.view setFrame:newFrame];
         }completion:^(BOOL finished)
         {
         }];
    }
}

- (void) keyboardWillShow: (NSNotification *)notification {
    NSInteger lastIndex = self.actionLabel.count - 1;
    if (self.isCustomTextEditing && _selectedLabelIndex == lastIndex ) {
        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        [UIView animateWithDuration:0.25 animations:^
         {
             CGRect newFrame = self.view.frame;
             newFrame.origin.y -= keyboardSize.height;
             [self.view setFrame:newFrame];
             
         }completion:^(BOOL finished)
         {
         }];
    }
}

- (void)cancel {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextButtonPressed:(id)sender {
    [self preview];
}

- (IBAction)hideKeyboardPressed:(id)sender {
    [self.view endEditing:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _actionLabel.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCConfirmWidgetEditorCell *cell = (CCConfirmWidgetEditorCell *) [tableView dequeueReusableCellWithIdentifier:@"CCConfirmWidgetEditorCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row < self.actionLabel.count) {
        cell.contentLabel.text = _actionLabel[indexPath.row][0];
    }
    if (_selectedLabelIndex == indexPath.row) {
        cell.checkmarkIcon.image = [UIImage SDKImageNamed:@"radioButtonGreyOn"];
    } else {
        cell.checkmarkIcon.image = [UIImage SDKImageNamed:@"radioButtonGreyOff"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedLabelIndex = indexPath.row;
    [self.view endEditing:YES];
    [tableView reloadData];
}

- (BOOL) validInput {
    if (self.confirmWidgetContent.text != nil && [self.confirmWidgetContent.text length] > 0)  {
        NSInteger lastIndex = self.actionLabel.count - 1;
        if (self.selectedLabelIndex == lastIndex) {
            NSString *inputText = [_customTextContent.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (inputText.length > 0) {
                return YES;
            }
        } else {
            return YES;
        }
    }
    return NO;
}
- (void)preview {
    if ([self validInput])  {
        [self showPreviewView];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:CCLocalizedString(@"Please fill in items.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:CCLocalizedString(@"OK")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void) showPreviewView {
    CCCommonWidgetPreviewViewController *previewController = [[CCCommonWidgetPreviewViewController alloc] initWithNibName:@"CCCommonWidgetPreviewViewController" bundle:SDK_BUNDLE];
    [previewController setMessage:[self createMessage]];
    previewController.delegate = delegate;
    previewController.closeWidgetPreviewCallback = self.closeConfirmCallback;
    [self.navigationController pushViewController:previewController animated:YES];
}

- (void)setDelegate:(id)newDelegate {
    delegate = newDelegate;
}

- (CCJSQMessage *)createMessage {
    NSLog(@"Create message");
    CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:@""];
    msg.type = CC_RESPONSETYPESTICKER;
    msg.content = @{
                    @"message": @{@"text":_confirmWidgetContent.text},
                    @"sticker-action": [self getStickerAction],
                    @"sticker-type":@"confirm",
                    @"uid": [delegate generateMessageUniqueId]
                    };
    return msg;
}

-(NSDictionary *)getStickerAction {
    NSString *label;
    NSInteger lastIndex = _actionLabel.count - 1;
    NSString *type = _actionLabel[_selectedLabelIndex][1];
    if (lastIndex == _selectedLabelIndex) {
        label = self.customTextContent.text;
    } else {
        label = _actionLabel[_selectedLabelIndex][0];
    }
    NSDictionary *stickerAction = @{
                                    @"action-type": @"confirm",
                                    @"action-data":
                                        @[
                                            @{
                                                @"label": label,
                                                @"type": type,
                                                @"value": @{
                                                        @"answer":@(YES)
                                                        }
                                                }
                                            ]
                                    };
    return stickerAction;
}

#pragma mark - Text Field delegate
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    NSInteger lastIndex = self.actionLabel.count - 1;
    if (_selectedLabelIndex != lastIndex) {
        _selectedLabelIndex = lastIndex;
        [self.tableView reloadData];
    }
    self.isCustomTextEditing = YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *inputText = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    long textLenght = inputText.length;
    if (textLenght > CCWidgetInputTitleLimit) {
        [self.customTextContent resignFirstResponder];
        textField.text = [inputText substringToIndex:CCWidgetInputTitleLimit];
        CCAlertView *alert = [[CCAlertView alloc] initWithController:self title:nil message:[NSString stringWithFormat:CCLocalizedString(@"Please input %d characters or less."), CCWidgetInputTitleLimit]];
        [alert addActionWithTitle:CCLocalizedString(@"OK") handler:nil];
        [alert show];
        return NO;
    }
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    self.isCustomTextEditing = NO;
}

#pragma mark - Textview delegate
- (void)textViewDidChange:(UITextView *)textView {
    NSString *inputText = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    long textLenght = inputText.length;
    if (textLenght > CCWidgetInputTitleLimit) {
        textView.text = [inputText substringToIndex:CCWidgetInputTitleLimit];
        CCAlertView *alert = [[CCAlertView alloc] initWithController:self title:nil message:[NSString stringWithFormat:CCLocalizedString(@"Please input %d characters or less."), CCWidgetInputTitleLimit]];
        [alert addActionWithTitle:CCLocalizedString(@"OK") handler:nil];
        [alert show];
    }
}
@end
