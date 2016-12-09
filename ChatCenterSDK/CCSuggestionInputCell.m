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
