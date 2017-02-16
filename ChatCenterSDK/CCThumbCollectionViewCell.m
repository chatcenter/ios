//
//  CCThumbCollectionViewCell.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/04/17.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCThumbCollectionViewCell.h"

@implementation CCThumbCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.stickerContainer.layer.cornerRadius = 5.0f;
    self.stickerContainer.layer.borderWidth = 0.5f;
}

- (BOOL)setupWithIndex:(NSIndexPath *)indexPath message:(CCJSQMessage *)msg avatar:(CCJSQMessagesAvatarImage *)avatar delegate:(id<CCStickerCollectionViewCellActionProtocol>)delegate options:(CCStickerCollectionViewCellOptions)options {

    
    if(options & CCStickerCollectionViewCellOptionShowAsMyself) {
        self.stickerContainer.backgroundColor = [[CCConstants sharedInstance] baseColor];
    } else {
        self.stickerContainer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    }

    self.avatarImage.image = avatar.avatarImage;
    
    UIButton *yesButton = (UIButton*)[self.choiceContainer viewWithTag:10];
    UIButton *noButton  = (UIButton*)[self.choiceContainer viewWithTag:20];
    
    [yesButton addTarget:delegate
                  action:@selector(thumbChoicePressed:) forControlEvents:UIControlEventTouchUpInside];
    [noButton addTarget:delegate
                 action:@selector(thumbChoicePressed:) forControlEvents:UIControlEventTouchUpInside];

    return YES;
}

@end
