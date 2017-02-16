//
//  CCAboutChatCenterViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 7/7/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCAboutChatCenterViewController.h"
#import "ChatCenterPrivate.h"
#import "CCWebViewController.h"
#import "CCCopyrightViewController.h"
#import "CCConstants.h"
#import <SafariServices/SafariServices.h>

#define ROW_HEIGHT 40

@implementation CCAboutChatCenterViewController
- (void)awakeFromNib {
    [super awakeFromNib];
    _isOpenedFromRightMenu = YES;
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = CCLocalizedString(@"About ChatCenter IO");
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                  target:self
                                                  action:@selector(pressClose:)];
    closeButton.tintColor = [CCConstants sharedInstance].baseColor;
    self.navigationItem.leftBarButtonItem = closeButton;
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableHeaderView:v];
    [self.tableView setTableFooterView:v];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.deviceLanguage = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - table view delegate methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = CCLocalizedString(@"About ChatCenter IO");
            break;
        case 1:
            cell.textLabel.text = CCLocalizedString(@"Terms of service");
            break;
        case 2:
            cell.textLabel.text = CCLocalizedString(@"Privacy policy");
            break;
        case 3:
            cell.textLabel.text = CCLocalizedString(@"Service Level Agreement");
            break;
        case 4:
            cell.textLabel.text = CCLocalizedString(@"Copyright");
            break;
        default:
            break;
    }
    return cell;
 
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *urlString, *title;
    switch (indexPath.row) {
        case 0:
            if([self.deviceLanguage isEqualToString:@"ja"]) {
                urlString = @"https://www.chatcenter.io/ja/";
            } else {
                urlString = @"https://www.chatcenter.io/";
            }
            title = CCLocalizedString(@"About ChatCenter IO");
            break;
        case 1:
            urlString = @"https://www.chatcenter.io/termsofservice/";
            title = CCLocalizedString(@"Terms of service");
            break;
        case 2:
            urlString = @"https://www.chatcenter.io/privacypolicy/";
            title = CCLocalizedString(@"Privacy policy");
            break;
        case 3:
            urlString = @"https://www.chatcenter.io/sla/";
            title = CCLocalizedString(@"Service Level Agreement");
            break;
        case 4:
            title = CCLocalizedString(@"Copyright");
            break;
        default:
            break;
    }
    if (indexPath.row != 4) {
        if (urlString != nil) {
            [self pushWebView:urlString title:title];
        }
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter" bundle:SDK_BUNDLE];
        CCCopyrightViewController *viewController = [storyboard  instantiateViewControllerWithIdentifier:@"CCCopyrightViewController"];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}

- (void)pressClose:(id)sender{
    if (_isOpenedFromRightMenu ) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)pushWebView:(NSString *)urlString title:(NSString *)title{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(osVersion >= 9.0) {
        SFSafariViewController *webViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:urlString] entersReaderIfAvailable:YES];
        webViewController.view.tintColor = [[CCConstants sharedInstance] headerItemColor];
        [self presentViewController:webViewController animated:YES completion:nil];
        return;
    }
#endif
    CCWebViewController *webViewController = [[CCWebViewController alloc] initWithURL:urlString title:title];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:webViewController animated:YES];
}
@end
