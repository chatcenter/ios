//
//  CCSuggestionInputCell.m
//  ChatCenterDemo
//
//  Created by GiapNH on 2017/05/15.
//  Copyright © 2017年 AppSocially Inc. All rights reserved.
//

#import "CCFixedPhraseInputCell.h"
#import "CCConstants.h"
#import "UIImage+CCSDKImage.h"

@interface CCFixedPhraseInputCell () {

}
@end

@implementation CCFixedPhraseInputCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setupWithLabel:(NSString*)label {
    
    self.textView.text = label;
    
    UIColor *bc = [[CCConstants sharedInstance] baseColor];

    UIImage *img = [UIImage SDKImageNamed:@"questionBubbleIcon"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.imageView setTintColor:bc];
    [self.imageView setImage:img];

    self.containerView.layer.borderColor = bc.CGColor;
    self.textView.textColor = bc;
}


@end
