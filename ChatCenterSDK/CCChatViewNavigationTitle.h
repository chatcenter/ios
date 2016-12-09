//
//  CCChatViewNavigationTitle.h
//  ChatCenterDemo
//
//  Created by Shingo Hagiwara on 2016/11/22.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCChatViewNavigationTitleDelegate <NSObject>
@required

/**
 *  Press navigation title button.
 *
 *  @param sender button.
 */
- (void)pressNavigationTitleButton:(id)sender;

@end

@interface CCChatViewNavigationTitle : UIView

/** Delegate */
@property (nonatomic, weak) id<CCChatViewNavigationTitleDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrow;
@property (strong, nonatomic) IBOutlet UIView *contentView;

- (IBAction)didTapNavigationTitle:(id)sender;

@end
