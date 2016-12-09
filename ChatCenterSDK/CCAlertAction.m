//
//  CCAlertAction.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2/19/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCAlertAction.h"

@implementation CCAlertAction

- (CCAlertAction*)initWithTitle:(NSString*)title handler:(void (^ __nullable)(CCAlertAction *action))handler {
    self->_title = title;
    self->_handler = handler;
    return self;
}

- (NSString*)getTitle {
    return _title;
}

- (void(^)(CCAlertAction *))getHandler {
    return _handler;
}

@end
