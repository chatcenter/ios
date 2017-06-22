//
//  CCSuggestionInputView.h
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/14.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCLabel.h"

@class CCChatViewController;

@interface CCSuggestionInputView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet CCLabel *noMessageLable;

- (void)setupWithData:(NSArray<NSDictionary *> *)data owner:(CCChatViewController *)owner;

@end
