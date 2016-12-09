//
//  CCHistoryFilterViewItemCell.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2016/04/19.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCHistoryFilterViewItemCell.h"

#import "ChatCenterPrivate.h"
#import "UIImage+CCSDKImage.h"

@interface CCHistoryFilterViewItemCell() {
@private
    
    // Check ImageView.
    __weak IBOutlet UIImageView *_checkImageView;
    // Item Label.
    __weak IBOutlet UILabel *_itemLabel;
    // Count Label.
    __weak IBOutlet UILabel *_countLabel;
    
    BOOL _isChecked;
}
@end

@implementation CCHistoryFilterViewItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

/**
 *  Setup cell.
 *
 *  @param itemTitle
 *  @param count
 *  @param isChecked
 */
- (void)setupWithItemTitle:(NSString *)itemTitle count:(NSString *)count isChecked:(BOOL)isChecked {
    _itemLabel.text = CCLocalizedString(itemTitle);
    _countLabel.text = count;
    [self setChecked:isChecked];
}

/**
 *  Selected cell.
 *
 *  @param checked
 */
- (void)setChecked:(BOOL)checked {
    _isChecked = checked;
    if (_isChecked) {
        _checkImageView.image = [UIImage SDKImageNamed:@"checked"];
        _itemLabel.textColor = [UIColor colorWithRed:75.0/255.0 green:193.0/255.0 blue:219.0/255.0 alpha:1.0];
        _itemLabel.font = [UIFont boldSystemFontOfSize:14];
    } else {
        _checkImageView.image = nil;
        _itemLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        _itemLabel.font = [UIFont systemFontOfSize:14];
    }
}

@end
