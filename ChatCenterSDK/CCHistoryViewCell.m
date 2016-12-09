//
//  CCHistoryViewCell.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/07/02.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCHistoryViewCell.h"
#import "CCConnectionHelper.h"

@implementation CCHistoryViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(osVersion >= 8.0f)  {  //iOS8~
        if ([CCConnectionHelper sharedClient].twoColumnLayoutMode == YES) {
            self.avatarLeftMargin.constant = 10;
            self.timeStampRightMargin.constant = 10;
            self.statusRightMargin.constant = 10;
        }
    }else { ///~iOS7
        self.avatarLeftMargin.constant = 23;
        self.timeStampRightMargin.constant = 23;
        self.statusRightMargin.constant = 23;
    }
}

@end
