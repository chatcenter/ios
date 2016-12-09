//
//  THContactTextField.h
//  ContactPicker
//
//  Created by mysteriouss on 14-5-13.
//  Copyright (c) 2014 mysteriouss. All rights reserved.
//

@class CCTHContactTextField;

@protocol THContactTextFieldDelegate<UITextFieldDelegate>

@optional
- (void)textFieldDidChange:(CCTHContactTextField *)textField;
- (void)textFieldDidHitBackspaceWithEmptyText:(CCTHContactTextField *)textField;

@end

@interface CCTHContactTextField : UITextField

@property (nonatomic, assign) id <THContactTextFieldDelegate>delegate;

@end
