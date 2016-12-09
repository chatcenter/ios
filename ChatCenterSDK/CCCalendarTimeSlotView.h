//
//  CCCalendarTimeView.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/08/24.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCHourTime.h"
#import "CCHourTimeButton.h"

@protocol CCCalendarTimeSlotViewDelegate <NSObject>

- (void)removedSlotView:(UIView *)slotView hourTime:(CCHourTime *)hourTime;

@end

@interface CCCalendarTimeSlotView : UIView

@property (nonatomic, weak) id<CCCalendarTimeSlotViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedSlotView;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomButtonDisplay;
@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (weak, nonatomic) IBOutlet UIButton *topButtonDisplay;
@property (copy, nonatomic) CCHourTime *hourTime;
@property BOOL is24h;

- (IBAction)didTapDeleteButton:(id)sender;

- (id)initWithFrameAndLabels:(CGRect)frame
                    hourTime:(CCHourTime *)hourTime
                       is24h:(BOOL)is24h
                    delegate:(id)delegate;

@end
