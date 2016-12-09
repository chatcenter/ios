//
//  THContactView.h
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CCTHContactViewStyle.h"

@class CCTHContactView;
@class CCTHContactTextField;

@protocol THContactViewDelegate <NSObject>

- (void)contactViewWasSelected:(CCTHContactView *)contactView;
- (void)contactViewWasUnSelected:(CCTHContactView *)contactView;
- (void)contactViewShouldBeRemoved:(CCTHContactView *)contactView;

@end

@interface CCTHContactView : UIView <UITextViewDelegate, UITextInputTraits>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) CCTHContactTextField *textField; // used to capture keyboard touches when view is selected
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL showComma;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) id <THContactViewDelegate>delegate;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) CCTHContactViewStyle *style;
@property (nonatomic, strong) CCTHContactViewStyle *selectedStyle;

- (id)initWithName:(NSString *)name;
- (id)initWithName:(NSString *)name style:(CCTHContactViewStyle *)style selectedStyle:(CCTHContactViewStyle *)selectedStyle;
- (id)initWithName:(NSString *)name style:(CCTHContactViewStyle *)style selectedStyle:(CCTHContactViewStyle *)selectedStyle showComma:(BOOL)showComma;

- (void)select;
- (void)unSelect;
- (void)setFont:(UIFont *)font;

@end
