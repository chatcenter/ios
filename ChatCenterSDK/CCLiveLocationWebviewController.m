//
//  CCLiveLocationWebviewController.m
//  ChatCenterDemo
//
//  Created by VietHD on 12/21/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCLiveLocationWebviewController.h"
#import "ChatCenterPrivate.h"
#import "CCLiveLocationStickerViewController.h"
#import "CCConnectionHelper.h"
#import "CCConstants.h"

@interface CCLiveLocationWebviewController () {
    UILabel *liveLabel;
}
@end

@implementation CCLiveLocationWebviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

-(void)setupView {
    self.navigationController.navigationBar.tintColor = [[CCConstants sharedInstance] baseColor];
    self.navigationItem.title = CCLocalizedString(@"Live Location");
    self.automaticallyAdjustsScrollViewInsets = NO;
    _liveLocationActionButton.layer.borderWidth = 1;
    _liveLocationActionButton.layer.cornerRadius = 5;
    _liveLocationActionButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    if(!_isSharingLocation) {
        [_liveLocationActionButton setTitle:CCLocalizedString(@"Share my Live Location") forState:UIControlStateNormal];
    } else {
        [_liveLocationActionButton setTitle:CCLocalizedString(@"Stop") forState:UIControlStateNormal];

    }

}

-(void) addLiveLabel {
    liveLabel = [[UILabel alloc] init];
    liveLabel.textAlignment = NSTextAlignmentCenter;
    liveLabel.text = CCLocalizedString(@"Live");
    liveLabel.font = [UIFont boldSystemFontOfSize:12.0];
    liveLabel.textColor = [UIColor whiteColor];
    liveLabel.backgroundColor = [UIColor colorWithRed:250.0/255 green:81.0/255 blue:92.0/255 alpha:1];
    liveLabel.layer.cornerRadius = 5;
    liveLabel.clipsToBounds = YES;
    liveLabel.frame = CGRectMake(self.view.frame.size.width - 40, 13, 30, 18);
    [self.navigationController.navigationBar addSubview:liveLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSURL *URL = [NSURL URLWithString:self.urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:request];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addLiveLabel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [liveLabel removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidStartLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)webViewDidFinishLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    return YES;
}

- (IBAction)onLiveLocationButtonClicked:(id)sender {
    if(_isSharingLocation) {
        [self.delegate didStopSharingLiveLocation];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable && [CCConnectionHelper sharedClient].webSocketStatus == CCCWebSocketOpened) || CCLocalDevelopmentMode) {
            CCLiveLocationStickerViewController *locationStickerViewController = [[CCLiveLocationStickerViewController alloc] initWithNibName:@"CCLiveLocationStickerViewController" bundle:SDK_BUNDLE];
            locationStickerViewController.liveLocationWidgetDelegate = self.delegate;
            locationStickerViewController.isOpenedFromWidgetMessage = YES;
            NSMutableArray *viewControllers = [[self.navigationController viewControllers] mutableCopy];
            [viewControllers removeLastObject];
            [viewControllers addObject:locationStickerViewController];
            [self.navigationController setViewControllers:viewControllers animated:YES];
            return;
        }else{
            [[CCConnectionHelper sharedClient] displyAlert:CCLocalizedString(@"Connection Failed") message:nil alertType:SingleButtonAlert];
        }
    }
}

@end
