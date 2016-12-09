//
//  CCCalendarWeekView.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/08/17.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCConstants.h"
@protocol CCCalendarWeekViewDelegate <NSObject>

- (void)moveWeekDay:(NSInteger)dayOfWeek;

@end

@interface CCCalendarWeekView : UIView

@property (nonatomic, weak) id<CCCalendarWeekViewDelegate> delegate;
@property (nonatomic, copy) NSArray *dayArray;
-(void)setUp:(NSArray *)dayArray dayOfWeek:(NSInteger)dayOfWeek;
-(void)updateDateTxt:(NSArray *)dayArray;
-(void)updateWeekDay:(NSInteger)dayOfWeek;

@end
