//
//  CCAboutChatCenterViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 7/7/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCCopyrightViewController.h"
#import "ChatCenterPrivate.h"
#import "CCWebViewController.h"
#import "CCCopyrightViewCell.h"
#import "CCConstants.h"
#import "UIImage+CCSDKImage.h"

@implementation CCCopyrightViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = CCLocalizedString(@"Copyright");
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage SDKImageNamed:CC_BUTTON_PRESS_BACK] style:UIBarButtonItemStylePlain target:self action:@selector(pressBack:)];
    self.navigationItem.leftBarButtonItem = backButton;

    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableHeaderView:v];
    [self.tableView setTableFooterView:v];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 140;
    self.copyrightContent = [[NSArray alloc]initWithContentsOfFile:[SDK_BUNDLE pathForResource:@"Copyright" ofType:@"plist"]];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - table view delegate methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Number row in section = %lu", (unsigned long)self.copyrightContent.count);
    return self.copyrightContent.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    CCCopyrightViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.name.text = self.copyrightContent[row][@"name"];
    cell.content.text = self.copyrightContent[row][@"content"];
    cell.selectionStyle = UITableViewCellAccessoryNone;
    cell.content.scrollEnabled = NO;
    cell.userInteractionEnabled = NO;
    [cell.content sizeToFit];
    [cell.content layoutIfNeeded];
    
    long height = [cell.content sizeThatFits:CGSizeMake(cell.content.frame.size.width, CGFLOAT_MAX)].height;
    cell.contentHeight.constant = height;
    return cell;
    
}

- (void)pressBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
