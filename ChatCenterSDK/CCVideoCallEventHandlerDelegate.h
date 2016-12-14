//
//  CCVideoCallEventHandlerDelegate.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 11/21/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

@protocol CCVideoCallEventHandlerDelegate <NSObject>
- (void) handleCallEvent:(NSString *) messageId content: (NSDictionary *)content;
@end
