//
//  CCDateTimes.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/08/26.
//  Copyright © 2015年 AppSocially Inc. All rights reserved.
//

#import "CCDateTimes.h"
#import "CCHourTime.h"

@implementation CCDateTimes

-(instancetype)initWithDate:(NSString *)year
                      month:(NSString *)month
                        day:(NSString *)day
                  weekIndex:(NSInteger)weekIndex
                       date:(NSDate *)date
                      times:(NSArray *)times
{
    self = [super init];
    if(self)
    {
        self.year = year;
        self.month = month;
        self.day = day;
        self.weekIndex = weekIndex;
        self.date = date;
        if (times != nil && [times respondsToSelector:@selector(sortedArrayUsingSelector:)]
            && [times count] > 0 && [[times objectAtIndex:0] respondsToSelector:@selector(compare:)]) {
            NSMutableArray *timesCopy = [times mutableCopy];
            NSMutableArray *smallTimes = [NSMutableArray array];
            NSMutableArray *largeTimes = [NSMutableArray array];
            for (CCHourTime *hourTime in timesCopy) {
                if ([hourTime.endHour intValue] < 10) {
                    [smallTimes addObject:hourTime];
                }else{
                    [largeTimes addObject:hourTime];
                }
            }
            NSArray *sortedSmallTimes, *sortedLargeTimes;
            if (smallTimes.count > 0) {
                sortedSmallTimes = [smallTimes sortedArrayUsingSelector:@selector(compare:)];
            }
            if (largeTimes.count > 0) {
                sortedLargeTimes = [largeTimes sortedArrayUsingSelector:@selector(compare:)];
            }
            NSMutableArray *sortedTimes = [NSMutableArray array];
            for (CCHourTime *hourTime in sortedSmallTimes) {
                [sortedTimes addObject:hourTime];
            }
            for (CCHourTime *hourTime in sortedLargeTimes) {
                [sortedTimes addObject:hourTime];
            }
            self.times = sortedTimes;
        }else{
            self.times = times;
        }
    }
    return self;
}

-(instancetype)initWithDateCalendar:(NSString *)year
                              month:(NSString *)month
                                day:(NSString *)day
                          weekIndex:(NSInteger)weekIndex
                               date:(NSDate *)date
                              times:(NSArray *)times {
    self = [super init];
    if(self)
    {
        self.year = year;
        self.month = month;
        self.day = day;
        self.weekIndex = weekIndex;
        self.date = date;
        self.times = times;
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    CCDateTimes *dateTimes = [(CCDateTimes *)[[self class] allocWithZone:zone] initWithDate:self.year
                                                                                      month:self.month
                                                                                        day:self.day
                                                                                  weekIndex:self.weekIndex
                                                                                       date:self.date 
                                                                                      times:self.times];
    return dateTimes;
}

- (NSComparisonResult)compare:(CCDateTimes *)otherObject {
    return [self.date compare:otherObject.date];
}

@end
