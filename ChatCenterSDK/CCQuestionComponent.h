//
//  CCQuestionComponent.h
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/02.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//
#import "CCConstants.h"

@protocol CCQuestionComponentDelegate <NSObject>

- (void)userDidSelectActionItems:(NSArray<NSDictionary*> *)items;

@end


@interface CCQuestionComponent : UIView

+ (instancetype)componentForStickerAction:(NSDictionary*)stickerAction delegate:(id<CCQuestionComponentDelegate>)delegate;

- (void)setupWithStickerAction:(NSDictionary*)stickerAction delegate:(id<CCQuestionComponentDelegate>)delegate;
- (void)setSelection:(NSArray*)selectedValues;

+ (CGFloat)calculateHeightForStickerAction:(NSDictionary*)stickerAction;

// Utility
- (NSArray<NSNumber*> *)getSelectedIndeces:(NSArray*)selectedValues fromAvailableAction:(NSArray*)actionData;
- (void)setDefaultStyleToLabel:(UILabel*)label;

@end

