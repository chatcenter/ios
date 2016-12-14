//
//  CCCommonWidgetPreviewViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 11/10/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCJSQMessage.h"
#import "CCCommonWidgetEditorDelegate.h"
#import "CCCommonWidgetEditorDelegate.h"

@interface CCCommonWidgetPreviewViewController : UIViewController {
    NSString *channelId;
    NSString *userId;
    CCJSQMessage *message;
    id delegate;
}
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
- (void) setDelegate: (id<CCCommonWidgetEditorDelegate>)newDelegate;
- (void) setMessage: (CCJSQMessage *) msg;
- (void) cancelButtonPressed:(id)sender;

@end
