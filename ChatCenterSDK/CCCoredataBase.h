//
//  CCCoredataBase.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/02/20.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ChatCenter.h"

@interface CCCoredataBase : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CCCoredataBase *)sharedClient;
- (void)saveContext;
- (BOOL)isRequiredMigration;
- (NSPersistentStoreCoordinator *)doMigration;
///Message
- (BOOL)insertMessage:(NSNumber *)uid
                 type:(NSString *)type
              content:(NSDictionary *)content
                 date:(NSDate *)date
           channelUid:(NSString *)channelUid
            channelId:(NSNumber *)channelId
                 user:(NSDictionary *)user
     usersReadMessage:(NSArray *)usersReadMessage
               answer:(NSDictionary *)answer
             question:(NSDictionary *)question
               status:(NSInteger)status;
- (BOOL)updateMessage:(NSNumber *)uid
                 type:(NSString *)type
              content:(NSDictionary *)content
                 date:(NSDate *)date
           channelUid:(NSString *)channelUid
            channelId:(NSNumber *)channelId
                 user:(NSDictionary *)user
     usersReadMessage:(NSArray *)usersReadMessage
               answer:(NSDictionary *)answer
             question:(NSDictionary *)question
               status:(NSInteger)status;
- (NSInteger)getSmallestMessageId;
- (NSArray *)selectMessageWithChannel:(NSString *)channelUid lastId:(NSNumber *)lastId limit:(int)limit;
- (NSManagedObject *)selectLatestMessageWithChannel:(NSString *)channelUid;
- (NSArray *)selectFailedMessageWithChannel:(NSString *)channelUid;
- (NSArray *)selectDraftMessageWithChannel:(NSString *)channelUid;
- (NSArray *)selectMessageWithChannelAndUid:(NSNumber *)uid limit:(int)limit;
- (BOOL)updateMessageUsersReadMessage:(NSString *)channelId messageId:(NSNumber *)messageId userUid:(NSString *)userUid userAdmin:(BOOL)userAdmin;
- (BOOL)deleteAllMessagesWithChannel:(NSString *)channelUid;
- (BOOL)deleteAllMessages;
- (BOOL)deleteDraftMessagesWithChannel:(NSString *)channelUid;
- (BOOL)updateMessage:(NSNumber *)uid withResponseContent:(NSDictionary *)response;
///Channel
- (BOOL)insertChannel:(NSString *)channelUid
            createdAt:(NSDate *)createdAt
             updateAt:(NSDate *)updateAt
                users:(NSArray *)users
              org_uid:(NSString *)org_uid
             org_name:(NSString *)org_name
      unread_messages:(NSString *)unread_messages
       latest_message:(NSDictionary *)latest_message
                  uid:(NSNumber *)uid
               status:(NSString *)status
 channel_informations:(NSDictionary *)channel_informations
             icon_url:(NSString *)icon_url
                 read:(BOOL)read
        lastUpdatedAt:(NSDate *)lastUpdatedAt
                 name:(NSString *)name
       direct_message:(BOOL)direct_message
             assignee:(NSDictionary *)assignee;
- (NSArray *)selectAllChannel:(int)limit channelType:(CCChannelType)channelType;
- (NSArray *)selectChannels:(int)limit
              lastUpdatedAt:(NSDate *)lastUpdatedAt
                channelType:(CCChannelType)channelType;
- (NSArray *)selectChannelWithUid:(int)limit uid:(NSString *)uid;
- (NSArray *)selectChannelWithOrgUid:(int)limit orgUid:(NSString *)orgUid;
-(BOOL)updateChannelUpdatedWithUid:(NSString *)channelUid
                         createdAt:(NSDate *)createdAt
                          updateAt:(NSDate *)updateAt
                             users:(NSArray *)users
                           org_uid:(NSString *)org_uid
                          org_name:(NSString *)org_name
                   unread_messages:(NSString *)unread_messages
                    latest_message:(NSDictionary *)latest_message
                               uid:(NSNumber *)uid
                            status:(NSString *)status
              channel_informations:(NSDictionary *)channel_informations
                          icon_url:(NSString *)icon_url
                              read:(BOOL)read
                     lastUpdatedAt:(NSDate *)lastUpdatedAt
                              name:(NSString *)name
                    direct_message:(BOOL)direct_message
                          assignee:(NSDictionary *)assignee;
- (BOOL)updateChannelUpdatedWithUid:(NSString *)uid updateAt:(NSDate *)updateAt;
- (BOOL)updateChannelUpdateAtAndStatusWithUid:(NSString *)uid updateAt:(NSDate *)updateAt status:(NSString *)status;
- (BOOL)updateChannelWithUidAndLatestmessage:(NSString *)uid updateAt:(NSDate *)updateAt latestMessage:(NSDictionary *)latestMessage;
- (BOOL)updateChannelWithUidAndLatestmessageAndunreadMessagesPlus:(NSString *)uid updateAt:(NSDate *)updateAt latestMessage:(NSDictionary *)latestMessage user:(NSDictionary *)user;
- (BOOL)updateMessageWithAnswer:(NSNumber *)messageId answer:(NSDictionary *)answer;
- (BOOL)updateMessageWithStatus:(NSNumber *)messageId status:(NSInteger)status;
- (BOOL)deleteTempMessage:(NSNumber *)uid;
- (BOOL)updateChannelWithUsers:(NSString *)uid users:(NSArray *)users lastUpdateAt:(NSDate *)lastUpdateAt;
- (BOOL)updateChannelWithJoinedUser:(NSString *)uid newUser:(NSDictionary *)newUser lastUpdateAt:(NSDate *)lastUpdateAt;
- (BOOL)updateChannelWithRemovedUser:(NSString *)uid
                        removedUser:(NSDictionary *)removedUser
                       lastUpdateAt:(NSDate *)lastUpdateAt;
- (BOOL)updateChannelWithUnreadMessage:(NSString *)uid unreadMessage:(NSString *)unreadMessages;
- (BOOL)deleteChannelWithUid:(NSString *)uid;
- (BOOL)deleteAllChannel;
///Org
- (BOOL)insertOrg:(NSString *)uid name:(NSString *)name withUnreadMessagesChannels:(NSData *)unreadMessagesChannels users: (NSData *) users;
- (NSArray *)selectOrgAll:(int)limit;
- (NSArray *)selectOrgWithUid: (NSString *) uid;
- (BOOL)deleteAllOrg;

@end
