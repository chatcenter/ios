//
//  CCCalemdarCollectionViewCell.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/03/29.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCStickerCollectionViewCell.h"

@interface CCStickerCollectionViewCell()


@end

@implementation CCStickerCollectionViewCell

-(BOOL)setupWithIndex:(NSIndexPath*)indexPath
              message:(CCJSQMessage*)msg
               avatar:(CCJSQMessagesAvatarImage*)avatar
     textviewDelegate:(id<UITextViewDelegate>)textviewDelegate
             delegate:(id<CCStickerCollectionViewCellActionProtocol>)delegate
              options:(CCStickerCollectionViewCellOptions)options
{
    // Should be overridden by subclasses
    
    return YES;
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.stickerContainer.layer.borderWidth = 0.5f;
    self.stickerContainer.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.stickerContainer.layer.cornerRadius = 8.0f;
    
    UILongPressGestureRecognizer *longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(detectedLongTapGesture:)];
    [self.contentView addGestureRecognizer:longTapGestureRecognizer];
    [self.selectedBackgroundView addGestureRecognizer:longTapGestureRecognizer];
    [self.backgroundView addGestureRecognizer:longTapGestureRecognizer];
    
}

- (void)detectedTapGesture:(UITapGestureRecognizer *)sender {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGPoint point = [sender locationOfTouch:0 inView:window];
    NSLog(@"tap point: %@", NSStringFromCGPoint(point));
}

- (void)detectedLongTapGesture:(UILongPressGestureRecognizer *)sender {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGPoint point = [sender locationOfTouch:0 inView:window];
    NSLog(@"long tap point: %@", NSStringFromCGPoint(point));
}

@end
