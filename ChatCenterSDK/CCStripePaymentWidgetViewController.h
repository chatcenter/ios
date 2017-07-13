//
//  CCStripePaymentWidgetViewController.h
//  ChatCenterDemo
//
//  Created by GiapNH on 6/21/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCChatViewController.h"

@interface CCStripePaymentWidgetViewController : UIViewController<UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *tvPaymentTitle;
@property (strong, nonatomic) IBOutlet UITextField *tfAmount;
@property (strong, nonatomic) IBOutlet UIButton *btnCurrency;
@property (nullable, nonatomic, weak) id delegate;
@end
