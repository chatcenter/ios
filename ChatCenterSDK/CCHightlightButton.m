//
//  CCHightlightButton.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2/26/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCHightlightButton.h"

@implementation CCHightlightButton

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [UIColor lightGrayColor];
    }
    else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
