//
//  CCModalListViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/02/06.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCModalListHeader.h"

@interface CCModalListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CCModalListHeaderDelegate>

@property (nonatomic, copy) void (^didTapAboutCallback)(void);
@property (nonatomic, copy) void (^didTapLogoutCallback)(void);
@property (nonatomic, copy) void (^didTapSwitchAppCallback)(void);
@property (nonatomic, copy) void (^didTapSwitchOrgCallback)(void);
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UIImageView *avatarApp;
@property (weak, nonatomic) IBOutlet UIButton *btnSetting;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImageRight;
@property (weak, nonatomic) IBOutlet UILabel *lablelSwithApp;
@property (weak, nonatomic) IBOutlet UIView *appInforView;

@end

@interface CCModalListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *unreadLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end
