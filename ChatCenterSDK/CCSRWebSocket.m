//
//  CCSRWebSocket.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2014/10/03.
//  Copyright (c) 2014年 AppSocially Inc. All rights reserved.
//

#import "CCSRWebSocket.h"
#import "CCSRWebSocketOriginal.h"
#import "CCConstants.h"
#import "CCCoredataBase.h"
#import "ChatCenterPrivate.h"
#import "CCSSKeychain.h"
#import "ChatCenterClient.h"
#import "CCConnectionHelper.h"

@interface CCSRWebSocket () <CCSRWebSocketOriginalDelegate>


@end

@implementation CCSRWebSocket{
    CCSRWebSocketOriginal *_webSocket;
    NSMutableArray *_messages;
    int subscribingChannelNum;
    int subscribedChannelNum;
}

+ (CCSRWebSocket *)sharedInstance
{
    static CCSRWebSocket *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [CCSRWebSocket new];
        
    });
    return instance;
}

- (void)_disconnect;
{
    _webSocket.delegate = nil;
    [_webSocket close];
}

- (void)disconnect
{
    [self _disconnect];
}

- (void)_reconnect
{
    if ([[CCConstants sharedInstance] getKeychainToken] == nil) {
        return;
    }
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    _webSocket.delegate = nil;
    [_webSocket close];
    
     NSString *url = [NSString stringWithFormat:@"%@?authentication=%@&app_token=%@",[ChatCenter getWebsocketBaseUrl], token, [ChatCenterClient sharedClient].appToken];
    _webSocket = [[CCSRWebSocketOriginal alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    _webSocket.delegate = self;
    
    [_webSocket open];
    
}

- (void)reconnect
{
    [self _reconnect];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(CCSRWebSocketOriginal *)webSocket;
{
    NSLog(@"Websocket Connected");
    if (self.webSocketDidOpenCallback)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.webSocketDidOpenCallback();
        });
    }
    NSArray *channelArray = [[CCCoredataBase sharedClient] selectAllChannel:CCloadLoacalChannelLimit channelType:CCAllChannel];
    subscribingChannelNum = (int)channelArray.count;
    subscribedChannelNum = 0;
    for (int i = 0; i < channelArray.count; i++) {
        NSManagedObject *object = [channelArray objectAtIndex:i];
        NSString *channelId     = [object valueForKey:@"uid"];
        NSString *subscribe = [NSString stringWithFormat:@"[\"subscribe\", {\"channel_uid\":\"%@\"}]",channelId];
        [webSocket send:subscribe];
    }
}

- (void)webSocket:(CCSRWebSocketOriginal *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    if (self.didFailWithErrorOrClosedCallback)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.didFailWithErrorOrClosedCallback(error,nil);
        });
    }
    _webSocket = nil;
}

- (void)webSocket:(CCSRWebSocketOriginal *)webSocket didReceiveMessage:(id)message;
{
    NSLog(@"Received \"%@\"", message);
    if (![message isKindOfClass:[NSString class]])
    {
        return;
    }
    //
    // arguments[0] : String specifying the type. ex) @"message:response"
    // arguments[1] : Dictionary containing all other data
    //
    id arguments = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];

    if (![arguments isKindOfClass:[NSArray class]])
    {
        return;
    }
    NSLog(@"arguments: %@", arguments);
    
    //----------------------------------------------------
    //
    // Message type check
    //
    //----------------------------------------------------
    
    // argument[0] should be NSString
    if (![arguments[0] isKindOfClass:[NSString class]])
    {
        return;
    }
    if([arguments[0] isEqualToString:@"success:subscribe"]) {
        subscribedChannelNum++;
        if (subscribedChannelNum == subscribingChannelNum) {
            subscribedChannelNum = 0;
            subscribingChannelNum = 0;
            NSLog(@"success:all channel subscribed");
        }
        NSLog(@"success:subscribe");
    }else if([arguments[0] isEqualToString:@"failure:subscribe"]) {
        NSLog(@"failure:subscribe");
    }else if([arguments[0] isEqualToString:@"message"]
             || [arguments[0] isEqualToString:@"message:information"]
             || [arguments[0] isEqualToString:@"message:sticker"]
             || [arguments[0] isEqualToString:@"message:response"]
             || [arguments[0] isEqualToString:@"message:property"]
             || [arguments[0] isEqualToString:@"message:message"]
             || [arguments[0] isEqualToString:@"message:location"]
             || [arguments[0] isEqualToString:@"message:datetime"]
             || [arguments[0] isEqualToString:@"message:image"]
             || [arguments[0] isEqualToString:@"message:question"]
             || [arguments[0] isEqualToString:@"message:pdf"]
             || [arguments[0] isEqualToString:@"message:call"]
             || [arguments[0] isEqualToString:@"call:call"]
             || [arguments[0] isEqualToString:@"message:suggestion"])
    {
        NSString *messageType;
        if ([arguments[0] isEqualToString:@"message:message"]) {
            messageType = CC_RESPONSETYPEMESSAGE;
        }else if([arguments[0] isEqualToString:@"message:location"]){
            messageType = CC_RESPONSETYPELOCATION;
        }else if([arguments[0] isEqualToString:@"message:datetime"]){
            messageType = CC_RESPONSETYPEDATETIMEAVAILABILITY;
        }else if([arguments[0] isEqualToString:@"message:image"]){
            messageType = CC_RESPONSETYPEIMAGE;
        }else if([arguments[0] isEqualToString:@"message:question"]){
            messageType = CC_RESPONSETYPEQUESTION;
        }else if([arguments[0] isEqualToString:@"message:pdf"]){
            messageType = CC_RESPONSETYPEPDF;
        }else if([arguments[0] isEqualToString:@"message:information"]){
            messageType = CC_RESPONSETYPEINFORMATION;
        }else if([arguments[0] isEqualToString:@"message:sticker"]){
            messageType = CC_RESPONSETYPESTICKER;
        }else if([arguments[0] isEqualToString:@"message:response"]){
            messageType = CC_RESPONSETYPERESPONSE;
        }else if([arguments[0] isEqualToString:@"message:property"]){
            messageType = CC_RESPONSETYPEPROPERTY;
        }else if([arguments[0] isEqualToString:@"message:call"]){
            messageType = CC_RESPONSETYPECALL;
        }else if([arguments[0] isEqualToString:@"call:call"]) {
            messageType = CC_RESPONSETYPECALLINVITE;
        }else if([arguments[0] isEqualToString:@"message:suggestion"]) {
            messageType = CC_RESPONSETYPESUGGESTION;
        } 
        
        
        //----------------------------------------------------
        //
        // Message content handling
        //
        //----------------------------------------------------

        // arguments[1] should be NSDictionary
        if (![arguments[1] isKindOfClass:[NSDictionary class]] || [arguments[1] isEqual:[NSNull null]])
        {
            return;
        }
        NSLog(@"message: %@", arguments[1]);
        NSDictionary *argument = arguments[1];

        ///null check
        if ([[argument valueForKeyPath:@"content"] isEqual:[NSNull null]]
            || [[argument valueForKeyPath:@"channel_id"] isEqual:[NSNull null]]
            || [[argument valueForKeyPath:@"channel_uid"] isEqual:[NSNull null]]
            || [[argument valueForKeyPath:@"created"] isEqual:[NSNull null]]
            || [[argument valueForKeyPath:@"id"] isEqual:[NSNull null]]
            || ([[argument valueForKeyPath:@"user"] isEqual:[NSNull null]] && ![messageType isEqualToString:CC_RESPONSETYPEINFORMATION] && ![messageType isEqualToString:CC_RESPONSETYPEPROPERTY])
            || ([[argument valueForKeyPath:@"user.display_name"] isEqual:[NSNull null]] && ![messageType isEqualToString:CC_RESPONSETYPEINFORMATION] && ![messageType isEqualToString:CC_RESPONSETYPEPROPERTY])
            || ([[argument valueForKeyPath:@"user.id"] isEqual:[NSNull null]] && ![messageType isEqualToString:CC_RESPONSETYPEINFORMATION] && ![messageType isEqualToString:CC_RESPONSETYPEPROPERTY])
            || [[argument valueForKeyPath:@"org_uid"] isEqual:[NSNull null]]
            ///answer, question might be nill
            )
        {
            return;
        }
        id content      = [argument valueForKeyPath:@"content"];
        id channelId    = [argument valueForKeyPath:@"channel_id"];
        id channelUid   = [argument valueForKeyPath:@"channel_uid"];
        id orgUid       = [argument valueForKeyPath:@"org_uid"];
        id created      = [argument valueForKeyPath:@"created"];
        id uid          = [argument valueForKeyPath:@"id"];
        id user, displayName, userUid, userIconUrl, userAdmin, answer, question;
        if (![messageType isEqualToString:CC_RESPONSETYPEINFORMATION] && ![messageType isEqualToString:CC_RESPONSETYPEPROPERTY]) {
            user         = [argument valueForKeyPath:@"user"];
            displayName  = [argument valueForKeyPath:@"user.display_name"];
            userAdmin    = [argument valueForKeyPath:@"user.admin"];
            userUid      = [argument valueForKeyPath:@"user.id"];
            if ([argument valueForKeyPath:@"user.icon_url"] != nil
                && ![[argument valueForKeyPath:@"user.icon_url"] isEqual:[NSNull null]]) {
                userIconUrl  = [argument valueForKeyPath:@"user.icon_url"];
            }else{
                userIconUrl = nil;
            }
        }else{
            user = nil;
            displayName = nil;
            userUid = nil;
            userIconUrl = nil;
        }
        if ([argument valueForKeyPath:@"answer"] != nil) {
            answer = [argument valueForKeyPath:@"answer"];
        }else{
            answer = nil;
        }
        if ([argument valueForKeyPath:@"question"] != nil) {
            question = [argument valueForKeyPath:@"question"];
        }else{
            question = nil;
        }
       
        //type check
        if ((![channelUid isKindOfClass:[NSString class]] && ![messageType isEqualToString:CC_RESPONSETYPECALLINVITE])
            || ![message isKindOfClass:[NSString class]]
            || (![created isKindOfClass:[NSNumber class]] && ![messageType isEqualToString:CC_RESPONSETYPECALLINVITE])
            || ![uid isKindOfClass:[NSNumber class]]
            || (user != nil && ![user isKindOfClass:[NSDictionary class]] && ![messageType isEqualToString:CC_RESPONSETYPEINFORMATION] && ![messageType isEqualToString:CC_RESPONSETYPEPROPERTY])
            || (displayName != nil && ![displayName isKindOfClass:[NSString class]] && ![messageType isEqualToString:CC_RESPONSETYPEINFORMATION] && ![messageType isEqualToString:CC_RESPONSETYPEPROPERTY])
            || (userUid != nil && ![userUid isKindOfClass:[NSNumber class]] && ![messageType isEqualToString:CC_RESPONSETYPEINFORMATION] && ![messageType isEqualToString:CC_RESPONSETYPEPROPERTY])
            || (![orgUid isKindOfClass:[NSString class]] && ![messageType isEqualToString:CC_RESPONSETYPECALLINVITE]))
        {
            return;
        }
        
        NSTimeInterval interval = [created doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        NSNumber *uidNum = uid;
        NSString *userUidStr = (userUid != nil && userUid != [NSNull null]) ? [userUid stringValue] : nil;
        BOOL userAdminBool = [userAdmin boolValue];
        //invite callback
        if (self.didReceiveInviteCallCallback && [messageType isEqualToString:CC_RESPONSETYPECALLINVITE])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.didReceiveInviteCallCallback(uid, channelUid, content);
            });
            return;
        }
        
        //call action:accept, reject, hangup
        if (self.didReceiveCallEventCallback && [messageType isEqualToString:CC_RESPONSETYPECALL]) {
            // If message contains (accept, hangup) or (reject) then insert
            // it into db. In other hand ignore it
            dispatch_async(dispatch_get_main_queue(), ^{
                self.didReceiveCallEventCallback(uid, content);
            });

            NSArray *events = [content valueForKey:@"events"];
            BOOL needToInsert = NO;
            if (events != nil && events.count > 0) {
                BOOL containAccept = NO;
                BOOL containHangup = NO;
                BOOL containReject = NO;
                for(NSDictionary *event in events) {
                    NSDictionary *eventContent = [event valueForKey:@"content"];
                    if (eventContent != nil) {
                        NSString *action = [eventContent valueForKey:@"action"];
                        if (action != nil && ![action isEqual:[NSNull null]]) {
                            if([action isEqualToString:@"accept"]) {
                                containAccept = YES;
                            } else if ([action isEqualToString:@"hangup"]) {
                                containHangup = YES;
                            } else if ([action isEqualToString:@"reject"]) {
                                containReject = YES;
                            }
                        }
                    }
                }
                if((containAccept && containHangup) || containReject) {
                    needToInsert = YES;
                }
            }
            
            if(needToInsert) {
                if([[CCCoredataBase sharedClient] insertMessage:uidNum
                                                           type:messageType
                                                        content:content
                                                           date:[NSDate date]
                                                     channelUid:channelUid
                                                      channelId:channelId
                                                           user:user
                                               usersReadMessage:[[NSArray alloc]init]
                                                         answer:answer
                                                       question:question
                                                         status:CC_MESSAGE_STATUS_SEND_SUCCESS])
                {
                    NSLog(@"insertMessage Success!");
                    // update message:sticker if received message:response
                    if([messageType isEqualToString:CC_RESPONSETYPERESPONSE]) {
                        NSNumber *replyTo = content[@"reply_to"];
                        [[CCCoredataBase sharedClient] updateMessage:replyTo withResponseContent:content];
                    }
                }else{
                    NSLog(@"insertMessage Error!");
                }
            } else {
                return;
            }
        } else {
            if([[CCCoredataBase sharedClient] insertMessage:uidNum
                                                       type:messageType
                                                    content:content
                                                       date:[NSDate date]
                                                 channelUid:channelUid
                                                  channelId:channelId
                                                       user:user
                                           usersReadMessage:[[NSArray alloc]init]
                                                     answer:answer
                                                   question:question
                                                     status:CC_MESSAGE_STATUS_SEND_SUCCESS])
            {
                NSLog(@"insertMessage Success!");
                // update message:sticker if received message:response
                if([messageType isEqualToString:CC_RESPONSETYPERESPONSE]) {
                    NSNumber *replyTo = content[@"reply_to"];
                    [[CCCoredataBase sharedClient] updateMessage:replyTo withResponseContent:content];
                }
            }else{
                NSLog(@"insertMessage Error!");
            }
        }

        NSDictionary *latest_message;
        if (user == nil) {
            latest_message = @{
                               @"type" : messageType,
                               @"channel_uid" : channelUid,
                               @"content" : content,
                               @"created" : [NSDate date],
                               @"id" : uidNum
                               };
        }else{
            latest_message = @{
                               @"type" : messageType,
                               @"channel_uid" : channelUid,
                               @"content" : content,
                               @"created" : [NSDate date],
                               @"id" : uidNum,
                               @"user" :user
                               };
        }
        ///Update or Insert chennel
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([CCConstants sharedInstance].isAgent== YES && ![orgUid isEqualToString:[ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"]]) {
            return;
        }
        __block NSString *blockChannelUid = channelUid;
        ///duplicate check
        NSArray *mutableFetchResults = [[CCCoredataBase sharedClient] selectChannelWithUid:CCloadLoacalChannelLimit uid:channelUid];
        if ([mutableFetchResults count] > 0 && ![messageType isEqualToString:CC_RESPONSETYPESUGGESTION]) {
            NSLog(@"insertChannel Error or already existed!");
            if(![messageType isEqualToString:CC_RESPONSETYPERESPONSE]) {///Don't update latest message with response 
                if (userUidStr == nil
                    || ![userUidStr isEqualToString:[[CCConstants sharedInstance] getKeychainUid]]) {
                    ///Count up unread message num when the message comes from
                    if([[CCCoredataBase sharedClient] updateChannelWithUidAndLatestmessageAndunreadMessagesPlus:channelUid
                                                                                                       updateAt:[NSDate date]
                                                                                                  latestMessage:latest_message
                                                                                                           user:user]){
                        NSLog(@"update channel Success!");
                    }else{
                        NSLog(@"update channel Error!");
                    }
                    [[ChatCenter sharedInstance] countUpUnreadMessage:blockChannelUid];
                }else{
                    if([[CCCoredataBase sharedClient] updateChannelWithUidAndLatestmessage:channelUid updateAt:[NSDate date] latestMessage:latest_message]){
                        NSLog(@"update channel Success!");
                    }else{
                        NSLog(@"update channel Error!");
                    }
                }
            }
            if (self.didReceiveMessageCallback)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.didReceiveMessageCallback(messageType, uidNum, content, blockChannelUid, userUidStr, date, displayName, userIconUrl, userAdminBool, answer);
                });
            }
        }else{
            ///No duplicate
            ///get the channel
            [[CCConnectionHelper sharedClient] loadChannel:NO channelUid:channelUid completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
                if (self.didReceiveJoinCallback)
                {
                    if (error == nil) {
                        [[ChatCenter sharedInstance] countUpUnreadMessage:blockChannelUid];
                        if (self.didReceiveMessageCallback)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.didReceiveMessageCallback(messageType, uidNum, content, blockChannelUid, userUidStr, date, displayName, userIconUrl, userAdminBool, answer);
                            });
                        }
                    }
                }
            }];
        }

    }else if([arguments[0] isEqualToString:@"channel:join"]) {
        ///get uid, user
        ///null/type check
        if (![arguments[1] isKindOfClass:[NSDictionary class]] || [arguments[1] isEqual:[NSNull null]])
        {
            return;
        }
        NSLog(@"message: %@", arguments[1]);
        NSDictionary *argument = arguments[1];
        ///null/type check
        if (![[argument valueForKeyPath:@"uid"] isKindOfClass:[NSString class]]
            || [[argument valueForKeyPath:@"uid"] isEqual:[NSNull null]]
            || ![[argument valueForKeyPath:@"org_uid"] isKindOfClass:[NSString class]]
            || [[argument valueForKeyPath:@"org_uid"] isEqual:[NSNull null]]) {
            return;
        }
        NSString *orgUid = [argument valueForKeyPath:@"org_uid"];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([CCConstants sharedInstance].isAgent== YES && ![orgUid isEqualToString:[ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"]]) {
            return;
        }
        
        NSString *channelUid = [argument valueForKey:@"uid"];
        __block NSString *blockChannelUid = channelUid;
        ///duplicate check
        NSArray *mutableFetchResults = [[CCCoredataBase sharedClient] selectChannelWithUid:CCloadLoacalChannelLimit uid:channelUid];
        if ([mutableFetchResults count] > 0) {
            NSLog(@"insertChannel Error or already existed!");
            dispatch_async(dispatch_get_main_queue(), ^{
                self.didReceiveJoinCallback(blockChannelUid, NO);
            });
        }else{
            ///No duplicate
            ///get the channel
            [[CCConnectionHelper sharedClient] loadChannel:NO channelUid:channelUid completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
                if (self.didReceiveJoinCallback)
                {
                    if (error == nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.didReceiveJoinCallback(blockChannelUid, YES);
                        });
                    }
                }
            }];
        }
    } else if([arguments[0] isEqualToString:@"channel:online"]) {
        ///get uid, user
        ///null/type check
        if (![arguments[1] isKindOfClass:[NSDictionary class]] || [arguments[1] isEqual:[NSNull null]])
        {
            return;
        }
        NSLog(@"message: %@", arguments[1]);
        NSDictionary *argument = arguments[1];
        ///null/type check
        if (![[argument valueForKeyPath:@"uid"] isKindOfClass:[NSString class]]
            || [[argument valueForKeyPath:@"uid"] isEqual:[NSNull null]]
            || ![[argument valueForKeyPath:@"org_uid"] isKindOfClass:[NSString class]]
            || [[argument valueForKeyPath:@"org_uid"] isEqual:[NSNull null]]
            || ![[argument valueForKeyPath:@"user"] isKindOfClass:[NSDictionary class]]
            || [[argument valueForKeyPath:@"user"] isEqual:[NSNull null]]) {
            return;
        }
        NSString *orgUid = [argument valueForKeyPath:@"org_uid"];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([CCConstants sharedInstance].isAgent== YES && ![orgUid isEqualToString:[ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"]]) {
            return;
        }
        
        NSString *channelUid = [argument valueForKey:@"uid"];
        NSDictionary *user = [argument valueForKey:@"user"];
        __block NSString *blockChannelUid = channelUid;
        __block NSDictionary *blockUser = user;
        ///duplicate check
        NSArray *mutableFetchResults = [[CCCoredataBase sharedClient] selectChannelWithUid:CCloadLoacalChannelLimit uid:channelUid];
        if ([mutableFetchResults count] > 0) {
            NSLog(@"insertChannel Error or already existed!");
            [[CCConnectionHelper sharedClient] updateChannel:NO
                                                  channelUid:channelUid
                                           completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task)
             {
                 NSLog(@"Update Channel online");
             }];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.didReceiveOnlineCallback(blockChannelUid, blockUser);
            });
        }
    }  else if([arguments[0] isEqualToString:@"channel:offline"]) {
        ///get uid, user
        ///null/type check
        if (![arguments[1] isKindOfClass:[NSDictionary class]] || [arguments[1] isEqual:[NSNull null]])
        {
            return;
        }
        NSLog(@"message: %@", arguments[1]);
        NSDictionary *argument = arguments[1];
        ///null/type check
        if (![[argument valueForKeyPath:@"uid"] isKindOfClass:[NSString class]]
            || [[argument valueForKeyPath:@"uid"] isEqual:[NSNull null]]
            || ![[argument valueForKeyPath:@"org_uid"] isKindOfClass:[NSString class]]
            || [[argument valueForKeyPath:@"org_uid"] isEqual:[NSNull null]]
            || ![[argument valueForKeyPath:@"user"] isKindOfClass:[NSDictionary class]]
            || [[argument valueForKeyPath:@"user"] isEqual:[NSNull null]]) {
            return;
        }
        NSString *orgUid = [argument valueForKeyPath:@"org_uid"];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([CCConstants sharedInstance].isAgent== YES && ![orgUid isEqualToString:[ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"]]) {
            return;
        }
        
        NSString *channelUid = [argument valueForKey:@"uid"];
        NSDictionary *user = [argument valueForKey:@"user"];
        __block NSString *blockChannelUid = channelUid;
        __block NSDictionary *blockUser = user;
        ///duplicate check
        NSArray *mutableFetchResults = [[CCCoredataBase sharedClient] selectChannelWithUid:CCloadLoacalChannelLimit uid:channelUid];
        if ([mutableFetchResults count] > 0) {
            NSLog(@"insertChannel Error or already existed!");
            [[CCConnectionHelper sharedClient] updateChannel:NO
                                                  channelUid:channelUid
                                           completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task)
             {
                  NSLog(@"Update Channel offline");
             }];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.didReceiveOnlineCallback(blockChannelUid, blockUser);
            });
        }
    } else if([arguments[0] isEqualToString:@"message:receipt"]) {
        ///null/type check
        if (![arguments[1] isKindOfClass:[NSDictionary class]] || [arguments[1] isEqual:[NSNull null]])
        {
            return;
        }
        NSLog(@"receipt: %@", arguments[1]);
        NSDictionary *argument = arguments[1];
        ///null/type check /channel_uid/user/content/id
        if (![[argument valueForKeyPath:@"channel_uid"] isKindOfClass:[NSString class]] || [[argument valueForKeyPath:@"channel_uid"] isEqual:[NSNull null]] || ![[argument valueForKeyPath:@"user"] isKindOfClass:[NSDictionary class]] || [[argument valueForKeyPath:@"user"] isEqual:[NSNull null]] || ![[argument valueForKeyPath:@"user.id"] isKindOfClass:[NSNumber class]] || [[argument valueForKeyPath:@"user.id"] isEqual:[NSNull null]] || ![[argument valueForKeyPath:@"content"] isKindOfClass:[NSDictionary class]] || [[argument valueForKeyPath:@"content"] isEqual:[NSNull null]] || ![[argument valueForKeyPath:@"content.messages"] isKindOfClass:[NSArray class]] || [[argument valueForKeyPath:@"content.messages"] isEqual:[NSNull null]]) {
            return;
        }
        NSString *channelUid = [argument valueForKeyPath:@"channel_uid"];
        NSArray *messages = [argument valueForKeyPath:@"content.messages"];
        NSString *userUid = [[argument valueForKeyPath:@"user.id"] stringValue];
        BOOL userAdmin = ([argument valueForKeyPath:@"user.admin"]) ? [[argument valueForKeyPath:@"user.admin"] boolValue] : NO;
        
        //update message
        for (int i=0;i < messages.count; i++) {
            if (![messages[i] isKindOfClass:[NSNumber class]]) break;
            [[CCCoredataBase sharedClient] updateMessageUsersReadMessage:channelUid messageId:messages[i] userUid:userUid userAdmin:userAdmin];
        }
        ///call channel join callback
        if (self.didReceiveJoinCallback)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.didReceiveReceiptCallback(channelUid, messages, userUid, userAdmin);
            });
        }
    } else if([arguments[0] isEqualToString:@"channel:assigned"]) {
        ///null/type check
        if (![arguments[1] isKindOfClass:[NSDictionary class]] || [arguments[1] isEqual:[NSNull null]])
        {
            return;
        }
        NSLog(@"receipt: %@", arguments[1]);
        NSDictionary *argument = arguments[1];
        ///null/type check /channel_uid/user/content/id
        if (![[argument valueForKeyPath:@"uid"] isKindOfClass:[NSString class]] || [[argument valueForKeyPath:@"uid"] isEqual:[NSNull null]] || ![[argument valueForKeyPath:@"status"] isKindOfClass:[NSString class]] || [[argument valueForKeyPath:@"status"] isEqual:[NSNull null]]) {
            return;
        }
        NSString *channelUid = [argument valueForKeyPath:@"uid"];
        NSString *status     = [argument valueForKeyPath:@"status"];
        ///update channel
        [[CCCoredataBase sharedClient] updateChannelUpdateAtAndStatusWithUid:channelUid updateAt:[NSDate date] status:status];
        ///add assignee to user list
        NSNumber *lastUpdatedAt = argument[@"last_updated_at"];
        NSTimeInterval interval = [lastUpdatedAt doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        NSArray *users = argument[@"users"];
        [[CCCoredataBase sharedClient] updateChannelWithUsers:channelUid users:users lastUpdateAt:date];
        ///call channel join callback
        if (self.didReceiveAssignedCallback)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.didReceiveAssignedCallback(channelUid);
            });
        }
    }else if ([arguments[0] isEqualToString:@"channel:unassigned"]) {
        ///null/type check
        if (![arguments[1] isKindOfClass:[NSDictionary class]] || [arguments[1] isEqual:[NSNull null]])
        {
            return;
        }
        NSLog(@"receipt: %@", arguments[1]);
        NSDictionary *argument = arguments[1];
        ///null/type check /channel_uid/user/content/id
        if (![[argument valueForKeyPath:@"uid"] isKindOfClass:[NSString class]] || [[argument valueForKeyPath:@"uid"] isEqual:[NSNull null]] || ![[argument valueForKeyPath:@"status"] isKindOfClass:[NSString class]] || [[argument valueForKeyPath:@"status"] isEqual:[NSNull null]]) {
            return;
        }
        NSString *channelUid = [argument valueForKeyPath:@"uid"];
        NSString *status     = [argument valueForKeyPath:@"status"];
        ///update channel
        [[CCCoredataBase sharedClient] updateChannelUpdateAtAndStatusWithUid:channelUid updateAt:[NSDate date] status:status];
        ///remove assignee from user list
        NSNumber *lastUpdatedAt = argument[@"last_updated_at"];
        NSTimeInterval interval = [lastUpdatedAt doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        NSArray *users = argument[@"users"];
        [[CCCoredataBase sharedClient] updateChannelWithUsers:channelUid users:users lastUpdateAt:date];
        if (self.didReceiveUnassignedCallback)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.didReceiveUnassignedCallback(channelUid);
            });
        }
    }else if([arguments[0] isEqualToString:@"message:answer"]) {
        if (![arguments[1] isKindOfClass:[NSDictionary class]] || [arguments[1] isEqual:[NSNull null]])
        {
            return;
        }
        NSDictionary *answer = arguments[1][@"answer"];
        if (![answer[@"message_id"] isKindOfClass:[NSNumber class]]
            || [answer[@"message_id"] isEqual:[NSNull null]]
            || ![answer[@"answer_type"] isKindOfClass:[NSNumber class]]
            || [answer[@"answer_type"] isEqual:[NSNull null]]) {
            return;
        }
        NSNumber *message_id = answer[@"message_id"];
        if([[CCCoredataBase sharedClient] updateMessageWithAnswer:message_id answer:answer]){
            NSLog(@"update answer Success!");
        }else{
            NSLog(@"update answer Error!");
        }
    } else if([arguments[0] isEqualToString:@"message:typing"]) {
        NSDictionary *argument = arguments[1];
        if ([argument[@"channel_uid"] isEqual:[NSNull null]]
            || ![argument[@"user"] isKindOfClass:[NSDictionary class]]) {
            return;
        }
                 
        NSString *channelUid = [argument valueForKeyPath:@"channel_uid"];
        NSDictionary *user = [argument valueForKeyPath:@"user"];
        if (self.didReceiveTypingCallback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.didReceiveTypingCallback(channelUid, user);
            });
        }
    } else if([arguments[0] isEqualToString:@"channel:followed"]) {
        if (![arguments[1] isKindOfClass:[NSDictionary class]] || [arguments[1] isEqual:[NSNull null]])
        {
            return;
        }
        NSDictionary *argument = arguments[1];
        if (![argument[@"user"] isKindOfClass:[NSDictionary class]]
            || [argument[@"user"] isEqual:[NSNull null]]
            || ![argument[@"last_updated_at"] isKindOfClass:[NSNumber class]]
            || [argument[@"last_updated_at"] isEqual:[NSNull null]]
            || ![argument[@"uid"] isKindOfClass:[NSString class]]
            || [argument[@"uid"] isEqual:[NSNull null]]) {
            return;
        }
        NSString *channelUid = [argument valueForKeyPath:@"uid"];
        NSString *status     = [argument valueForKeyPath:@"status"];
        ///update channel
        [[CCCoredataBase sharedClient] updateChannelUpdateAtAndStatusWithUid:channelUid updateAt:[NSDate date] status:status];
        NSNumber *lastUpdatedAt = argument[@"last_updated_at"];
        NSTimeInterval interval = [lastUpdatedAt doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        NSArray *users = argument[@"users"];
        if([[CCCoredataBase sharedClient] updateChannelWithUsers:channelUid users:users lastUpdateAt:date]) {
            NSLog(@"update channel with new user Success!");
            if (self.didReceiveFollowCallback)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.didReceiveFollowCallback(channelUid);
                });
            }
        }else{
            NSLog(@"update channel with new user Error!");
        }
    }else if([arguments[0] isEqualToString:@"channel:unfollowed"]) {
        if (![arguments[1] isKindOfClass:[NSDictionary class]] || [arguments[1] isEqual:[NSNull null]])
        {
            return;
        }
        NSDictionary *argument = arguments[1];
        if (![argument[@"user"] isKindOfClass:[NSDictionary class]]
            || [argument[@"user"] isEqual:[NSNull null]]
            || ![argument[@"last_updated_at"] isKindOfClass:[NSNumber class]]
            || [argument[@"last_updated_at"] isEqual:[NSNull null]]
            || ![argument[@"uid"] isKindOfClass:[NSString class]]
            || [argument[@"uid"] isEqual:[NSNull null]]) {
            return;
        }
        NSNumber *lastUpdatedAt = argument[@"last_updated_at"];
        NSString *channelUid = argument[@"uid"];
        NSTimeInterval interval = [lastUpdatedAt doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        NSArray *users = argument[@"users"];
        if([[CCCoredataBase sharedClient] updateChannelWithUsers:channelUid users:users lastUpdateAt:date]){
            NSLog(@"update channel with new user Success!");
            if (self.didReceiveFollowCallback)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.didReceiveFollowCallback(channelUid);
                });
            }
        }else{
            NSLog(@"update channel with new user Error!");
        }
    } else if ([arguments[0] isEqualToString:@"channel:closed"]) {
        if (![arguments[1] isKindOfClass:[NSDictionary class]] || [arguments[1] isEqual:[NSNull null]]) {
            return;
        }
        NSDictionary *argument = arguments[1];
        if (![argument[@"uid"] isKindOfClass:[NSString class]]
            || [argument[@"uid"] isEqual:[NSNull null]]) {
            return;
        }
        NSString *channelUid = argument[@"uid"];
        BOOL isClosed = [[CCCoredataBase sharedClient] updateChannelWithChannelStatus:channelUid status:@"closed"];
        if (isClosed == YES && self.didReceiveCloseChannelCallback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.didReceiveCloseChannelCallback(channelUid);
            });
        }

    } else if([arguments[0] isEqualToString:@"channel:deleted"]) {
        if (![arguments[1] isKindOfClass:[NSDictionary class]] || [arguments[1] isEqual:[NSNull null]]) {
            return;
        }
        NSDictionary *argument = arguments[1];
        if (![argument[@"uid"] isKindOfClass:[NSString class]]
            || [argument[@"uid"] isEqual:[NSNull null]]) {
            return;
        }
        NSString *channelUid = argument[@"uid"];
        BOOL isDeleted = [[CCCoredataBase sharedClient] deleteChannelWithUid:channelUid];
        if (isDeleted == YES && self.didReceiveDeleteChannelCallback) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.didReceiveDeleteChannelCallback(channelUid);
            });
        }
    } else if ([arguments[0] rangeOfString:@"message:"].location != NSNotFound){
        ///Unexpected type message
        NSString *messageType = CC_RESPONSETYPEUNEXPECTED;
        ///null/type check
        if (![arguments[1] isKindOfClass:[NSDictionary class]] || [arguments[1] isEqual:[NSNull null]])
        {
            return;
        }
        NSLog(@"message: %@", arguments[1]);
        NSDictionary *argument = arguments[1];
        
        ///null check
        if ([[argument valueForKeyPath:@"content"] isEqual:[NSNull null]]
            || [[argument valueForKeyPath:@"channel_uid"] isEqual:[NSNull null]]
            || [[argument valueForKeyPath:@"created"] isEqual:[NSNull null]]
            || [[argument valueForKeyPath:@"id"] isEqual:[NSNull null]]
            || [[argument valueForKeyPath:@"user"] isEqual:[NSNull null]]
            || [[argument valueForKeyPath:@"user.display_name"] isEqual:[NSNull null]]
            || [[argument valueForKeyPath:@"user.id"] isEqual:[NSNull null]]
            ///answer, question might be nill
            )
        {
            return;
        }
        id content      = [argument valueForKeyPath:@"content"];
        id channelUid   = [argument valueForKeyPath:@"channel_uid"];
        id created      = [argument valueForKeyPath:@"created"];
        id uid          = [argument valueForKeyPath:@"id"];
        id user         = [argument valueForKeyPath:@"user"];
        id displayName  = [argument valueForKeyPath:@"user.display_name"];
        id userUid      = [argument valueForKeyPath:@"user.id"];
        id userIconUrl  = [argument valueForKeyPath:@"user.icon_url"];
        BOOL userAdmin    = [[argument valueForKeyPath:@"user.admin"] boolValue];
        id answer, question;
        if ([argument valueForKeyPath:@"answer"] != nil) {
            answer = [argument valueForKeyPath:@"answer"];
        }else{
            answer = nil;
        }
        if ([argument valueForKeyPath:@"question"] != nil) {
            question = [argument valueForKeyPath:@"question"];
        }else{
            question = nil;
        }
        
        //type check
        if (![channelUid isKindOfClass:[NSString class]]
            || ![message isKindOfClass:[NSString class]]
            || ![created isKindOfClass:[NSNumber class]]
            || ![uid isKindOfClass:[NSNumber class]]
            || ![user isKindOfClass:[NSDictionary class]]
            || ![displayName isKindOfClass:[NSString class]]
            || ![userUid isKindOfClass:[NSNumber class]])
        {
            return;
        }
        NSTimeInterval interval = [created doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        NSNumber *uidNum = uid;
        NSString *userUidStr = [userUid stringValue];
        NSDictionary *newContent = @{@"text":CCLocalizedString(@"Your current version can't display the message. Please download the latest version in App Store.")};
        if([[CCCoredataBase sharedClient] insertMessage:uidNum
                                                   type:messageType
                                                content:newContent
                                                   date:[NSDate date]
                                             channelUid:channelUid
                                              channelId:nil
                                                   user:user
                                       usersReadMessage:[[NSArray alloc]init]
                                                 answer:answer
                                               question:question
                                                 status:CC_MESSAGE_STATUS_SEND_SUCCESS])
        {
            NSLog(@"insertMessage Success!");
        }else{
            NSLog(@"insertMessage Error!");
        }
        
        NSDictionary *latest_message = @{
                                         @"type" : messageType,
                                         @"channel_uid" : channelUid,
                                         @"content" : content,
                                         @"created" : [NSDate date],
                                         @"id" : uidNum,
                                         @"user" :user
                                         };
        
        if (![userUidStr isEqualToString:[[CCConstants sharedInstance] getKeychainUid]]) {
            ///Count up unread message num when the message comes from
            if([[CCCoredataBase sharedClient] updateChannelWithUidAndLatestmessageAndunreadMessagesPlus:channelUid
                                                                                               updateAt:[NSDate date]
                                                                                          latestMessage:latest_message
                                                                                                   user:user]){
                NSLog(@"update channel Success!");
            }else{
                NSLog(@"update channel Error!");
            }
            [[ChatCenter sharedInstance] countUpUnreadMessage:channelUid];
        }else{
            if([[CCCoredataBase sharedClient] updateChannelWithUidAndLatestmessage:channelUid updateAt:[NSDate date] latestMessage:latest_message]){
                NSLog(@"update channel Success!");
            }else{
                NSLog(@"update channel Error!");
            }
        }
        
        if (self.didReceiveMessageCallback)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.didReceiveMessageCallback(messageType, uidNum, content, channelUid, userUidStr, date, displayName, userIconUrl, userAdmin, answer);
            });
        }
    }
}

- (void)webSocket:(CCSRWebSocketOriginal *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    if (self.didFailWithErrorOrClosedCallback)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.didFailWithErrorOrClosedCallback(nil,reason);
        });
    }
    _webSocket = nil;
}

- (void)sendMessage:(NSString *)message {
    if (_webSocket.readyState != SR_CONNECTING) {
        return;
    }
    [_webSocket send:message];
}
@end
