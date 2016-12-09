//
//  CCOrg.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2014/12/19.
//  Copyright (c) 2014年 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CCOrg : NSManagedObject

@property (nonatomic, retain) NSString * ancestry;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSDate * deleteAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSData *unreadMessagesChannels;
@property (nonatomic, retain) NSDate * updateAt;
@property (nonatomic, retain) NSData * users;

@end
