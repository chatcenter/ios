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

- (void)resetSelection;
- (void)setupQuestionComponentWithMessage:(CCJSQMessage*)msg needRecreateSubviews:(BOOL)needRecreateSubviews;
@end
