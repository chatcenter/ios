//
//  CCJSQMessage.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/01/02.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCJSQMessageOriginal.h"

@interface CCJSQMessage : CCJSQMessageOriginal

@property (copy, nonatomic) NSDictionary *content;
@property (copy, nonatomic) NSNumber *uid;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSDictionary *answer;
@property (nonatomic) NSInteger status;
@property (nonatomic) BOOL isAgent;

+ (instancetype)messageWithSenderId:(NSString *)senderId
                        displayName:(NSString *)displayName
                              media:(id<CCJSQMessageMediaData>)media;


//
// It may return multiple objects if messageType is image
//
+ (NSArray<CCJSQMessage*> *)messageObjectsOfType:(NSString *)messageType
                                             uid:(NSNumber *)uid
                                         content:(NSDictionary *)content
                                usersReadMessage:(NSArray *)usersReadMessage
                                      fromSender:(NSString *)userUid
                                          onDate:(NSDate *)date
                                     displayName:(NSString *)displayName
                                     userIconUrl:(NSString *)userIconUrl
                                       userAdmin:(BOOL)userAdmin
                                          answer:(NSDictionary *)answer
                                          status:(NSInteger)status;

//
// Object Retrieval Utility
//
+ (id)getObjectAtPath:(NSString*)path fromObject:(id)obj;
+ (NSDictionary*)getDictionaryAtPath:(NSString*)path fromObject:(id)inObj;
+ (NSArray*)getArrayAtPath:(NSString*)path fromObject:(id)inObj;
+ (NSString*)getStringAtPath:(NSString*)path fromObject:(id)inObj;
+ (NSNumber*)getNumberAtPath:(NSString*)path fromObject:(id)inObj;
- (NSDictionary*)getDictionaryAtPath:(NSString*)path;
- (NSArray*)getArrayAtPath:(NSString*)path;
- (NSString*)getStringAtPath:(NSString*)path;
- (NSNumber*)getNumberAtPath:(NSString*)path;


@end
