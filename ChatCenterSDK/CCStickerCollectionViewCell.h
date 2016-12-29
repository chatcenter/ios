//
//  CCCalemdarCollectionViewCell.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/03/29.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCJSQMessagesCellTextView.h"
#import "CCJSQMessage.h"
#import "CCJSQMessagesAvatarImage.h"
#import "CCConstants.h"
#import "CCChoiceButton.h"
#import "CCStickerCollectionViewCellActionProtocol.h"
#import "CCJSQMessagesTimestampFormatter.h"


@interface CCStickerCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellTopLabel; ///Displaying date
@property (weak, nonatomic) IBOutlet UILabel *stickerTopLabel; ///Displaying sender name
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *titleView;
@property (weak, nonatomic) IBOutlet UITextView *discriptionView;
@property (weak, nonatomic) IBOutlet UIView *stickerContainer;
@property (weak, nonatomic) IBOutlet UIView *choiceContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stickerWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellTopLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stickerTopLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *discriptionViewHeight;
@property (weak, nonatomic) IBOutlet UIView *messageBubbleContainerView; ///Prevent crash when user long tap
@property (weak, nonatomic) IBOutlet CCJSQMessagesCellTextView *textView; ///Prevent crash when user long tap
@property (weak, nonatomic) IBOutlet UITextView *inforDescriptionView;
@property (strong, nonatomic) IBOutlet UILabel *stickerStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerLiveWidgetLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *liveUsersContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *liveUserContainerWidth;

-(BOOL)setupWithIndex:(NSIndexPath*)indexPath
              message:(CCJSQMessage*)msg
               avatar:(CCJSQMessagesAvatarImage*)avatar
             delegate:(id<CCStickerCollectionViewCellActionProtocol>)delegate
              options:(CCStickerCollectionViewCellOptions)options;

@end
