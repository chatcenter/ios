//
//  CCGoogleCalendarTimeSlotView.h
//  ChatCenterDemo
//
//  Created by GiapNH on 3/31/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCHourTime.h"

@interface CCGoogleCalendarTimeSlotView : UIView

@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *calendarSlotView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (copy, nonatomic) CCHourTime *hourTime;
@property BOOL is24h;

- (id)initWithFrameAndLabels:(CGRect)frame
                    hourTime:(CCHourTime *)hourTime
                       is24h:(BOOL)is24h;
@end
