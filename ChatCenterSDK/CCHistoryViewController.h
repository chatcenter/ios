//
//  CCHistoryViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2014/07/30.
//  Copyright (c) 2014年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCConectionHelperDelegate.h"
#import "CCUISplitViewController.h"
#import "ChatCenter.h"
#import "CCChatAndHistoryViewController.h"
#import "CCHistoryNavigationTitleView.h"
#import "CCHistoryFilterViewController.h"
#import "CCMGSwipeTableCell.h"

@interface CCHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, CCConectionHelperDelegate, CCHistoryNavigationTitleViewDelegate, CCHistoryFilterViewControllerDelegate, CCMGSwipeTableCellDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, weak) CCUISplitViewController* mySplitViewController;
@property (nonatomic, weak) CCChatAndHistoryViewController* chatAndHistoryViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewTopMargin;

- (id)initWithUserdata:(int)channelType
              provider:(NSString *)provider
         providerToken:(NSString *)providerToken
   providerTokenSecret:(NSString *)providerTokenSecret
  providerRefreshToken:(NSString *)providerRefreshToken
     providerCreatedAt:(NSDate *)providerCreatedAt
     providerExpiresAt:(NSDate *)providerExpiresAt
     completionHandler:(void (^)(void))completionHandler;
- (void)closeChatView;
@end
