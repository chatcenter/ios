//
//  CCLiveLocationTask.h
//  ChatCenterDemo
//
//  Created by VietHD on 12/27/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCJSQMessage.h"

@interface CCLiveLocationTask: NSObject
@property (nonatomic, strong) NSTimer *colocationTimer;
@property (nonatomic) int liveColocationShareDuration;
@property (nonatomic) int liveColocationShareTimer;
@property (nonatomic) UIBackgroundTaskIdentifier colocationBackgroundTask;
@property (nonatomic) CCJSQMessage *colocationMessage;
@end
