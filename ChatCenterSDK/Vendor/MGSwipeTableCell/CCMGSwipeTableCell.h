/*
 * CCMGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2016 Imanol Fernandez @MortimerGoro
 */

#import <UIKit/UIKit.h>
#import "CCMGSwipeButton.h"


/** Transition types */
typedef NS_ENUM(NSInteger, CCMGSwipeTransition) {
    CCMGSwipeTransitionBorder = 0,
    CCMGSwipeTransitionStatic,
    CCMGSwipeTransitionDrag,
    CCMGSwipeTransitionClipCenter,
    CCMGSwipeTransitionRotate3D
};

/** Compatibility with older versions */
#define CCMGSwipeTransition3D CCMGSwipeTransitionRotate3D
#define CCMGSwipeStateSwippingLeftToRight CCMGSwipeStateSwipingLeftToRight
#define CCMGSwipeStateSwippingRightToLeft CCMGSwipeStateSwipingRightToLeft

/** Swipe directions */
typedef NS_ENUM(NSInteger, CCMGSwipeDirection) {
    CCMGSwipeDirectionLeftToRight = 0,
    CCMGSwipeDirectionRightToLeft
};

/** Swipe state */
typedef NS_ENUM(NSInteger, CCMGSwipeState) {
    CCMGSwipeStateNone = 0,
    CCMGSwipeStateSwipingLeftToRight,
    CCMGSwipeStateSwipingRightToLeft,
    CCMGSwipeStateExpandingLeftToRight,
    CCMGSwipeStateExpandingRightToLeft,
};

/** Swipe state */
typedef NS_ENUM(NSInteger, CCMGSwipeExpansionLayout) {
    CCMGSwipeExpansionLayoutBorder = 0,
    CCMGSwipeExpansionLayoutCenter
};

/** Swipe Easing Function */
typedef NS_ENUM(NSInteger, CCMGSwipeEasingFunction) {
    CCMGSwipeEasingFunctionLinear = 0,
    CCMGSwipeEasingFunctionQuadIn,
    CCMGSwipeEasingFunctionQuadOut,
    CCMGSwipeEasingFunctionQuadInOut,
    CCMGSwipeEasingFunctionCubicIn,
    CCMGSwipeEasingFunctionCubicOut,
    CCMGSwipeEasingFunctionCubicInOut,
    CCMGSwipeEasingFunctionBounceIn,
    CCMGSwipeEasingFunctionBounceOut,
    CCMGSwipeEasingFunctionBounceInOut
};

/**
 * Swipe animation settings
 **/
@interface CCMGSwipeAnimation : NSObject
/** Animation duration in seconds. Default value 0.3 */
@property (nonatomic, assign) CGFloat duration;
/** Animation easing function. Default value EaseOutBounce */
@property (nonatomic, assign) CCMGSwipeEasingFunction easingFunction;
/** Override this method to implement custom easing functions */
-(CGFloat) value:(CGFloat) elapsed duration:(CGFloat) duration from:(CGFloat) from to:(CGFloat) to;

@end

/**
 * Swipe settings
 **/
@interface CCMGSwipeSettings: NSObject
/** Transition used while swiping buttons */
@property (nonatomic, assign) CCMGSwipeTransition transition;
/** Size proportional threshold to hide/keep the buttons when the user ends swiping. Default value 0.5 */
@property (nonatomic, assign) CGFloat threshold;
/** Optional offset to change the swipe buttons position. Relative to the cell border position. Default value: 0 
 ** For example it can be used to avoid cropped buttons when sectionIndexTitlesForTableView is used in the UITableView
 **/
@property (nonatomic, assign) CGFloat offset;
/** Top margin of the buttons relative to the contentView */
@property (nonatomic, assign) CGFloat topMargin;
/** Bottom margin of the buttons relative to the contentView */
@property (nonatomic, assign) CGFloat bottomMargin;

/** Animation settings when the swipe buttons are shown */
@property (nonatomic, strong, nonnull) CCMGSwipeAnimation * showAnimation;
/** Animation settings when the swipe buttons are hided */
@property (nonatomic, strong, nonnull) CCMGSwipeAnimation * hideAnimation;
/** Animation settings when the cell is stretched from the swipe buttons */
@property (nonatomic, strong, nonnull) CCMGSwipeAnimation * stretchAnimation;

/** Property to read or change swipe animation durations. Default value 0.3 */
@property (nonatomic, assign) CGFloat animationDuration DEPRECATED_ATTRIBUTE;

/** If true the buttons are kept swiped when the threshold is reached and the user ends the gesture
 * If false, the buttons are always hidden when the user ends the swipe gesture
 */
@property (nonatomic, assign) BOOL keepButtonsSwiped;

/** If true the table cell is not swiped, just the buttons **/
@property (nonatomic, assign) BOOL onlySwipeButtons;

/** If NO the swipe bounces will be disabled, the swipe motion will stop right after the button */
@property (nonatomic, assign) BOOL enableSwipeBounces;

/** Coefficient applied to cell movement in bounce zone. Set to value between 0.0 and 1.0
    to make the cell 'resist' swiping after buttons are revealed. Default is 1.0 */
@property (nonatomic, assign) CGFloat swipeBounceRate;

@end


/**
 * Expansion settings to make expandable buttons
 * Swipe button are not expandable by default
 **/
@interface CCMGSwipeExpansionSettings: NSObject
/** index of the expandable button (in the left or right buttons arrays) */
@property (nonatomic, assign) NSInteger buttonIndex;
/** if true the button fills the cell on trigger, else it bounces back to its initial position */
@property (nonatomic, assign) BOOL fillOnTrigger;
/** Size proportional threshold to trigger the expansion button. Default value 1.5 */
@property (nonatomic, assign) CGFloat threshold;
/** Optional expansion color. Expanded button's background color is used by default **/
@property (nonatomic, strong, nullable) UIColor * expansionColor;
/** Defines the layout of the expanded button **/
@property (nonatomic, assign) CCMGSwipeExpansionLayout expansionLayout;
/** Animation settings when the expansion is triggered **/
@property (nonatomic, strong, nonnull) CCMGSwipeAnimation * triggerAnimation;

/** Property to read or change expansion animation durations. Default value 0.2 
 * The target animation is the change of a button from normal state to expanded state
 */
@property (nonatomic, assign) CGFloat animationDuration;
@end


/** helper forward declaration */
@class CCMGSwipeTableCell;

/** 
 * Optional delegate to configure swipe buttons or to receive triggered actions.
 * Buttons can be configured inline when the cell is created instead of using this delegate,
 * but using the delegate improves memory usage because buttons are only created in demand
 */
@protocol CCMGSwipeTableCellDelegate <NSObject>

@optional
/**
 * Delegate method to enable/disable swipe gestures
 * @return YES if swipe is allowed
 **/
-(BOOL) swipeTableCell:(nonnull CCMGSwipeTableCell*) cell canSwipe:(CCMGSwipeDirection) direction fromPoint:(CGPoint) point;
-(BOOL) swipeTableCell:(nonnull CCMGSwipeTableCell*) cell canSwipe:(CCMGSwipeDirection) direction DEPRECATED_ATTRIBUTE; //backwards compatibility

/**
 * Delegate method invoked when the current swipe state changes
 @param state the current Swipe State
 @param gestureIsActive YES if the user swipe gesture is active. No if the uses has already ended the gesture
 **/
-(void) swipeTableCell:(nonnull CCMGSwipeTableCell*) cell didChangeSwipeState:(CCMGSwipeState) state gestureIsActive:(BOOL) gestureIsActive;

/**
 * Called when the user clicks a swipe button or when a expandable button is automatically triggered
 * @return YES to autohide the current swipe buttons
 **/
-(BOOL) swipeTableCell:(nonnull CCMGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(CCMGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion;
/**
 * Delegate method to setup the swipe buttons and swipe/expansion settings
 * Buttons can be any kind of UIView but it's recommended to use the convenience CCMGSwipeButton class
 * Setting up buttons with this delegate instead of using cell properties improves memory usage because buttons are only created in demand
 * @param cell the UITableViewCell to configure. You can get the indexPath using [tableView indexPathForCell:cell]
 * @param direction The swipe direction (left to right or right to left)
 * @param swipeSettings instance to configure the swipe transition and setting (optional)
 * @param expansionSettings instance to configure button expansions (optional)
 * @return Buttons array
 **/
-(nullable NSArray<UIView*>*) swipeTableCell:(nonnull CCMGSwipeTableCell*) cell swipeButtonsForDirection:(CCMGSwipeDirection)direction
             swipeSettings:(nonnull CCMGSwipeSettings*) swipeSettings expansionSettings:(nonnull CCMGSwipeExpansionSettings*) expansionSettings;

/**
 * Called when the user taps on a swiped cell
 * @return YES to autohide the current swipe buttons
 **/
-(BOOL) swipeTableCell:(nonnull CCMGSwipeTableCell *)cell shouldHideSwipeOnTap:(CGPoint) point;

/**
 * Called when the cell will begin swiping
 * Useful to make cell changes that only are shown after the cell is swiped open
 **/
-(void) swipeTableCellWillBeginSwiping:(nonnull CCMGSwipeTableCell *) cell;

/**
 * Called when the cell will end swiping
 **/
-(void) swipeTableCellWillEndSwiping:(nonnull CCMGSwipeTableCell *) cell;

@end


/**
 * Swipe Cell class
 * To implement swipe cells you have to override from this class
 * You can create the cells programmatically, using xibs or storyboards
 */
@interface CCMGSwipeTableCell : UITableViewCell

/** optional delegate (not retained) */
@property (nonatomic, weak, nullable) id<CCMGSwipeTableCellDelegate> delegate;

/** optional to use contentView alternative. Use this property instead of contentView to support animated views while swiping */
@property (nonatomic, strong, readonly, nonnull) UIView * swipeContentView;

/** 
 * Left and right swipe buttons and its settings.
 * Buttons can be any kind of UIView but it's recommended to use the convenience CCMGSwipeButton class
 */
@property (nonatomic, copy, nonnull) NSArray<UIView*> * leftButtons;
@property (nonatomic, copy, nonnull) NSArray<UIView*> * rightButtons;
@property (nonatomic, strong, nonnull) CCMGSwipeSettings * leftSwipeSettings;
@property (nonatomic, strong, nonnull) CCMGSwipeSettings * rightSwipeSettings;

/** Optional settings to allow expandable buttons */
@property (nonatomic, strong, nonnull) CCMGSwipeExpansionSettings * leftExpansion;
@property (nonatomic, strong, nonnull) CCMGSwipeExpansionSettings * rightExpansion;

/** Readonly property to fetch the current swipe state */
@property (nonatomic, readonly) CCMGSwipeState swipeState;
/** Readonly property to check if the user swipe gesture is currently active */
@property (nonatomic, readonly) BOOL isSwipeGestureActive;

// default is NO. Controls whether multiple cells can be swiped simultaneously
@property (nonatomic) BOOL allowsMultipleSwipe;
// default is NO. Controls whether buttons with different width are allowed. Buttons are resized to have the same size by default.
@property (nonatomic) BOOL allowsButtonsWithDifferentWidth;
//default is YES. Controls whether swipe gesture is allowed when the touch starts into the swiped buttons
@property (nonatomic) BOOL allowsSwipeWhenTappingButtons;
//default is YES. Controls whether swipe gesture is allowed in opposite directions. NO value disables swiping in opposite direction once started in one direction
@property (nonatomic) BOOL allowsOppositeSwipe;
// default is NO.  Controls whether the cell selection/highlight status is preserved when expansion occurs
@property (nonatomic) BOOL preservesSelectionStatus;
/* default is NO. Controls whether dismissing a swiped cell when tapping outside of the cell generates a real touch event on the other cell.
 Default behaviour is the same as the Mail app on iOS. Enable it if you want to allow to start a new swipe while a cell is already in swiped in a single step.  */
@property (nonatomic) BOOL touchOnDismissSwipe;

/** Optional background color for swipe overlay. If not set, its inferred automatically from the cell contentView */
@property (nonatomic, strong, nullable) UIColor * swipeBackgroundColor;
/** Property to read or change the current swipe offset programmatically */
@property (nonatomic, assign) CGFloat swipeOffset;

/** Utility methods to show or hide swipe buttons programmatically */
-(void) hideSwipeAnimated: (BOOL) animated;
-(void) hideSwipeAnimated: (BOOL) animated completion:(nullable void(^)(BOOL finished)) completion;
-(void) showSwipe: (CCMGSwipeDirection) direction animated: (BOOL) animated;
-(void) showSwipe: (CCMGSwipeDirection) direction animated: (BOOL) animated completion:(nullable void(^)(BOOL finished)) completion;
-(void) setSwipeOffset:(CGFloat)offset animated: (BOOL) animated completion:(nullable void(^)(BOOL finished)) completion;
-(void) setSwipeOffset:(CGFloat)offset animation: (nonnull CCMGSwipeAnimation *) animation completion:(nullable void(^)(BOOL finished)) completion;
-(void) expandSwipe: (CCMGSwipeDirection) direction animated: (BOOL) animated;

/** Refresh method to be used when you want to update the cell contents while the user is swiping */
-(void) refreshContentView;
/** Refresh method to be used when you want to dynamically change the left or right buttons (add or remove)
 * If you only want to change the title or the backgroundColor of a button you can change it's properties (get the button instance from leftButtons or rightButtons arrays)
 * @param usingDelegate if YES new buttons will be fetched using the CCMGSwipeTableCellDelegate. Otherwise new buttons will be fetched from leftButtons/rightButtons properties.
 */
-(void) refreshButtons: (BOOL) usingDelegate;

@end

