//
//  CCBaseQuestionWidgetPaneViewController.h
//  ChatCenterDemo
//
//  Created by VietHD on 11/17/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCQuestionWidgetEditorViewController.h"

@interface CCBaseQuestionWidgetPaneViewController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) id<CCQuestionEditorScrollViewDelegate> scrollViewDelegate;
#define SCROLLVIEW_MIN_HEIGHT   450
@end
