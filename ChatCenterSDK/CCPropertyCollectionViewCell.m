//
//  CCPropertyCollectionViewCell.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2/19/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCPropertyCollectionViewCell.h"

@implementation CCPropertyCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.stickerContainer.layer.borderWidth = 0.0f;
}

- (BOOL)setupWithIndex:(NSIndexPath *)indexPath message:(CCJSQMessage *)msg avatar:(CCJSQMessagesAvatarImage *)avatar textviewDelegate:(id<UITextViewDelegate>)textviewDelegate delegate:(id<UITextViewDelegate>)delegate options:(CCStickerCollectionViewCellOptions)options {

    
    // title
    self.stickerTopLabel.attributedText = [msg.content objectForKey:@"attributedTitle"];
    
    // image
    self.image.image = nil;
    if([msg.content objectForKey:@"image"] != nil && [msg.content objectForKey:@"image"] != [NSNull null]) {
        NSURL *url = [NSURL URLWithString:[msg.content objectForKey:@"image"]];
        if(url != nil) {
            self.image.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        }
    }
    
    // remove corner radius
    [self.stickerContainer.layer setCornerRadius:0];
    
    // description
    const int STICKER_CONTAINER_MARGIN = 10;
    const int STICKER_CONTAINER_PADDING_LEFT_RIGHT = 10;
    const int STICKER_IMAGE_WIDTH = 100;
    const int TV_PADDING = 20;
    const int ContainerInsetLeftRightMargin = 10;
    CGRect screenRect = [UIScreen mainScreen].bounds;
    float width = screenRect.size.width - STICKER_IMAGE_WIDTH - STICKER_CONTAINER_MARGIN * 2 - STICKER_CONTAINER_PADDING_LEFT_RIGHT * 2 - ContainerInsetLeftRightMargin;
    
    NSAttributedString *upperAS = [msg.content objectForKey:@"upperContent"];
    CGRect upperTVFrame = [upperAS boundingRectWithSize:CGSizeMake(width, 1800)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                context:nil];
    
    self.upperTextviewHeightConstraint.constant = upperTVFrame.size.height + TV_PADDING;
    self.upperTextview.attributedText = upperAS;
    self.upperTextview.delegate = delegate;
    
    if (([msg.content objectForKey:@"kDeposit"] == nil || [[msg.content objectForKey:@"kDeposit"] isEqualToString:@""])&& ([msg.content objectForKey:@"kMoney"] == nil || [[msg.content objectForKey:@"kMoney"] isEqualToString:@""])) {
        self.depositMoneyViewHeightConstraint.constant = 4;
        [self.depositLabel setText:@""];
        [self.moneyLabel setText:@""];
    }else {
        self.depositMoneyViewHeightConstraint.constant = 26;
        [self.depositLabel setText:[msg.content objectForKey:@"kDeposit"]];
        [self.moneyLabel setText:[msg.content objectForKey:@"kMoney"]];
    }
    
    self.lowerTextview.attributedText = [msg.content objectForKey:@"lowerContent"];
    
    ///Display date
    if (options & CCStickerCollectionViewCellOptionShowDate) {
        self.cellTopLabelHeight.constant = 20;
        self.cellTopLabel.attributedText = [[CCJSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:msg.date];
    }else{
        self.cellTopLabelHeight.constant = 0;
    }

    return YES;
}

@end
