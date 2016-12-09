//
//  CCChannelViewerCollectionViewCell.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 7/4/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCJSQMessagesAvatarImage.h"

@interface CCChannelViewerCollectionViewCell : UICollectionViewCell
- (void) setAvatar:(CCJSQMessagesAvatarImage *)jSQMessagesAvatarImage;

@property (strong, nonatomic) IBOutlet UIImageView *viewerAvatar;
@end
