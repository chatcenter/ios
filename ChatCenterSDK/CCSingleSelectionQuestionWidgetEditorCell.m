//
//  CCSingleSelectionQuestionWidgetEditorCell.m
//  ChatCenterDemo
//
//  Created by VietHD on 11/11/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCSingleSelectionQuestionWidgetEditorCell.h"

@implementation CCSingleSelectionQuestionWidgetEditorCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)delete:(id)sender {
    [self.delegate deleteCell:_index];
}

@end
