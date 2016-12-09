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

@protocol CCCalendarTimeViewDelegate <NSObject>

- (void)selectedHourTime:(CCHourTime *)hourTime;
- (void)removedHourTime:(CCHourTime *)hourTime;
- (void)swipeRight;
- (void)swipeLeft;

@end

@interface CCCalendarTimeView : UIView

@property (nonatomic, weak) id<CCCalendarTimeViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *topTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *selectedTopView;
@property (weak, nonatomic) IBOutlet UIView *selectedBottomView;
@property (weak, nonatomic) IBOutlet CCHourTimeButton *bottomHourTimeButton;
@property (weak, nonatomic) IBOutlet CCHourTimeButton *topHourTimeButton;
- (IBAction)pressSelectedTopView:(id)sender;
- (IBAction)pressSelectedBottomView:(id)sender;
- (IBAction)dragInsideTopView:(id)sender forEvent:(UIEvent *)event;
- (IBAction)dragInsideBottomView:(id)sender forEvent:(UIEvent *)event;

- (id)initWithFrameAndLabels:(CGRect)frame
               timeLabelText:(NSString *)timeLabelText
            topTimeLabelText:(NSString *)topTimeLabelText
         bottomTimeLabelText:(NSString *)bottomTimeLabelText
                 topHourTime:(CCHourTime *)topHourTime
              bottomHourTime:(CCHourTime *)bottomHourTime
                    delegate:(id)delegate;

- (NSComparisonResult)compare:(CCCalendarTimeView *)otherObject;

@end
