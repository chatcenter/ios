//
//  CCNavigationController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/06/25.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCNavigationController.h"
#import "CCConstants.h"

@interface CCNavigationController ()

@end

@implementation CCNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
