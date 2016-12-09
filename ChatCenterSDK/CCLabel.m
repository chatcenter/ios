//
//  CCLabel.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/29.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCLabel.h"
#import "ChatCenterPrivate.h"
#import "CCConstants.h"

@implementation CCLabel

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
    NSString* key = self.text;
    NSString* res = [ChatCenter localizedStringForKey:key];
    self.text = res;
    
    if (self.useBaseColor) {
        UIColor *col = [[CCConstants sharedInstance] baseColor];
        self.textColor = col;        
    }
    
}



@end
