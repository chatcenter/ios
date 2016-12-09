//
//  CCChatAndHistoryViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/07/09.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCVoidViewController.h"
#import "CCChatViewController.h"

@interface CCChatAndHistoryViewController : UIViewController

@property (nonatomic) CCVoidViewController* voidViewController;
@property (nonatomic) CCChatViewController* chatViewController;

- (id)initWithUserdata:(int)channelType
              provider:(NSString *)provider
         providerToken:(NSString *)providerToken
   providerTokenSecret:(NSString *)providerTokenSecret
     providerCreatedAt:(NSDate *)providerCreatedAt
     providerExpiresAt:(NSDate *)providerExpiresAt
      closeViewHandler:(void (^)(void))closeViewHandler;
- (void)switchApp;
- (void)switchOrg;
- (void)switchChannel:(NSString *)channelUid;
- (void)close;
- (void)displayVoidViewController;

@end
