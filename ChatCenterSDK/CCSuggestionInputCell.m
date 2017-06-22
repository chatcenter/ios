//
//  CCSuggestionInputCell.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/15.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCSuggestionInputCell.h"
#import "CCConstants.h"
#import "UIImage+CCSDKImage.h"

@interface CCSuggestionInputCell () {

}
@end

@implementation CCSuggestionInputCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.textContainer.lineFragmentPadding = 0;
}

- (void)setupWithLabel:(NSString*)label contentType:(NSString *)contentType stickerType:(NSString *)stickerType; {
    
    self.textView.text = label;
    
    UIColor *bc = [[CCConstants sharedInstance] baseColor];
    if (![contentType isEqualToString:CC_RESPONSETYPEMESSAGE]) {
        NSString *imageName = @"questionBubbleIcon";
        if ([stickerType isEqualToString:CC_RESPONSETYPELOCATION]) {
            imageName = @"CCmenu_icon_location";
        } else if ([stickerType isEqualToString:@"file"]) {
            imageName = @"CCmenu_icon_image";
        }
        UIImage *img = [UIImage SDKImageNamed:imageName];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.imageView setHidden:NO];
        self.iconWidthConstraint.constant = 45;
        [self.imageView setTintColor:bc];
        [self.imageView setImage:img];
    } else {
        // Hide image
        [self.imageView setHidden:YES];
        self.iconWidthConstraint.constant = 5;
    }

    self.containerView.layer.borderColor = bc.CGColor;
    self.textView.textColor = bc;
    [self estimateHeightTextView];
}

- (void) estimateHeightTextView {
    NSString *dynamicString = self.textView.text;
    NSDictionary *attr = @{NSFontAttributeName: self.textView.font};
    CGRect textRect = [dynamicString boundingRectWithSize:CGSizeMake(self.textView.frame.size.width,80)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attr
                                                  context:nil];
    self.constraintTextViewHeight.constant = textRect.size.height;
}

@end
