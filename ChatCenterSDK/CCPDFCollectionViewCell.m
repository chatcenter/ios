//
//  CCPDFCollectionViewCell.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/07/28.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCPDFCollectionViewCell.h"
#import "ChatCenterPrivate.h"

@implementation CCPDFCollectionViewCell


-(BOOL)setupWithIndex:(NSIndexPath*)indexPath
              message:(CCJSQMessage*)msg
               avatar:(CCJSQMessagesAvatarImage*)avatar
     textviewDelegate:(id<UITextViewDelegate>)textviewDelegate
             delegate:(id<CCStickerCollectionViewCellActionProtocol>)delegate
              options:(CCStickerCollectionViewCellOptions)options
{

    // Initialization code
    
    if(options & CCStickerCollectionViewCellOptionShowAsMyself) {
        self.stickerContainer.backgroundColor = [[CCConstants sharedInstance] baseColor];
    } else {
        self.stickerContainer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    }

    
    for (UIView *view in [self.stickerContainer subviews]) {
        if ([view isKindOfClass:[CCChoiceButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    self.avatarImage.image = avatar.avatarImage;

    
    if (msg.content[@"text"] != nil && msg.content[@"pdfUrl"] != nil) {
        self.discriptionView.textContainer.lineFragmentPadding = 0;
        self.discriptionView.textContainerInset = UIEdgeInsetsMake(10, 5, 5, 5);
        NSString *string = msg.content[@"text"];
        NSMutableAttributedString *discriptionString = [[NSMutableAttributedString alloc] initWithString:string];
        NSRange link = [string rangeOfString:string];
        [discriptionString addAttributes:@{@"NSLink":msg.content[@"pdfUrl"]} range:link];
        [discriptionString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:link];
        [discriptionString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:link];
        [discriptionString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:link];
        self.discriptionView.attributedText = discriptionString;
        CGRect discriptionViewFrame = [discriptionString boundingRectWithSize:CGSizeMake(163, 1800)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                      context:nil];
        self.stickerWidthConstraint.constant = discriptionViewFrame.size.width + 43;
        discriptionViewFrame.size.width = discriptionViewFrame.size.width + 10; ///10 prevents UICollectionView's bug
        discriptionViewFrame.size.height = discriptionViewFrame.size.height + 20;
        discriptionViewFrame.origin.y = 0;
        discriptionViewFrame.origin.x = 27;
        self.discriptionView.frame = discriptionViewFrame;
        
        ///Add link button
        CCChoiceButton *pdfLinkBtn = [CCChoiceButton buttonWithType:UIButtonTypeSystem];
        pdfLinkBtn.responseType = CC_RESPONSETYPEPDF;
        pdfLinkBtn.questionId = msg.content[@"pdfUrl"];
        pdfLinkBtn.frame = CGRectMake(0, 0, discriptionViewFrame.size.width+34, discriptionViewFrame.size.height);
        [pdfLinkBtn addTarget:delegate
                       action:@selector(pressPdfLinkBtn:)
             forControlEvents:UIControlEventTouchUpInside];
        pdfLinkBtn.layer.cornerRadius = 14.0f;
        [self.stickerContainer addSubview:pdfLinkBtn];
    }
    
    ///Display name
    if (options & CCStickerCollectionViewCellOptionShowName) {
        self.stickerTopLabelHeight.constant = 20;
        self.stickerTopLabel.text = msg.senderDisplayName;
    }else{
        self.stickerTopLabelHeight.constant = 0;
    }
    ///Display date
    if (options & CCStickerCollectionViewCellOptionShowDate) {
        self.cellTopLabelHeight.constant = 20;
        self.cellTopLabel.attributedText = [[CCJSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:msg.date];
    }else{
        self.cellTopLabelHeight.constant = 0;
    }
    ///display status
    if(options & CCStickerCollectionViewCellOptionShowStatus) {
        self.stickerStatusLabel.text = [delegate getStatusForMessage:msg];
        // notification when "delivering" pdf sticker
        if([self.stickerStatusLabel.text isEqualToString:CCLocalizedString(@"Delivering")]) {
            self.userInteractionEnabled = NO;
        } else {
            self.userInteractionEnabled = YES;
        }
    } else {
        self.stickerStatusLabel.text = @"";
    }
    
    return YES;

}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.stickerContainer.layer.borderWidth = 0.8f;
    self.stickerContainer.backgroundColor = [UIColor whiteColor];
    self.stickerContainer.layer.cornerRadius = 14.0f;
}

@end
