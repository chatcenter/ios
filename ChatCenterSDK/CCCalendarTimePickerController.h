//
//  CCCalendarTimePickerController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/08/17.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCalendarWeekScrollView.h"
#import "CCCalendarWeekView.h"
#import "CCConstants.h"
#import "ChatCenterPrivate.h"
#import "CCCalendarTimeView.h"
#import "CCHourTime.h"
#import "CCDateTimes.h"
#import "CCCalendarTimeScrollView.h"
#import "CCCalendarPreview.h"
#import "CCConnectionHelper.h"
#import "CCCommonWidgetEditorDelegate.h"


@interface CCCalendarTimePickerController : UIViewController<UIScrollViewDelegate, CCCalendarTimeScrollViewDelegate, CCCalendarWeekViewDelegate, CCCalendarPreviewDelegate>

@property (weak, nonatomic) id<CCCommonWidgetEditorDelegate> delegate;

@property (nonatomic) NSMutableArray *selectedDateTimes;
@property (weak, nonatomic) IBOutlet CCCalendarWeekScrollView *calendarWeekScrollView;
@property (weak, nonatomic) IBOutlet CCCalendarTimeScrollView *calendarTimeScrollView;
@property (weak, nonatomic) IBOutlet UILabel *CCCalendarDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleDiscriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *navigationBarView;
@property (nonatomic, copy) void (^closeCalendarTimePickerCallback)(NSArray *dateTimes);

- (instancetype)initWithDelegate:(id<CCCommonWidgetEditorDelegate>)delegate;

- (IBAction)didTapCancelButton:(id)sender;
- (IBAction)didTapDoneButton:(id)sender;

@end
