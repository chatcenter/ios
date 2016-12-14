//
//  CCYesNoQuestionWidgetEditorCell.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 11/9/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCYesNoQuestionWidgetEditorCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *checkmarkIcon;
@property (strong, nonatomic) IBOutlet UILabel *yesLabel;
@property (strong, nonatomic) IBOutlet UILabel *noLabel;
@end
