//
//  CCCommonStickerPreviewCollectionViewCell.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2/29/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCCommonStickerPreviewCollectionViewCell.h"

@implementation CCCommonStickerPreviewCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.stickerContainer.layer.borderWidth = 1.0f;
    self.stickerContainer.layer.borderColor = [[[CCConstants sharedInstance] baseColor] CGColor];
}

- (void) onActionClicked:(UIButton*)sender {
    // do nothing
}

+ (CGSize) estimateSizeForMessage:(CCJSQMessage *)msg atIndexPath:(NSIndexPath *)indexPath hasPreviousMessage:(CCJSQMessage *)preMsg withListUser:(NSArray *)users{
    CGSize tmpSize = [CCCommonStickerCollectionViewCell estimateSizeForMessage:msg atIndexPath:indexPath hasPreviousMessage:preMsg options:0 withListUser:users];
    return CGSizeMake(tmpSize.width, tmpSize.height - CC_STICKER_SENDER_NAME_HEIGHT + 20); // no sender name but have 20 for padding top and bottom
}

@end
