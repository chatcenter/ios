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

#import "CCJSQMediaItem.h"

/**
 *  The `CCJSQPhotoMediaItem` class is a concrete `CCJSQMediaItem` subclass that implements the `CCJSQMessageMediaData` protocol
 *  and represents a photo media message. An initialized `CCJSQPhotoMediaItem` object can be passed 
 *  to a `CCJSQMediaMessage` object during its initialization to construct a valid media message object.
 *  You may wish to subclass `CCJSQPhotoMediaItem` to provide additional functionality or behavior.
 */
@interface CCJSQPhotoMediaItem : CCJSQMediaItem <CCJSQMessageMediaData, NSCoding, NSCopying>

/**
 *  The image for the photo media item. The default value is `nil`.
 */
@property (copy, nonatomic) UIImage *image;

/**
 *  Initializes and returns a photo media item object having the given image.
 *
 *  @param image The image for the photo media item. This value may be `nil`.
 *
 *  @return An initialized `CCJSQPhotoMediaItem` if successful, `nil` otherwise.
 *
 *  @discussion If the image must be dowloaded from the network, 
 *  you may initialize a `CCJSQPhotoMediaItem` object with a `nil` image. 
 *  Once the image has been retrieved, you can then set the image property.
 */
- (instancetype)initWithImage:(UIImage *)image;

@end
