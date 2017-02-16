
//
//  ChatCenterClient.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2014/10/04.
//  Copyright (c) 2014年 AppSocially Inc. All rights reserved.
//

#import "ChatCenterClient.h"
#import "CCConstants.h"
#import <sys/utsname.h>
#import "CCSSKeychain.h"
#import "CCUserDefaultsUtil.h"
#import "CCHistoryFilterViewController.h"
#import "CCConstants.h"

@interface ChatCenterClient()

@end


@implementation ChatCenterClient

+ (ChatCenterClient *)sharedClient
{
    static ChatCenterClient *sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[ChatCenterClient alloc] initWithBaseURL:[NSURL URLWithString:CC_API_BASE_URL]];
    });
    
    return sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    if (self = [super initWithBaseURL:url]) {
        self.requestSerializer = [CCAFJSONRequestSerializer serializer];
    }
    return self;
}

- (void)setAppToken:(NSString *)appToken{
    _appToken = appToken;
    [self.requestSerializer setValue:appToken forHTTPHeaderField:@"App-Token"];
}

- (void)setDeviceInfo {
    [self.requestSerializer setValue:[self model] forHTTPHeaderField:@"Device-Model"];
    [self.requestSerializer setValue:[self os] forHTTPHeaderField:@"Device-Os"];
    [self.requestSerializer setValue:[self sdkVersion] forHTTPHeaderField:@"Sdk-Version"];
    [self.requestSerializer setValue:[self appVersion] forHTTPHeaderField:@"App-Version"];
    [self.requestSerializer setValue:[self devVersion] forHTTPHeaderField:@"Dev-Version"];
    [self.requestSerializer setValue:[self localeLanguage] forHTTPHeaderField:@"Accept-Language"];
    if([self isSupportVideoChat]) {
        [self.requestSerializer setValue:@"true" forHTTPHeaderField:@"Supports-Video-Chat"];
    } else {
        [self.requestSerializer setValue:@"false" forHTTPHeaderField:@"Supports-Video-Chat"];
    }
}

- (NSString *)model
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (NSString *)os
{
    UIDevice *dev = [UIDevice currentDevice];
    return [NSString stringWithFormat:@"%@ %@", dev.systemName, dev.systemVersion];
}

- (NSString *)appVersion
{
    NSString *verStr = [SDK_BUNDLE objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    return !verStr ? @"" : verStr;
}

- (NSString *)devVersion
{
    NSString *verStr = [[self sharedBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    return !verStr ? @"" : verStr;
}

- (NSString *)sdkVersion
{
    NSString *verStr = CC_SDK_VERSION;
    
    return !verStr ? @"" : verStr;
}

- (NSBundle *)sharedBundle {
    
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *bundlePath = [SDK_BUNDLE pathForResource:kBundleResourceName ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    });
    
    return bundle;
}

-(NSString *)localeLanguage{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *languageID = [languages objectAtIndex:0];
    return languageID;
}

- (BOOL)isSupportVideoChat {
    // OS version >= 9.0
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(osVersion < 9.0) {
        NSLog(@"Not support video chat: OS version < 9.0");
        return NO;
    }
    // ChatCenterSDK > 1.0.5
    if([CC_SDK_SUPPORT_VIDEO_CHAT_VERSION compare:CC_SDK_VERSION options:NSNumericSearch] == NSOrderedDescending) {
        // current version is lower than minimum support version
        NSLog(@"Not support video chat: ChatCenterSDK version < 1.0.5");
        return NO;
    }
    NSLog(@"Is support video chat: YES");
    return YES;
}

#pragma mark - User

- (void)createGuestUser:(NSString *)orgUid
              firstName:(NSString *)firstName
             familyName:(NSString *)familyName
                  email:(NSString *)email
               provider:(NSString *)provider
          providerToken:(NSString *)providerToken
    providerTokenSecret:(NSString *)providerTokenSecret
   providerRefreshToken:(NSString *)providerRefreshToken
      providerCreatedAt:(NSDate *)providerCreatedAt
      providerExpiresAt:(NSDate *)providerExpiresAt
    channelInformations:(NSDictionary *)channelInformations
            deviceToken:(NSString *)deviceToken
      completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    NSMutableDictionary *param =    [NSMutableDictionary dictionary];
    if (orgUid != nil)              [param setValue:orgUid              forKey:@"org_uid"];
    if (firstName != nil)           [param setValue:firstName           forKey:@"first_name"];
    if (familyName != nil)          [param setValue:familyName          forKey:@"family_name"];
    if (email != nil)               [param setValue:email               forKey:@"email"];
    if (provider != nil)            [param setValue:provider            forKey:@"provider"];
    if (providerToken != nil)       [param setValue:providerToken       forKey:@"provider_token"];
    if (providerTokenSecret != nil) [param setValue:providerTokenSecret forKey:@"provider_token_secret"];
    if (providerRefreshToken != nil)[param setValue:providerRefreshToken forKey:@"provider_refresh_token"];
    if (providerCreatedAt != nil){
        NSTimeInterval providerCreatedAtInterval = [providerCreatedAt timeIntervalSince1970];
        NSNumber *providerCreatedAtNumber = [NSNumber numberWithDouble:providerCreatedAtInterval];
        [param setValue:providerCreatedAtNumber forKey:@"provider_created_at"];
    }
    if (providerExpiresAt != nil){
        NSTimeInterval providerExpiresAtInterval = [providerExpiresAt timeIntervalSince1970];
        NSNumber *providerExpiresAtNumber = [NSNumber numberWithDouble:providerExpiresAtInterval];
        [param setValue:providerExpiresAtNumber forKey:@"provider_expires_at"];
    }
    if (channelInformations != nil) [param setValue:channelInformations forKey:@"channel_informations"];
    if (deviceToken != nil) {
        [param setValue:deviceToken forKey:@"device_token"];
        [param setValue:@"ios" forKey:@"device_type"];
    }
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:@"/api/users"
       parameters:param
          success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"response: %@", responseObject);
              if(completionHandler != nil) completionHandler(responseObject, nil, operation);
          } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
              if(completionHandler != nil) completionHandler(nil, error, operation);
              NSLog(@"error:%@", error);
          }];
}

- (void)getUserToken:(NSString*)email
            password:(NSString*)password
            provider:(NSString *)provider
       providerToken:(NSString *)providerToken
 providerTokenSecret:(NSString *)providerTokenSecret
providerRefreshToken:(NSString *)providerRefreshToken
   providerCreatedAt:(NSDate *)providerCreatedAt
   providerExpiresAt:(NSDate *)providerExpiresAt
         deviceToken:(NSString *)deviceToken
   completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    NSMutableDictionary *param =    [NSMutableDictionary dictionary];
    if (email         != nil)     [param setValue:email         forKey:@"email"];
    if (password      != nil)     [param setValue:password      forKey:@"password"];
    if (provider      != nil)     [param setValue:provider      forKey:@"provider"];
    if (providerToken != nil)     [param setValue:providerToken forKey:@"provider_token"];
    if (providerTokenSecret != nil) [param setValue:providerTokenSecret forKey:@"provider_token_secret"];
    if (providerRefreshToken != nil) [param setValue:providerRefreshToken forKey:@"provider_refresh_token"];
    if (providerCreatedAt != nil){
        NSTimeInterval providerCreatedAtInterval = [providerCreatedAt timeIntervalSince1970];
        NSNumber *providerCreatedAtNumber = [NSNumber numberWithDouble:providerCreatedAtInterval];
        [param setValue:providerCreatedAtNumber forKey:@"provider_created_at"];
    }
    if (providerExpiresAt != nil){
        NSTimeInterval providerExpiresAtInterval = [providerExpiresAt timeIntervalSince1970];
        NSNumber *providerExpiresAtNumber = [NSNumber numberWithDouble:providerExpiresAtInterval];
        [param setValue:providerExpiresAtNumber forKey:@"provider_expires_at"];
    }
    if (deviceToken != nil) {
        [param setValue:@"ios" forKey:@"device_type"];
        [param setValue:deviceToken forKey:@"device_token"];
    }
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:@"/api/users/auth"
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)getUser :(NSString*)userUid
completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    NSString *url = [NSString stringWithFormat:@"/api/users/%@",userUid];
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self GET:url
   parameters:nil
      success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"response: %@", responseObject);
          if(completionHandler != nil) completionHandler(responseObject, nil, operation);
      } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
          if(completionHandler != nil) completionHandler(nil, error, operation);
          NSLog(@"error:%@", error);
      }];
}

- (void)getUsers:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    NSString *url = @"/api/users";
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self GET:url
   parameters:nil
      success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"response: %@", responseObject);
          if(completionHandler != nil) completionHandler(responseObject, nil, operation);
      } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
          if(completionHandler != nil) completionHandler(nil, error, operation);
          NSLog(@"error:%@", error);
      }];
}

- (void)getUserMe:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    NSString *url = [NSString stringWithFormat:@"/api/users/me"];
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    if (token == nil){
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self GET:url
   parameters:nil
      success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"response: %@", responseObject);
          if(completionHandler != nil) completionHandler(responseObject, nil, operation);
      } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
          if(completionHandler != nil) completionHandler(nil, error, operation);
          NSLog(@"error:%@", error);
      }];
}

- (void)getFixedPhrases: (NSString *)orgUid withHandler: (void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    NSString *url = [NSString stringWithFormat:@"/api/fixed_phrases?org_uid=%@", orgUid];
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    if (token == nil){
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self GET:url
   parameters:nil
      success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"response: %@", responseObject);
          if(completionHandler != nil) completionHandler(responseObject, nil, operation);
      } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
          if(completionHandler != nil) completionHandler(nil, error, operation);
          NSLog(@"error:%@", error);
      }];
}

- (void)assignChannel:(NSString *)channelId
              userUid:(NSString *)userUid
    completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    NSString *url = [NSString stringWithFormat:@"/api/channels/%@/assign",channelId];
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    NSDictionary *param = @{@"user_id":userUid};
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
     NSLog(@"authentication: %@", authentication);
     NSLog(@"param: %@", param);
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)signInDeviceTokenWithAuthToken:(NSString *)deviceToken
                     completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    if (token == nil){
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    NSString *url = @"/api/devices";
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    NSDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:@"ios" forKey:@"device_type"];
    [param setValue:deviceToken forKey:@"device_token"];
    if ([CCConstants sharedInstance].isAgent == YES) {
        [param setValue:[[NSNumber alloc] initWithBool:YES] forKey:@"multiple"];
    }
    NSLog(@"authentication: %@", authentication);
    NSLog(@"param: %@", param);
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(@{@"result":@"success"}, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)signOutDeviceToken:(NSString *)deviceToken
         completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    if (token == nil){
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    NSString *url = @"/api/devices/sign_out";
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    NSDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:@"ios" forKey:@"device_type"];
    [param setValue:deviceToken forKey:@"device_token"];
    NSLog(@"authentication: %@", authentication);
    NSLog(@"param: %@", param);
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(@{@"result":@"success"}, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

#pragma mark - Message

- (void)sendMessage:(NSDictionary *)content
          channelId:(NSString *)channelId
            userUid:(NSString*)userUid
              token:(NSString*)token
               type:(NSString *)type
  completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *url = [NSString stringWithFormat:@"/api/channels/%@/messages",channelId];
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    NSDictionary *param = @{@"content":content,@"type":type};
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)sendFile:(NSString *)channelId
           files:(NSArray *)files
completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *token    = [[CCConstants sharedInstance] getKeychainToken];
    NSString *url = [NSString stringWithFormat:@"/api/channels/%@/messages/upload_files",channelId];
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:url
    parameters:nil constructingBodyWithBlock:^(id<CCAFMultipartFormData> formData){
        for(NSDictionary *file in files){
            [formData appendPartWithFileData:file[@"data"]
                                        name:@"files[]"
                                    fileName:file[@"name"]
                                    mimeType:file[@"mimeType"]];
        }
     }success:^(CCAFHTTPRequestOperation *operation, id responseObject){
         NSLog(@"response: %@", responseObject);
         if(completionHandler != nil) completionHandler(responseObject, nil, operation);
     }failure:^(CCAFHTTPRequestOperation *operation, NSError *error){
         NSLog(@"error:%@", error);
         if(completionHandler != nil) completionHandler(nil, error, operation);
     }];
}

- (void)sendMessage:(NSDictionary *)content
          channelId:(NSString *)channelId
               type:(NSString *)type
  completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *userUid  = [[CCConstants sharedInstance] getKeychainUid];
    NSString *token    = [[CCConstants sharedInstance] getKeychainToken];
    [self sendMessage:content channelId:channelId
              userUid:userUid token:token
                 type:type
    completionHandler:completionHandler];
}

-(void)sendMessageStatus:(NSString *)channelId messageIds:(NSArray *)messageIds completionHandler:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    NSString *url = [NSString stringWithFormat:@"/api/channels/%@/messages",channelId];
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    NSLog(@"authentication: %@", authentication);
    NSDictionary *content = @{@"messages":messageIds};
    NSDictionary *param = @{@"type"   :@"receipt",
                            @"content":content};
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           if(completionHandler != nil) completionHandler(nil, error, operation);
           NSLog(@"error:%@", error);
       }];
}

-(void)sendMessageResponseForChannel:(NSString *)channelId
                              answer:(NSObject *)answer
                         answerLabel:(NSString *)answerLabel
                             replyTo:(NSString *)replyTo
                   completionHandler:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    NSString *url = [NSString stringWithFormat:@"/api/channels/%@/messages",channelId];
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    NSLog(@"authentication: %@", authentication);
    NSDictionary *param = @{@"type"   :@"response",
                            @"content": @{ @"answer" : answer, @"answer_label" : answerLabel, @"reply_to" : replyTo } };
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           if(completionHandler != nil) completionHandler(nil, error, operation);
           NSLog(@"error:%@", error);
       }];
}

-(void)sendMessageResponseForChannel:(NSString *)channelId
                              answers:(NSArray *)answers
                             replyTo:(NSString *)replyTo
                   completionHandler:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    NSString *url = [NSString stringWithFormat:@"/api/channels/%@/messages",channelId];
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    NSLog(@"authentication: %@", authentication);
    
    NSDictionary *dummyAnswer;
    NSString *dummyLabel;
    if (answers.count==1) {
        dummyAnswer = answers[0];
        dummyLabel = [answers[0] objectForKey:@"label"];
    } else {
        dummyAnswer = @{};
        dummyLabel = @"";
    }
    
    NSDictionary *param = @{@"type"   :@"response",
                            @"content": @{ @"answer" : dummyAnswer,
                                           @"answer_label" : dummyLabel,
                                           @"answers" : answers,
                                           @"reply_to" : replyTo } };
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           if(completionHandler != nil) completionHandler(nil, error, operation);
           NSLog(@"error:%@", error);
       }];
}


-(void)sendMessageAnswer:(NSString *)channelId
              message_id:(NSNumber *)message_id
             answer_type:(NSNumber *)answer_type
             question_id:(NSString *)question_id
       completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    NSString *url = [NSString stringWithFormat:@"/api/channels/%@/questions/%@/answers",channelId,question_id];
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    NSLog(@"authentication: %@", authentication);
    NSDictionary *answer = [NSMutableDictionary dictionary];
    [answer setValue:answer_type forKey:@"answer_type"];
    [answer setValue:message_id forKey:@"message_id"];
    NSDictionary *param = @{@"answer":answer};
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           if(completionHandler != nil) completionHandler(nil, error, operation);
           NSLog(@"error:%@", error);
       }];
}

-(void)sendSuggestionMessage:(NSString *)channelId answer:(NSObject *)answer text:(NSString *)text replyTo:(NSString *)replyTo completionHandler:(void (^)(NSArray *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    NSString *url = [NSString stringWithFormat:@"/api/channels/%@/suggestion/reply",channelId];
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    NSLog(@"authentication: %@", authentication);
    if (text == nil) {
        text = @"";
    }
    if (replyTo == nil) {
        replyTo = @"";
    }
    NSDictionary *param = @{@"answer" : answer, @"text" : text, @"reply_to" : replyTo};
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo];
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           if(completionHandler != nil) completionHandler(nil, error, operation);
           NSLog(@"error:%@", error);
       }];
}

- (void)getMessage:(NSString *)channelId
             token:(NSString *)token
             limit:(int)limit
            lastId:(NSNumber *)lastId
 completionHandler:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *url = [NSString stringWithFormat:@"/api/channels/%@/messages",channelId];
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    NSDictionary *param;
    if (lastId == nil){
        param = @{@"limit":[NSNumber numberWithInteger: limit]};
    }else{
        param = @{@"limit":[NSNumber numberWithInteger: limit],@"last_id":lastId};
    }
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self GET:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"get message response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           if(completionHandler != nil) completionHandler(nil, error, operation);
           NSLog(@"error:%@", error);
       }];

}

-(void)getMessage:(NSString *)channelId
            limit:(int)limit
           lastId:(NSNumber *)lastId
completionHandler:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    [self getMessage:channelId token:token limit:limit lastId:lastId completionHandler:completionHandler];
}

#pragma mark - Channel

- (void)getChannelsMine:(NSString*)token
                  limit:(int)limit
          lastUpdatedAt:(NSDate *)lastUpdatedAt
      completionHandler:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *url = @"/api/channels/mine";
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
     NSLog(@"authentication: %@", authentication);
    NSDictionary *param;
    if (lastUpdatedAt == nil){
        param = @{@"limit":[NSNumber numberWithInteger: limit]};
    }else{
        NSTimeInterval lastUpdatedAtInterval = [lastUpdatedAt timeIntervalSince1970];
        NSNumber *lastUpdatedAtNumber = [NSNumber numberWithDouble:lastUpdatedAtInterval];
        param = @{@"limit":[NSNumber numberWithInteger: limit], @"last_updated_at":lastUpdatedAtNumber};
    }
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self GET:url
   parameters:param
      success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"response: %@", responseObject);
          if(completionHandler != nil) completionHandler(responseObject, nil, operation);
      } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"error:%@", error);
          if(completionHandler != nil) completionHandler(nil, error, operation);
      }];
}

- (void)getChannels:(NSString*)token
            org_uid:(NSString*)org_uid
              limit:(int)limit
      lastUpdatedAt:(NSDate *)lastUpdatedAt
  completionHandler:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *url = @"/api/channels";
    NSMutableDictionary *param;
    if (lastUpdatedAt == nil){
        param = @{@"org_uid":org_uid, @"limit":[NSNumber numberWithInteger: limit]}.mutableCopy;
    }else{
        NSTimeInterval lastUpdatedAtInterval = [lastUpdatedAt timeIntervalSince1970];
        NSNumber *lastUpdatedAtNumber = [NSNumber numberWithDouble:lastUpdatedAtInterval];
        param = @{@"org_uid":org_uid, @"limit":[NSNumber numberWithInteger: limit], @"last_updated_at":lastUpdatedAtNumber}.mutableCopy;
    }
    // Business funnel.
    NSDictionary *filterBusinessFunnel = [CCUserDefaultsUtil filterBusinessFunnel];
    if (filterBusinessFunnel != nil) {
        [param setObject:[filterBusinessFunnel objectForKey:@"id"] forKey:@"funnel_id"];
    }
    // Message status.
    NSArray <NSString *> *filterMessageStatus = [CCUserDefaultsUtil filterMessageStatus];
    NSMutableArray <NSString *> *statuses = [[NSMutableArray alloc] init];
    if(filterMessageStatus != nil){
        for (NSString *itemTitle in filterMessageStatus) {
            if ([itemTitle isEqualToString:CCHistoryFilterMessagesStatusTypeUnassigned]) {
                [statuses addObject:@"0"];
            } else if ([itemTitle isEqualToString:CCHistoryFilterMessagesStatusTypeAssignedToMe]) {
                [statuses addObject:@"1"];
                NSString *uid  = [[CCConstants sharedInstance] getKeychainUid];
                [param setObject:uid forKey:@"assignee_id"];
            } else if ([itemTitle isEqualToString:CCHistoryFilterMessagesStatusTypeClosed]) {
                [statuses addObject:@"2"];
            } else if ([itemTitle isEqualToString:CCHistoryFilterMessagesStatusTypeAll]) {
                [statuses addObject:@"0"];
                [statuses addObject:@"1"];
            }
        }
    }
    else{
        [statuses addObject:@"0"];
        [statuses addObject:@"1"];
    }
    if (statuses.count > 0) {
        [param setObject:statuses forKey:@"status"];
    }
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    NSLog(@"authentication: %@", authentication);
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this everytime
    [self GET:url
   parameters:param
      success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"response: %@", responseObject);
          if(completionHandler != nil) completionHandler(responseObject, nil, operation);
      } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"error:%@", error);
          if(completionHandler != nil) completionHandler(nil, error, operation);
      }];
}

-(void)getChannel:(int)getChannelsType
          org_uid:(NSString *)org_uid
            limit:(int)limit
    lastUpdatedAt:(NSDate *)lastUpdatedAt
completionHandler:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    if (getChannelsType == CCGetChannelsMine) {
        [self getChannelsMine:token limit:limit lastUpdatedAt:lastUpdatedAt completionHandler:completionHandler];
    }else if(getChannelsType == CCGetChannels) {
        [self getChannels:token org_uid:org_uid limit:limit lastUpdatedAt:lastUpdatedAt completionHandler:completionHandler];
    }
}

- (void)getChannel:(NSString*)channelUid
 completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *url = [NSString stringWithFormat:@"/api/channels/%@",channelUid];
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    NSLog(@"authentication: %@", authentication);
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this everytime
    [self GET:url
   parameters:nil
      success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"response: %@", responseObject);
          if(completionHandler != nil) completionHandler(responseObject, nil, operation);
      } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"error:%@", error);
          if(completionHandler != nil) completionHandler(nil, error, operation);
      }];
}

- (void)createChannel:(NSString*)token
               orgUid:(NSString*)orgUid
  channelInformations:(NSDictionary *)channelInformations
 completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *url = @"/api/channels";
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    NSLog(@"authentication: %@", authentication);
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:orgUid forKey:@"org_uid"];
    if (channelInformations != nil) [param setValue:channelInformations forKey:@"channel_informations"];
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:url
   parameters:param
      success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"response: %@", responseObject);
          if(completionHandler != nil) completionHandler(responseObject, nil, operation);
      } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"error:%@", error);
          if(completionHandler != nil) completionHandler(nil, error, operation);
      }];
}

- (void)createChannel:(NSString*)orgUid
              userIds:(NSArray *)userIds
        directMessage:(BOOL)directMessage
            groupName:(NSString *)groupName
  channelInformations:(NSDictionary *)channelInformations
    completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *url = @"/api/channels";
    NSString *token = [[CCConstants sharedInstance] getKeychainToken];
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    NSLog(@"authentication: %@", authentication);
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:orgUid forKey:@"org_uid"];
    [param setValue:userIds forKey:@"user_ids"];
    [param setValue: [[NSNumber alloc] initWithBool:directMessage] forKey:@"direct_message"];
    if(groupName != nil) [param setValue:userIds forKey:@"user_ids"];
    if (channelInformations != nil) [param setValue:channelInformations forKey:@"channel_informations"];
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

-(void)createChannel:(NSString *)orgUid
 channelInformations:(NSDictionary *)channelInformations
   completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    [self createChannel:token orgUid:orgUid channelInformations:channelInformations completionHandler:completionHandler];
}

- (void)updateChannel:(NSString *)channelId channelInformations:(NSDictionary *)channelInformations note:(NSString *)note completionHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    NSString *url = [NSString stringWithFormat:@"/api/channels/%@", channelId];
    NSString *authentication = [NSString stringWithFormat:@"%@", [[CCConstants sharedInstance] getKeychainToken]];
    NSLog(@"authentication: %@", authentication);
    NSDictionary *param;
    if (channelInformations != nil) {
        param = @{@"channel_informations":channelInformations, @"note": @{@"content":note}};
    } else {
        param = @{@"note": @{@"content":note}};
    }
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self PATCH:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];

}

- (void)closeChannels:(NSArray*)channelUids
   completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *url = @"/api/channels/close";
    NSString *authentication = [NSString stringWithFormat:@"%@", [[CCConstants sharedInstance] getKeychainToken]];
    NSLog(@"authentication: %@", authentication);
    NSDictionary *param = @{@"channel_uids":channelUids};
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)openChannels:(NSArray*)channelUids
    completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *url = @"/api/channels/open";
    NSString *authentication = [NSString stringWithFormat:@"%@", [[CCConstants sharedInstance] getKeychainToken]];
    NSLog(@"authentication: %@", authentication);
    NSDictionary *param = @{@"channel_uids":channelUids};
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)deleteChannel:(NSString *)channelUid completionHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    NSString *url = [NSString stringWithFormat:@"/api/channels/%@", channelUid];
    NSString *authentication = [NSString stringWithFormat:@"%@", [[CCConstants sharedInstance] getKeychainToken]];
    NSLog(@"authentication: %@", authentication);
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self DELETE:url
      parameters:@{}
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)getChannelCount:(NSString *)orgUid
               funnelId:(NSNumber *)funnelId
      completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler{
    NSString *url = @"/api/channels/count";
    NSString *authentication = [NSString stringWithFormat:@"%@", [[CCConstants sharedInstance] getKeychainToken]];
    NSLog(@"authentication: %@", authentication);
    NSMutableDictionary *param = @{}.mutableCopy;
    if (orgUid == nil) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        orgUid = [ud stringForKey:@"ChatCenterUserdefaults_currentOrgUid"];
    }
    if (orgUid != nil) {
        [param setObject:orgUid forKey:@"org_uid"];
    }
    if (funnelId != nil) {
        [param setObject:funnelId forKey:@"funnel_id"];
    }
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo];
    [self GET:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)setAssigneeForChannel:(NSString *)channelID agentID:(NSString *)agentID completionHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    if (_appToken == nil || channelID == nil) { ///Should specify an app
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"/api/channels/%@/assign", channelID];
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    [self.requestSerializer setValue:token forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:agentID forKey:@"user_id"];
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)removeAssigneeFromChannel:(NSString *)channelID agentID:(NSString *)agentID completionHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    if (_appToken == nil || channelID == nil) { ///Should specify an app
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"/api/channels/%@/unassign", channelID];
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    [self.requestSerializer setValue:token forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:agentID forKey:@"user_id"];
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)setFollowerForChannel:(NSString *)channelID agentID:(NSString *)agentID completionHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    if (_appToken == nil || channelID == nil) { ///Should specify an app
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"/api/channels/%@/follow", channelID];
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    [self.requestSerializer setValue:token forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:agentID forKey:@"user_id"];
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)removeFollowerFromChannel:(NSString *)channelID agentID:(NSString *)agentID completionHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    if (_appToken == nil || channelID == nil) { ///Should specify an app
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"/api/channels/%@/unfollow", channelID];
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    [self.requestSerializer setValue:token forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:agentID forKey:@"user_id"];
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

#pragma mark - Org
-(void)getOrg:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    [self getOrg:token completionHandler:completionHandler];
}

- (void)getOrg:(NSString*)token
 completionHandler:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    NSString *url;
    url = @"/api/orgs";
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    NSLog(@"authentication: %@", authentication);
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self GET:url
   parameters:nil
      success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"response: %@", responseObject);
          if(completionHandler != nil) completionHandler(responseObject, nil, operation);
      } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"error:%@", error);
          if(completionHandler != nil) completionHandler(nil, error, operation);
      }];   
}

- (void)getOrgOnlineStatus:(NSString*)orgUid completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler {
    NSString *url = [NSString stringWithFormat:@"/api/orgs/%@/online", orgUid];
    [self setDeviceInfo];
    [self GET:url parameters:nil success:^(CCAFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"response: %@", responseObject);
        if(completionHandler != nil) completionHandler(responseObject, nil, operation);
    } failure:^(CCAFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"error:%@", error);
        if(completionHandler != nil) completionHandler(nil, error, operation);
    }];
}

#pragma mark - App
///GET list of apps(Only Agent)
- (void)getApps:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    if (_appToken != nil) { ///Should not specify an app
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    NSString *url;
    url = @"/api/apps";
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    [self.requestSerializer setValue:token forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self GET:url
   parameters:nil
      success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
          NSLog(@"response: %@", responseObject);
          if(completionHandler != nil) completionHandler(responseObject, nil, operation);
      } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"error:%@", error);
          if(completionHandler != nil) completionHandler(nil, error, operation);
      }];
}
///GET an app(Guest and Agent)
- (void)getAppManifest:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler
{
    if (_appToken == nil) { ///Should specify an app
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    NSString* url = @"/api/apps";
    if ([CCConstants sharedInstance].isAgent == YES) {
        NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
        [self.requestSerializer setValue:token forHTTPHeaderField:@"Authentication"];
    }
    [self setDeviceInfo];
    [self GET:url
   parameters:nil
      success:^(CCAFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
          if(completionHandler != nil) completionHandler(responseObject, nil, operation);
      } failure:^(CCAFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
          if(completionHandler != nil) completionHandler(nil, error, operation);
      }];
}

#pragma mark - Video Call
- (void)getCallIdentity:(NSString *)channelId callerInfo:(NSDictionary *)callerInfo receiverInfo:(NSArray *)receiversInfor callAction:(NSString *)callAction completionHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    if (_appToken == nil || channelId == nil) { ///Should specify an app
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"/api/channels/%@/calls", channelId];
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    [self.requestSerializer setValue:token forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo];
    NSDictionary *param = @{@"content":@{@"caller":callerInfo, @"receivers":receiversInfor, @"action": callAction}};
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)setBusinessFunnelToChannel:(NSString *)channelId funnelId:(NSString *)funnelId showProgress:(BOOL)showProgress completionHandler:(void (^)(NSDictionary *, NSError *, CCAFHTTPRequestOperation *))completionHandler {
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    NSString *url = @"/api/channels/funnels";
    NSString *authentication = [NSString stringWithFormat:@"%@", token];
    NSDictionary *param = @{@"channel_uid":channelId, @"funnel_id": funnelId};
    [self.requestSerializer setValue:authentication forHTTPHeaderField:@"Authentication"];
    NSLog(@"authentication: %@", authentication);
    NSLog(@"param: %@", param);
    [self setDeviceInfo]; ///Just in case can not get infomation, calling this evertime
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation *operation, id responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation *operation, NSError *error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];

}

#pragma mark - Video Call
- (void)getReceiverIdentityWithChannelId:(NSString *)channelId
                                  caller:(NSDictionary *)callerInfo
                               receivers:(NSArray *)receiversList
                       completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler {
    if (_appToken == nil || channelId == nil) { ///Should specify an app
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"/api/channels/%@/calls", channelId];
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    [self.requestSerializer setValue:token forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo];
    NSDictionary *param = @{@"content":@{@"caller":callerInfo, @"receivers":receiversList}};
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
           NSLog(@"response: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
           NSLog(@"error:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)acceptCall:(NSString *)channelId
         messageId:(NSString *)messageId
              user:(NSDictionary *)user
 completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler {
    if (_appToken == nil || channelId == nil) { ///Should specify an app
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"/api/channels/%@/calls/%@/accept", channelId, messageId];
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    [self.requestSerializer setValue:token forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo];
    NSDictionary *param = @{@"content":@{@"user":user}};
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
           NSLog(@"response acceptVideoCallWithChannelId: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
           NSLog(@"error acceptVideoCallWithChannelId:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)hangupCall:(NSString *)channelId
         messageId:(NSString *)messageId
              user:(NSDictionary *)user
 completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler {
    if (_appToken == nil || channelId == nil) { ///Should specify an app
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"/api/channels/%@/calls/%@/hangup", channelId, messageId];
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    [self.requestSerializer setValue:token forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo];
    NSDictionary *param = @{@"content":@{@"user":user}};
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
           NSLog(@"response hangupVideoCallWithChannelId: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
           NSLog(@"error hangupVideoCallWithChannelId:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)rejectCall:(NSString *)channelId
         messageId:(NSString *)messageId
            reason:(NSDictionary *)reason
              user:(NSDictionary *)user
                   completionHandler:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler {
    if (_appToken == nil || channelId == nil) { ///Should specify an app
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    
    NSString* url = [NSString stringWithFormat:@"/api/channels/%@/calls/%@/reject", channelId, messageId];
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    [self.requestSerializer setValue:token forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo];
    NSDictionary *param = @{@"content":@{@"reason":reason, @"user":user}};
    [self POST:url
    parameters:param
       success:^(CCAFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
           NSLog(@"response rejectVideoCallWithChannelId: %@", responseObject);
           if(completionHandler != nil) completionHandler(responseObject, nil, operation);
       } failure:^(CCAFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
           NSLog(@"error rejectVideoCallWithChannelId:%@", error);
           if(completionHandler != nil) completionHandler(nil, error, operation);
       }];
}

- (void)getVideoAccessToken:(void (^)(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler {
    if (_appToken == nil) { ///Should specify an app
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    NSString* url = @"/api/calls/token";
    NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
    [self.requestSerializer setValue:token forHTTPHeaderField:@"Authentication"];
    [self setDeviceInfo];
    [self GET:url
   parameters:nil
      success:^(CCAFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
          if(completionHandler != nil) completionHandler(responseObject, nil, operation);
      } failure:^(CCAFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
          if(completionHandler != nil) completionHandler(nil, error, operation);
      }];
}
#pragma mark - Business funnel.

/**
 *  Getting business funnels.
 *
 *  @param completionHandler
 */
-(void)getBusinessFunnels:(void (^)(NSArray *result, NSError *error, CCAFHTTPRequestOperation *operation))completionHandler {
    if (_appToken == nil) {
        if(completionHandler != nil) completionHandler(nil, nil, nil);
        return;
    }
    NSString* url = @"/api/funnels";
    if ([CCConstants sharedInstance].isAgent == YES) {
        NSString *token  = [[CCConstants sharedInstance] getKeychainToken];
        [self.requestSerializer setValue:token forHTTPHeaderField:@"Authentication"];
    }
    [self setDeviceInfo];
    [self GET:url
   parameters:nil
      success:^(CCAFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
          if(completionHandler != nil) completionHandler(responseObject, nil, operation);
      } failure:^(CCAFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
          if(completionHandler != nil) completionHandler(nil, error, operation);
      }];
}

@end
