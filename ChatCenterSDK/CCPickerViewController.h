//
//  CCPickerViewController.h
//  ChatCenterDemo
//
//  Created by VietHD on 6/2/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCJSQMessage.h"
#import "CCChatViewController.h"

@interface CCPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) CCChatViewController* chatViewController;

-(void)setupWithMessage:(CCJSQMessage *)msg;

@end
