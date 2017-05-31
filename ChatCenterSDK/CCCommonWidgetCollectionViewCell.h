//
//  CCCommonStickWidgetCollectionViewCell.h
//  ChatCenterDemo
//
//  Created by GiapNH on 4/26/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CCStickerCollectionViewCell.h"
#import "CCJSQMessage.h"
#import "CCJSQMessagesAvatarImage.h"
#import "CCQuestionComponent.h"

// Text area size calculation by NSAttributedString always underestimates the width
// and the text will be chopped at the drawing step.
// So we subtract this correction value when estimating

@interface CCCommonWidgetCollectionViewCell : CCStickerCollectionViewCell<CCQuestionComponentDelegate>
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

- (void)resetSelection;

@end
