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

#import "CCJSQMessagesCollectionViewFlowLayout.h"
#import "CCJSQMessagesCollectionViewDelegateFlowLayout.h"
#import "CCJSQMessagesCollectionViewDataSource.h"
#import "CCJSQMessagesCollectionViewCell.h"

@class CCJSQMessagesTypingIndicatorFooterView;
@class CCJSQMessagesLoadEarlierHeaderView;


/**
 *  The `CCJSQMessagesCollectionView` class manages an ordered collection of message data items and presents
 *  them using a specialized layout for messages.
 */
@interface CCJSQMessagesCollectionView : UICollectionView <CCJSQMessagesCollectionViewCellDelegate>

/**
 *  The object that provides the data for the collection view.
 *  The data source must adopt the `CCJSQMessagesCollectionViewDataSource` protocol.
 */
@property (weak, nonatomic) id<CCJSQMessagesCollectionViewDataSource> dataSource;

/**
 *  The object that acts as the delegate of the collection view. 
 *  The delegate must adopt the `CCJSQMessagesCollectionViewDelegateFlowLayout` protocol.
 */
@property (weak, nonatomic) id<CCJSQMessagesCollectionViewDelegateFlowLayout> delegate;

/**
 *  The layout used to organize the collection view’s items.
 */
@property (strong, nonatomic) CCJSQMessagesCollectionViewFlowLayout *collectionViewLayout;

/**
 *  Specifies whether the typing indicator displays on the left or right side of the collection view
 *  when shown. That is, whether it displays for an "incoming" or "outgoing" message.
 *  The default value is `YES`, meaning that the typing indicator will display on the left side of the
 *  collection view for incoming messages.
 *
 *  @discussion If your `CCJSQMessagesViewController` subclass displays messages for right-to-left
 *  languages, such as Arabic, set this property to `NO`.
 *
 */
@property (assign, nonatomic) BOOL typingIndicatorDisplaysOnLeft;

/**
 *  The color of the typing indicator message bubble. The default value is a light gray color.
 */
@property (strong, nonatomic) UIColor *typingIndicatorMessageBubbleColor;

/**
 *  The color of the typing indicator ellipsis. The default value is a dark gray color.
 */
@property (strong, nonatomic) UIColor *typingIndicatorEllipsisColor;

/**
 *  The color of the text in the load earlier messages header. The default value is a bright blue color.
 */
@property (strong, nonatomic) UIColor *loadEarlierMessagesHeaderTextColor;

/**
 *  Returns a `CCJSQMessagesTypingIndicatorFooterView` object for the specified index path
 *  that is configured using the collection view's properties:
 *  typingIndicatorDisplaysOnLeft, typingIndicatorMessageBubbleColor, typingIndicatorEllipsisColor.
 *
 *  @param indexPath The index path specifying the location of the supplementary view in the collection view. This value must not be `nil`.
 *
 *  @return A valid `CCJSQMessagesTypingIndicatorFooterView` object.
 */
- (CCJSQMessagesTypingIndicatorFooterView *)dequeueTypingIndicatorFooterViewForIndexPath:(NSIndexPath *)indexPath;

/**
 *  Returns a `CCJSQMessagesLoadEarlierHeaderView` object for the specified index path
 *  that is configured using the collection view's loadEarlierMessagesHeaderTextColor property.
 *
 *  @param indexPath The index path specifying the location of the supplementary view in the collection view. This value must not be `nil`.
 *
 *  @return A valid `CCJSQMessagesLoadEarlierHeaderView` object.
 */
- (CCJSQMessagesLoadEarlierHeaderView *)dequeueLoadEarlierMessagesViewHeaderForIndexPath:(NSIndexPath *)indexPath;

@end
