//
//  CCLocalizedBarButtonItem.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/30.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCLocalizedBarButtonItem.h"
#import "ChatCenterPrivate.h"
#import "CCConstants.h"

@implementation CCLocalizedBarButtonItem

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
    NSString* key = self.title;
    NSString* res = [ChatCenter localizedStringForKey:key];
    self.title = res;
    
    if (self.useBaseColor) {
        UIColor *col = [[CCConstants sharedInstance] baseColor];
        self.tintColor = col;
    }
}


@end
