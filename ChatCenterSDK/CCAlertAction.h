//
//  CCAlertAction.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2/19/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCAlertAction : NSObject
{
    NSString *_title;
    void (^ __nullable _handler)(CCAlertAction* __nonnull action);
}

- (CCAlertAction* __nonnull)initWithTitle:(NSString* __nonnull)title handler:(void (^ __nullable)(CCAlertAction* __nonnull action))handler;
- (NSString* __nonnull)getTitle;
- (void(^ __nullable)(CCAlertAction* __nonnull))getHandler;

@end
