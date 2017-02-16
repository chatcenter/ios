//
//  CCCalendarTimeView.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/08/24.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCCalendarTimeSlotView.h"
#import "CCConstants.h"

@interface CCCalendarTimeSlotView(){
    int dragStartX;
    int dragStartY;
    BOOL isDragging;
    BOOL dispatched;
}
@end

@implementation CCCalendarTimeSlotView

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
                    delegate:(id)delegate
{
    self = [self initWithFrame:frame];
    self.is24h = is24h;
    self.hourTime = hourTime;
    self.delegate = delegate;
    isDragging = NO;
    dispatched = NO;
    self.selectedSlotView.backgroundColor = [[CCConstants sharedInstance] baseColor];
    self.topButtonDisplay.layer.borderColor = [[CCConstants sharedInstance] baseColor].CGColor;
    self.bottomButtonDisplay.layer.borderColor = [[CCConstants sharedInstance] baseColor].CGColor;
    
    return self;
}

- (void)setHourTime:(CCHourTime *)hourTime{
    _hourTime = hourTime;
    if (_is24h) {
        _timeLabel.text = [NSString stringWithFormat:@"%@:%@ - %@:%@",hourTime.startHour, hourTime.startTime, hourTime.endHour, hourTime.endTime];
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
        _timeLabel.text = [NSString stringWithFormat:@"%@ - %@",startHourLabel, endHourLabel];
    }
}

- (IBAction)didTapDeleteButton:(id)sender {
    NSLog(@"didTapDeleteSlotButton");
    if ([self.delegate respondsToSelector:@selector(removedSlotView:hourTime:)]) {
        [self.delegate removedSlotView:self hourTime:self.hourTime];
    }
}

@end
