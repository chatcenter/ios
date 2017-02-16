//
//  CCPhoneStickerCollectionViewCell.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/10/27.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCPhoneStickerCollectionViewCell.h"
#import "CCHightlightButton.h"
#import "ChatCenterPrivate.h"

@interface CCPhoneStickerCollectionViewCell () {
    NSString *receiverName;
    NSString *senderName;
    NSString *duration;
}
@end

@implementation CCPhoneStickerCollectionViewCell

- (BOOL)setupWithIndex:(NSIndexPath *)indexPath message:(CCJSQMessage *)msg avatar:(CCJSQMessagesAvatarImage *)avatar delegate:(id<CCStickerCollectionViewCellActionProtocol>)delegate options:(CCStickerCollectionViewCellOptions)options userList:(NSArray*)users {

    
    NSString *userId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:kCCUserDefaults_userId]];
    if([userId isEqualToString:msg.senderId]) {
        senderName = CCLocalizedString(@"You");
    } else {
        senderName = msg.senderDisplayName;
    }

    if(users) {
        NSArray *receiversArray = msg.content[@"receivers"];
        receiverName = [self getReceiverNameFrom:receiversArray inUserArray:users];
    }


    NSAttributedString *str = [self createMessageString:msg];
    NSMutableDictionary *dic = [msg.content mutableCopy];
    [dic setObject:[str string] forKey:@"text"];
    msg.content = dic;
    
    [super setupWithIndex:indexPath
                  message:msg
                   avatar:avatar
                 delegate:delegate
                  options:options];
    
    
    
    if(msg.content[@"action"] != nil && msg.content[@"action"] != [NSNull null]) {
        int currButtonStartY = 0;
        //
        // create button
        //
        CCHightlightButton *button = [CCHightlightButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(onCallAgainClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:CCLocalizedString(@"Call again") forState:UIControlStateNormal];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.numberOfLines = 0;
        button.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        int buttonHeight = CC_STICKER_ACTION_BUTTON_MIN_HEIGHT;
        
        button.frame = CGRectMake(0.0, currButtonStartY, CC_STICKER_BUBBLE_WIDTH, buttonHeight);
        currButtonStartY += buttonHeight;
        stickerActionsContainerHeight.constant = currButtonStartY;
        // 20160624 AppSocially Inc. hide "call again" of call message (temporary)
        stickerActionsContainerHeight.constant = 0;
        // add button to container
        //        [stickerActionsContainer addSubview:button];
    }
    
    return YES;

}

- (NSAttributedString *)createMessageString:(CCJSQMessage *)msg {

    NSString *text = nil;
    long startCallTime = 0;
    long endCallTime = 0;

    NSArray *events = msg.content[@"events"];
    if (events != nil && ![events isEqual:[NSNull null]]) {
        Boolean isMissedCall = false;
        for(int i = 0; i < events.count; i++) {
            if (events[i][@"content"] != nil && ![events[i][@"content"] isEqual:[NSNull null]]
                && events[i][@"content"][@"action"] != nil && ![events[i][@"content"][@"action"] isEqual:[NSNull null]]) {
                NSString *action = events[i][@"content"][@"action"];
                if ([action isEqualToString:@"reject"]) {
                    isMissedCall = true;
                } else if ([action isEqualToString:@"accept"]) {
                    isMissedCall = false;
                    startCallTime = [events[i][@"created_at"] longValue];
                } else if([action isEqualToString:@"hangup"]) {
                    long newEndCallTime = [events[i][@"created_at"] longValue];
                    if (endCallTime < newEndCallTime) {
                        endCallTime = newEndCallTime;
                    }
                }
            }
        }
        if (startCallTime == 0 || startCallTime > endCallTime) {
            duration = CCLocalizedString(@"Missed call");
            text = [NSString stringWithFormat:CCLocalizedString(@"Call message"), senderName, receiverName, duration];
        } else {
            if (endCallTime == 0 && !isMissedCall) {
                endCallTime = startCallTime;
            }
            
            long durationTime = endCallTime - startCallTime;
            NSInteger hours = (((NSInteger) durationTime) / (60 * 60));
            NSInteger minutes = (((NSInteger) durationTime) / 60) - (hours * 60);
            NSInteger seconds = ((NSInteger) round(durationTime)) % 60;
            NSString *hourText = @"", *minuteText = @"", *secondText = @"";
            if (hours >= 0 && hours < 10) {
                hourText = [NSString stringWithFormat:@"0%ld", (long)hours];
            } else {
                hourText = [NSString stringWithFormat:@"%ld", (long)hours];
            }
            
            if (minutes >= 0 && minutes < 10) {
                minuteText = [NSString stringWithFormat:@"0%ld", (long)minutes];
            } else {
                minuteText = [NSString stringWithFormat:@"%ld", (long)minutes];
            }
            
            if (seconds >= 0 && seconds < 10) {
                secondText = [NSString stringWithFormat:@"0%ld", (long)seconds];
            } else {
                secondText = [NSString stringWithFormat:@"%ld", (long)seconds];
            }
            
            if (hours > 0) {
                duration = [NSString stringWithFormat:@"%@:%@:%@", hourText, minuteText, secondText];
            } else {
                duration = [NSString stringWithFormat:@"%@:%@", minuteText, secondText];
            }
            text = [NSString stringWithFormat:CCLocalizedString(@"Call message"), senderName, receiverName, duration];
        }
    } else {
        duration = CCLocalizedString(@"Missed call");
        text = [NSString stringWithFormat:CCLocalizedString(@"Call message"), senderName, receiverName, duration];
    }
    
    if (!text) {
        return nil;
    }


    NSDictionary *messageStringAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:15.0f]};
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:text attributes:messageStringAttributes];
    
    NSRange boldRange1 = [text rangeOfString:senderName];
    NSRange boldRange2 = [text rangeOfString:receiverName];
    NSRange italicRange = [text rangeOfString:duration];
    [message setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0f]} range:boldRange1];
    [message setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0f]} range:boldRange2];
    [message setAttributes:@{NSFontAttributeName:[UIFont italicSystemFontOfSize:15.0f]} range:italicRange];
    
    return message;
}


- (NSString *)getReceiverNameFrom:(NSArray *)usersToCheck inUserArray:(NSArray *)users {
    if(!usersToCheck || !users) {
        return @"";
    }
    NSString *usersName = @"";
    for (int i = 0; i < usersToCheck.count; i++) {
        NSDictionary *receiverDict = [usersToCheck objectAtIndex:i];
        NSInteger userId = [receiverDict[@"user_id"] integerValue];
        for (NSDictionary *userDict in users) {
            if([[userDict objectForKey:@"id"] integerValue] == userId) {
                NSInteger currentUserId = [[[NSUserDefaults standardUserDefaults] valueForKey:kCCUserDefaults_userId] integerValue];
                if(userId == currentUserId) {
                    usersName = [usersName stringByAppendingString:[NSString stringWithFormat:@"%@, ", CCLocalizedString(@"You")]];
                } else {
                    usersName = [usersName stringByAppendingString:[NSString stringWithFormat:@"%@, ", [userDict objectForKey:@"display_name"]]];
                }
                
            }
        }
        if(usersName.length > 0) {
            return [usersName substringToIndex:usersName.length-2]; //escape white space and "," character
        } else {
            return usersName;
        }
    }
    
    // should never happend
    return @"";
}

+ (NSString *)getReceiverNameFrom:(NSArray *)usersToCheck inUserArray:(NSArray *)users {
    if(!usersToCheck || !users) {
        return @"";
    }
    
    NSString *usersName = @"";
    for (int i = 0; i < usersToCheck.count; i++) {
        NSDictionary *receiverDict = [usersToCheck objectAtIndex:i];
        NSInteger userId = [receiverDict[@"user_id"] integerValue];
        for (NSDictionary *userDict in users) {
            if([[userDict objectForKey:@"id"] integerValue] == userId) {
                NSInteger currentUserId = [[[NSUserDefaults standardUserDefaults] valueForKey:kCCUserDefaults_userId] integerValue];
                if(userId == currentUserId) {
                    usersName = [usersName stringByAppendingString:@"You, "];
                } else {
                    usersName = [usersName stringByAppendingString:[NSString stringWithFormat:@"%@, ", [userDict objectForKey:@"display_name"]]];
                }
            }
        }
        if(usersName.length > 0) {
            return [usersName substringToIndex:usersName.length-2]; //escape white space and "," character
        } else {
            return usersName;
        }
    }
    
    // should never happend
    return @"";
}


- (void) onCallAgainClicked:(UIButton *)sender {
    NSLog(@"onCallAgainClicked");
    NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:kCCUserDefaults_userId];
    NSDictionary *callerInfo;
    if(userId != nil && [CCConstants sharedInstance].userIdentity != nil) {
        callerInfo = @{@"user_id": userId, @"identity": [CCConstants sharedInstance].userIdentity};
    }
    
    // receiverName
    NSMutableDictionary *callInfo = [[NSMutableDictionary alloc] init];
    if([receiverName isEqualToString:CCLocalizedString(@"You")]) {
        NSMutableDictionary *content = [_msg.content mutableCopy];
        NSDictionary *caller = content[@"caller"];
        NSArray *receivers = content[@"receivers"];
        if(receivers.count == 1 && callerInfo != nil) {
            [content setObject:callerInfo forKey:@"caller"];
        }
        [content setObject:@[caller] forKey:@"receivers"];
        [callInfo removeObjectForKey:@"events"];
        [callInfo setObject:content forKey:@"content"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCCNoti_UserReactionToCallAgain object:senderName userInfo:callInfo];
    } else {
        NSMutableDictionary *content = [_msg.content mutableCopy];
        if(callerInfo) {
            [content setObject:callerInfo forKey:@"caller"];
        }
        [callInfo removeObjectForKey:@"events"];
        [callInfo setObject:content forKey:@"content"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCCNoti_UserReactionToCallAgain object:receiverName userInfo:callInfo];
    }
    
}


+ (CGSize) estimateSizeForMessage:(CCJSQMessage *)msg atIndexPath:(NSIndexPath *)indexPath hasPreviousMessage:(CCJSQMessage *)preMsg options:(CCStickerCollectionViewCellOptions)options withListUser:(NSArray *)users {
    int height = 0;
    
    // date height
    if (options & CCStickerCollectionViewCellOptionShowDate) {
        height += CC_STICKER_DATE_HEIGHT;
    }
    
    // sender name height
    if (options & CCStickerCollectionViewCellOptionShowName) {
        height += CC_STICKER_SENDER_NAME_HEIGHT;
    }
    
    // sticker message height
    NSString *text = nil;
    if (msg.content[@"message"] != nil && ![msg.content[@"message"] isEqual:[NSNull null]]
        && msg.content[@"message"][@"text"] != nil && ![msg.content[@"message"][@"text"] isEqual:[NSNull null]]) {
        text = msg.content[@"message"][@"text"];
        
    } else if (msg.content[@"text"] != nil && ![msg.content[@"text"] isEqual:[NSNull null]]) {
        text = msg.content[@"text"];
    }
    
    // for call message
    
     NSString *receiverName, *senderName, *duration;
     long startCallTime = 0;
     long endCallTime = 0;
     if([msg.type isEqualToString:CC_RESPONSETYPECALL]) {
     if(users) {
     NSArray *receiversArray = msg.content[@"receivers"];
     receiverName = [self getReceiverNameFrom:receiversArray inUserArray:users];
     }
     
     NSString *userId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:kCCUserDefaults_userId]];
     if([userId isEqualToString:msg.senderId]) {
     senderName = CCLocalizedString(@"You");
     } else {
     senderName = msg.senderDisplayName;
     }
         
         NSArray *events = msg.content[@"events"];
         if (events != nil && ![events isEqual:[NSNull null]]) {
             Boolean isMissedCall = false;
             for(int i = 0; i < events.count; i++) {
                 if (events[i][@"content"] != nil && ![events[i][@"content"] isEqual:[NSNull null]]
                     && events[i][@"content"][@"action"] != nil && ![events[i][@"content"][@"action"] isEqual:[NSNull null]]) {
                     NSString *action = events[i][@"content"][@"action"];
                     if ([action isEqualToString:@"reject"]) {
                         isMissedCall = true;
                     } else if ([action isEqualToString:@"accept"]) {
                         isMissedCall = false;
                         startCallTime = [events[i][@"created_at"] longValue];
                     } else if([action isEqualToString:@"hangup"]) {
                         long newEndCallTime = [events[i][@"created_at"] longValue];
                         if (endCallTime < newEndCallTime) {
                             endCallTime = newEndCallTime;
                         }
                     }
                 }
             }
             if (startCallTime == 0 || startCallTime > endCallTime) {
                 duration = CCLocalizedString(@"Missed call");
                 text = [NSString stringWithFormat:CCLocalizedString(@"Call message"), senderName, receiverName, duration];
             } else {
                 if (endCallTime == 0 && !isMissedCall) {
                     endCallTime = startCallTime;
                 }
                 long durationTime = endCallTime - startCallTime;
                 NSInteger hours = (((NSInteger) durationTime) / (60 * 60));
                 NSInteger minutes = (((NSInteger) durationTime) / 60) - (hours * 60);
                 NSInteger seconds = ((NSInteger) round(durationTime)) % 60;
                 NSString *hourText = @"", *minuteText = @"", *secondText = @"";
                 if (hours >= 0 && hours < 10) {
                     hourText = [NSString stringWithFormat:@"0%ld", (long)hours];
                 } else {
                     hourText = [NSString stringWithFormat:@"%ld", (long)hours];
                 }
                 
                 if (minutes >= 0 && minutes < 10) {
                     minuteText = [NSString stringWithFormat:@"0%ld", (long)minutes];
                 } else {
                     minuteText = [NSString stringWithFormat:@"%ld", (long)minutes];
                 }
                 
                 if (seconds >= 0 && seconds < 10) {
                     secondText = [NSString stringWithFormat:@"0%ld", (long)seconds];
                 } else {
                     secondText = [NSString stringWithFormat:@"%ld", (long)seconds];
                 }
                 
                 if (hours > 0) {
                     duration = [NSString stringWithFormat:@"%@:%@:%@", hourText, minuteText, secondText];
                 } else {
                     duration = [NSString stringWithFormat:@"%@:%@", minuteText, secondText];
                 }
                 text = [NSString stringWithFormat:CCLocalizedString(@"Call message"), senderName, receiverName, duration];
             }
         } else {
             duration = CCLocalizedString(@"Missed call");
             text = [NSString stringWithFormat:CCLocalizedString(@"Call message"), senderName, receiverName, duration];
         }
     }
    
    
    NSDictionary *messageStringAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:15.0f]};
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:text attributes:messageStringAttributes];
    CGRect discriptionViewFrame = [message boundingRectWithSize:CGSizeMake(CC_STICKER_BUBBLE_WIDTH - 25, 1800)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                        context:nil];
    NSLog(@"discriptionViewFrame.height %.2f at index %ld", discriptionViewFrame.size.height, (long)indexPath.row);
    height += discriptionViewFrame.size.height + 20; // 20 for Container Insets

    
    // TODO sticker object height
    if (msg.content[CC_STICKERCONTENT] != nil && msg.content[CC_STICKERCONTENT][CC_THUMBNAILURL] != nil
        && ![msg.content[CC_STICKERCONTENT][CC_THUMBNAILURL] isEqual:[NSNull null]]) {
        NSURL *thumbnailUrl = [NSURL URLWithString:[msg.content[CC_STICKERCONTENT][CC_THUMBNAILURL] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        if (thumbnailUrl && thumbnailUrl.host && thumbnailUrl.scheme) {
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                height += 255.0f;
            }else {
                height += 150.0f;
            }
        } else if ([msg.type isEqualToString:CC_STICKERTYPEIMAGE]){
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                height += 255.0f;
            }else {
                height += 150.0f;
            }
        }
    }
    
    // sticker actions height
    NSString *stickerActionType = msg.content[@"sticker-action"][@"action-type"];
    NSArray *stickerActions = msg.content[@"sticker-action"][@"action-data"];
    NSLog(@"Sticker action = %@", stickerActions);
    NSDictionary *labelStringAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12.0f]};
    if (stickerActions != nil && stickerActions.count == 2 && [stickerActionType isEqualToString:@"confirm"]) {
        int currButtonStartY = 0;
        for (int i=0; i<stickerActions.count; i++) {
            NSDictionary *stickerAction = [stickerActions objectAtIndex:i];
            NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString:[stickerAction objectForKey:@"label"] attributes:labelStringAttributes];
            int buttonHeight = MAX(CC_STICKER_ACTION_BUTTON_MIN_HEIGHT, [labelText boundingRectWithSize:CGSizeMake((CC_STICKER_BUBBLE_WIDTH - 10)/2, 1800) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height + 10);
            if (currButtonStartY < buttonHeight) {
                currButtonStartY = buttonHeight;
            }
        }
        height += currButtonStartY;
    }else if(![stickerActionType isEqualToString:@"text"] && stickerActions != nil && stickerActions.count > 0) {
        // add actions
        int currButtonStartY = 0;
        for (int i=0; i<stickerActions.count; i++) {
            NSDictionary *stickerAction = [stickerActions objectAtIndex:i];
            NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString:[stickerAction objectForKey:@"label"] attributes:labelStringAttributes];
            int buttonHeight = MAX(CC_STICKER_ACTION_BUTTON_MIN_HEIGHT, [labelText boundingRectWithSize:CGSizeMake(CC_STICKER_BUBBLE_WIDTH - 10, 1800) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height + 10);
            currButtonStartY += buttonHeight;
        }
        height += currButtonStartY;
    }
    
    // calculate cell width
    CGRect screenRect = [UIScreen mainScreen].applicationFrame;
    float cellWidth = screenRect.size.width;
    
    return CGSizeMake(cellWidth, height);
}


@end
