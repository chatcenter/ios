//
//  CCChannelViewerCollectionViewCell.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 7/4/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCCopyrightViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentHeight;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UITextView *content;
@end
