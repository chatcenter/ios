//
//  CCChatViewHelper.h
//  ChatCenterDemo
//
//  Created by GiapNH on 6/29/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCChatViewHelper : NSObject
+ (void) sendChannelActive:(NSString *)channelId;
+ (NSArray *)filteredGuestFrom:(NSArray *)users;
+ (NSArray *)removeSpecifiedUserFrom:(NSArray *)users userId:(NSString *)userId;
+ (NSArray *)filterUserCanVideoChatFrom:(NSArray *)users;
+ (UIViewController *)topViewController;
@end
