//
//  CCHistoryFilterViewItemCell.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2016/04/19.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCHistoryFilterViewItemCell : UITableViewCell

/**
 *  Setup cell.
 *
 *  @param itemTitle
 *  @param count
 *  @param isChecked
 */
- (void)setupWithItemTitle:(NSString *)itemTitle count:(NSString *)count isChecked:(BOOL)isChecked;

/**
 *  Selected cell.
 *
 *  @param checked
 */
- (void)setChecked:(BOOL)checked;

@end
