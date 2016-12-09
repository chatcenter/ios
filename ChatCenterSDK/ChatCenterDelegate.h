//
//  ChatCenterDelegate.h
//  ChatCenterDemo
//
//  Created by NgocNH on 2/16/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChatCenterDelegate <NSObject>

@optional
- (void)authenticationErrorAlertClosed;

@end

@interface ChatCenterDelegate : NSObject

@end
