//
//  CCAlertView.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2/19/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCAlertView.h"

@implementation CCAlertView

- (CCAlertView*)initWithController:(UIViewController*)controller title:(nullable NSString *)title message:(nullable NSString *)message {
    // set data
    self->_controller = controller;
    self->_title = title;
    self->_message = message;
    self->_actions = [[NSMutableArray alloc] init];
    return self;
}

- (void)addActionWithTitle:(NSString*)title handler:(void (^ __nullable)(CCAlertAction *action))handler {
    CCAlertAction *action = [[CCAlertAction alloc] initWithTitle:title handler:handler];
    [_actions addObject:action];
}

- (void)show {
    // create alert & show
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(osVersion >= 8.0f)  {
        // iOS >= 8
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:_title message:_message preferredStyle:UIAlertControllerStyleAlert];
        for(int i=0; i<_actions.count; i++) {
            CCAlertAction *action = [_actions objectAtIndex:i];
            [alert addAction:[UIAlertAction actionWithTitle:[action getTitle] style:UIAlertActionStyleDefault handler:^(UIAlertAction *_) {
                if([action getHandler] != nil) {
                    [action getHandler](action);
                }
            }]];
        }
        [_controller presentViewController:alert animated:YES completion:nil];
    } else {
        // iOS < 8
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_title message:_message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        for(int i=0; i<_actions.count; i++) {
            CCAlertAction *action = [_actions objectAtIndex:i];
            [alert addButtonWithTitle:[action getTitle]];
        }
        [alert show];
    }
}

//=====================================================================================================================
// UIAlertViewDelegate
//=====================================================================================================================

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // get button label & call callback
    NSString *buttonText = [alertView buttonTitleAtIndex:buttonIndex];
    for(int i=0; i<_actions.count; i++) {
        CCAlertAction *action = [_actions objectAtIndex:i];
        if([[action getTitle] isEqualToString:buttonText]) {
            if([action getHandler] != nil) {
                [action getHandler](action);
            }
            break;
        }
    }
}

@end
