//
//  SWTableViewCell.h
//  SWTableViewCell
//
//  Created by Chris Wendel on 9/10/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "CCSWCellScrollView.h"
#import "CCSWLongPressGestureRecognizer.h"
#import "CCSWUtilityButtonTapGestureRecognizer.h"
#import "NSMutableArray+CCSWUtilityButtons.h"

@class CCSWTableViewCell;

typedef NS_ENUM(NSInteger, CCSWCellState)
{
    kCellStateCenter,
    kCellStateLeft,
    kCellStateRight,
};

@protocol CCSWTableViewCellDelegate <NSObject>

@optional
- (void)swipeableTableViewCell:(CCSWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index;
- (void)swipeableTableViewCell:(CCSWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index;
- (void)swipeableTableViewCell:(CCSWTableViewCell *)cell scrollingToState:(CCSWCellState)state;
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(CCSWTableViewCell *)cell;
- (BOOL)swipeableTableViewCell:(CCSWTableViewCell *)cell canSwipeToState:(CCSWCellState)state;
- (void)swipeableTableViewCellDidEndScrolling:(CCSWTableViewCell *)cell;
- (void)swipeableTableViewCell:(CCSWTableViewCell *)cell didScroll:(UIScrollView *)scrollView;

@end

@interface CCSWTableViewCell : UITableViewCell

@property (nonatomic, copy) NSArray *leftUtilityButtons;
@property (nonatomic, copy) NSArray *rightUtilityButtons;

@property (nonatomic, weak) id <CCSWTableViewCellDelegate> delegate;

- (void)setRightUtilityButtons:(NSArray *)rightUtilityButtons WithButtonWidth:(CGFloat) width;
- (void)setLeftUtilityButtons:(NSArray *)leftUtilityButtons WithButtonWidth:(CGFloat) width;
- (void)hideUtilityButtonsAnimated:(BOOL)animated;
- (void)showLeftUtilityButtonsAnimated:(BOOL)animated;
- (void)showRightUtilityButtonsAnimated:(BOOL)animated;

- (BOOL)isUtilityButtonsHidden;

@end
