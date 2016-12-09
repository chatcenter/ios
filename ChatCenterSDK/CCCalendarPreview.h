//
//  CCCalendarPreview.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/09/07.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCalendarPreviewCell.h"

@protocol CCCalendarPreviewDelegate <NSObject>

- (void)calendarPreviewDidTapClose;
- (void)calendarPreviewDidTapSend;

@end

@interface CCCalendarPreview : UIView

@property (nonatomic, weak) id<CCCalendarPreviewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, strong) NSArray *selectedDateTimes;

extern const int DATE_LABEL_HEIGHT;
extern const int DATE_LABEL_MARGIN;
extern const int CHOICE_HEIGHT;
extern const int CHOICE_MARGIN;

- (id)initWithFrameAndData:(CGRect)frame
         selectedDateTimes:(NSArray *)selectedDateTimes;

@end
