//
//  CCSuggestionInputCell.h
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/15.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCSuggestionInputCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

- (void)setupWithLabel:(NSString*)label;

@end
