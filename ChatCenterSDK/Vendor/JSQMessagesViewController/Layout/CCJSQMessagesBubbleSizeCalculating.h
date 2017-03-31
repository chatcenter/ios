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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CCJSQMessagesCollectionViewFlowLayout;
@protocol CCJSQMessageData;

/**
 *  The `CCJSQMessagesBubbleSizeCalculating` protocol defines the common interface through which
 *  an object provides layout information to an instance of `CCJSQMessagesCollectionViewFlowLayout`.
 *
 *  A concrete class that conforms to this protocol is provided in the library.
 *  See `CCJSQMessagesBubbleSizeCalculator`.
 */
@protocol CCJSQMessagesBubbleSizeCalculating <NSObject>

/**
 *  Computes and returns the size of the `messageBubbleImageView` property 
 *  of a `CCJSQMessagesCollectionViewCell` for the specified messageData at indexPath.
 *
 *  @param messageData A message data object.
 *  @param indexPath   The index path at which messageData is located.
 *  @param layout      The layout object asking for this information.
 *
 *  @return A sizes that specifies the required dimensions to display the entire message contents.
 *  Note, this is *not* the entire cell, but only its message bubble.
 */
- (CGSize)messageBubbleSizeForMessageData:(id<CCJSQMessageData>)messageData
                              atIndexPath:(NSIndexPath *)indexPath
                               withLayout:(CCJSQMessagesCollectionViewFlowLayout *)layout;

/**
 *  Notifies the receiver that the layout will be reset. 
 *  Use this method to clear any cached layout information, if necessary.
 *
 *  @param layout The layout object notifying the receiver.
 */
- (void)prepareForResettingLayout:(CCJSQMessagesCollectionViewFlowLayout *)layout;

@end
