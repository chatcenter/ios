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

#import "CCJSQMessagesMediaViewBubbleImageMasker.h"

#import "CCJSQMessagesBubbleImageFactory.h"


@interface CCJSQMessagesMediaViewBubbleImageMasker ()

- (void)jsq_maskView:(UIView *)view withImage:(UIImage *)image;

@end


@implementation CCJSQMessagesMediaViewBubbleImageMasker

#pragma mark - Initialization

- (instancetype)init
{
    return [self initWithBubbleImageFactory:[[CCJSQMessagesBubbleImageFactory alloc] init]];
}

- (instancetype)initWithBubbleImageFactory:(CCJSQMessagesBubbleImageFactory *)bubbleImageFactory
{
    NSParameterAssert(bubbleImageFactory != nil);
    
    self = [super init];
    if (self) {
        _bubbleImageFactory = bubbleImageFactory;
    }
    return self;
}

#pragma mark - View masking

- (void)applyOutgoingBubbleImageMaskToMediaView:(UIView *)mediaView
{
    CCJSQMessagesBubbleImage *bubbleImageData = [self.bubbleImageFactory outgoingMessagesBubbleImageWithColor:[UIColor whiteColor]];
    [self jsq_maskView:mediaView withImage:[bubbleImageData messageBubbleImage]];
}

- (void)applyIncomingBubbleImageMaskToMediaView:(UIView *)mediaView
{
    CCJSQMessagesBubbleImage *bubbleImageData = [self.bubbleImageFactory incomingMessagesBubbleImageWithColor:[UIColor whiteColor]];
    [self jsq_maskView:mediaView withImage:[bubbleImageData messageBubbleImage]];
}

+ (void)applyBubbleImageMaskToMediaView:(UIView *)mediaView isOutgoing:(BOOL)isOutgoing
{
    CCJSQMessagesMediaViewBubbleImageMasker *masker = [[CCJSQMessagesMediaViewBubbleImageMasker alloc] init];
    
    if (isOutgoing) {
        [masker applyOutgoingBubbleImageMaskToMediaView:mediaView];
    }
    else {
        [masker applyIncomingBubbleImageMaskToMediaView:mediaView];
    }
}

#pragma mark - Private

- (void)jsq_maskView:(UIView *)view withImage:(UIImage *)image
{
    NSParameterAssert(view != nil);
    NSParameterAssert(image != nil);
    
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = CGRectInset(view.frame, 2.0f, 2.0f);
    
    view.layer.mask = imageViewMask.layer;
}

@end
