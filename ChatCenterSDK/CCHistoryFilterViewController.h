//
//  CCHistoryFilterViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2016/04/19.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// Message status string.
// All.
static NSString *CCHistoryFilterMessagesStatusTypeAll = @"All";
// Unassigned.
static NSString *CCHistoryFilterMessagesStatusTypeUnassigned = @"Unassigned";
// Assigned to me.
static NSString *CCHistoryFilterMessagesStatusTypeAssignedToMe = @"Assigned to me";
// Assigned.
static NSString *CCHistoryFilterMessagesStatusTypeClosed = @"Closed";

@protocol CCHistoryFilterViewControllerDelegate <NSObject>
@required

/**
 *  Press filter button.
 */
- (void)pressFilterButton;

@end

@interface CCHistoryFilterViewController : UIViewController

/** Delegate */
@property (nonatomic, weak) id<CCHistoryFilterViewControllerDelegate> delegate;

@end
