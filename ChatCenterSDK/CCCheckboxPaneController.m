//
//  CCCheckboxPaneController.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/09.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCCheckboxPaneController.h"
#import "CCSingleSelectionQuestionWidgetEditorCell.h"
#import "ChatCenterPrivate.h"

@interface CCCheckboxPaneController () {
    NSMutableArray *optionLabels;
}
@end

@implementation CCCheckboxPaneController

static const float TOP_VIEW_HEIGHT        = 255;
static const float TABLEVIEW_CELL_HEIGHT  = 55;
static const float ADD_MORE_VIEW_HEIGHT   = 72;

- (void)viewDidLoad {
    [super viewDidLoad];
    optionLabels = [[NSMutableArray alloc] init];
    [optionLabels addObject:@""];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    self.tableViewHeightConstraint.constant = TABLEVIEW_CELL_HEIGHT * optionLabels.count;
    return optionLabels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float tableViewHeight = TABLEVIEW_CELL_HEIGHT * optionLabels.count;
    self.tableViewHeightConstraint.constant = tableViewHeight;
    float scrollHeight = tableViewHeight + TOP_VIEW_HEIGHT + ADD_MORE_VIEW_HEIGHT;
    if (scrollHeight < SCROLLVIEW_MIN_HEIGHT) {
        scrollHeight = SCROLLVIEW_MIN_HEIGHT;
    }
    [self.scrollViewDelegate setScrollviewContentHeight:scrollHeight];

    return TABLEVIEW_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCSingleSelectionQuestionWidgetEditorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CCCheckboxQuestionWidgetEditorCell" forIndexPath:indexPath];
    NSString *label = [optionLabels objectAtIndex:indexPath.row];
    cell.textView.layer.borderWidth = 1.0f;
    cell.textView.layer.cornerRadius = 5.0f;
    cell.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    cell.textView.leftView = paddingView;
    cell.textView.leftViewMode = UITextFieldViewModeAlways;
    cell.textView.text = label;
    cell.textView.placeholder = [NSString stringWithFormat:@"%@ %ld", CCLocalizedString(@"Option"), indexPath.row + 1];
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
    [self getDataFromTextviews];
    [optionLabels addObject:@""];
    [self.tableView reloadData];
}

- (void) getDataFromTextviews {
    for (int i = 0; i < optionLabels.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CCSingleSelectionQuestionWidgetEditorCell *theCell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (theCell != nil) {
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
                                            @"type": @"checkbox"
                                            },
                                    @"action-data": actionData
                                    };
    return stickerAction;
}
@end
