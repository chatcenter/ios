//
//  CCUISplitViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/02/01.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCUISplitViewController.h"
#import "CCConstants.h"

@implementation CCUISplitViewController


- (void)displayModalList{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter-iPad" bundle:SDK_BUNDLE];
    UIViewController *historyView = [storyboard  instantiateViewControllerWithIdentifier:@"CCModalListViewController"];;
    //    historyView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    historyView.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    historyView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:historyView animated:YES completion:nil];
}


@end
