//
//  CCChannelViewerCollectionViewCell.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 7/4/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCChannelViewerCollectionViewCell.h"

@implementation CCChannelViewerCollectionViewCell
- (void) setAvatar:(CCJSQMessagesAvatarImage *)jSQMessagesAvatarImage {
    if (self.viewerAvatar != nil) {
        self.viewerAvatar.image = jSQMessagesAvatarImage.avatarImage;
    }
}
@end
