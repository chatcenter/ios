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
#import "CCLiveLocationTask.h"
#import "CCConstants.h"

@interface CCLiveLocationWebviewController () {
    UILabel *liveLabel;
    NSTimer *timer;
    CCLiveLocationTask *task;
    int duration;
    int sharedTime;
}
@end

@implementation CCLiveLocationWebviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    task = [[CCConnectionHelper sharedClient].shareLocationTasks objectForKey:self.channelID];
    if (_isSharingLocation && task != nil) {
        sharedTime = task.liveColocationShareTimer;
        duration = task.liveColocationShareDuration * 60 - sharedTime;
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
        _lbStopStartSharingLocation.text = CCLocalizedString(@"Stop");
    }
    [self setupView];
}

-(void)setupView {
    self.navigationItem.title = CCLocalizedString(@"Live Location");
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(pressBack)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _liveLocationActionButton.layer.borderWidth = 1;
    _liveLocationActionButton.layer.cornerRadius = 5;
    _liveLocationActionButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    if(!_isSharingLocation) {
        _lbStopStartSharingLocation.text = CCLocalizedString(@"Share my Live Location");
    }
}

-(void) pressBack {
    [self.navigationController popViewControllerAnimated:YES];
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
    [self stopTimer];
}

- (void) stopTimer {
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
        if (_isSharingLocation) {
            task = [[CCConnectionHelper sharedClient].shareLocationTasks objectForKey:self.channelID];
            if (task != nil) {
                task.liveColocationShareTimer = sharedTime;
                [[CCConnectionHelper sharedClient].shareLocationTasks setObject:task forKey:self.channelID];
            }
        }
    }
}

- (void) updateTimer {
    sharedTime += 1;
    int remainingTime = duration - sharedTime;
    if (remainingTime < 0) {
        remainingTime = 0;
        _lbStopStartSharingLocation.text = CCLocalizedString(@"Share my Live Location");
        _isSharingLocation = NO;
        [self.delegate didStopSharingLiveLocation];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    NSString *timeString = [self getFormattedTimeString:remainingTime];
    _lbStopStartSharingLocation.text = timeString;
}

- (NSString *) getFormattedTimeString:(int) time {
    int hours = time / 3600;
    int minutes = (time - hours * 3600) / 60;
    int seconds = time - hours * 3600 - minutes * 60;
    
    if (hours > 0) {
            return [NSString stringWithFormat:@"%@\n%@", CCLocalizedString(@"Stop"), [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds]];
    } else {
        return [NSString stringWithFormat:@"%@\n%@", CCLocalizedString(@"Stop"), [NSString stringWithFormat:@"%02d:%02d", minutes, seconds]];
    }
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
        _isSharingLocation = NO;
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
