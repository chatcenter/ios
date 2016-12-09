//
//  CCChannel.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2014/12/19.
//  Copyright (c) 2014年 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CCChannel : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSDate * deleteAt;
@property (nonatomic, retain) NSString * unread_messages;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSDate * updateAt;
@property (nonatomic, retain) NSData * users;
@property (nonatomic, retain) NSString * org_uid;
@property (nonatomic, retain) NSString * org_name;
@property (nonatomic, retain) NSData * latest_message;
@property (nonatomic, retain) NSDate * last_updated_at;
@property (nonatomic, retain) NSDate * channel_informations;
@property (nonatomic, retain) NSString * icon_url;
@property (nonatomic) BOOL read;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) BOOL direct_message;
@property (nonatomic, retain) NSData * assignee;

@end
