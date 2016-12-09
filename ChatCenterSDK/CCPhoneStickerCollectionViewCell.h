//
//  CCPhoneStickerCollectionViewCell.h
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/10/27.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCCommonStickerCollectionViewCell.h"

@interface CCPhoneStickerCollectionViewCell : CCCommonStickerCollectionViewCell

- (BOOL)setupWithIndex:(NSIndexPath *)indexPath message:(CCJSQMessage *)msg avatar:(CCJSQMessagesAvatarImage *)avatar delegate:(id<CCStickerCollectionViewCellActionProtocol>)delegate options:(CCStickerCollectionViewCellOptions)options userList:(NSArray*)users;
@end
