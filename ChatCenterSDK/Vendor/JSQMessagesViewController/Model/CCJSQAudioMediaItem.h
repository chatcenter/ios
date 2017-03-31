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
#import "CCJSQAudioMediaViewAttributes.h"

#import <AVFoundation/AVFoundation.h>

@class CCJSQAudioMediaItem;

NS_ASSUME_NONNULL_BEGIN

@protocol CCJSQAudioMediaItemDelegate <NSObject>

/**
 *  Tells the delegate if the specified `CCJSQAudioMediaItem` changes the sound category or categoryOptions, or if an error occurs.
 */
- (void)audioMediaItem:(CCJSQAudioMediaItem *)audioMediaItem
didChangeAudioCategory:(NSString *)category
               options:(AVAudioSessionCategoryOptions)options
                 error:(nullable NSError *)error;

@end


/**
 *  The `CCJSQAudioMediaItem` class is a concrete `CCJSQMediaItem` subclass that implements the `CCJSQMessageMediaData` protocol
 *  and represents an audio media message. An initialized `CCJSQAudioMediaItem` object can be passed
 *  to a `CCJSQMediaMessage` object during its initialization to construct a valid media message object.
 *  You may wish to subclass `CCJSQAudioMediaItem` to provide additional functionality or behavior.
 */
@interface CCJSQAudioMediaItem : CCJSQMediaItem <CCJSQMessageMediaData, AVAudioPlayerDelegate, NSCoding, NSCopying>

/**
 *  The delegate object for audio event notifications.
 */
@property (nonatomic, weak, nullable) id<CCJSQAudioMediaItemDelegate> delegate;

/**
 *  The view attributes to configure the appearance of the audio media view.
 */
@property (nonatomic, strong, readonly) CCJSQAudioMediaViewAttributes *audioViewAttributes;

/**
 *  A data object that contains an audio resource.
 */
@property (nonatomic, strong, nullable) NSData *audioData;

/**
 *  Initializes and returns a audio media item having the given audioData.
 *
 *  @param audioData              The data object that contains the audio resource.
 *  @param audioViewConfiguration The view attributes to configure the appearance of the audio media view.
 *
 *  @return An initialized `CCJSQAudioMediaItem`.
 *
 *  @discussion If the audio must be downloaded from the network,
 *  you may initialize a `CCJSQVideoMediaItem` with a `nil` audioData.
 *  Once the audio is available you can set the `audioData` property.
 */
- (instancetype)initWithData:(nullable NSData *)audioData
         audioViewAttributes:(CCJSQAudioMediaViewAttributes *)audioViewAttributes NS_DESIGNATED_INITIALIZER;

/**
 *  Initializes and returns a default audio media item.
 *
 *  @return An initialized `CCJSQAudioMediaItem`.
 *
 *  @discussion You must set `audioData` to enable the play button.
 */
- (instancetype)init;

/**
 Initializes and returns a default audio media using the specified view attributes.

 @param audioViewAttributes The view attributes to configure the appearance of the audio media view.

 @return  An initialized `CCJSQAudioMediaItem`.
 */
- (instancetype)initWithAudioViewAttributes:(CCJSQAudioMediaViewAttributes *)audioViewAttributes;

/**
 *  Initializes and returns an audio media item having the given audioData.
 *
 *  @param audioData The data object that contains the audio resource.
 *
 *  @return An initialized `CCJSQAudioMediaItem`.
 *
 *  @discussion If the audio must be downloaded from the network,
 *  you may initialize a `CCJSQAudioMediaItem` with a `nil` audioData.
 *  Once the audio is available you can set the `audioData` property.
 */
- (instancetype)initWithData:(nullable NSData *)audioData;

/**
 *  Sets or updates the data object in an audio media item with the data specified at audioURL.
 *
 *  @param audioURL A File URL containing the location of the audio data.
 */
- (void)setAudioDataWithUrl:(nonnull NSURL *)audioURL;

@end

NS_ASSUME_NONNULL_END
