//
//  CCSuggestionInputCell.h
//  ChatCenterDemo
//
//  Created by GiapNH on 2017/05/15.
//  Copyright © 2017年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCFixedPhraseInputCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

- (void)setupWithLabel:(NSString*)label;

@end
