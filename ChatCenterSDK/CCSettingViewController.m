//
//  CCSettingViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/11/17.
//  Copyright © 2015年 AppSocially Inc. All rights reserved.
//

#import "CCSettingViewController.h"
#import "ChatCenterPrivate.h"
#import "CCWebViewController.h"

@interface CCSettingViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation CCSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = CCLocalizedString(@"About this app");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                          target:self
                                                                                          action:@selector(pressClose:)];
    ///Disappearing boarder of void cells
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableHeaderView:v];
    [self.tableView setTableFooterView:v];
    self.tableView.separatorInset = UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = CCLocalizedString(@"Terms of service");
            break;
        case 1:
            cell.textLabel.text = CCLocalizedString(@"Privacy policy");
            break;
        default:
            break;
    }
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *urlString, *title;
    switch (indexPath.row) {
        case 0:
            urlString = @"https://www.chatcenter.io/termsofservice/";
            title = CCLocalizedString(@"Terms of service");
            break;
        case 1:
            urlString = @"https://www.chatcenter.io/privacypolicy/";
            title = CCLocalizedString(@"Privacy policy");
            break;
        default:
            break;
    }
    if (urlString != nil) {
        [self pushWebView:urlString title:title];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)pressClose:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pushWebView:(NSString *)urlString title:(NSString *)title{
    CCWebViewController *webViewController = [[CCWebViewController alloc] initWithURL:urlString title:title];
    [self.navigationController pushViewController:webViewController animated:YES];
}

@end
