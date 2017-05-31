//
//  CCJSQMessage.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/01/02.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCJSQMessage.h"
#import "CCConstants.h"
#import "ChatCenterPrivate.h"
#import "CCJSQPhotoMediaItem.h"
#import "CCConnectionHelper.h"
#import "CCDateTimes.h"

@implementation CCJSQMessage

+ (instancetype)messageWithSenderId:(NSString *)senderId
                        displayName:(NSString *)displayName
                              media:(id<CCJSQMessageMediaData>)media
{
    CCJSQMessage *message = [[CCJSQMessage alloc] initWithSenderId:senderId
                                                 senderDisplayName:displayName
                                                              date:[NSDate date]
                                                             media:media];
    return message;
}


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
                                       userAdmin:(BOOL) userAdmin
                                          answer:(NSDictionary *)answer
                                          status:(NSInteger)status {
    
    
    //
    // Prepare return array
    //
    NSMutableArray *messages = [NSMutableArray array];

    
    if ([messageType isEqualToString:CC_RESPONSETYPELOCATION]
        && [[CCConstants sharedInstance].stickers containsObject:CC_RESPONSETYPELOCATION])
    {
        //
        // Location
        //
        
        // Validation
        if (content[CC_RESPONSETYPESTICKERCONTENT][CC_STICKER_DATA][CC_STICKERTYPELOCATION][CC_LATITUDE] == nil || content[CC_RESPONSETYPESTICKERCONTENT][CC_STICKER_DATA][CC_STICKERTYPELOCATION][CC_LONGITUDE] == nil) {
            return nil;
        }
        if (status == CC_MESSAGE_STATUS_SEND_SUCCESS) {
            return nil;
        }
        
        // Set data
        CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:userUid senderDisplayName:displayName date:date text:@""];
        msg.uid = uid;
        msg.type = CC_RESPONSETYPESTICKER;
        NSMutableDictionary *newContent = [NSMutableDictionary dictionaryWithDictionary:content];
        msg.content =  [newContent copy];
        msg.status = status;
        msg.isAgent = userAdmin;
        [messages addObject:msg];
    } else if ([messageType isEqualToString:CC_STICKERTYPEIMAGE]) {
        //
        // Image
        //
        
        // Set data
        CCJSQMessage *message = [[CCJSQMessage alloc] initWithSenderId:userUid
                                                     senderDisplayName:displayName
                                                                  date:date
                                                                  text:content[@"text"]];
        NSMutableDictionary *newContent = [NSMutableDictionary dictionaryWithDictionary:content];
        newContent[@"usersReadMessage"] = usersReadMessage;
        message.content = [newContent copy];
        message.status = status;
        message.type = CC_STICKERTYPEIMAGE;
        message.isAgent = userAdmin;
        [messages addObject:message];
        
    }else if([messageType isEqualToString:CC_RESPONSETYPELINK]
             && [[CCConstants sharedInstance].stickers containsObject:CC_RESPONSETYPELINK])
    {
        //
        // Link
        //
        if(content[CC_RESPONSETYPELINK][@"title"] == nil && content[CC_RESPONSETYPELINK][@"url"] == nil){
            return nil;
        };
        NSString *sendText;
        if(content[CC_RESPONSETYPELINK][@"title"] == nil){
            sendText = content[CC_RESPONSETYPELINK][@"url"];
        }else if (content[CC_RESPONSETYPELINK][@"url"] == nil){
            sendText = content[CC_RESPONSETYPELINK][@"title"];
        }else{
            sendText  = [content[CC_RESPONSETYPELINK][@"title"] stringByAppendingFormat:@" %@", content[CC_RESPONSETYPELINK][@"url"]];
        }
        CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:userUid
                                                 senderDisplayName:displayName
                                                              date:date
                                                              text:sendText];
        msg.status = status;
        msg.isAgent = userAdmin;
        [messages addObject:msg];
    }else if([messageType isEqualToString:CC_RESPONSETYPEINFORMATION]
             && content != nil)
    {
        //
        // Info
        //
        
        // Content data setting
        // TODO: Should not be here
        
        NSString *titleTitle =@"", *titleUrl =@"", *name = @"", *name_kana = @"", *birthday= @"", *phone_number = @"", *email = @"", *gender = @"";
        if (content[@"header"] != nil) {
            NSDictionary *contentHeader = content[@"header"];
            if (contentHeader[@"title"] != nil){
                titleTitle = contentHeader[@"title"];
            }
            if (contentHeader[@"url"] != nil){
                titleUrl = contentHeader[@"url"];
            }
        }
        if (content[@"body"] != nil) {
            NSDictionary *contentBody = content[@"body"];
            if (contentBody[@"name"] != nil){
                name = contentBody[@"name"];
            }
            if (contentBody[@"name_kana"] != nil){
                name_kana = contentBody[@"name_kana"];
            }
            if (contentBody[@"birthday"] != nil){
                birthday = contentBody[@"birthday"];
            }
            if (contentBody[@"phone_number"] != nil){
                phone_number = contentBody[@"phone_number"];
            }
            if (contentBody[@"email"] != nil){
                email = contentBody[@"email"];
            }
            if (contentBody[@"gender"] != nil){
                gender = contentBody[@"gender"];
            }
        }
        NSMutableString *sendText = [NSMutableString string];
        [sendText appendString:@"<body>"];
        if (![titleTitle isEqualToString:@""]) {
            if (titleUrl.length > 0) {
                [sendText appendFormat:@"<a href='%@'>%@</a><br/>", titleUrl, titleTitle ];
            }else {
                [sendText appendFormat:@"%@<br/>", titleTitle];
            }
        }
        [sendText appendFormat:@"%@: %@<br/>", CCLocalizedString(@"Name"), name];
        [sendText appendFormat:@"%@: %@<br/>", CCLocalizedString(@"Name kana"), name_kana];
        [sendText appendFormat:@"%@: %@<br/>", CCLocalizedString(@"Birthday"), birthday];
        [sendText appendFormat:@"%@: %@<br/>", CCLocalizedString(@"Gender"), gender];
        [sendText appendFormat:@"%@: %@<br/>", CCLocalizedString(@"Phone Number"), phone_number];
        [sendText appendFormat:@"%@: %@<br/>", CCLocalizedString(@"Email"), email];
        [sendText appendString:@"</body>"];
        
        NSAttributedString *attributedText = [self attributedStringWithHTML:[self styledHTMLwithHTML:sendText]];
        
        // set data
        CCJSQMessage *msg;
        if ([[CCConstants sharedInstance] getKeychainUid] != nil){
            msg = [[CCJSQMessage alloc] initWithSenderId:[[CCConstants sharedInstance] getKeychainUid]
                                       senderDisplayName:@""
                                                    date:date
                                                    text:@""];
            msg.content = @{@"attributedText" : attributedText};
            msg.type = CC_RESPONSETYPEINFORMATION;
            msg.status = status;
            msg.isAgent = userAdmin;
            [messages addObject:msg];
        }
    }else if([messageType isEqualToString:CC_RESPONSETYPESTICKER])
    {
        //
        // Sticker
        //
        CCJSQMessage *msg;
        if ([[CCConstants sharedInstance] getKeychainUid] != nil){
            msg = [[CCJSQMessage alloc] initWithSenderId:userUid
                                       senderDisplayName:displayName
                                                    date:date
                                                    text:@""];
            msg.uid = uid;
            msg.type = CC_RESPONSETYPESTICKER;
            NSMutableDictionary *newContent = [NSMutableDictionary dictionaryWithDictionary:content];
            newContent[@"usersReadMessage"] = usersReadMessage;
            msg.content =  [newContent copy];
            msg.status = status;
            msg.isAgent = userAdmin;
            [messages addObject:msg];
        }
        //Do not need to display message:resposne because server will send text message of response
        //    }else if([messageType isEqualToString:CC_RESPONSETYPERESPONSE])
        //    {
        //        CCJSQMessage *msg;
        //        if ([[CCConstants sharedInstance] getKeychainUid] != nil){
        //            msg = [[CCJSQMessage alloc] initWithSenderId:userUid
        //                                       senderDisplayName:displayName
        //                                                    date:date
        //                                                    text:content[@"answer_label"]];
        //            msg.uid = uid;
        //            msg.type = CC_RESPONSETYPERESPONSE;
        //            [self.messages addObject:msg];
        //        }
    }else if([messageType isEqualToString:CC_RESPONSETYPESUGGESTION])
    {
        //
        // Suggestion
        //
        CCJSQMessage *msg;
        if ([[CCConstants sharedInstance] getKeychainUid] != nil){
            msg = [[CCJSQMessage alloc] initWithSenderId:userUid
                                       senderDisplayName:displayName
                                                    date:date
                                                    text:@""];
            msg.uid = uid;
            msg.type = CC_RESPONSETYPESUGGESTION;
            NSMutableDictionary *newContent = [NSMutableDictionary dictionaryWithDictionary:content];
            newContent[@"usersReadMessage"] = usersReadMessage;
            msg.content =  [newContent copy];
            msg.status = status;
            msg.isAgent = userAdmin;
            [messages addObject:msg];
        }
    }else if([messageType isEqualToString:CC_RESPONSETYPEPROPERTY]
             && content != nil)
    {
        //
        // Property
        //
        
        
        // Content data setup
        // TODO: Should not be here
        
        
        //        NSLog(@"CC_RESPONSETYPEPROPERTY: %@", content);
        NSString *code =@"", *name = @"", *room_number = @"", *price = @"", *administration_cost = @"", *deposit = @"", *key_money = @"", *address = @"", *area = @"", *floor = @"", *url = @"", *image = @"", *floor_plan = @"", *age = @"" ;
        NSArray *traffic_division;
        if (content[@"property"] != nil && ![content[@"property"] isEqual:[NSNull null]]) {
            NSDictionary *contentBody = content[@"property"];
            if (contentBody[@"code"] != nil && ![contentBody[@"code"] isEqual:[NSNull null]]){
                code = contentBody[@"code"];
            }
            if (contentBody[@"name"] != nil && ![contentBody[@"name"] isEqual:[NSNull null]]){
                name = contentBody[@"name"];
            }
            if (contentBody[@"room_number"] != nil && ![contentBody[@"room_number"] isEqual:[NSNull null]]){
                room_number = contentBody[@"room_number"];
            }
            if (contentBody[@"price"] != nil && ![contentBody[@"price"] isEqual:[NSNull null]]){
                price = contentBody[@"price"];
            }
            if (contentBody[@"administration_cost"] != nil && ![contentBody[@"administration_cost"] isEqual:[NSNull null]]){
                administration_cost = contentBody[@"administration_cost"];
            }
            if (contentBody[@"deposit"] != nil && ![contentBody[@"deposit"] isEqual:[NSNull null]]){
                deposit = contentBody[@"deposit"];
            }
            if (contentBody[@"key_money"] != nil && ![contentBody[@"key_money"] isEqual:[NSNull null]]){
                key_money = contentBody[@"key_money"];
            }
            if (contentBody[@"address"] != nil && ![contentBody[@"address"] isEqual:[NSNull null]]){
                address = contentBody[@"address"];
            }
            if (contentBody[@"area"] != nil && ![contentBody[@"area"] isEqual:[NSNull null]]){
                area = contentBody[@"area"];
            }
            if (contentBody[@"floor"] != nil && ![contentBody[@"floor"] isEqual:[NSNull null]]){
                floor = contentBody[@"floor"];
            }
            if (contentBody[@"url"] != nil && ![contentBody[@"url"] isEqual:[NSNull null]]){
                url = contentBody[@"url"];
            }
            if (contentBody[@"image"] != nil && ![contentBody[@"image"] isEqual:[NSNull null]]){
                image = contentBody[@"image"];
            }
            if (contentBody[@"floor_plan"] != nil && ![contentBody[@"floor_plan"] isEqual:[NSNull null]]){
                floor_plan = contentBody[@"floor_plan"];
            }
            if (contentBody[@"age"] != nil && ![contentBody[@"age"] isEqual:[NSNull null]]){
                age = contentBody[@"age"];
            }
            if ([contentBody[@"traffic_division"] isKindOfClass:[NSArray class]] && contentBody[@"traffic_division"] != nil && ![contentBody[@"traffic_division"] isEqual:[NSNull null]]){
                traffic_division =  contentBody[@"traffic_division"];
            }
        }
        
        //NGOCNH
        NSMutableString *titleHtml = [NSMutableString string];
        [titleHtml appendString:@"<body>"];
        [titleHtml appendFormat:@"%@", CCLocalizedString(@"Inquired property")];
        [titleHtml appendString:@"</body>"];
        NSString *kMoney, *kDeposit;
        NSMutableString *infoHtml = [NSMutableString string];
        NSMutableString *upperContent = [NSMutableString string];
        NSMutableString *lowerContent = [NSMutableString string];
        [infoHtml appendString:@"<body>"];
        [upperContent appendFormat:@"<body>"];
        if (url.length > 0) {
            [infoHtml appendFormat:@"<a href='%@'>%@</a><br/>", url, name];
            [upperContent appendFormat:@"<a href='%@'>%@</a><br/>", url, name];
        }else {
            [infoHtml appendFormat:@"%@</br>", name];
            [upperContent appendFormat:@"%@</br>", name];
        }
        if ([price length] > 0) {
            [infoHtml appendFormat:@"%@", price];
            [upperContent appendFormat:@"%@", price];
        }
        if ([administration_cost length] > 0) {
            [infoHtml appendFormat:@" (%@: %@)", CCLocalizedString(@"管理費"), administration_cost];
            [upperContent appendFormat:@" (%@: %@)", CCLocalizedString(@"管理費"), administration_cost];
        }
        [upperContent appendFormat:@"</body>"];
        [infoHtml appendFormat:@"<br/>"];
        if ([deposit length] > 0) {
            [infoHtml appendFormat:@"%@ %@&nbsp;&nbsp;&nbsp;&nbsp;", CCLocalizedString(@"敷"), deposit];
            kDeposit = [NSString stringWithFormat:@" %@", deposit];
        }
        if ([key_money length] > 0) {
            [infoHtml appendFormat:@"%@ %@<br/>", CCLocalizedString(@"礼"), key_money];
            kMoney = [NSString stringWithFormat:@" %@", key_money];
        }
        [lowerContent appendString:@"<body>"];
        if (traffic_division != nil) {
            for (NSString *trafficDivision in traffic_division) {
                [infoHtml appendFormat:@"%@<br/>", trafficDivision];
                [lowerContent appendFormat:@"%@<br/>", trafficDivision];
            }
        }
        if ([address length] > 0) {
            [infoHtml appendFormat:@"%@<br/>", address];
            [lowerContent appendFormat:@"%@<br/>", address];
        }
        if ([floor_plan length] > 0) {
            [infoHtml appendFormat:@"%@",floor_plan];
            [lowerContent appendFormat:@"%@",floor_plan];
            if ([area length] > 0) {
                [infoHtml  appendString:@"/"];
                [lowerContent  appendString:@"/"];
            }else {
                [infoHtml  appendString:@"</br>"];
                [lowerContent  appendString:@"</br>"];
            }
        }
        if ([area length] > 0) {
            [infoHtml appendFormat:@"%@<br/>", area];
            [lowerContent appendFormat:@"%@<br/>", area];
        }
        if ([floor length] > 0) {
            [infoHtml appendFormat:@"%@&nbsp;&nbsp;&nbsp;", floor];
            [lowerContent appendFormat:@"%@&nbsp;&nbsp;&nbsp;", floor];
        }
        if ([age length] > 0) {
            [infoHtml appendFormat:@"%@", age];
            [lowerContent appendFormat:@"%@", age];
        }
        [infoHtml appendString:@"</body>"];
        [lowerContent appendString:@"</body>"];
        
        NSAttributedString *attributedTitle = [self attributedStringWithHTML:[self styledHTMLwithHTML:titleHtml]];
        NSAttributedString *attributedText = [self attributedStringWithHTML:[self styledHTMLwithHTML:infoHtml]];
        
        CCJSQMessage *msg;
        if ([[CCConstants sharedInstance] getKeychainUid] != nil){
            msg = [[CCJSQMessage alloc] initWithSenderId:[[CCConstants sharedInstance] getKeychainUid]
                                       senderDisplayName:@""
                                                    date:date
                                                    text:@""];
            msg.content = @{@"attributedTitle" : attributedTitle,
                            @"image": image,
                            @"attributedText" : attributedText,
                            @"kDeposit" : kDeposit == nil ? @"" : kDeposit,
                            @"kMoney" : kMoney == nil ? @"" : kMoney,
                            @"upperContent" : [self attributedStringWithHTML:[self styledHTMLwithHTML:upperContent]],
                            @"lowerContent" : [self attributedStringWithHTML:[self styledHTMLwithHTML:lowerContent]]};
            msg.type = CC_RESPONSETYPEPROPERTY;
            msg.status = status;
            msg.isAgent = userAdmin;
            [messages addObject:msg];
        }
    }else if([messageType isEqualToString:CC_RESPONSETYPEIMAGE]
             && content[@"files"] != nil)
    {
        //
        // Image
        //
        for (NSDictionary *file in content[@"files"]) {
            CCJSQPhotoMediaItem *photoItem = [[CCJSQPhotoMediaItem alloc] initWithImage:nil];
            CCJSQMessage *message = [CCJSQMessage messageWithSenderId:userUid
                                                          displayName:displayName
                                                                media:photoItem];
            NSMutableDictionary *newContent = [content mutableCopy];
            newContent[@"imageUrl"] = file[@"url"];
            newContent[@"usersReadMessage"] = usersReadMessage;
            message.content = [newContent copy];
            message.status = status;
            message.isAgent = userAdmin;
            [messages addObject:message];
            

        }
    }else if([messageType isEqualToString:CC_RESPONSETYPEPDF]
             && content[@"files"] != nil)
    {
        //
        // PDF
        //
        for (NSDictionary *file in content[@"files"]) {
            CCJSQMessage *message = [[CCJSQMessage alloc] initWithSenderId:userUid
                                                         senderDisplayName:displayName
                                                                      date:date
                                                                      text:file[@"name"]];
            NSMutableDictionary *newContent = [content mutableCopy];
            newContent[@"pdfUrl"] = [[CCConnectionHelper sharedClient] addAuthToUrl:file[@"url"][@"original"]];
            newContent[@"text"] = file[@"name"];
            newContent[@"usersReadMessage"] = usersReadMessage;
            message.content = [newContent copy];
            message.status = status;
            message.isAgent = userAdmin;
            [messages addObject:message];
        }
    }else if([messageType isEqualToString:CC_RESPONSETYPEDATETIMEAVAILABILITY]
             && content[CC_CONTENTKEYDATETIMEAVAILABILITY] != nil)
    {
        CCJSQMessage *message = [[CCJSQMessage alloc] initWithSenderId:userUid
                                                     senderDisplayName:displayName
                                                                  date:date
                                                                  text:@""];
        //
        // Availability
        //
        
        //
        ///Convert type selectedDates to selectedDateTimes
        //
        NSArray *selectedDates = content[CC_CONTENTKEYDATETIMEAVAILABILITY];
        NSMutableArray *selectedDateTimes = [NSMutableArray array];
        NSUInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay;
        for (NSDictionary *fromTo in selectedDates) {
            CCDateTimes *newDateTime;
            NSDate *fromDate = [NSDate dateWithTimeIntervalSince1970:[fromTo[@"from"] doubleValue]];
            NSDate *toDate = [NSDate dateWithTimeIntervalSince1970:[fromTo[@"to"] doubleValue]];
            NSDictionary *newTime = @{@"from":fromDate, @"to":toDate};
            NSDateComponents *crtComponents = [[NSCalendar currentCalendar] components:flags fromDate:fromDate];
            NSInteger year = crtComponents.year;
            NSInteger month = crtComponents.month;
            NSInteger weekDay = crtComponents.weekday;
            NSInteger weekIndex;
            if (weekDay == 1) { ///Sunday
                weekIndex = 6;
            }else{
                weekIndex = weekDay - 2;
            }
            NSInteger day = crtComponents.day;
            NSString *yearString = [NSString stringWithFormat:@"%ld", (long)year];
            NSString *monthString = [NSString stringWithFormat:@"%ld", (long)month];
            NSString *dayString = [NSString stringWithFormat:@"%ld", (long)day];
            NSPredicate *predicate = [NSPredicate
                                      predicateWithFormat:@"year == %@ AND month == %@ AND day == %@", yearString, monthString, dayString];
            CCDateTimes *result = [[selectedDateTimes filteredArrayUsingPredicate:predicate] firstObject];
            if (result != nil) {
                newDateTime = [result copy];
                NSMutableArray *newTimes = [result.times mutableCopy];
                [newTimes addObject:newTime];
                newDateTime.times = newTimes;
                [selectedDateTimes removeObject:result];
            }else{
                newDateTime = [[CCDateTimes alloc] initWithDate:yearString
                                                          month:monthString
                                                            day:dayString
                                                      weekIndex:weekIndex
                                                           date:fromDate
                                                          times:@[newTime]];
            }
            [selectedDateTimes addObject:newDateTime];
        }
        NSMutableDictionary *newContent = [content mutableCopy];
        newContent[CC_CONTENTKEYDATETIMEAVAILABILITY] = selectedDateTimes;
        message.content = [newContent copy];
        message.status = status;
        [messages addObject:message];
    }else if([messageType isEqualToString:CC_RESPONSETYPEDATETIMEAVAILABILITY]
             && content[@"text"] != nil
             && [[CCConstants sharedInstance].stickers containsObject:CC_RESPONSETYPEDATETIMEAVAILABILITY])
    {
        CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:userUid
                                                 senderDisplayName:displayName
                                                              date:date
                                                              text:content[@"text"]];
        msg.status = status;
        msg.isAgent = userAdmin;
        [messages addObject:msg];
    }else if([messageType isEqualToString:CC_RESPONSETYPEMESSAGE]
             && content[@"text"] != nil)
    {
        //
        // Suggestion
        //
        
        CCJSQMessage *message = [[CCJSQMessage alloc] initWithSenderId:userUid
                                                     senderDisplayName:displayName
                                                                  date:date
                                                                  text:content[@"text"]];
        NSMutableDictionary *newContent = [NSMutableDictionary dictionaryWithDictionary:content];
        newContent[@"usersReadMessage"] = usersReadMessage;
        message.content = [newContent copy];
        message.status = status;
        message.isAgent = userAdmin;
        [messages addObject:message];
    }else if([messageType isEqualToString:CC_RESPONSETYPEQUESTION]
             && content[@"question"] != nil)
    {
        CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:userUid
                                                 senderDisplayName:displayName
                                                              date:date
                                                              text:@""];
        msg.status = status;
        msg.isAgent = userAdmin;
        [messages addObject:msg];
    } else if([messageType isEqualToString:CC_RESPONSETYPECALL]) {
        CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:userUid
                                                 senderDisplayName:displayName
                                                              date:date
                                                              text:@""];
        msg.status = status;
        msg.content = content;
        msg.isAgent = userAdmin;
        [messages addObject:msg];
    } else {
        return nil;
    }
    
    for (CCJSQMessage *message in messages) {
        if (message.content == nil) message.content = content;
        if (message.uid == nil) message.uid = uid;
        if (message.type == nil) message.type = messageType;
        if (message.answer == nil && answer != nil) message.answer = answer;
    }

    return [messages copy];

}


//
//
#pragma mark Object Retrieval Utility
//
//
+ (id)getObjectAtPath:(NSString*)path fromObject:(id)obj {
    NSArray<NSString*> *components = [path componentsSeparatedByString:@"/"];
    if (components.count<1) {
        return nil;
    }
    
    id retObj;
    if ([components[0] hasSuffix:@"#"]) { //array
        if (![obj isKindOfClass:[NSArray class]]) {
            return nil;
        } else {
            NSInteger num = [[components[0] substringFromIndex:1] integerValue];
            if ([(NSArray *)obj count] > num ) {
                retObj = [(NSArray*)obj objectAtIndex:num];
            } else {
                return nil;
            }
        }
    } else {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            return nil;
        } else {
            retObj = [(NSDictionary*)obj objectForKey:components[0]];
        }
    }
    if (components.count==1) {
        return [retObj copy];
    } else {
        NSMutableArray *a2 = [components mutableCopy];
        [a2 removeObjectAtIndex:0];
        NSString *newPath = [a2 componentsJoinedByString:@"/"];

        return [self getObjectAtPath:newPath fromObject:retObj];
    }
    return nil;
}

+ (NSDictionary*)getDictionaryAtPath:(NSString*)path fromObject:(id)inObj {
    id retObj = [self getObjectAtPath:path fromObject:inObj];
    if ([retObj isKindOfClass:[NSDictionary class]]) {
        return retObj;
    } else {
        return nil;
    }
}
+ (NSArray*)getArrayAtPath:(NSString*)path fromObject:(id)inObj {
    id retObj = [self getObjectAtPath:path fromObject:inObj];
    if ([retObj isKindOfClass:[NSArray class]]) {
        return retObj;
    } else {
        return nil;
    }
}
+ (NSString*)getStringAtPath:(NSString*)path fromObject:(id)inObj {
    id retObj = [self getObjectAtPath:path fromObject:inObj];
    if ([retObj isKindOfClass:[NSString class]]) {
        return retObj;
    } else {
        return nil;
    }
}

+ (NSNumber*)getNumberAtPath:(NSString*)path fromObject:(id)inObj {
    id retObj = [self getObjectAtPath:path fromObject:inObj];
    if ([retObj isKindOfClass:[NSNumber class]]) {
        return retObj;
    } else {
        return nil;
    }
}

- (NSDictionary*)getDictionaryAtPath:(NSString*)path {
    return [[self class] getObjectAtPath:path fromObject:self.content];
}

- (NSArray*)getArrayAtPath:(NSString*)path {
    return [[self class] getArrayAtPath:path fromObject:self.content];
}
- (NSString*)getStringAtPath:(NSString*)path {
    return [[self class] getStringAtPath:path fromObject:self.content];
}
- (NSNumber*)getNumberAtPath:(NSString*)path {
    return [[self class] getNumberAtPath:path fromObject:self.content];
}





+ (NSString *)styledHTMLwithHTML:(NSString *)HTML {
    NSString *style = @"<meta charset=\"UTF-8\"><style> * { -webkit-touch-callout: none; -webkit-user-select: none; /* Disable selection/copy in UIWebView */} body { font-family: 'HelveticaNeue'; font-size: 13; } b {font-family: 'MarkerFelt-Wide'; } </style>";
    
    return [NSString stringWithFormat:@"%@%@", style, HTML];
}


+ (NSAttributedString *)attributedStringWithHTML:(NSString *)HTML {
    NSDictionary *options = @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute : @(NSUTF8StringEncoding)};
    __block NSAttributedString *attributedString;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [HTML dataUsingEncoding:NSUTF8StringEncoding];
        attributedString = [[NSAttributedString alloc] initWithData:data options:options documentAttributes:NULL error:NULL];
    });
    return attributedString;
}


@end
