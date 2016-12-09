//
//  CCHistoryNavigationTitleView.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2016/04/20.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCHistoryNavigationTitleViewDelegate <NSObject>
@required

/**
 *  Press navigation title button.
 *
 *  @param sender button.
 */
- (void)pressNavigationTitleButton:(id)sender;

@end

@interface CCHistoryNavigationTitleView : UIView

/** Delegate */
@property (nonatomic, weak) id<CCHistoryNavigationTitleViewDelegate> delegate;

/** Navigation title. */
@property (nonatomic, strong) NSString *title;

/**
 *  Title button enabled.
 *
 *  @param enabled
 */
- (void)setTitleButonEnabled:(BOOL)enabled;

/**
 *  Update search label.
 */
- (void)updateSearchLabel;

@end
