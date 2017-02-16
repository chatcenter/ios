//
//  CCChoiceButton.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/07/11.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCChoiceButton.h"
#import "CCConstants.h"

@implementation CCChoiceButton

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    } else {
        [UIView transitionWithView:self
                          duration:0.2
                           options:UIViewAnimationOptionCurveEaseOut
                        animations:^{
                            if ([self.responseType isEqualToString:CC_RESPONSETYPEDATETIMEAVAILABILITY]) {
                                self.backgroundColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0];
                            }else{
                                self.backgroundColor = nil;
                            }
                        } completion:nil];
    }
}

@end
