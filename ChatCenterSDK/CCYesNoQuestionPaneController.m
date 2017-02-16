//
//  CCYesNoQuestionPaneController.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/09.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCYesNoQuestionPaneController.h"
#import "CCYesNoQuestionWidgetEditorCell.h"
#import "CCQuestionWidgetEditorViewController.h"
#import "UIImage+CCSDKImage.h"

@interface CCYesNoQuestionPaneController () {
}
@property (nonatomic, strong) NSArray *actionLabel;
@property NSInteger selectedLabelIndex;
@end

@implementation CCYesNoQuestionPaneController

- (void)viewDidLoad {
    [super viewDidLoad];
    _actionLabel = @[
                     @[@"Yes", @"No"],
                     @[@"👍", @"👎"]
                     ];
    _selectedLabelIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.scrollViewDelegate setScrollviewContentHeight:SCROLLVIEW_MIN_HEIGHT];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _actionLabel.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCYesNoQuestionWidgetEditorCell *cell = (CCYesNoQuestionWidgetEditorCell *) [tableView dequeueReusableCellWithIdentifier:@"CCYesNoQuestionWidgetEditorCell" forIndexPath:indexPath];
    cell.yesLabel.text = _actionLabel[indexPath.row][0];
    cell.noLabel.text = _actionLabel[indexPath.row][1];
    if (_selectedLabelIndex == indexPath.row) {
        cell.checkmarkIcon.image = [UIImage SDKImageNamed:@"radioButtonGreyOn"];
    } else {
        cell.checkmarkIcon.image = [UIImage SDKImageNamed:@"radioButtonGreyOff"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedLabelIndex = indexPath.row;
    [tableView reloadData];
}

- (BOOL)validInput {
    return YES;
}

-(NSDictionary *)getStickerAction {
    NSDictionary *stickerAction = @{
                                    @"action-type": @"select",
                                    @"view-info":
                                            @{
                                                @"type": @"yesno"
                                            },
                                    @"action-data":
                                            @[
                                                @{
                                                    @"label": _actionLabel[_selectedLabelIndex][0],
                                                    @"value": @{
                                                            @"answer":@(YES)
                                                            }
                                                },
                                                @{
                                                    @"label": _actionLabel[_selectedLabelIndex][1],
                                                    @"value": @{
                                                            @"answer":@(NO)
                                                            }
                                                }
                                            ]
                                    };
    return stickerAction;
}
@end
