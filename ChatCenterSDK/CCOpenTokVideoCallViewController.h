//
//  CCOpenTokVideoCallViewController.h
//  ChatCenterDemo
//
//  Created by VietHD on 11/15/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCVideoCallEventHandlerDelegate.h"

@interface CCOpenTokVideoCallViewController : UIViewController<CCVideoCallEventHandlerDelegate>
@property (strong, nonatomic) IBOutlet UIView *remoteView;
@property (strong, nonatomic) IBOutlet UIView *localView;
@property (strong, nonatomic) IBOutlet UIView *otherVideoInfoContainer;
@property (strong, nonatomic) IBOutlet UILabel *otherVideoDisabledLabel;

@property (strong, nonatomic) IBOutlet UIImageView *otherMicrophoneInfo;


@property (strong, nonatomic) IBOutlet UILabel *callingLabel;

@property (strong, nonatomic) IBOutlet UIButton *microphoneButton;
@property (strong, nonatomic) IBOutlet UIButton *hangupButton;
@property (strong, nonatomic) IBOutlet UIButton *cameraButton;

@property (nonatomic) BOOL conversationStarted;
@property (nonatomic) BOOL isCaller;
@property (strong, nonatomic) NSDictionary *publisherInfor;
@property (strong, nonatomic) NSString *videoAction;
@property (strong, nonatomic) NSString *channelUid;
@property (strong, nonatomic) NSString *messageId;
@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) NSString *sessionId;
@property BOOL publishAudio;
@property BOOL publishVideo;
@end
