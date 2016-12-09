//
//  CCCommonStickerCollectionViewCell.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2/25/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCStickerCollectionViewCell.h"
#import "CCJSQMessage.h"
#import "CCJSQMessagesAvatarImage.h"
#import "CCQuestionComponent.h"

#define CC_STICKER_DATE_HEIGHT              20
#define CC_STICKER_SENDER_NAME_HEIGHT       20
#define CC_STICKER_ACTION_BUTTON_MIN_HEIGHT 30
#define CC_STICKER_BUBBLE_WIDTH             240

@interface CCCommonStickerCollectionViewCell : CCStickerCollectionViewCell<CCQuestionComponentDelegate>
{
    CCJSQMessage *_msg;
    
    IBOutlet UIView *stickerObjectContainer;
    IBOutlet UIView *stickerActionsContainer;
    IBOutlet NSLayoutConstraint *stickerObjectContainerHeight;
    IBOutlet NSLayoutConstraint *stickerActionsContainerHeight;
    IBOutlet NSLayoutConstraint *stickerContainerWidth;
}


+ (CGSize) estimateSizeForMessage:(CCJSQMessage *)msg
                      atIndexPath:(NSIndexPath *)indexPath
               hasPreviousMessage:(CCJSQMessage *)preMsg
                          options:(CCStickerCollectionViewCellOptions)options
                     withListUser:(NSArray *)users ;


- (NSAttributedString*)createMessageString:(CCJSQMessage*)msg;

@end
