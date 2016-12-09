//
//  UIImage+CCSDKImage.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/12/08.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "UIImage+CCSDKImage.h"
#import "CCConstants.h"

@implementation UIImage (CCSDKImage)

+ (UIImage*)SDKImageNamed:(NSString*)name {

    UIImage *img = [UIImage imageNamed:name inBundle:SDK_BUNDLE compatibleWithTraitCollection:nil];

    return img;
}

@end
