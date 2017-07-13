//
//  CCChatViewHelper.m
//  ChatCenterDemo
//
//  Created by GiapNH on 6/29/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import "CCChatViewHelper.h"
#import "ChatCenterPrivate.h"
#import "CCConnectionHelper.h"
#import "CCParseUtils.h"

@implementation CCChatViewHelper
// Send channel:active to server via Websocket
+ (void) sendChannelActive:(NSString *)channelId {
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(q_global, ^{
        if (channelId != nil) {
            NSString *content = [NSString stringWithFormat:@"{\"channel_uid\":\"%@\"}", channelId];
            [[CCConnectionHelper sharedClient] sendMessageViaWebsocket:@"channel:active" content:content];
        }
    });
}

// Filter guest user from list user
+ (NSArray *)filteredGuestFrom:(NSArray *)users {
    NSMutableArray *guests = [[NSMutableArray alloc] init];
    for(NSDictionary *user in users) {
        if (![CCParseUtils getBoolAtPath:@"admin" fromObject:user]) {
            [guests addObject:user];
        }
    }
    return [guests copy];
}

// Remove specified user with user id from list users
+ (NSArray *)removeSpecifiedUserFrom:(NSArray *)users userId:(NSString *)userId {
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < users.count; i++) {
        NSInteger currentUserId = [[[users objectAtIndex:i] objectForKey:@"id"] integerValue];
        if(currentUserId != [userId integerValue]) {
            [filteredArray addObject:[users objectAtIndex:i]];
        }
    }
    return [[NSArray alloc] initWithArray:filteredArray];
}

// Filter user who can use video chat feature
+ (NSArray *)filterUserCanVideoChatFrom:(NSArray *)users {
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < users.count; i++) {
        NSDictionary *user = [users objectAtIndex:i];
        if([user objectForKey:@"can_use_video_chat"] != nil &&
           [user objectForKey:@"can_use_video_chat"] != [NSNull null] &&
           [[user objectForKey:@"can_use_video_chat"] integerValue] == 1) {
            [filteredArray addObject:user];
        }
    }
    return filteredArray;
}

+ (UIViewController *)topViewController{
    return [[self class] topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}
@end
