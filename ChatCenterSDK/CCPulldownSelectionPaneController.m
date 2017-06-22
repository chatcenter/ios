//
//  CCPulldownSelectionPaneController.h
//  ChatCenterDemo
//
//  Created by VietHD on 2017/06/02.
//  Copyright © 2017年 AppSocially Inc. All rights reserved.
//

#import "CCPulldownSelectionPaneController.h"
#import "CCSingleSelectionQuestionWidgetEditorCell.h"
#import "ChatCenterPrivate.h"

@interface CCPulldownSelectionPaneController () {
    NSMutableArray *optionLabels;
    UIView *viewToShow;
}
@end

@implementation CCPulldownSelectionPaneController
CGFloat keyboardHeight;

static const float TOP_VIEW_HEIGHT        = 255;
static const float TABLEVIEW_CELL_HEIGHT  = 55;
static const float ADD_MORE_VIEW_HEIGHT   = 72;

- (void)viewDidLoad {
    [super viewDidLoad];
    optionLabels = [[NSMutableArray alloc] init];
    [optionLabels addObject:@""];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    keyboardHeight = kbSize.height + 40;
    [self.scrollViewDelegate setViewMovedUp:keyboardHeight viewToShow:viewToShow];
}

-(void)keyboardWillHide:(NSNotification*)aNotification  {
    keyboardHeight = 0;
    [self.scrollViewDelegate setViewMovedUp:0 viewToShow:viewToShow];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate & TableView Datasource Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    float tableViewHeight = TABLEVIEW_CELL_HEIGHT * optionLabels.count;
    self.tableViewHeightConstraint.constant = tableViewHeight;
    float scrollHeight = tableViewHeight + TOP_VIEW_HEIGHT + ADD_MORE_VIEW_HEIGHT;
    if (scrollHeight < SCROLLVIEW_MIN_HEIGHT) {
        scrollHeight = SCROLLVIEW_MIN_HEIGHT;
    }
    [self.scrollViewDelegate setScrollviewContentHeight:scrollHeight];
    return optionLabels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TABLEVIEW_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCSingleSelectionQuestionWidgetEditorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CCSingleSelectionQuestionWidgetEditorCell" forIndexPath:indexPath];
    NSString *label = [optionLabels objectAtIndex:indexPath.row];
    cell.textView.layer.borderWidth = 1.0f;
    cell.textView.layer.cornerRadius = 5.0f;
    cell.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    cell.textView.leftView = paddingView;
    cell.textView.leftViewMode = UITextFieldViewModeAlways;
    cell.textView.placeholder = [NSString stringWithFormat:@"%@ %ld", CCLocalizedString(@"Option"), (long) (indexPath.row + 1)];
    cell.textView.text = label;
    cell.textView.delegate = self;
    cell.index = indexPath.row;
    cell.delegate = self;
    if(optionLabels.count == 1 && indexPath.row == 0) {
        cell.deleteButton.hidden = true;
    } else {
        cell.deleteButton.hidden = false;
    }
    return cell;
}

- (void)deleteCell:(NSInteger)index {
    [self getDataFromTextviews];
    if (optionLabels.count > 1) {
        [optionLabels removeObjectAtIndex:index];
    }
    [self.tableView reloadData];
}

- (IBAction)addOption:(id)sender {
    NSInteger numberOption = [optionLabels count];
    if (numberOption >= CCWidgetInputNumberChoiceLimit) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:CCLocalizedString(@"Please select up to %d choices"), CCWidgetInputNumberChoiceLimit] message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:okAction];
        [self presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    
    [self getDataFromTextviews];
    [optionLabels addObject:@""];
    [self.tableView reloadData];
}

- (void) getDataFromTextviews {
    for (int i = 0; i < optionLabels.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CCSingleSelectionQuestionWidgetEditorCell *theCell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (theCell != nil && theCell.textView.text.length != 0) {
            optionLabels[i] = theCell.textView.text;
        }
    }
}

- (BOOL)validInput {
    for (int i = 0; i < optionLabels.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CCSingleSelectionQuestionWidgetEditorCell *theCell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (theCell != nil && ![[theCell.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            return YES;
        }
    }
    return NO;
}

-(NSDictionary *)getStickerAction {
    NSMutableArray *actionData = [[NSMutableArray alloc] init];
    int value = 1;
    for (int i = 0; i < optionLabels.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CCSingleSelectionQuestionWidgetEditorCell *theCell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (theCell != nil && ![[theCell.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            [actionData addObject:@{
                                    @"label": theCell.textView.text,
                                    @"value": @{
                                            @"answer": [NSString stringWithFormat:@"%d", value]
                                            }
                                    }];
            value ++;
        }
    }
    NSDictionary *stickerAction = @{
                                    @"action-type": @"select",
                                    @"view-info":
                                        @{
                                            @"type": @"selectbox"
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
    if (newLength >= CCWidgetInputChoiceTextLimit) {
        CCAlertView *alert = [[CCAlertView alloc] initWithController:self title:nil message:[NSString stringWithFormat:CCLocalizedString(@"Please input %d characters or less."), CCWidgetInputChoiceTextLimit]];
        [alert addActionWithTitle:CCLocalizedString(@"OK") handler:nil];
        [alert show];
    }
    return newLength <= CCWidgetInputChoiceTextLimit;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIScreen *screen = [UIScreen mainScreen];
    float y = screen.bounds.size.height - textField.bounds.origin.y;
    NSLog(@"textFieldDidBeginEditing = %f", y);
    
    viewToShow = textField;
    
    if (keyboardHeight>0) {
        //        [self.scrollViewDelegate setViewMovedUp:keyboardHeight];
    }
}
@end
