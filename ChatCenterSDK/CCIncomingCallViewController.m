//
//  CCIncomingCallViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 11/21/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCIncomingCallViewController.h"
#import "ChatCenterPrivate.h"
#import "CCOpenTokVideoCallViewController.h"
#import "CCConnectionHelper.h"
#import "CCConstants.h"

@interface CCIncomingCallViewController () {
    NSString *uid;
}

@end

@implementation CCIncomingCallViewController

#define CC_CALLER_AVATAR_SIZE   80

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    uid = [[CCConstants sharedInstance] getKeychainUid];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupView];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void) setupView {
    //
    // Caller information
    //
    if (self.callerInfo[@"display_name"] != nil) {
        self.callerName.text = self.callerInfo[@"display_name"];
    } else {
        self.callerName.text = @"";
    }
    [self setupCallerAvatar];
    self.callingLabel.text = CCLocalizedString(@"is calling you...");
    
    // Audio or Video call
    if ([self.actionCall isEqualToString:CC_ACTIONTYPE_VOICECALL]) {
        self.acceptVideo.hidden = YES;
    }
}

- (void) setupCallerAvatar {
    self.callerAvatar.layer.cornerRadius = CC_CALLER_AVATAR_SIZE / 2;
    self.callerAvatar.clipsToBounds = YES;
    if(self.callerInfo[@"icon_url"] != nil && !([self.callerInfo[@"icon_url"] isEqual:[NSNull null]])) {
        dispatch_queue_t q_main   = dispatch_get_main_queue();
        NSError *error = nil;
        NSData *dt = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.callerInfo[@"icon_url"]]
                                           options:NSDataReadingUncached
                                             error:&error];
        dispatch_async(q_main, ^{
            UIImage *newIconImage = [[UIImage alloc] initWithData:dt scale:[UIScreen mainScreen].scale];
            if (newIconImage != nil) {
                self.callerAvatar.image = newIconImage;
            }
        });
        return;
    }
    
    CGFloat avatarFontSize = CC_CALLER_AVATAR_SIZE * 0.75;
    CGFloat avatarTextOffset = 1.0f + (CC_CALLER_AVATAR_SIZE - 24.0f) * 0.0625;
    NSString *firstCharacter = [self.callerInfo[@"display_name"] substringToIndex:1];
    UIImage *textIconImage = [[ChatCenter sharedInstance] createAvatarImage:firstCharacter width:CC_CALLER_AVATAR_SIZE height:CC_CALLER_AVATAR_SIZE color:[[ChatCenter sharedInstance] getRandomColor:self.callerInfo[@"user_id"]] fontSize:avatarFontSize textOffset:avatarTextOffset];
    if (textIconImage != nil) {
        self.callerAvatar.image = textIconImage;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)reject:(id)sender {
    [[CCConnectionHelper sharedClient] rejectCall:self.channelUid messageId:self.messageId reason:@{@"type": @"error", @"message": @"Invite to Participant was canceled"} user:@{@"user_id":uid}  completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)acceptVideo:(id)sender {
    [[CCConnectionHelper sharedClient] acceptCall:self.channelUid messageId:self.messageId user:@{@"user_id":uid}   completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        if (error == nil) {
            CCOpenTokVideoCallViewController *videoCallVC = [[CCOpenTokVideoCallViewController alloc] initWithNibName:@"CCOpenTokVideoCallViewController" bundle:SDK_BUNDLE];
            videoCallVC.isCaller = NO;
            videoCallVC.channelUid = self.channelUid;
            videoCallVC.messageId = self.messageId;
            videoCallVC.publisherInfor = self.receiverInfo;
            videoCallVC.videoAction = self.actionCall;
            videoCallVC.apiKey = self.apiKey;
            videoCallVC.sessionId = self.sessionId;
            videoCallVC.publishAudio = YES;
            videoCallVC.publishVideo = YES;
            self.chatViewController.delegateCall = videoCallVC;

            NSMutableArray *viewControllers = [[self.navigationController viewControllers] mutableCopy];
            [viewControllers removeObjectAtIndex:viewControllers.count - 1];
            [viewControllers addObject:videoCallVC];
            [self.navigationController setViewControllers:viewControllers animated:YES];
        } else {
            // Error occurred
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (IBAction)acceptAudio:(id)sender {
    [[CCConnectionHelper sharedClient] acceptCall:self.channelUid messageId:self.messageId user:@{@"user_id":uid}   completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        if (error == nil) {
            CCOpenTokVideoCallViewController *videoCallVC = [[CCOpenTokVideoCallViewController alloc] initWithNibName:@"CCOpenTokVideoCallViewController" bundle:SDK_BUNDLE];
            videoCallVC.isCaller = NO;
            videoCallVC.channelUid = self.channelUid;
            videoCallVC.messageId = self.messageId;
            videoCallVC.publisherInfor = self.receiverInfo;
            videoCallVC.videoAction = self.actionCall;
            videoCallVC.apiKey = self.apiKey;
            videoCallVC.sessionId = self.sessionId;
            videoCallVC.publishAudio = YES;
            videoCallVC.publishVideo = NO;
            self.chatViewController.delegateCall = videoCallVC;
            
            NSMutableArray *viewControllers = [[self.navigationController viewControllers] mutableCopy];
            [viewControllers removeObjectAtIndex:viewControllers.count - 1];
            [viewControllers addObject:videoCallVC];
            [self.navigationController setViewControllers:viewControllers animated:YES];
        } else {
            // Error occurred
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark - CCVideoCallEventHandlerDelegate
- (void)handleCallEvent:(NSString *)messageId content:(NSDictionary *)content {
    NSArray *events = content[@"events"];
    if (events == nil) {
        return;
    }
    for (int i = 0; i < events.count; i++) {
        NSDictionary *eventContent = events[i][@"content"];
        if(eventContent == nil ) {
            return;
        }
        NSString *action = eventContent[@"action"];
        if(action == nil) {
            return;
        }
        if ([action isEqualToString:@"reject"]) {
            [self handleReject];
        }
        if ([action isEqualToString:@"accept"]) {
            [self handleAccept:content];
        }
    }
}

- (void) handleReject {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) handleAccept: (NSDictionary *)content {
    NSArray *receivers = content[@"receivers"];
    NSLog(@"Receivers = %@", receivers);
    BOOL otherAcceptedCall = YES;
    for (NSDictionary *receiver in receivers) {
        NSString *receiverId = [[receiver valueForKey:@"user_id"] stringValue];
        if([receiverId isEqualToString:uid]) {
            otherAcceptedCall = NO;
            break;
        }
    }
    
    if (otherAcceptedCall) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
