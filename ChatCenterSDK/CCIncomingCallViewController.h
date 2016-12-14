//
//  CCIncomingCallViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 11/21/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCVideoCallEventHandlerDelegate.h"
#import "CCChatViewController.h"

@interface CCIncomingCallViewController : UIViewController<CCVideoCallEventHandlerDelegate>
@property (strong, nonatomic) CCChatViewController* chatViewController;
@property (strong, nonatomic) IBOutlet UIImageView *callerAvatar;
@property (strong, nonatomic) IBOutlet UILabel *callerName;
@property (strong, nonatomic) IBOutlet UILabel *callingLabel;
@property (strong, nonatomic) IBOutlet UIButton *rejectButton;
@property (strong, nonatomic) IBOutlet UIButton *acceptVideo;
@property (strong, nonatomic) IBOutlet UIButton *acceptAudio;

@property (strong, nonatomic) NSString *channelUid;
@property (strong, nonatomic) NSString *messageId;
@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) NSString *sessionId;
@property (strong, nonatomic) NSString *actionCall;
@property (strong, nonatomic) NSDictionary *callerInfo;
@property (strong, nonatomic) NSDictionary *receiverInfo;
@end
