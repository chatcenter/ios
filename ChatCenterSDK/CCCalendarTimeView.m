//
//  CCCalendarTimeView.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/08/24.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCCalendarTimeView.h"
#import "CCConstants.h"

@interface CCCalendarTimeView(){
    int dragStartX;
    BOOL isDragging;
    BOOL dispatched;
}

@end

@implementation CCCalendarTimeView

const int LIMIT_OF_MOVEMENT = 20;

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
               timeLabelText:(NSString *)timeLabelText
            topTimeLabelText:(NSString *)topTimeLabelText
         bottomTimeLabelText:(NSString *)bottomTimeLabelText
                 topHourTime:(CCHourTime *)topHourTime
              bottomHourTime:(CCHourTime *)bottomHourTime
                    delegate:(id)delegate
{
    self = [self initWithFrame:frame];
    self.timeLabel.text = timeLabelText;
    self.topTimeLabel.text = topTimeLabelText;
    self.bottomTimeLabel.text = bottomTimeLabelText;
    self.topHourTimeButton.hourTime = topHourTime;
    self.bottomHourTimeButton.hourTime = bottomHourTime;
    self.delegate = delegate;
    isDragging = NO;
    dispatched = NO;
    return self;
}

- (IBAction)pressSelectedTopView:(id)sender {
    isDragging = NO;
    if (dispatched == YES) {
        dispatched = NO;
        return;
    }
    
    CCHourTimeButton *selectedButton = (CCHourTimeButton *)sender;
    CCHourTime *hourTime = selectedButton.hourTime;
    if (self.selectedTopView.alpha == 0) {
        self.selectedTopView.alpha = 1;
        if (hourTime != nil) {
            if ([self.delegate respondsToSelector:@selector(selectedHourTime:)]) {
                [self.delegate selectedHourTime:hourTime];
            }
        }
    }else{
        self.selectedTopView.alpha = 0;
        if (hourTime != nil) {
            if ([self.delegate respondsToSelector:@selector(removedHourTime:)]) {
                [self.delegate removedHourTime:hourTime];
            }
        }
    }
}

- (IBAction)pressSelectedBottomView:(id)sender {
    isDragging = NO;
    if (dispatched == YES) {
        dispatched = NO;
        return;
    }

    CCHourTimeButton *selectedButton = (CCHourTimeButton *)sender;
    CCHourTime *hourTime = selectedButton.hourTime;
    if (self.selectedBottomView.alpha == 0) {
        self.selectedBottomView.alpha = 1;
        if (hourTime != nil) {
            if ([self.delegate respondsToSelector:@selector(selectedHourTime:)]) {
                [self.delegate selectedHourTime:hourTime];
            }
        }
    }else{
        self.selectedBottomView.alpha = 0;
        if (hourTime != nil) {
            if ([self.delegate respondsToSelector:@selector(removedHourTime:)]) {
                [self.delegate removedHourTime:hourTime];
            }
        }
    }
}

- (IBAction)dragInsideTopView:(id)sender forEvent:(UIEvent *)event {
    NSLog(@"dragInsideTopView");
    [self dragOccured:sender forEvent:event];
}

- (IBAction)dragInsideBottomView:(id)sender forEvent:(UIEvent *)event {
    NSLog(@"dragInsideBottomView");
    [self dragOccured:sender forEvent:event];
}

- (void)dragOccured:(id)sender forEvent:(UIEvent *)event {
    if (dispatched == YES) {
        return;
    }
    
    UIButton *btn = (UIButton *)sender;
    NSSet *touches = [event touchesForView:btn];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:btn];
    if (isDragging == NO) {
        isDragging = YES;
        dragStartX = touchPoint.x;
    }else{
        int movement = touchPoint.x - dragStartX;
        NSLog(@"movement: %d",movement) ;
        if (LIMIT_OF_MOVEMENT < movement) {
            NSLog(@"swipeRight");
            if ([self.delegate respondsToSelector:@selector(swipeRight)]) {
                dispatched = YES;
                [self.delegate swipeRight];
            }
        }else if(movement < -LIMIT_OF_MOVEMENT){
            NSLog(@"swipeLeft");
            if ([self.delegate respondsToSelector:@selector(swipeLeft)]) {
                dispatched = YES;
                [self.delegate swipeLeft];
            }
        }
    }
}

- (NSComparisonResult)compare:(CCCalendarTimeView *)otherObject {
    CCHourTime *bottomHourTime = self.bottomHourTimeButton.hourTime;
    CCHourTime *otherObjectBottomHourTime = otherObject.bottomHourTimeButton.hourTime;
    return [bottomHourTime compare:otherObjectBottomHourTime];
}

@end
