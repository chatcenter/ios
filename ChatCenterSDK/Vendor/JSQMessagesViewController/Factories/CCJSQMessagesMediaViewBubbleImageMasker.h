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

@class CCJSQMessagesBubbleImageFactory;

/**
 *  An instance of `CCJSQMessagesMediaViewBubbleImageMasker` is an object that masks
 *  media views for a `CCJSQMessageMediaData` object. Given a view, it will mask the view
 *  with a bubble image for an outgoing or incoming media view.
 *
 *  @see CCJSQMessageMediaData.
 *  @see CCJSQMessagesBubbleImageFactory.
 *  @see CCJSQMessagesBubbleImage.
 */
@interface CCJSQMessagesMediaViewBubbleImageMasker : NSObject

/**
 *  Returns the bubble image factory that the masker uses to mask media views.
 */
@property (strong, nonatomic, readonly) CCJSQMessagesBubbleImageFactory *bubbleImageFactory;

/**
 *  Creates and returns a new instance of `CCJSQMessagesMediaViewBubbleImageMasker`
 *  that uses a default instance of `CCJSQMessagesBubbleImageFactory`. The masker uses the `CCJSQMessagesBubbleImage`
 *  objects returned by the factory to mask media views.
 *
 *  @return An initialized `CCJSQMessagesMediaViewBubbleImageMasker` object if created successfully, `nil` otherwise.
 *
 *  @see CCJSQMessagesBubbleImageFactory.
 *  @see CCJSQMessagesBubbleImage.
 */
- (instancetype)init;

/**
 *  Creates and returns a new instance of `CCJSQMessagesMediaViewBubbleImageMasker`
 *  having the specified bubbleImageFactory. The masker uses the `CCJSQMessagesBubbleImage`
 *  objects returned by the factory to mask media views.
 *
 *  @param bubbleImageFactory An initialized `CCJSQMessagesBubbleImageFactory` object to use for masking media views. This value must not be `nil`.
 *
 *  @return An initialized `CCJSQMessagesMediaViewBubbleImageMasker` object if created successfully, `nil` otherwise.
 *
 *  @see CCJSQMessagesBubbleImageFactory.
 *  @see CCJSQMessagesBubbleImage.
 */
- (instancetype)initWithBubbleImageFactory:(CCJSQMessagesBubbleImageFactory *)bubbleImageFactory NS_DESIGNATED_INITIALIZER;

/**
 *  Applies an outgoing bubble image mask to the specified mediaView.
 *
 *  @param mediaView The media view to mask.
 */
- (void)applyOutgoingBubbleImageMaskToMediaView:(UIView *)mediaView;

/**
 *  Applies an incoming bubble image mask to the specified mediaView.
 *
 *  @param mediaView The media view to mask.
 */
- (void)applyIncomingBubbleImageMaskToMediaView:(UIView *)mediaView;

/**
 *  A convenience method for applying a bubble image mask to the specified mediaView.
 *  This method uses the default instance of `CCJSQMessagesBubbleImageFactory`.
 *
 *  @param mediaView  The media view to mask.
 *  @param isOutgoing A boolean value specifiying whether or not the mask should be for an outgoing or incoming view.
 *  Specify `YES` for outgoing and `NO` for incoming.
 */
+ (void)applyBubbleImageMaskToMediaView:(UIView *)mediaView isOutgoing:(BOOL)isOutgoing;

@end
