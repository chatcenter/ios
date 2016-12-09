//
//  UIView+Border.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 3/2/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "UIView+Border.h"

@implementation UIView (Border)

@dynamic borderColor,borderWidth,cornerRadius;

- (void)setBorderColor:(UIColor *)borderColor {
    [self.layer setBorderColor:borderColor.CGColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    [self.layer setBorderWidth:borderWidth];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    [self.layer setCornerRadius:cornerRadius];
}

@end
