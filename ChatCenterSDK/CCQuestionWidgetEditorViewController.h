//
//  CCQuestionWidgetEditorViewController.h
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/09.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCommonWidgetEditorViewController.h"

@protocol CCQuestionEditorScrollViewDelegate<NSObject>
-(void)setScrollviewContentHeight: (float) height;
-(void)setViewMovedUp:(CGFloat)movedAmount viewToShow:(UIView*)view;
-(void)bringViewToVisibleArea:(UIView*)view;
@end

@interface CCQuestionWidgetEditorViewController : CCCommonWidgetEditorViewController<UIGestureRecognizerDelegate, CCQuestionEditorScrollViewDelegate, UITextFieldDelegate> {
    
    IBOutlet UIView *containerView;
    IBOutlet UIScrollView *scrollView;
    IBOutlet NSLayoutConstraint *scrollViewHeightConstraint;
    
    __weak IBOutlet UITextView *questionContent;
    __weak IBOutlet UIView *typeAnswerSelectorView;
    __weak IBOutlet UIImageView *typeAnswerIcon;
    __weak IBOutlet UILabel *typeAnswerLabel;
}
@end
