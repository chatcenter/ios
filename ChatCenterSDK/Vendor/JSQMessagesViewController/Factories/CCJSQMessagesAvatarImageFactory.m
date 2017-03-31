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

#import "CCJSQMessagesAvatarImageFactory.h"

#import "UIColor+CCJSQMessages.h"


@implementation CCJSQMessagesAvatarImageFactory

#pragma mark - Public

+ (CCJSQMessagesAvatarImage *)avatarImageWithPlaceholder:(UIImage *)placeholderImage diameter:(NSUInteger)diameter
{
    UIImage *circlePlaceholderImage = [CCJSQMessagesAvatarImageFactory jsq_circularImage:placeholderImage
                                                                          withDiameter:diameter
                                                                      highlightedColor:nil];

    return [CCJSQMessagesAvatarImage avatarImageWithPlaceholder:circlePlaceholderImage];
}

+ (CCJSQMessagesAvatarImage *)avatarImageWithImage:(UIImage *)image diameter:(NSUInteger)diameter
{
    UIImage *avatar = [CCJSQMessagesAvatarImageFactory circularAvatarImage:image withDiameter:diameter];
    UIImage *highlightedAvatar = [CCJSQMessagesAvatarImageFactory circularAvatarHighlightedImage:image withDiameter:diameter];

    return [[CCJSQMessagesAvatarImage alloc] initWithAvatarImage:avatar
                                              highlightedImage:highlightedAvatar
                                              placeholderImage:avatar];
}

+ (UIImage *)circularAvatarImage:(UIImage *)image withDiameter:(NSUInteger)diameter
{
    return [CCJSQMessagesAvatarImageFactory jsq_circularImage:image
                                               withDiameter:diameter
                                           highlightedColor:nil];
}

+ (UIImage *)circularAvatarHighlightedImage:(UIImage *)image withDiameter:(NSUInteger)diameter
{
    return [CCJSQMessagesAvatarImageFactory jsq_circularImage:image
                                               withDiameter:diameter
                                           highlightedColor:[UIColor colorWithWhite:0.1f alpha:0.3f]];
}

+ (CCJSQMessagesAvatarImage *)avatarImageWithUserInitials:(NSString *)userInitials
                                        backgroundColor:(UIColor *)backgroundColor
                                              textColor:(UIColor *)textColor
                                                   font:(UIFont *)font
                                               diameter:(NSUInteger)diameter
{
    UIImage *avatarImage = [CCJSQMessagesAvatarImageFactory jsq_imageWitInitials:userInitials
                                                               backgroundColor:backgroundColor
                                                                     textColor:textColor
                                                                          font:font
                                                                      diameter:diameter];

    UIImage *avatarHighlightedImage = [CCJSQMessagesAvatarImageFactory jsq_circularImage:avatarImage
                                                                          withDiameter:diameter
                                                                      highlightedColor:[UIColor colorWithWhite:0.1f alpha:0.3f]];

    return [[CCJSQMessagesAvatarImage alloc] initWithAvatarImage:avatarImage
                                              highlightedImage:avatarHighlightedImage
                                              placeholderImage:avatarImage];
}

#pragma mark - Private

+ (UIImage *)jsq_imageWitInitials:(NSString *)initials
                  backgroundColor:(UIColor *)backgroundColor
                        textColor:(UIColor *)textColor
                             font:(UIFont *)font
                         diameter:(NSUInteger)diameter
{
    NSParameterAssert(initials != nil);
    NSParameterAssert(backgroundColor != nil);
    NSParameterAssert(textColor != nil);
    NSParameterAssert(font != nil);
    NSParameterAssert(diameter > 0);

    CGRect frame = CGRectMake(0.0f, 0.0f, diameter, diameter);

    NSDictionary *attributes = @{ NSFontAttributeName : font,
                                  NSForegroundColorAttributeName : textColor };

    CGRect textFrame = [initials boundingRectWithSize:frame.size
                                              options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                           attributes:attributes
                                              context:nil];

    CGPoint frameMidPoint = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    CGPoint textFrameMidPoint = CGPointMake(CGRectGetMidX(textFrame), CGRectGetMidY(textFrame));

    CGFloat dx = frameMidPoint.x - textFrameMidPoint.x;
    CGFloat dy = frameMidPoint.y - textFrameMidPoint.y;
    CGPoint drawPoint = CGPointMake(dx, dy);
    UIImage *image = nil;

    UIGraphicsBeginImageContextWithOptions(frame.size, NO, [UIScreen mainScreen].scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
        CGContextFillRect(context, frame);
        [initials drawAtPoint:drawPoint withAttributes:attributes];

        image = UIGraphicsGetImageFromCurrentImageContext();

    }
    UIGraphicsEndImageContext();

    return [CCJSQMessagesAvatarImageFactory jsq_circularImage:image withDiameter:diameter highlightedColor:nil];
}

+ (UIImage *)jsq_circularImage:(UIImage *)image withDiameter:(NSUInteger)diameter highlightedColor:(UIColor *)highlightedColor
{
    NSParameterAssert(image != nil);
    NSParameterAssert(diameter > 0);

    CGRect frame = CGRectMake(0.0f, 0.0f, diameter, diameter);
    UIImage *newImage = nil;

    UIGraphicsBeginImageContextWithOptions(frame.size, NO, [UIScreen mainScreen].scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();

        UIBezierPath *imgPath = [UIBezierPath bezierPathWithOvalInRect:frame];
        [imgPath addClip];
        [image drawInRect:frame];

        if (highlightedColor != nil) {
            CGContextSetFillColorWithColor(context, highlightedColor.CGColor);
            CGContextFillEllipseInRect(context, frame);
        }

        newImage = UIGraphicsGetImageFromCurrentImageContext();
        
    }
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
