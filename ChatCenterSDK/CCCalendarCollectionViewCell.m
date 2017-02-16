//
//  CCCalemdarCollectionViewCellOutgoing.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/04/07.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCCalendarCollectionViewCell.h"

@implementation CCCalendarCollectionViewCell

#pragma mark - Overrides

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //
    // The settings of cornerRadius and borderWidth are moved into .xib file
    // (See "custom class" section in the inspector)
    //
}

- (BOOL)setupWithIndex:(NSIndexPath *)indexPath message:(CCJSQMessage *)msg avatar:(CCJSQMessagesAvatarImage *)avatar delegate:(id<CCStickerCollectionViewCellActionProtocol>)delegate options:(CCStickerCollectionViewCellOptions)options {

    
    if(options & CCStickerCollectionViewCellOptionShowAsMyself) {
        self.stickerContainer.backgroundColor = [[CCConstants sharedInstance] baseColor];
    } else {
        self.stickerContainer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    }

    
    
    NSArray *choices = msg.content[CC_RESPONSETYPEDATETIMEAVAILABILITY];

    for (UIView *view in [self.choiceContainer subviews]) {
        [view removeFromSuperview];
    }
    self.avatarImage.image = avatar.avatarImage;

    for (int i=0; i < choices.count; i++) {
        UIButton *choice = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        CGFloat y = 38*i;
        choice.frame = CGRectMake(0, y, self.choiceContainer.bounds.size.width, 28);
        [choice setTitle:msg.content[CC_RESPONSETYPEDATETIMEAVAILABILITY][i] forState:UIControlStateNormal];
        [choice setTintColor:[UIColor whiteColor]];
        [choice setBackgroundColor:[UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0]];
        [choice addTarget:delegate
                   action:@selector(calendarChoicePressed:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.choiceContainer addSubview:choice];
    }
    
    return  YES;

}

@end
