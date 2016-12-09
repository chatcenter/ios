//
//  CCInformationCollectionViewCell.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 1/23/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCInformationCollectionViewCell.h"
#import "ChatCenterPrivate.h"

@implementation CCInformationCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.stickerContainer.layer.borderWidth = 0.0f;
}

- (BOOL)setupWithIndex:(NSIndexPath *)indexPath message:(CCJSQMessage *)msg avatar:(CCJSQMessagesAvatarImage *)avatar delegate:(id<CCStickerCollectionViewCellActionProtocol>)delegate options:(CCStickerCollectionViewCellOptions)options {


    self.stickerContainer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
/*
    if(options & CCStickerCollectionViewCellOptionShowAsMyself) {
        self.stickerContainer.backgroundColor = [[CCConstants sharedInstance] baseColor];
    } else {
        self.stickerContainer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    }
  */  

    
    self.discriptionView.textContainer.lineFragmentPadding = 0;
    self.discriptionView.textContainerInset = UIEdgeInsetsMake(10, 5, 5, 5);
    NSString *titleStr = CCLocalizedString(@"Inquired information");
    
    if (msg.content[@"attributedText"] != nil) {
        self.inforDescriptionView.attributedText = msg.content[@"attributedText"];
        self.stickerTopLabel.text = titleStr;
        
        // show 1 date per 3 items
        if (options & CCStickerCollectionViewCellOptionShowDate) {
            self.cellTopLabelHeight.constant = 20;
            self.cellTopLabel.attributedText = [[CCJSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:msg.date];
        } else {
            self.cellTopLabelHeight.constant = 0;
        }
    }

    return YES;
}

@end
