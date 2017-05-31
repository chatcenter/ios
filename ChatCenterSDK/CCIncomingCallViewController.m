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
    [[CCConnectionHelper sharedClient] rejectCall:self.channelUid messageId:self.messageId reason:@{@"type": @"error", @"message": @"Invite to Participant was canceled"} user:@{@"user_id":@([uid integerValue])}  completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)acceptVideo:(id)sender {
    [[CCConnectionHelper sharedClient] acceptCall:self.channelUid messageId:self.messageId user:@{@"user_id":@([uid integerValue])}   completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
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
    [[CCConnectionHelper sharedClient] acceptCall:self.channelUid messageId:self.messageId user:@{@"user_id":@([uid integerValue])}   completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
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
    NSArray *receivers = content[@"receivers"];
    NSDictionary *caller = content[@"caller"];
    if (events == nil) {
        return;
    }
    
    BOOL needHandleReject = NO;
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
            needHandleReject = YES;
        }
        if ([action isEqualToString:@"accept"]) {
            [self handleAccept:eventContent];
            return;
        }
    }
    if (needHandleReject) {
        [self handleReject:receivers caller:caller events:events];
    }
}

- (void) handleReject:(NSArray *)receivers caller:(NSDictionary *)caller events:(NSArray *)events {
    BOOL needCloseView = NO;
    
    if (events == nil) {
        return;
    }
    ///
    /// 1. Filter reject events
    ///
    NSMutableArray *rejectEvents = [NSMutableArray array];
    for(NSDictionary *event in events) {
        NSDictionary *eventContent = event[@"content"];
        if(eventContent == nil ) {
            return;
        }
        NSString *action = eventContent[@"action"];
        if(action == nil) {
            return;
        }
        if ([action isEqualToString:@"reject"]) {
            [rejectEvents addObject:event];
        }
    }
    
    ///
    /// Case-1: If rejected user in receivers and the user's id is same with the current user's id
    /// Or rejected user is caller then dismiss incoming view.
    ///
    for (NSDictionary *event in rejectEvents) {
        NSDictionary *eventContent = event[@"content"];
        if(eventContent == nil ) {
            continue;
        }

        NSString *action = eventContent[@"action"];
        if(action == nil) {
            continue;
        }
        
        NSString *rejectedUserId = [eventContent[@"user"][@"user_id"] stringValue];
        BOOL rejectedUserInReceivers = NO;
        for(NSDictionary *user in receivers) {
            NSString *userID = [[user objectForKey:@"user_id"] stringValue];
            if (userID != nil && [userID isEqualToString:rejectedUserId]) {
                rejectedUserInReceivers = YES;
                break;
            }
        }
        NSString *callerId = [[caller objectForKey:@"user_id"] respondsToSelector:@selector(stringValue)] ? [[caller objectForKey:@"user_id"] stringValue]: [caller objectForKey:@"user_id"];
        if ((!rejectedUserInReceivers && [callerId isEqualToString:rejectedUserId])|| (rejectedUserInReceivers && [rejectedUserId isEqualToString:uid])) {
            needCloseView = YES;
            break;
        }
    }
    
    ///
    /// Case-2: All receivers already rejected
    ///
    NSMutableArray *tempReceivers = [receivers mutableCopy];
    for (NSDictionary *event in rejectEvents) {
        NSDictionary *eventContent = event[@"content"];
        if(eventContent == nil ) {
            continue;
        }
        
        NSString *action = eventContent[@"action"];
        if(action == nil) {
            continue;
        }
        NSString *rejectedUserId = [eventContent[@"user"][@"user_id"] stringValue];
        for(NSDictionary *user in tempReceivers) {
            NSString *userID = [[user objectForKey:@"user_id"] stringValue];
            if (userID != nil && [userID isEqualToString:rejectedUserId]) {
                [tempReceivers removeObject:user];
                break;
            }
        }
    }
    
    if ([tempReceivers count] == 0) {
        needCloseView = YES;
    }
    
    if (needCloseView) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) handleAccept: (NSDictionary *)content {
    ///
    /// Close incoming call view if other agent already accepted the call
    ///
    BOOL otherAcceptedCall = YES;
    NSString *acceptedUserId = [content[@"user"][@"user_id"] stringValue];
    if([acceptedUserId isEqualToString:uid]) {
        otherAcceptedCall = NO;
    }
    
    if (otherAcceptedCall) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
