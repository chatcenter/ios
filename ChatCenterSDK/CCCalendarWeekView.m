//
//  CCCalendarWeekView.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/08/17.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCCalendarWeekView.h"
#import <QuartzCore/QuartzCore.h>
#import "ChatCenterPrivate.h"
#import "CCConstants.h"

@interface CCCalendarWeekView(){
    NSMutableArray *dayBottomViews;
    NSMutableArray *dayBottomLabels;
    NSMutableArray *dayBottomCircles;
}
@end

@implementation CCCalendarWeekView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setUp:(NSArray *)dayArray dayOfWeek:(NSInteger)dayOfWeek{
    dayBottomViews = [NSMutableArray array];
    dayBottomCircles = [NSMutableArray array];
    dayBottomLabels = [NSMutableArray array];
    int width = self.frame.size.width/7;
    NSArray *weekDayArrray = @[CCLocalizedString(@"Monday-Min"),
                               CCLocalizedString(@"Tuesday-Min"),
                               CCLocalizedString(@"Wednesday-Min"),
                               CCLocalizedString(@"Thursday-Min"),
                               CCLocalizedString(@"Friday-Min"),
                               CCLocalizedString(@"Saturday-Min"),
                               CCLocalizedString(@"Sunday-Min")];
    for (int i = 0; i < 7; i++) {
        UIView *dayTopView =  [[UIView alloc] initWithFrame:CGRectMake(width*i,0,width,40)];
        ///border
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0, 0, dayTopView.frame.size.width, 1.0f);
        topBorder.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
//        CALayer *bottomBorder = [CALayer layer];
//        bottomBorder.frame = CGRectMake(0, 32, dayTopView.frame.size.width, 0.4f);
//        bottomBorder.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
        ///label
        UILabel *dayToplabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,width,40)];
        dayToplabel.text = weekDayArrray[i];
        dayToplabel.font = [UIFont systemFontOfSize:16.0f];
        dayToplabel.textColor = [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1.0];
        dayToplabel.textAlignment = NSTextAlignmentCenter;
        ///Add
        [dayTopView.layer addSublayer:topBorder];
//        [dayTopView.layer addSublayer:bottomBorder];
        [dayTopView addSubview:dayToplabel];
        [self addSubview:dayTopView];
        UIView *dayBottomView =  [[UIView alloc] initWithFrame:CGRectMake(width*i,40,width,40)];
        ///Circle
        UIView *dayBottomCircle =  [[UIView alloc] initWithFrame:CGRectMake(width/2-14,6,28,28)];
        dayBottomCircle.layer.cornerRadius = 14.0f;
        dayBottomCircle.clipsToBounds = YES;
        dayBottomCircle.backgroundColor = [[CCConstants sharedInstance] baseColor];
        if (i != dayOfWeek) {
            dayBottomCircle.alpha = 0;
        }
        ///border
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0, dayBottomView.frame.size.height-1.0f, dayBottomView.frame.size.width, 1.0f);
        bottomBorder.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
        ///label
        UILabel *dayBottomlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,width,40)];
        dayBottomlabel.text = dayArray[i][@"day"];
        dayBottomlabel.font = [UIFont systemFontOfSize:16.0f];
        dayBottomlabel.textAlignment = NSTextAlignmentCenter;
        if (i == dayOfWeek) {
            dayBottomlabel.textColor = [UIColor whiteColor];
        }
        ///Add
        [dayBottomView.layer addSublayer:bottomBorder];
        [dayBottomView addSubview:dayBottomCircle];
        [dayBottomView addSubview:dayBottomlabel];
        [self addSubview:dayBottomView];
        [dayBottomViews addObject:dayBottomView];
        [dayBottomCircles addObject:dayBottomCircle];
        [dayBottomLabels addObject:dayBottomlabel];
        ///Day button
        UIButton *dayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dayButton.frame = CGRectMake(width*i,0,width,80);
        dayButton.tag = i;
        [dayButton addTarget:self
                      action:@selector(didTapDayButton:)
            forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dayButton];
    }
    self.dayArray = dayArray;
}

-(void)updateDateTxt:(NSArray *)dayArray{
    for (int i = 0; i < 7; i++) {
        [(UILabel *)dayBottomLabels[i] setText:dayArray[i][@"day"]];
    }
    self.dayArray = dayArray;
}

-(void)updateWeekDay:(NSInteger)dayOfWeek{
    for (int i = 0; i < 7; i++) {
        if (i == dayOfWeek) {
            [(UILabel *)dayBottomLabels[i] setTextColor:[UIColor whiteColor]];
            [(UIView *)dayBottomCircles[i] setAlpha:1.0];
        }else{
            [(UILabel *)dayBottomLabels[i] setTextColor:[UIColor blackColor]];
            [(UIView *)dayBottomCircles[i] setAlpha:0];
        }
    }
}

-(void)didTapDayButton:(id)sender{
    UIButton *selectedDayButton = (UIButton *)sender;
    if ([self.delegate respondsToSelector:@selector(moveWeekDay:)]) {
        [self.delegate moveWeekDay:selectedDayButton.tag];
    }
}


@end
