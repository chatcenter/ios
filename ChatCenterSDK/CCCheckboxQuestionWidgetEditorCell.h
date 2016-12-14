//
//  CCCheckboxQuestionWidgetEditorCell.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 11/11/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCQuestionEditorCellDelegate.h"

@interface CCCheckboxQuestionWidgetEditorCell : UITableViewCell
@property NSInteger index;
@property (strong, nonatomic) IBOutlet UITextField *textView;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) id<CCQuestionEditorCellDelegate> delegate;
@end
