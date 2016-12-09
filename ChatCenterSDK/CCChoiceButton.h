//
//  CCChoiceButton.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/07/11.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCChoiceButton : UIButton

@property (copy, nonatomic) NSString *questionId;
@property (copy, nonatomic) NSNumber *answerType;
@property (copy, nonatomic) NSString *answerText;
@property (copy, nonatomic) NSIndexPath *index;
@property (copy, nonatomic) NSString *responseType;

@end
