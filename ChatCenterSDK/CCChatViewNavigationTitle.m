//
//  CCChatViewNavigationTitle.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2016/11/22.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCChatViewNavigationTitle.h"
#import "CCConstants.h"

@implementation CCChatViewNavigationTitle

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init {
    self = [super init];
    if (self != nil) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self setup];
    }
    return self;
}

// Setup.
- (void)setup {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    [bundle loadNibNamed:NSStringFromClass([self class]) owner:self options:0];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    [self.rightArrow setImage:[self.rightArrow.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    if ([CCConstants sharedInstance].headerItemColor == nil) {
        self.rightArrow.tintColor = [UIColor colorWithRed:41/255.0 green:59/255.0 blue:84/255.0 alpha:1.0];
    }else{
        self.title.textColor = [[CCConstants sharedInstance] headerItemColor];
        self.rightArrow.tintColor = [[CCConstants sharedInstance] headerItemColor];
    }
}

- (IBAction)didTapNavigationTitle:(id)sender {
    if ([self.delegate respondsToSelector:@selector(pressNavigationTitleButton:)]) {
        [self.delegate pressNavigationTitleButton:sender];
    }
}
@end
