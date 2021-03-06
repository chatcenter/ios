//
//  CCHistoryViewCell.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/07/02.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCMGSwipeTableCell.h"

@interface CCHistoryViewCell : CCMGSwipeTableCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarLeftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeStampRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *UnreadNumWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *UnassignedWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *UnassignedRightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LastMessageRightMargin;
@property (strong, nonatomic) IBOutlet UIImageView *imageReply;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageReplyWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageReplyLeftMargin;
@end
