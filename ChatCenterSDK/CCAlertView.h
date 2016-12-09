//
//  CCAlertView.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2/19/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCAlertAction.h"

@interface CCAlertView : NSObject <UIAlertViewDelegate>
{
    UIViewController *_controller;
    NSString *_title;
    NSString *_message;
    NSMutableArray *_actions;
    
}

- (CCAlertView* __nonnull)initWithController:(UIViewController* __nonnull)controller title:(nullable NSString *)title message:(nullable NSString *)message;
- (void)addActionWithTitle:(NSString* __nonnull)title handler:(void (^ __nullable)(CCAlertAction* __nonnull action))handler;
- (void)show;

@end
