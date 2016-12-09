//
//  CCCoredataBase.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/02/20.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCCoredataBase.h"
#import "CCConstants.h"
#import "ChatCenter.h"

@implementation CCCoredataBase
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;

+ (CCCoredataBase *)sharedClient
{
    static CCCoredataBase *sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[CCCoredataBase alloc] init];
    });
    
    return sharedClient;
}

# pragma mark - Coredata Base Api

-(NSManagedObjectModel *)managedObjectModel
{
    NSURL *modelURL1 = [[NSBundle bundleForClass:[self class]] URLForResource:@"ChatCenter" withExtension:@"momd"];
    if (_managedObjectModel == nil) {
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL1];
    }
    return _managedObjectModel;
}

- (NSString *)applicationDocumentsDirectory { ///Save directory
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator == nil) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
        
        NSURL *url =  [NSURL fileURLWithPath:[[self applicationDocumentsDirectory]
                                              stringByAppendingPathComponent: @"ChatCenter.sqlite"]];
        NSError *error = nil;
        
        NSDictionary *options = [NSDictionary
                                 dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES],
                                 NSInferMappingModelAutomaticallyOption,
                                 nil];
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:url
                                                             options:options
                                                               error:&error])
        {
            NSLog(@"persistentStoreCoordinator: Error %@, %@", error, [error userInfo]);
        }
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext == nil) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _managedObjectContext;
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
        NSLog(@"saveContext: %@", error.debugDescription);
    }
}

- (BOOL)isRequiredMigration{
    NSURL *url =  [NSURL fileURLWithPath:[[self applicationDocumentsDirectory]
                                          stringByAppendingPathComponent: @"ChatCenter.sqlite"]];
    NSError* error = nil;
    NSDictionary* sourceMetaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:url
                                                                                            error:&error];
    if (sourceMetaData == nil) {
        return NO;
    } else if (error) {
        NSLog(@"Checking migration was failed (%@, %@)", error, [error userInfo]);
        abort();
    }
    
    BOOL isCompatible = [self.managedObjectModel isConfiguration:nil
                                     compatibleWithStoreMetadata:sourceMetaData];
    
    return !isCompatible;
}

- (NSPersistentStoreCoordinator *)doMigration{
    NSURL *url =  [NSURL fileURLWithPath:[[self applicationDocumentsDirectory]
                                          stringByAppendingPathComponent: @"ChatCenter.sqlite"]];
    
    NSDictionary *options = [NSDictionary
                             dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                             NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES],
                             NSInferMappingModelAutomaticallyOption,
                             nil];
    NSError *error = nil;
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:url
                                                         options:options
                                                           error:&error])
    {
        NSLog(@"persistentStoreCoordinator: Error %@, %@", error, [error userInfo]);
    }
    return _persistentStoreCoordinator;
}

# pragma mark - Coredata CRUD Methods

# pragma mark - Coredata Message Table
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
               status:(NSInteger)status
{
    //Check nil for user if type != information
    if (user == nil && ![type isEqualToString:CC_RESPONSETYPEINFORMATION] && ![type isEqualToString:CC_RESPONSETYPEPROPERTY]) {
        return NO;
    }
    ///duplicate check
    NSArray *mutableFetchResults = [[CCCoredataBase sharedClient] selectMessageWithChannelAndUid:uid limit:CCloadLoacalMessageSelectLimit];
    if (!mutableFetchResults) {
        // error handling code.
    }
    if ([mutableFetchResults count] > 0) {
        //notify duplicates
        NSLog(@"Duplicate insert!");
        [self updateMessage:uid
                       type:type
                    content:content
                       date:date
                 channelUid:channelUid
                  channelId:nil
                       user:user
           usersReadMessage:usersReadMessage
                     answer:answer
                   question:question
                     status:CC_MESSAGE_STATUS_SEND_SUCCESS];
        return NO;
    }else{
        NSLog(@"No duplicate insert");
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"CCMessage" inManagedObjectContext:[self managedObjectContext]];
        
        /// If appropriate, configure the new managed object.
        /// Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        NSData *contentData = [NSKeyedArchiver archivedDataWithRootObject:content];
        NSData *usersReadMessageData = [NSKeyedArchiver archivedDataWithRootObject:usersReadMessage];
        [newManagedObject setValue:uid forKey:@"id"];
        [newManagedObject setValue:contentData forKey:@"content"];
        [newManagedObject setValue:date forKey:@"created"];
        [newManagedObject setValue:date forKey:@"updateAt"];
        [newManagedObject setValue:channelUid forKey:@"channel_uid"];
        [newManagedObject setValue:usersReadMessageData forKey:@"users_read_message"];
        [newManagedObject setValue:nil forKey:@"deleteAt"];
        [newManagedObject setValue:type forKey:@"type"];
        [newManagedObject setValue:[NSNumber numberWithInteger:status] forKey:@"status"];
        if (user != nil){
            NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user];
            [newManagedObject setValue:userData forKey:@"user"];
        }
        if (answer != nil){
            NSData *answerData = [NSKeyedArchiver archivedDataWithRootObject:answer];
            [newManagedObject setValue:answerData forKey:@"answer"];
        }
        if (question != nil) {
            NSData *questionData = [NSKeyedArchiver archivedDataWithRootObject:question];
            [newManagedObject setValue:questionData forKey:@"question"];
        }
        if (channelId != nil){
            [newManagedObject setValue:channelId forKey:@"channel_id"];
        }
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) { /// Save the context.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            return NO;
        }else{
            return YES;
        }
    }
}

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
               status:(NSInteger)status
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCMessage" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCloadLoacalChannelLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"id = %@", uid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    if (resultArray != nil && [resultArray count] != 0) {
        NSManagedObject *newManagedObject = resultArray[0];
        NSData *contentData = [NSKeyedArchiver archivedDataWithRootObject:content];
        NSData *usersReadMessageData = [NSKeyedArchiver archivedDataWithRootObject:usersReadMessage];
        [newManagedObject setValue:contentData forKey:@"content"];
        [newManagedObject setValue:date forKey:@"created"];
        [newManagedObject setValue:date forKey:@"updateAt"];
        [newManagedObject setValue:channelUid forKey:@"channel_uid"];
        [newManagedObject setValue:usersReadMessageData forKey:@"users_read_message"];
        [newManagedObject setValue:nil forKey:@"deleteAt"];
        [newManagedObject setValue:[NSNumber numberWithInteger:status] forKey:@"status"];
        if (user != nil){
            NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user];
            [newManagedObject setValue:userData forKey:@"user"];
        }
        if (answer != nil){
            NSData *answerData = [NSKeyedArchiver archivedDataWithRootObject:answer];
            [newManagedObject setValue:answerData forKey:@"answer"];
        }
        if (question != nil) {
            NSData *questionData = [NSKeyedArchiver archivedDataWithRootObject:question];
            [newManagedObject setValue:questionData forKey:@"question"];
        }
        if (channelId != nil){
            [newManagedObject setValue:channelId forKey:@"channel_id"];
        }
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) { /// Save the context.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            return NO;
        }else{
            return YES;
        }
    } else {
        return NO;
    }
}

- (NSInteger)getSmallestMessageId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCMessage" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:1];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSDictionary *entityProperties = [entity propertiesByName];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"id"]]];
    [fetchRequest setReturnsDistinctResults:YES];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    if (resultArray != nil && [resultArray count] > 0) {
        NSManagedObject *message = [resultArray objectAtIndex:0];
        return [[message valueForKey:@"id"] integerValue];
    }
    
    return 0;
}

- (NSArray *)selectMessageWithChannel:(NSString *)channelUid lastId:(NSNumber *)lastId limit:(int)limit
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCMessage" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:limit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred;
    if (lastId == nil) {
        pred = [NSPredicate predicateWithFormat:@"(channel_uid = %@) && (status != %d)", channelUid, CC_MESSAGE_STATUS_DELIVERING];
    }else{
        pred = [NSPredicate predicateWithFormat:@"(channel_uid = %@) AND (id < %@) AND (status != %d)", channelUid, lastId, CC_MESSAGE_STATUS_DELIVERING];
    }
    [fetchRequest setPredicate:pred];
    
    ///prevent dupilicate but this doesn't work
    NSDictionary *entityProperties = [entity propertiesByName];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"id"]]];
    [fetchRequest setReturnsDistinctResults:YES];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    return resultArray;
}

- (NSArray *)selectLatestMessageWithChannel:(NSString *)channelUid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCMessage" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:1];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"channel_uid = %@", channelUid];
    [fetchRequest setPredicate:pred];
    
    ///prevent dupilicate but this doesn't work
    NSDictionary *entityProperties = [entity propertiesByName];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"id"]]];
    [fetchRequest setReturnsDistinctResults:YES];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    if(resultArray != nil && resultArray.count > 0) {
        return [resultArray objectAtIndex:0];
    }
    return nil;
}

- (NSArray *)selectFailedMessageWithChannel:(NSString *)channelUid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCMessage" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:100];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"channel_uid = %@ AND (status = %d)", channelUid, CC_MESSAGE_STATUS_SEND_FAILED];
    [fetchRequest setPredicate:pred];
    
    ///prevent dupilicate but this doesn't work
    NSDictionary *entityProperties = [entity propertiesByName];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"id"]]];
    [fetchRequest setReturnsDistinctResults:YES];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    return resultArray;
}

- (NSArray *)selectDraftMessageWithChannel:(NSString *)channelUid {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCMessage" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:1];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred;
    pred = [NSPredicate predicateWithFormat:@"channel_uid = %@ AND status = %d", channelUid, CC_MESSAGE_STATUS_DRAFT];
    [fetchRequest setPredicate:pred];
    
    ///prevent dupilicate but this doesn't work
    NSDictionary *entityProperties = [entity propertiesByName];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"id"]]];
    [fetchRequest setReturnsDistinctResults:YES];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    return resultArray;
}

- (NSArray *)selectMessageWithChannelAndUid:(NSNumber *)uid limit:(int)limit
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCMessage" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:limit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"id = %@", uid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    return resultArray;
}

- (BOOL)updateMessageUsersReadMessage:(NSString *)channelId messageId:(NSNumber *)messageId userUid:(NSString *)userUid userAdmin:(BOOL)userAdmin
{
    NSArray *messageArray = [[CCCoredataBase sharedClient] selectMessageWithChannelAndUid:messageId limit:CCupdateMessageUsersReadMessageLimit];
    if (messageArray != nil && [messageArray count] != 0) {
        NSManagedObject *object = [messageArray objectAtIndex:0];
        NSData *usersReadMessageData = [object valueForKey:@"users_read_message"];
        NSArray *usersReadMessage    = [NSKeyedUnarchiver unarchiveObjectWithData:usersReadMessageData];
        NSMutableArray *newUsersReadMessage = [usersReadMessage mutableCopy];
        [newUsersReadMessage addObject:@{ @"id":userUid, @"admin":[NSNumber numberWithBool:userAdmin]}];
        NSData *newUsersReadMessageData = [NSKeyedArchiver archivedDataWithRootObject:newUsersReadMessage];
        [object setValue:newUsersReadMessageData forKey:@"users_read_message"];
        
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        } else {
            return YES;
        }
    }else{
        return NO;
    }
}

- (BOOL)updateMessageWithAnswer:(NSNumber *)messageId answer:(NSDictionary *)answer
{
    NSArray *messageArray = [[CCCoredataBase sharedClient] selectMessageWithChannelAndUid:messageId
                                                                                    limit:CCupdateMessageUsersReadMessageLimit];
    if (messageArray != nil && [messageArray count] != 0) {
        NSManagedObject *object = [messageArray objectAtIndex:0];
        NSData *answerData = [NSKeyedArchiver archivedDataWithRootObject:answer];
        [object setValue:answerData forKey:@"answer"];
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        } else {
            return YES;
        }
    }else{
        return NO;
    }
}

- (BOOL)updateMessageWithStatus:(NSNumber *)messageId status:(NSInteger)status
{
    NSArray *messageArray = [[CCCoredataBase sharedClient] selectMessageWithChannelAndUid:messageId
                                                                                    limit:CCupdateMessageUsersReadMessageLimit];
    if (messageArray != nil && [messageArray count] != 0) {
        NSManagedObject *object = [messageArray objectAtIndex:0];
        [object setValue:[NSNumber numberWithInteger:status] forKey:@"status"];
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        } else {
            return YES;
        }
    }else{
        return NO;
    }
}

- (BOOL)deleteTempMessage:(NSNumber *)uid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCMessage" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCdeleteLoacalLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"id = %@", uid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    }else{
        NSArray *resultArray = [fetchedResultsController fetchedObjects];
        for (int i = 0; i < resultArray.count; i++) {
            NSManagedObject *object = [resultArray objectAtIndex:i];
            [self.managedObjectContext deleteObject:object];
        }
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
    }
}

- (BOOL)deleteAllMessagesWithChannel:(NSString *)channelUid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCMessage" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCdeleteLoacalLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"channel_uid = %@ AND (status != %d AND status != %d AND status != %d)", channelUid, CC_MESSAGE_STATUS_DELIVERING, CC_MESSAGE_STATUS_SEND_FAILED, CC_MESSAGE_STATUS_DRAFT];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    }else{
        NSArray *resultArray = [fetchedResultsController fetchedObjects];
        for (int i = 0; i < resultArray.count; i++) {
            NSManagedObject *object = [resultArray objectAtIndex:i];
            [self.managedObjectContext deleteObject:object];
        }
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
    }
}

- (BOOL)deleteDraftMessagesWithChannel:(NSString *)channelUid {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCMessage" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCdeleteLoacalLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"channel_uid = %@ AND status = %d", channelUid, CC_MESSAGE_STATUS_DRAFT];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    }else{
        NSArray *resultArray = [fetchedResultsController fetchedObjects];
        for (int i = 0; i < resultArray.count; i++) {
            NSManagedObject *object = [resultArray objectAtIndex:i];
            [self.managedObjectContext deleteObject:object];
        }
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
    }
}

- (BOOL)deleteAllMessages
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCMessage" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCdeleteLoacalLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(status != %d AND status != %d)", CC_MESSAGE_STATUS_DELIVERING, CC_MESSAGE_STATUS_SEND_FAILED];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    }else{
        NSArray *resultArray = [fetchedResultsController fetchedObjects];
        for (int i = 0; i < resultArray.count; i++) {
            NSManagedObject *object = [resultArray objectAtIndex:i];
            [self.managedObjectContext deleteObject:object];
        }
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
    }
}

- (BOOL)updateMessage:(NSNumber *)uid withResponseContent:(NSDictionary *)response {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCMessage" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCloadLoacalChannelLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"id = %@", uid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    if (resultArray != nil && [resultArray count] != 0) {
        NSManagedObject *object = resultArray[0];
        
        // update content
        NSData *contentData                = [object valueForKey:@"content"];
        NSMutableDictionary *content       = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:contentData]];
        NSMutableDictionary *stickerAction = [NSMutableDictionary dictionaryWithDictionary:[content objectForKey:@"sticker-action"]];

        NSMutableArray *actionResponseData = [NSMutableArray array];;

        NSDictionary *answers = [response objectForKey:@"answers"];
        if(answers) {
            //
            // Moon-style multiple choice
            //
            for (NSDictionary *anAnswer in answers) {
                [actionResponseData addObject:anAnswer];
            }
        } else {
            //
            // Conventional style single-choice
            //
            [actionResponseData addObject:response[@"answer"]];
        }
        
        //
        // For backward compatibility action-response-data should be in this form
        // (Wrapped by an array and a dictionary with the key "action")
        //
        // (
        //    {
        //       "action" = (
        //                    {
        //                      "label" = label
        //                      "value" = {
        //                                     //Any specific key-values
        //                                 }
        //                    },
        //                    {
        //                      "label" = label
        //                      "value" = {
        //                                     //Any specific key-values
        //                                 }
        //                    },
        //                    ...
        //                 )
        //     }
        // )
        NSArray *wrapped = @[ @{ @"action":actionResponseData } ];
        
        [stickerAction setValue:wrapped forKey:@"action-response-data"];
        [content setValue:stickerAction forKey:@"sticker-action"];
        
        NSData *newContentData = [NSKeyedArchiver archivedDataWithRootObject:content];
        [object setValue:newContentData forKey:@"content"];
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
        return YES;
    }else{
        return NO;
    }
}

# pragma mark - Coredata Channel Table
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
             assignee:(NSDictionary *)assignee
{
    ///duplicate check
    NSArray *mutableFetchResults = [[CCCoredataBase sharedClient] selectChannelWithUid:CCloadLoacalChannelLimit uid:channelUid];
    if (!mutableFetchResults) {
        // error handling code.
    }
    if ([mutableFetchResults count] > 0) {
        //notify duplicates
        NSLog(@"Duplicate insert!");
        return NO;
    }else{
        NSLog(@"No duplicate insert");
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:users];
        NSData *latestMessageData = [NSKeyedArchiver archivedDataWithRootObject:latest_message];
        if(uid != nil) [newManagedObject setValue:uid   forKey:@"id"];
        [newManagedObject setValue:channelUid           forKey:@"uid"];
        [newManagedObject setValue:createdAt            forKey:@"created"];
        [newManagedObject setValue:updateAt             forKey:@"updateAt"];
        [newManagedObject setValue:data                 forKey:@"users"];
        [newManagedObject setValue:latestMessageData    forKey:@"latest_message"];
        [newManagedObject setValue:nil                  forKey:@"deleteAt"];
        [newManagedObject setValue:status               forKey:@"status"];
        [newManagedObject setValue:org_uid              forKey:@"org_uid"];
        [newManagedObject setValue:org_name             forKey:@"org_name"];
        [newManagedObject setValue:unread_messages      forKey:@"unread_messages"];
        [newManagedObject setValue:[NSNumber numberWithBool:read] forKey:@"read"];
        [newManagedObject setValue:lastUpdatedAt        forKey:@"last_updated_at"];
        if(icon_url != nil) [newManagedObject setValue:icon_url forKey:@"icon_url"];
        [newManagedObject setValue:[NSNumber numberWithBool:direct_message] forKey:@"direct_message"];
        if(name != nil) [newManagedObject setValue:name forKey:@"name"];
        if (channel_informations != nil) {
            NSData *channelInformationsData = [NSKeyedArchiver archivedDataWithRootObject:channel_informations];
            [newManagedObject setValue:channelInformationsData forKey:@"channel_informations"];
        }
        if (assignee != nil) {
            NSData *assigneeData = [NSKeyedArchiver archivedDataWithRootObject:assignee];
            [newManagedObject setValue:assigneeData forKey:@"assignee"];
        }
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            return NO;
        }else{
            return YES;
        }
    }
}

- (NSArray *)selectAllChannel:(int)limit channelType:(CCChannelType)channelType
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:limit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"last_updated_at" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred;
    switch(channelType){
    case CCAllChannel:
        break;
    case CCUnarchivedChannel:
        pred = [NSPredicate predicateWithFormat:@"status != %@", @"closed"];
        [fetchRequest setPredicate:pred];
        break;
    case CCArchivedChannel:
        pred = [NSPredicate predicateWithFormat:@"status = %@", @"closed"];
        [fetchRequest setPredicate:pred];
        break;
    default:
        break;
    }
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    return resultArray;
}

- (NSArray *)selectChannels:(int)limit
              lastUpdatedAt:(NSDate *)lastUpdatedAt
                channelType:(CCChannelType)channelType
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:limit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"last_updated_at" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred;
    switch(channelType){
        case CCAllChannel:
            pred = [NSPredicate predicateWithFormat:@"(last_updated_at < %@)", lastUpdatedAt];
            break;
        case CCUnarchivedChannel:
            pred = [NSPredicate predicateWithFormat:@"(last_updated_at < %@) AND (status != %@)", lastUpdatedAt, @"closed"];
            break;
        case CCArchivedChannel:
            pred = [NSPredicate predicateWithFormat:@"(last_updated_at < %@) AND (status = %@)", lastUpdatedAt, @"closed"];
            break;
        default:
            break;
    }
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    return resultArray;
}

- (NSArray *)selectChannelWithUid:(int)limit uid:(NSString *)uid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:limit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updateAt" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    return resultArray;
}

- (NSArray *)selectChannelWithOrgUid:(int)limit orgUid:(NSString *)orgUid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:limit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updateAt" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"org_uid = %@", orgUid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    return resultArray;
}

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
                          assignee:(NSDictionary *)assignee
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCloadLoacalChannelLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updateAt" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid = %@", channelUid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    if (resultArray != nil && [resultArray count] != 0) {
        NSManagedObject *object = resultArray[0];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:users];
        NSData *latestMessageData = [NSKeyedArchiver archivedDataWithRootObject:latest_message];
        if(uid != nil) [object setValue:uid   forKey:@"id"];
        [object setValue:channelUid           forKey:@"uid"];
        [object setValue:createdAt            forKey:@"created"];
        [object setValue:updateAt             forKey:@"updateAt"];
        [object setValue:data                 forKey:@"users"];
        [object setValue:latestMessageData    forKey:@"latest_message"];
        [object setValue:nil                  forKey:@"deleteAt"];
        [object setValue:status               forKey:@"status"];
        [object setValue:org_uid              forKey:@"org_uid"];
        [object setValue:org_name             forKey:@"org_name"];
        [object setValue:unread_messages      forKey:@"unread_messages"];
        [object setValue:[NSNumber numberWithBool:read] forKey:@"read"];
        [object setValue:lastUpdatedAt        forKey:@"last_updated_at"];
        if(icon_url != nil) [object setValue:icon_url forKey:@"icon_url"];
        [object setValue:[NSNumber numberWithBool:direct_message] forKey:@"direct_message"];
        if(name != nil) [object setValue:name forKey:@"name"];
        if (channel_informations != nil) {
            NSData *channelInformationsData = [NSKeyedArchiver archivedDataWithRootObject:channel_informations];
            [object setValue:channelInformationsData forKey:@"channel_informations"];
        }
        if (assignee != nil) {
            NSData *assigneeData = [NSKeyedArchiver archivedDataWithRootObject:assignee];
            [object setValue:assigneeData forKey:@"assignee"];
        }
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)updateChannelUpdatedWithUid:(NSString *)uid updateAt:(NSDate *)updateAt
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCloadLoacalChannelLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updateAt" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    if (resultArray != nil && [resultArray count] != 0) {
        NSManagedObject *object = resultArray[0];
        [object setValue:updateAt forKey:@"updateAt"];
        
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)updateChannelUpdateAtAndStatusWithUid:(NSString *)uid updateAt:(NSDate *)updateAt status:(NSString *)status
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCloadLoacalChannelLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updateAt" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    if (resultArray != nil && [resultArray count] != 0) {
        NSManagedObject *object = resultArray[0];
        [object setValue:updateAt forKey:@"updateAt"];
        [object setValue:status forKey:@"status"];
        
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)updateChannelWithUidAndLatestmessage:(NSString *)uid
                                   updateAt:(NSDate *)updateAt
                              latestMessage:(NSDictionary *)latestMessage
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCloadLoacalChannelLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updateAt" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    if (resultArray != nil && [resultArray count] != 0) {
        NSManagedObject *object = resultArray[0];
        [object setValue:updateAt forKey:@"updateAt"];
        [object setValue:updateAt forKey:@"last_updated_at"];
        NSData *latest_messageData = [NSKeyedArchiver archivedDataWithRootObject:latestMessage];
        [object setValue:latest_messageData forKey:@"latest_message"];

        if (latestMessage[@"user"] != nil) { ///type:information has no user
            NSDictionary *newUser = latestMessage[@"user"];
            NSData *usersData      = [object valueForKey:@"users"];
            NSArray *users    = [NSKeyedUnarchiver unarchiveObjectWithData:usersData];
            NSMutableArray *newUsers = [NSMutableArray array];
            for (NSDictionary *user in users) {
                if (![user[@"id"] isKindOfClass:[NSNumber class]] || [user[@"id"] isEqual:[NSNull null]]){
                    continue;
                }
                if (![user[@"id"] isEqualToNumber:newUser[@"id"]]){
                    [newUsers addObject:user];
                }
            }
            [newUsers insertObject:newUser atIndex:0];
            NSData *newUsersData = [NSKeyedArchiver archivedDataWithRootObject:newUsers];
            [object setValue:newUsersData forKey:@"users"];
        }
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)updateChannelWithUidAndLatestmessageAndunreadMessagesPlus:(NSString *)uid updateAt:(NSDate *)updateAt latestMessage:(NSDictionary *)latestMessage user:(NSDictionary *)user
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCloadLoacalChannelLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updateAt" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    if (resultArray != nil && [resultArray count] != 0) {
        NSManagedObject *object = resultArray[0];
        [object setValue:updateAt forKey:@"updateAt"];
        [object setValue:updateAt forKey:@"last_updated_at"];
         NSData *latest_messageData = [NSKeyedArchiver archivedDataWithRootObject:latestMessage];
        [object setValue:latest_messageData forKey:@"latest_message"];
        
        NSString *unread_messages = [object valueForKey:@"unread_messages"];
        int unreadMessageNumInt = [unread_messages intValue];
        unreadMessageNumInt++;
        NSString *newUnreadMessageNum = [NSString stringWithFormat:@"%d",unreadMessageNumInt];
        [object setValue:newUnreadMessageNum forKey:@"unread_messages"];
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)updateChannelWithUsers:(NSString *)uid users:(NSArray *)users lastUpdateAt:(NSDate *)lastUpdateAt {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCloadLoacalChannelLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updateAt" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    if (resultArray != nil && [resultArray count] != 0) {
        NSManagedObject *object = resultArray[0];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:users];
        if(uid != nil) [object setValue:uid   forKey:@"uid"];
        [object setValue:data                 forKey:@"users"];
        [object setValue:lastUpdateAt        forKey:@"last_updated_at"];
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)updateChannelWithJoinedUser:(NSString *)uid newUser:(NSDictionary *)newUser lastUpdateAt:(NSDate *)lastUpdateAt
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCloadLoacalChannelLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"last_updated_at" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    if (resultArray != nil && [resultArray count] != 0) {
        NSManagedObject *object = resultArray[0];
        [object setValue:lastUpdateAt forKey:@"last_updated_at"];
        NSData *usersData      = [object valueForKey:@"users"];
        NSArray *users    = [NSKeyedUnarchiver unarchiveObjectWithData:usersData];
        NSMutableArray *newUsers = [NSMutableArray array];
        for (NSDictionary *user in users) {
            if (![user[@"id"] isKindOfClass:[NSNumber class]] || [user[@"id"] isEqual:[NSNull null]]) return NO;
            if ([user[@"id"] isEqualToNumber:newUser[@"id"]]) return NO;
            [newUsers addObject:user];
        }
        [newUsers addObject:newUser];
        NSData *newUsersData = [NSKeyedArchiver archivedDataWithRootObject:newUsers];
        [object setValue:newUsersData forKey:@"users"];
        
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)updateChannelWithRemovedUser:(NSString *)uid
                        removedUser:(NSDictionary *)removedUser
                       lastUpdateAt:(NSDate *)lastUpdateAt
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCloadLoacalChannelLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"last_updated_at" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    if (resultArray != nil && [resultArray count] != 0) {
        NSManagedObject *object = resultArray[0];
        [object setValue:lastUpdateAt forKey:@"last_updated_at"];
        NSData *usersData      = [object valueForKey:@"users"];
        NSArray *users    = [NSKeyedUnarchiver unarchiveObjectWithData:usersData];
        NSMutableArray *newUsers = [NSMutableArray array];
        for (NSDictionary *user in users) {
            if (![user[@"id"] isKindOfClass:[NSNumber class]] || [user[@"id"] isEqual:[NSNull null]]) return NO;
            if ([user[@"id"] isEqualToNumber:removedUser[@"id"]]){
                continue;
            }
            [newUsers addObject:user];
        }
        NSData *newUsersData = [NSKeyedArchiver archivedDataWithRootObject:newUsers];
        [object setValue:newUsersData forKey:@"users"];
        
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)updateChannelWithUnreadMessage:(NSString *)uid unreadMessage:(NSString *)unreadMessages
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCloadLoacalChannelLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updateAt" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    if (resultArray != nil && [resultArray count] != 0) {
        NSManagedObject *object = resultArray[0];
        [object setValue:unreadMessages forKey:@"unread_messages"];
        
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)deleteChannelWithUid:(NSString *)uid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCdeleteLoacalLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    }else{
        NSArray *resultArray = [fetchedResultsController fetchedObjects];
        for (int i = 0; i < resultArray.count; i++) {
            NSManagedObject *object = [resultArray objectAtIndex:i];
            [self.managedObjectContext deleteObject:object];
        }
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            if (![[self managedObjectContext] save:&error]) {
                NSLog(@"error = %@", error);
                return NO;
            }else{
                return YES;
            }
        }
    }
}

- (BOOL)deleteAllChannel
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCChannel" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCdeleteLoacalLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    }else{
        NSArray *resultArray = [fetchedResultsController fetchedObjects];
        for (int i = 0; i < resultArray.count; i++) {
            NSManagedObject *object = [resultArray objectAtIndex:i];
            [self.managedObjectContext deleteObject:object];
        }
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
    }
}

+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

# pragma mark - Coredata Org Table
- (BOOL)insertOrg:(NSString *)uid name:(NSString *)name withUnreadMessagesChannels:(NSData *)unreadMessagesChannels users: (NSData *) users
{
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"CCOrg" inManagedObjectContext:[self managedObjectContext]];
    
    [newManagedObject setValue:name forKey:@"name"];
    [newManagedObject setValue:uid forKey:@"uid"];
    [newManagedObject setValue:unreadMessagesChannels forKey:@"unreadMessagesChannels"];
    
    [newManagedObject setValue:nil forKey:@"ancestry"];
    [newManagedObject setValue:nil forKey:@"created"];
    [newManagedObject setValue:nil forKey:@"deleteAt"];
    [newManagedObject setValue:nil forKey:@"updateAt"];
    [newManagedObject setValue:users forKey:@"users"];
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    }else{
        return YES;
    }
}
- (NSArray *)selectOrgAll:(int)limit
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCOrg" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:limit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    return resultArray;
}

- (NSArray *)selectOrgWithUid:(NSString *)uid {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCOrg" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"uid = %@", uid];
    [fetchRequest setPredicate:pred];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSArray *resultArray = [fetchedResultsController fetchedObjects];
    return resultArray;
}

- (BOOL)deleteAllOrg
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CCOrg" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:CCdeleteLoacalLimit];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:[self managedObjectContext]
                                                                                                 sectionNameKeyPath:nil
                                                                                                          cacheName:nil];
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    }else{
        NSArray *resultArray = [fetchedResultsController fetchedObjects];
        for (int i = 0; i < resultArray.count; i++) {
            NSManagedObject *object = [resultArray objectAtIndex:i];
            [self.managedObjectContext deleteObject:object];
        }
        if (![[self managedObjectContext] save:&error]) {
            NSLog(@"error = %@", error);
            return NO;
        }else{
            return YES;
        }
    }
}

@end
