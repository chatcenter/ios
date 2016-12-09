//
//  CCCalendarTimeScrollView.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/08/26.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCalendarTimeView.h"
#import "CCCalendarTimeViewBorder.h"
#import "CCCalendarTimeSlotView.h"

@protocol CCCalendarTimeScrollViewDelegate <NSObject>

- (void)moveForward;
- (void)moveBack;

@end

@interface CCCalendarTimeScrollView : UIScrollView<UIScrollViewDelegate, CCCalendarTimeViewDelegate>

@property (nonatomic, weak) id<CCCalendarTimeScrollViewDelegate>timeScrollViewDelegate;
@property (nonatomic) NSMutableArray *selectedHourTimes;
@property (nonatomic) NSMutableArray *hourTimes;

- (void)updateSelections:(NSMutableArray *)selectedHourTimes;

@end
