//
//  CCLocalizedButton.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/30.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCLocalizedButton.h"
#import "ChatCenterPrivate.h"

@implementation CCLocalizedButton

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self doSetup];
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    [self doSetup];
    
    return self;
}

//
// Generate String
//
-(void)doSetup
{
    NSUInteger states[4] = {
        UIControlStateNormal,
        UIControlStateHighlighted,
        UIControlStateDisabled,
        UIControlStateSelected
    };

    for(int i=0; i<4; i++) {
        UIControlState s = states[i];
        NSString *text = [self titleForState:s];
        
        if (text) {
            NSString* localized = [ChatCenter localizedStringForKey:text];
            [self setTitle:localized forState:s];
        }
    }
    
}

@end
