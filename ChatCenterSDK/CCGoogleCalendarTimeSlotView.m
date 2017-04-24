//
//  CCGoogleCalendarTimeSlotView.m
//  ChatCenterDemo
//
//  Created by GiapNH on 3/31/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import "CCGoogleCalendarTimeSlotView.h"
#import "CCConstants.h"

@interface CCGoogleCalendarTimeSlotView(){
    int dragStartX;
    int dragStartY;
    BOOL isDragging;
    BOOL dispatched;
}
@end

@implementation CCGoogleCalendarTimeSlotView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (void)p_commonInit
{
    NSString *className = NSStringFromClass([self class]);
    [SDK_BUNDLE loadNibNamed:className owner:self options:0];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
}

- (id)initWithFrameAndLabels:(CGRect)frame
                    hourTime:(CCHourTime *)hourTime
                    is24h:(BOOL)is24h
{
    self = [self initWithFrame:frame];
    self.is24h = is24h;
    self.hourTime = hourTime;
    isDragging = NO;
    dispatched = NO;
    return self;
}

- (void)setHourTime:(CCHourTime *)hourTime{
    hourTime = hourTime;
    if (_is24h) {
        _timeLabel.text = [NSString stringWithFormat:@"%@:%@ - %@:%@  %@",hourTime.startHour, hourTime.startTime, hourTime.endHour, hourTime.endTime, hourTime.summary];
    }else{
        NSString *startHourLabel;
        NSString *endHourLabel;
        if (12 < [hourTime.startHour intValue]) {
            startHourLabel = [NSString stringWithFormat:@"PM %d:%@", [hourTime.startHour intValue]-12, hourTime.startTime];
        }else{
            startHourLabel = [NSString stringWithFormat:@"AM %d:%@", [hourTime.startHour intValue], hourTime.startTime];
        }
        if (12 < [hourTime.endHour intValue]) {
            endHourLabel = [NSString stringWithFormat:@"PM %d:%@", [hourTime.endHour intValue]-12, hourTime.endTime];
        }else{
            endHourLabel = [NSString stringWithFormat:@"AM %d:%@", [hourTime.endHour intValue], hourTime.endTime];
        }
        _timeLabel.text = [NSString stringWithFormat:@"%@ - %@  %@",startHourLabel, endHourLabel, hourTime.summary];
    }
}

@end
