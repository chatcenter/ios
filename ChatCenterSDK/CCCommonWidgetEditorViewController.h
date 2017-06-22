//
//  CCCommonWidgetEditorViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 11/10/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCJSQMessage.h"
#import "CCCommonWidgetEditorDelegate.h"

@interface CCCommonWidgetEditorViewController : UIViewController {
    NSString *channelId;
    NSString *userId;
    id delegate;
}

- (BOOL)validInput;
- (void)setChannelId:(NSString *)newChannelId;
- (void)setDelegate: (id)newDelegate;
- (void)setUserId:(NSString *)newUserId;
- (void)cancel;
- (void)preview;
- (CCJSQMessage *) createMessage;
- (NSString *)generateMessageUniqueId;
@property (nullable, nonatomic, copy) void (^closeQuestionCallback)(void);

@end
