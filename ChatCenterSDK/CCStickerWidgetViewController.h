//
//  CCStickerWidgetViewController.h
//  ChatCenterDemo
//
//  Created by GiapNH on 4/18/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCStickerWidgetViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nullable, nonatomic, strong) NSString *channelId;
@property (nullable, nonatomic, strong) NSString *uid;
@property (nullable, nonatomic, strong) NSString *stickerType;
@property (nullable, nonatomic, strong) NSString *titleNavigation;
@property (nullable, nonatomic, strong) NSMutableArray *messages;

@property (weak, nonatomic) IBOutlet UICollectionView * _Nullable collectionView;
@property (strong, nonatomic) IBOutlet UITextView * _Nullable noDataMessage;

@end
