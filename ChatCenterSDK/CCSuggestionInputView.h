//
//  CCSuggestionInputView.h
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/14.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCChatViewController;

@interface CCSuggestionInputView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (void)setupWithData:(NSArray<NSDictionary *> *)data owner:(CCChatViewController *)owner;

@end
