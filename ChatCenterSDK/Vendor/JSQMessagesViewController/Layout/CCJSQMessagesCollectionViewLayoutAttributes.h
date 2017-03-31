//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

/**
 *  A `CCJSQMessagesCollectionViewLayoutAttributes` is an object that manages the layout-related attributes
 *  for a given `CCJSQMessagesCollectionViewCell` in a `CCJSQMessagesCollectionView`.
 */
@interface CCJSQMessagesCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes <NSCopying>

/**
 *  The font used to display the body of a text message in a message bubble within a `CCJSQMessagesCollectionViewCell`.
 *  This value must not be `nil`.
 */
@property (strong, nonatomic) UIFont *messageBubbleFont;

/**
 *  The width of the `messageBubbleContainerView` of a `CCJSQMessagesCollectionViewCell`.
 *  This value should be greater than `0.0`.
 *
 *  @see CCJSQMessagesCollectionViewCell.
 */
@property (assign, nonatomic) CGFloat messageBubbleContainerViewWidth;

/**
 *  The inset of the text container's layout area within the text view's content area in a `CCJSQMessagesCollectionViewCell`. 
 *  The specified inset values should be greater than or equal to `0.0`.
 */
@property (assign, nonatomic) UIEdgeInsets textViewTextContainerInsets;

/**
 *  The inset of the frame of the text view within a `CCJSQMessagesCollectionViewCell`. 
 *  
 *  @discussion The inset values should be greater than or equal to `0.0` and are applied in the following ways:
 *
 *  1. The right value insets the text view frame on the side adjacent to the avatar image 
 *  (or where the avatar would normally appear). For outgoing messages this is the right side, 
 *  for incoming messages this is the left side.
 *
 *  2. The left value insets the text view frame on the side opposite the avatar image 
 *  (or where the avatar would normally appear). For outgoing messages this is the left side, 
 *  for incoming messages this is the right side.
 *
 *  3. The top value insets the top of the frame.
 *
 *  4. The bottom value insets the bottom of the frame.
 */
@property (assign, nonatomic) UIEdgeInsets textViewFrameInsets;

/**
 *  The size of the `avatarImageView` of a `CCJSQMessagesCollectionViewCellIncoming`.
 *  The size values should be greater than or equal to `0.0`.
 *
 *  @see CCJSQMessagesCollectionViewCellIncoming.
 */
@property (assign, nonatomic) CGSize incomingAvatarViewSize;

/**
 *  The size of the `avatarImageView` of a `CCJSQMessagesCollectionViewCellOutgoing`.
 *  The size values should be greater than or equal to `0.0`.
 *
 *  @see `CCJSQMessagesCollectionViewCellOutgoing`.
 */
@property (assign, nonatomic) CGSize outgoingAvatarViewSize;

/**
 *  The height of the `cellTopLabel` of a `CCJSQMessagesCollectionViewCell`.
 *  This value should be greater than or equal to `0.0`.
 *
 *  @see CCJSQMessagesCollectionViewCell.
 */
@property (assign, nonatomic) CGFloat cellTopLabelHeight;

/**
 *  The height of the `messageBubbleTopLabel` of a `CCJSQMessagesCollectionViewCell`.
 *  This value should be greater than or equal to `0.0`.
 *
 *  @see CCJSQMessagesCollectionViewCell.
 */
@property (assign, nonatomic) CGFloat messageBubbleTopLabelHeight;

/**
 *  The height of the `cellBottomLabel` of a `CCJSQMessagesCollectionViewCell`.
 *  This value should be greater than or equal to `0.0`.
 *
 *  @see CCJSQMessagesCollectionViewCell.
 */
@property (assign, nonatomic) CGFloat cellBottomLabelHeight;

@end
