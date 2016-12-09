//
//  CCCalendarPreviewCell.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/09/07.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCDateTimes.h"
#import "ChatCenterPrivate.h"
#import "CCHourTime.h"
#import "CCCalendarPreview.h"
#import "CCConstants.h"

@interface CCCalendarPreviewCell : UIView

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *choiceContainer;

- (id)initWithFrameAndData:(CGRect)frame
         selectedDateTimes:(NSArray *)selectedDateTimes;

@end
