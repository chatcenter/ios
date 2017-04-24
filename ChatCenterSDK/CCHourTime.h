//
//  CCHourTime.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/08/26.
//  Copyright © 2015年 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCHourTime : NSObject <NSCopying>

@property (copy, nonatomic) NSString *startHour;
@property (copy, nonatomic) NSString *startTime;
@property (copy, nonatomic) NSString *endHour;
@property (copy, nonatomic) NSString *endTime;
@property (copy, nonatomic) NSString *summary;
@property int overLappinglevel;
@property BOOL isAllDay;
@property BOOL isEndDay;
@property BOOL isStartDay;

-(instancetype)initWithHourTime:(NSString *)startHour
                      startTime:(NSString *)startTime
                        endHour:(NSString *)endHour
                        endTime:(NSString *)endTime;

-(instancetype)initWithHourTime:(NSString *)startHour
                      startTime:(NSString *)startTime
                        endHour:(NSString *)endHour
                        endTime:(NSString *)endTime
                        summary:(NSString *)summary;

- (NSComparisonResult)compare:(CCHourTime *)otherObject;

@end
