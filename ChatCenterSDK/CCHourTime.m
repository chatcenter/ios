//
//  CCHourTime.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/08/26.
//  Copyright © 2015年 AppSocially Inc. All rights reserved.
//

#import "CCHourTime.h"

@implementation CCHourTime

-(instancetype)initWithHourTime:(NSString *)startHour
                      startTime:(NSString *)startTime
                        endHour:(NSString *)endHour
                        endTime:(NSString *)endTime
{
    self = [super init];
    if(self)
    {
        self.startHour = startHour;
        self.startTime = startTime;
        self.endHour = endHour;
        self.endTime = endTime;
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    CCHourTime *hourTime = [(CCHourTime *)[[self class] allocWithZone:zone] initWithHourTime:self.startHour
                                                                                   startTime:self.startTime
                                                                                     endHour:self.endHour
                                                                                     endTime:self.endTime];
    return hourTime;
}

- (NSComparisonResult)compare:(CCHourTime *)otherObject {
    NSString *endTime = [NSString stringWithFormat:@"%@%@", self.endHour, self.endTime];
    NSString *otherObjectEndTime = [NSString stringWithFormat:@"%@%@", otherObject.endHour, otherObject.endTime];
    return [endTime compare:otherObjectEndTime];
}

@end
