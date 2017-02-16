//
//  CCLiveLocationWebviewController.h
//  ChatCenterDemo
//
//  Created by VietHD on 12/21/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCChatViewController.h"

@interface CCLiveLocationWebviewController : UIViewController<UIWebViewDelegate>
@property (strong, nonatomic) NSString *channelID;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *liveLocationActionButton;
@property (weak, nonatomic) IBOutlet UILabel *lbStopStartSharingLocation;

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic) BOOL isSharingLocation;
@property id<CCLiveLocationWidgetDelegate> delegate;
///
/// To check if other user share live location on existing widget
///
@property (nonatomic) BOOL isOpenedFromWidgetMessage;
@end
