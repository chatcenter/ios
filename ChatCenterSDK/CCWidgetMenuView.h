//
//  CCWidgetMenuView.h
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/14.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCChatViewController;

@interface CCWidgetMenuView : UIView

@property (nonatomic, assign) CCChatViewController* owner;
@property BOOL shouldShowSuggestion;
@property (nonatomic, strong) NSMutableArray *buttons;

- (instancetype)initWithFrame:(CGRect)frame owner:(CCChatViewController*)owner;


@end
