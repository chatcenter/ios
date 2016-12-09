//
//  CCCalendarTimeViewBorder.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/09/06.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCCalendarTimeViewBorder.h"
#import "CCConstants.h"

@implementation CCCalendarTimeViewBorder

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (void)p_commonInit
{
    NSString *className = NSStringFromClass([self class]);
    [SDK_BUNDLE loadNibNamed:className owner:self options:0];
    
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
}

@end
