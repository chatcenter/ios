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

#import "CCJSQMessagesBubbleImageFactory.h"

#import "UIImage+CCJSQMessages.h"
#import "UIColor+CCJSQMessages.h"


@interface CCJSQMessagesBubbleImageFactory ()

@property (strong, nonatomic, readonly) UIImage *bubbleImage;
@property (assign, nonatomic, readonly) UIEdgeInsets capInsets;

@end



@implementation CCJSQMessagesBubbleImageFactory

#pragma mark - Initialization

- (instancetype)initWithBubbleImage:(UIImage *)bubbleImage capInsets:(UIEdgeInsets)capInsets
{
	NSParameterAssert(bubbleImage != nil);
    
	self = [super init];
	if (self) {
		_bubbleImage = bubbleImage;
        
        if (UIEdgeInsetsEqualToEdgeInsets(capInsets, UIEdgeInsetsZero)) {
            _capInsets = [self jsq_centerPointEdgeInsetsForImageSize:bubbleImage.size];
        }
        else {
            _capInsets = capInsets;
        }
	}
	return self;
}

- (instancetype)init
{
    return [self initWithBubbleImage:[UIImage jsq_bubbleCompactImage] capInsets:UIEdgeInsetsZero];
}

#pragma mark - Public

- (CCJSQMessagesBubbleImage *)outgoingMessagesBubbleImageWithColor:(UIColor *)color
{
    return [self jsq_messagesBubbleImageWithColor:color flippedForIncoming:NO];
}

- (CCJSQMessagesBubbleImage *)incomingMessagesBubbleImageWithColor:(UIColor *)color
{
    return [self jsq_messagesBubbleImageWithColor:color flippedForIncoming:YES];
}

#pragma mark - Private

- (UIEdgeInsets)jsq_centerPointEdgeInsetsForImageSize:(CGSize)bubbleImageSize
{
    // make image stretchable from center point
    CGPoint center = CGPointMake(bubbleImageSize.width / 2.0f, bubbleImageSize.height / 2.0f);
    return UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
}

- (CCJSQMessagesBubbleImage *)jsq_messagesBubbleImageWithColor:(UIColor *)color flippedForIncoming:(BOOL)flippedForIncoming
{
    NSParameterAssert(color != nil);
    
    UIImage *normalBubble = [self.bubbleImage jsq_imageMaskedWithColor:color];
    UIImage *highlightedBubble = [self.bubbleImage jsq_imageMaskedWithColor:[color jsq_colorByDarkeningColorWithValue:0.12f]];
    
    if (flippedForIncoming) {
        normalBubble = [self jsq_horizontallyFlippedImageFromImage:normalBubble];
        highlightedBubble = [self jsq_horizontallyFlippedImageFromImage:highlightedBubble];
    }
    
    normalBubble = [self jsq_stretchableImageFromImage:normalBubble withCapInsets:self.capInsets];
    highlightedBubble = [self jsq_stretchableImageFromImage:highlightedBubble withCapInsets:self.capInsets];
    
    return [[CCJSQMessagesBubbleImage alloc] initWithMessageBubbleImage:normalBubble highlightedImage:highlightedBubble];
}

- (UIImage *)jsq_horizontallyFlippedImageFromImage:(UIImage *)image
{
    return [UIImage imageWithCGImage:image.CGImage
                               scale:image.scale
                         orientation:UIImageOrientationUpMirrored];
}

- (UIImage *)jsq_stretchableImageFromImage:(UIImage *)image withCapInsets:(UIEdgeInsets)capInsets
{
    return [image resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
}

@end
