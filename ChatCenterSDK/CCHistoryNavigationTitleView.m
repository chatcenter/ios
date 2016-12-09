//
//  CCHistoryNavigationTitleView.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2016/04/20.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCHistoryNavigationTitleView.h"

#import "CCHistoryFilterViewController.h"
#import "CCUserDefaultsUtil.h"
#import "ChatCenterPrivate.h"
#import "CCConstants.h"

@interface CCHistoryNavigationTitleView() {
@private
    // Content view.
    IBOutlet UIView *_contentView;
    // Title button.
    __weak IBOutlet UIButton *_titleButton;
    // Search label.
    __weak IBOutlet UILabel *_searchLabel;
    // Under image view.
    __weak IBOutlet UIImageView *_underImageView;
}
@end

@implementation CCHistoryNavigationTitleView

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
    [SDK_BUNDLE loadNibNamed:NSStringFromClass([self class]) owner:self options:0];
    _contentView.frame = self.bounds;
    [self addSubview:_contentView];
    
    _title = @"";
    [_titleButton setTitle:@"" forState:UIControlStateNormal];
    if ([CCConstants sharedInstance].headerItemColor != nil) {
        [_titleButton setTitleColor:[[CCConstants sharedInstance] headerItemColor] forState:UIControlStateNormal];
    }
    
    _searchLabel.text = @"";
    
    if ([CCConstants sharedInstance].isAgent != YES){
        _searchLabel.hidden = YES;
        _underImageView.hidden = YES;
        _contentView.userInteractionEnabled = NO;
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [_titleButton setTitle:title forState:UIControlStateNormal];
}

- (void)setTitleButonEnabled:(BOOL)enabled {
    _titleButton.enabled = enabled;
}

- (void)updateSearchLabel {
    NSMutableArray *searchConditions = @[].mutableCopy;
    // Business funnel.
    NSDictionary *businessFunnel = [CCUserDefaultsUtil filterBusinessFunnel];
    if (businessFunnel != nil) {
        [searchConditions addObject:[businessFunnel objectForKey:@"name"]];
    }
    // Message status.
    NSArray *messageStatus = [CCUserDefaultsUtil filterMessageStatus];
    if (messageStatus.count > 0) {
        for (NSString *status in messageStatus) {
            // Allは弾く
            if ([status isEqualToString:CCHistoryFilterMessagesStatusTypeAll]) {
                continue;
            }
            [searchConditions addObject:CCLocalizedString(status)];
        }
    }
    if (searchConditions.count > 0) {
        _searchLabel.text = [searchConditions componentsJoinedByString:@","];
    } else {
        _searchLabel.text = CCLocalizedString(CCHistoryFilterMessagesStatusTypeAll);
    }
}

// Press title button.
- (IBAction)pressTitleButton:(id)sender {
    [_delegate pressNavigationTitleButton:sender];
}

@end
