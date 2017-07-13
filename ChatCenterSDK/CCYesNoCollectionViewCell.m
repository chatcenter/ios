//
//  CCYesNoCollectionViewCell.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/07/09.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCYesNoCollectionViewCell.h"
#import "CCChoiceButton.h"
#import "UIImage+CCSDKImage.h"

@implementation CCYesNoCollectionViewCell

-(BOOL)setupWithIndex:(NSIndexPath*)indexPath
              message:(CCJSQMessage*)msg
               avatar:(CCJSQMessagesAvatarImage*)avatar
     textviewDelegate:(id<UITextViewDelegate>)textviewDelegate
             delegate:(id<CCStickerCollectionViewCellActionProtocol>)delegate
              options:(CCStickerCollectionViewCellOptions)options
{
    
    if(options & CCStickerCollectionViewCellOptionShowAsMyself) {
        self.stickerContainer.backgroundColor = [[CCConstants sharedInstance] baseColor];
    } else {
        self.stickerContainer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    }

    
    //
    // Clear view
    //
    for (UIView *view in [self.choiceContainer subviews]) {
        [view removeFromSuperview];
    }
    self.avatarImage.image = avatar.avatarImage;
    
    ///Insert title
    if (msg.content[@"question"][@"title"] != nil) {
        self.titleLabel.text = msg.content[@"question"][@"title"];
    }
    
    ///Insert discription
    if (msg.content[@"question"][@"description"] != nil) {
        self.discriptionView.textContainer.lineFragmentPadding = 0;
        self.discriptionView.textContainerInset = UIEdgeInsetsMake(2, 5, 2, 5);
        NSAttributedString *discriptionString = [[NSAttributedString alloc] initWithString:msg.content[@"question"][@"description"]];
        self.discriptionView.attributedText = discriptionString;
        CGRect discriptionViewFrame = [discriptionString boundingRectWithSize:CGSizeMake(190, 1800)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                      context:nil];
        discriptionViewFrame.size.width = 200;
        discriptionViewFrame.origin.y = 20;
        if (![msg.content[@"question"][@"description"] isEqualToString:@""]) {
            discriptionViewFrame.size.height = discriptionViewFrame.size.height + 10;
        }else{
            discriptionViewFrame.size.height = 0;
        }
        self.discriptionView.frame = discriptionViewFrame;
    }
    
    ///Add choice btn
    ///Yes
    CCChoiceButton *yesBtn = [CCChoiceButton buttonWithType:UIButtonTypeSystem];
    yesBtn.responseType = CC_RESPONSETYPEQUESTION;
    yesBtn.index = indexPath;
    yesBtn.answerType = [[NSNumber alloc] initWithInt:0];
    yesBtn.questionId = [msg.content[@"question"][@"id"] stringValue];
    yesBtn.frame = CGRectMake(0, 0, 100, 32);
    UIImage *yesImg = [UIImage SDKImageNamed:@"CCyes-icon.png"];
    [yesBtn setImage:yesImg forState:UIControlStateNormal];
    yesBtn.tintColor = [UIColor grayColor];
    [yesBtn addTarget:self
               action:@selector(pressChoiceBtn:)
     forControlEvents:UIControlEventTouchDown];
    ///Create corner round
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:yesBtn.bounds
                                     byRoundingCorners:(UIRectCornerBottomLeft)
                                           cornerRadii:CGSizeMake(8.0, 8.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = yesBtn.bounds;
    maskLayer.path = maskPath.CGPath;
    yesBtn.layer.mask = maskLayer;
    
    ///No
    CCChoiceButton *noBtn = [CCChoiceButton buttonWithType:UIButtonTypeSystem];
    noBtn.responseType = CC_RESPONSETYPEQUESTION;
    noBtn.frame = CGRectMake(100, 0, 100, 32);
    UIImage *noImg = [UIImage SDKImageNamed:@"CCno-icon.png"];
    [noBtn setImage:noImg forState:UIControlStateNormal];
    noBtn.tintColor = [UIColor grayColor];
    noBtn.index = indexPath;
    noBtn.answerType =  [[NSNumber alloc] initWithInt:1];
    noBtn.questionId = [msg.content[@"question"][@"id"] stringValue];
    [noBtn addTarget:delegate
              action:@selector(pressChoiceBtn:)
    forControlEvents:UIControlEventTouchDown];
    ///Create corner round
    UIBezierPath *maskPath2;
    maskPath2 = [UIBezierPath bezierPathWithRoundedRect:noBtn.bounds
                                      byRoundingCorners:(UIRectCornerBottomRight)
                                            cornerRadii:CGSizeMake(8.0, 8.0)];
    CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
    maskLayer2.frame = noBtn.bounds;
    maskLayer2.path = maskPath2.CGPath;
    noBtn.layer.mask = maskLayer2;
    [self.choiceContainer addSubview:yesBtn];
    [self.choiceContainer addSubview:noBtn];
    
    ///Changing color by recognizing answered
    if (msg.answer == nil || [msg.answer isEqual:[NSNull null]]){
        return NO;
    }
    if(msg.answer[@"answer_type"] == nil) {
        return NO;
    }
    if ([msg.answer[@"answer_type"] isEqualToNumber:[[NSNumber alloc] initWithInt:0]]) {
        yesBtn.backgroundColor = [CCConstants defaultHeaderBackgroundColor];
        yesBtn.tintColor = [UIColor whiteColor];
        noBtn.backgroundColor = [UIColor darkGrayColor];
        noBtn.tintColor = [UIColor lightGrayColor];
    }else{
        noBtn.backgroundColor = [CCConstants defaultHeaderBackgroundColor];
        noBtn.tintColor = [UIColor whiteColor];
        yesBtn.backgroundColor = [UIColor darkGrayColor];
        yesBtn.tintColor = [UIColor lightGrayColor];
    }
    
    return YES;

}


@end
