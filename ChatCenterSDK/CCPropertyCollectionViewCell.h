//
//  CCPropertyCollectionViewCell.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2/19/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCStickerCollectionViewCell.h"
#import "CCTextView.h"

@interface CCPropertyCollectionViewCell : CCStickerCollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet CCTextView *upperTextview;
@property (weak, nonatomic) IBOutlet CCTextView *lowerTextview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upperTextviewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *depositLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *depositMoneyViewHeightConstraint;

@end
