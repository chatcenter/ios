//
//  CCMessage.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2014/12/19.
//  Copyright (c) 2014年 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CCMessage : NSManagedObject

@property (nonatomic, retain) NSString * channel_uid;
@property (nonatomic, retain) NSData * content;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSDate * deleteAt;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSData * users_read_message;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updateAt;
@property (nonatomic, retain) NSData * user;
@property (nonatomic, retain) NSData * answer;
@property (nonatomic, retain) NSData * question;
@property (nonatomic, retain) NSNumber * channel_id;
@property (nonatomic, retain) NSNumber * status;

@end
