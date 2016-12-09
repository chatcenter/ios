//
//  CCCommonStickerCreatorViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 3/2/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCommonStickerCreatorDelegate.h"

@interface CCCommonStickerCreatorViewController : UIViewController
{
    NSString *channelId;
    NSString *userId;
    id<CCCommonStickerCreatorDelegate> delegate;
    
    UIView *previewView;
    
}

- (BOOL)validInput;
- (void)setChannelId:(NSString *)newChannelId;
- (void)setUserId:(NSString *)newUserId;
- (void)setDelegate:(id<CCCommonStickerCreatorDelegate>)newDelegate;
- (void)cancel;
- (void)preview;
- (NSString *)generateMessageUniqueId;

@end
