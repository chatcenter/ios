//
//  CCOpenTokVideoCallViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 11/15/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//
#import "CCConstants.h"
#import "CCOpenTokVideoCallViewController.h"
#import <OpenTok/OpenTok.h>
#import "OTDefaultAudioDeviceWithVolumeControl.h"
#import "ChatCenterPrivate.h"
#import "CCConnectionHelper.h"
#import "CCVideoCallEventHandlerDelegate.h"
#import "CCConstants.h"
#import "UIImage+CCSDKImage.h"

@interface CCOpenTokVideoCallViewController ()<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>

@end

@implementation CCOpenTokVideoCallViewController {
    OTSession* _session;
    OTPublisher* _publisher;
    OTSubscriber* _subscriber;
    OTDefaultAudioDeviceWithVolumeControl* audioDevice;
    CGRect remoteViewRect;
    CGRect localViewRect;
    
    UIImage *microphoneOnImage;
    UIImage *microphoneOffImage;
    UIImage *cameraOnImage;
    UIImage *cameraOffImage;
    
    BOOL isClosed;
}

#define LOCAL_CAMERA_VIEW_WIDTH     128.0
#define LOCAL_CAMERA_VIEW_HEIGHT    128.0

// Change to NO to subscribe to streams other than your own.
static bool subscribeToSelf = NO;
    
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    audioDevice = [OTDefaultAudioDeviceWithVolumeControl sharedInstance];
    [OTAudioDeviceManager setAudioDevice:audioDevice];
    
    _session = [[OTSession alloc] initWithApiKey:self.apiKey
                                       sessionId:self.sessionId
                                        delegate:self];
    
    [self doConnect];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self viewSetup];
}

- (void) viewSetup {
    if (_isCaller) {
        _callingLabel.text = CCLocalizedString(@"Calling...");
    } else {
        _callingLabel.hidden = YES;
    }
    microphoneOnImage = [UIImage SDKImageNamed:@"micOn_btn"];
    microphoneOffImage = [UIImage SDKImageNamed:@"micOff_btn"];
    [_microphoneButton setImage:microphoneOnImage forState:UIControlStateNormal];
    
    cameraOnImage = [UIImage SDKImageNamed:@"cameraOn_btn"];
    cameraOffImage = [UIImage SDKImageNamed:@"cameraOff_btn"];
    [_cameraButton setImage:cameraOnImage forState:UIControlStateNormal];
    
    [self.view bringSubviewToFront:self.otherMicrophoneInfo];
    if (self.publishAudio) {
        [_microphoneButton setImage:microphoneOnImage forState:UIControlStateNormal];
    } else {
        [_microphoneButton setImage:microphoneOffImage forState:UIControlStateNormal];
    }
    
    if (self.publishVideo) {
        [_cameraButton setImage:cameraOnImage forState:UIControlStateNormal];
    } else {
        [_cameraButton setImage:cameraOffImage forState:UIControlStateNormal];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
    {
        // Return YES for supported orientations
        if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice]
                                          userInterfaceIdiom])
        {
            return NO;
        } else {
            return YES;
        }
    }

    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

    /**
     * Asynchronously begins the session connect process. Some time later, we will
     * expect a delegate method to call us back with the results of this action.
     */
- (void)doConnect
{
    OTError *error = nil;
    NSString *token = self.publisherInfor[@"token"];
    [_session connectWithToken:token error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
}

    /**
     * Sets up an instance of OTPublisher to use with this session. OTPubilsher
     * binds to the device camera and microphone, and will provide A/V streams
     * to the OpenTok session.
     */
- (void)doPublish
{
    self.conversationStarted = NO;
    if ([self.videoAction isEqualToString:@"audio"]) {
        _publisher = [[OTPublisher alloc] initWithDelegate:self name:[[UIDevice currentDevice] name] audioTrack:YES videoTrack:NO];
    } else {
        _publisher = [[OTPublisher alloc] initWithDelegate:self name:[[UIDevice currentDevice] name]];
    }
    
    OTError *error = nil;
    [_session publish:_publisher error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
    localViewRect = _localView.frame;
    [self.view addSubview:_publisher.view];
    [_publisher.view setFrame:localViewRect];
    _publisher.publishAudio = self.publishAudio;
    _publisher.publishVideo = self.publishVideo;
    if (!_publisher.publishVideo) {
        _publisher.view.hidden = YES;
    }
}
    
    /**
     * Cleans up the publisher and its view. At this point, the publisher should not
     * be attached to the session any more.
     */
- (void)cleanupPublisher {
    [_publisher.view removeFromSuperview];
    _publisher = nil;
    // this is a good place to notify the end-user that publishing has stopped.
}
    
    /**
     * Instantiates a subscriber for the given stream and asynchronously begins the
     * process to begin receiving A/V content for this stream. Unlike doPublish,
     * this method does not add the subscriber to the view hierarchy. Instead, we
     * add the subscriber only after it has connected and begins receiving data.
     */
- (void)doSubscribe:(OTStream*)stream
{
    _subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];

    OTError *error = nil;
    [_session subscribe:_subscriber error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
}
    
    /**
     * Cleans the subscriber from the view hierarchy, if any.
     * NB: You do *not* have to call unsubscribe in your controller in response to
     * a streamDestroyed event. Any subscribers (or the publisher) for a stream will
     * be automatically removed from the session during cleanup of the stream.
     */
- (void)cleanupSubscriber
{
    [_subscriber.view removeFromSuperview];
    _subscriber = nil;
    // Do hangup the call
//    [self.navigationController popViewControllerAnimated:YES];//TODO
}
    
# pragma mark - OTSession delegate callbacks
    
- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"sessionDidConnect (%@)", session.sessionId);
    
    // Step 2: We have successfully connected, now instantiate a publisher and
    // begin pushing A/V streams into OpenTok.
    [self doPublish];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSString* alertMessage =
    [NSString stringWithFormat:@"Session disconnected: (%@)",
     session.sessionId];
    NSLog(@"sessionDidDisconnect (%@)", alertMessage);
}

- (void)sessionDidReconnect:(OTSession *)session {
    NSLog(@"sessionDidReconnect (%@)", session.sessionId);
}
    
- (void)session:(OTSession*)mySession streamCreated:(OTStream *)stream
{
    NSLog(@"session streamCreated (%@)", stream.streamId);
    
    // Step 3a: (if NO == subscribeToSelf): Begin subscribing to a stream we
    // have seen on the OpenTok session.
    if (nil == _subscriber && !subscribeToSelf)
    {
        [self doSubscribe:stream];
    }
}
    
- (void)session:(OTSession*)session streamDestroyed:(OTStream *)stream
{
    NSLog(@"session streamDestroyed (%@)", stream.streamId);
    
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
}
    
- (void) session:(OTSession *)session connectionCreated:(OTConnection *)connection
{
    NSLog(@"session connectionCreated (%@)", connection.connectionId);
}
    
- (void) session:(OTSession *)session connectionDestroyed:(OTConnection *)connection
{
    NSLog(@"session connectionDestroyed (%@)", connection.connectionId);
    if ([_subscriber.stream.connection.connectionId
         isEqualToString:connection.connectionId])
    {
        [self cleanupSubscriber];
    }
}
    
- (void) session:(OTSession*)session didFailWithError:(OTError*)error
{
    NSLog(@"didFailWithError: (%@)", error);
    
    // Reconnect to session
    [self doConnect];
//    [self handleReject];
}
    
# pragma mark - OTSubscriber delegate callbacks
    
- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber
{
    self.conversationStarted = YES;
    NSLog(@"subscriberDidConnectToStream (%@)",
          subscriber.stream.connection.connectionId);
    assert(_subscriber == subscriber);
    remoteViewRect = _remoteView.bounds;
    [_subscriber.view setFrame:remoteViewRect];
    [self.view addSubview:_subscriber.view];
    [self.view sendSubviewToBack:_subscriber.view];
    
    self.callingLabel.hidden = YES;
    if ([subscriber subscribeToAudio]) {
        self.otherMicrophoneInfo.hidden = YES;
    } else {
        self.otherMicrophoneInfo.hidden = NO;
    }
    if ([subscriber subscribeToVideo]) {
        self.otherVideoInfoContainer.hidden = YES;
    } else {
        self.otherVideoInfoContainer.hidden = NO;
        self.otherVideoDisabledLabel.text = CCLocalizedString(@"Video is disabled");
    }
}
    
- (void)subscriber:(OTSubscriberKit*)subscriber didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@",
          subscriber.stream.streamId,
          error);
    [self doHangup];
}

- (void) subscriberDidReconnectToStream:(OTSubscriberKit *)subscriber {
    NSLog(@"subscriberDidReconnectToStream %@", subscriber);
}

- (void)subscriberDidDisconnectFromStream:(OTSubscriberKit *)subscriber
{
    NSLog(@"subscriberDidDisconnectFromStream %@", subscriber);
}

- (void)subscriberVideoEnabled:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    NSLog(@"subscriberVideoEnabled %@", subscriber);
    _subscriber.view.hidden = NO;
    self.otherVideoInfoContainer.hidden = YES;
}

- (void)subscriberVideoDisabled:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
    NSLog(@"subscriberVideoEnabled %@", subscriber);
    _subscriber.view.hidden = YES;
    self.otherVideoInfoContainer.hidden = NO;
    self.otherVideoDisabledLabel.text = CCLocalizedString(@"Video is disabled");
}
# pragma mark - OTPublisher delegate callbacks
    
- (void)publisher:(OTPublisherKit *)publisher streamCreated:(OTStream *)stream
{
    // Step 3b: (if YES == subscribeToSelf): Our own publisher is now visible to
    // all participants in the OpenTok session. We will attempt to subscribe to
    // our own stream. Expect to see a slight delay in the subscriber video and
    // an echo of the audio coming from the device microphone.
    if (nil == _subscriber && subscribeToSelf)
    {
        [self doSubscribe:stream];
    }
}
    
- (void)publisher:(OTPublisherKit*)publisher streamDestroyed:(OTStream *)stream
{
    NSLog(@"publisher %@ streamDestroyed %@", publisher, stream);
    
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
    
    [self cleanupPublisher];
}
    
- (void)publisher:(OTPublisherKit*)publisher didFailWithError:(OTError*) error
{
    NSLog(@"publisher didFailWithError %@", error);
    [self cleanupPublisher];
}
    
- (void)showAlert:(NSString *)string
{
    // show alertview on main UI
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OTError"
                                                        message:string
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil] ;
        [alert show];
    });
}

#pragma mark - UI actions
- (IBAction)switchCamera:(id)sender {
    if (_publisher.cameraPosition == AVCaptureDevicePositionBack) {
        [_publisher setCameraPosition:AVCaptureDevicePositionFront];
    } else {
        [_publisher setCameraPosition:AVCaptureDevicePositionBack];
    }
}

- (IBAction)onMicrophoneClicked:(id)sender {
    _publisher.publishAudio = !_publisher.publishAudio;
    if(!_publisher.publishAudio) {
        [_microphoneButton setImage:microphoneOffImage forState:UIControlStateNormal];
    } else {
        [_microphoneButton setImage:microphoneOnImage forState:UIControlStateNormal];
    }
}

- (IBAction)onHangupClicked:(id)sender {
    OTError* error = nil;
    [_session disconnect:&error];
    if (error) {
        NSLog(@"disconnect failed with error: (%@)", error);
    }
    //
    // If conversation is started, send hangup request
    //
    if (_conversationStarted) {
        [self doHangup];
        return;
    }
    
    //
    // If conversation isn't started, send reject request
    //
    [self doReject];
}

- (IBAction)onCameraClicked:(id)sender {
    _publisher.publishVideo = !_publisher.publishVideo;
    if(!_publisher.publishVideo) {
        [_cameraButton setImage:cameraOffImage forState:UIControlStateNormal];
        _publisher.view.hidden = YES;
        _switchCameraButton.hidden = YES;
    } else {
        [_cameraButton setImage:cameraOnImage forState:UIControlStateNormal];
        _publisher.view.hidden = NO;
        _switchCameraButton.hidden = NO;
    }
}

- (void) doHangup {
    NSLog(@"doHangup channelid = %@", self.channelUid);
    [[CCConnectionHelper sharedClient] hangupCall:self.channelUid messageId:self.messageId user:@{@"user_id": _publisherInfor[@"user_id"]} completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        if(!isClosed) {
            isClosed = YES;
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void) doReject {
    NSLog(@"doReject channelid = %@", self.channelUid);
    [[CCConnectionHelper sharedClient] rejectCall:self.channelUid messageId:self.messageId reason:@{@"type": @"error", @"message": @"Invite to Participant was canceled"} user:@{@"user_id": self.publisherInfor[@"user_id"]} completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        if(!isClosed) {
            isClosed = YES;
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark - CCVideoCallEventHandlerDelegate
- (void)handleCallEvent:(NSString *)messageId content:(NSDictionary *)content {
    NSArray *events = content[@"events"];
    NSArray *receivers = content[@"receivers"];
    NSDictionary *caller = content[@"caller"];
    NSLog(@"Events = %@", events);
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
        
        if ([action isEqualToString:@"hangup"]) {
            [self handleHangup];
        }
    }
    if (needHandleReject) {
        [self handleReject:receivers caller:caller events:events];
    }
}

- (void) handleReject:(NSArray *)receivers caller:caller events:(NSArray *)events {
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
        
        NSString *rejectedUserId = [[[eventContent objectForKey:@"user"] objectForKey:@"user_id"] stringValue];
        BOOL rejectedUserInReceivers = NO;
        for(NSDictionary *user in receivers) {
            NSString *userID = [[user objectForKey:@"user_id"] stringValue];
            if (userID != nil && [userID isEqualToString:rejectedUserId]) {
                rejectedUserInReceivers = YES;
                break;
            }
        }
        NSString *callerId = [[caller objectForKey:@"user_id"] stringValue];
        if (!rejectedUserInReceivers && [callerId isEqualToString:rejectedUserId]) {
            needCloseView = YES;
            break;
        }
    }
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
        NSString *rejectedUserId = [[[eventContent objectForKey:@"user"] objectForKey:@"user_id"] stringValue];
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
        if (!isClosed) {
            isClosed = YES;
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void) handleHangup {
    if (!isClosed) {
        isClosed = YES;
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
