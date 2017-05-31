//
//  CCFixedPhraseInputView.h
//  ChatCenterDemo
//
//  Created by GiapNH on 2017/05/15.
//  Copyright © 2017年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCChatViewController;

@interface CCFixedPhraseInputView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (void)setupWithData:(NSArray<NSDictionary *> *)data owner:(CCChatViewController *)owner;

@end
