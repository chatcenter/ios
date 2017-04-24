//
//  CCDateTimes.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/08/26.
//  Copyright © 2015年 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCDateTimes : NSObject

@property (copy, nonatomic) NSString *year;
@property (copy, nonatomic) NSString *month;
@property (copy, nonatomic) NSString *day;
@property (nonatomic) NSInteger weekIndex;
@property (copy, nonatomic) NSDate *date;
@property (copy, nonatomic) NSArray *times;

-(instancetype)initWithDate:(NSString *)year
                      month:(NSString *)month
                        day:(NSString *)day
                  weekIndex:(NSInteger)weekIndex
                       date:(NSDate *)date
                      times:(NSArray *)times;

-(instancetype)initWithDateCalendar:(NSString *)year
                      month:(NSString *)month
                        day:(NSString *)day
                  weekIndex:(NSInteger)weekIndex
                       date:(NSDate *)date
                      times:(NSArray *)times;

- (NSComparisonResult)compare:(CCDateTimes *)otherObject;

@end
