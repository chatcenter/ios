//
//  CCBaseQuestionWidgetPaneViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 11/17/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCBaseQuestionWidgetPaneViewController.h"

@interface CCBaseQuestionWidgetPaneViewController () {
    UIView *viewToShow;
}

@end

@implementation CCBaseQuestionWidgetPaneViewController
CGFloat keyboardHeight;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    keyboardHeight = 0;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(void)keyboardWillShow:(NSNotification*)aNotification {
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    keyboardHeight = kbSize.height + 40;
    [self.scrollViewDelegate setViewMovedUp:keyboardHeight viewToShow:viewToShow];
}

-(void)keyboardWillHide:(NSNotification*)aNotification  {
    keyboardHeight = 0;
    [self.scrollViewDelegate setViewMovedUp:0 viewToShow:viewToShow];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIScreen *screen = [UIScreen mainScreen];
    float y = screen.bounds.size.height - textField.bounds.origin.y;
    NSLog(@"textFieldDidBeginEditing = %f", y);
    
    viewToShow = textField;
    
    if (keyboardHeight>0) {
//        [self.scrollViewDelegate setViewMovedUp:keyboardHeight];
    }
}
@end
