//
//  CCPhraseStickerCollectionViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 4/20/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCommonStickerCreatorDelegate.h"

#define CC_APP_FIXED_PHRASE_INDEX       2
#define CC_ORG_FIXED_PHRASE_INDEX       1
#define CC_USER_FIXED_PHRASE_INDEX      0

#define CC_COLLECTION_VIEW_LINE_SEPARATOR_TAG 1231231

@interface CCPhraseStickerCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>
{

}

@property (nullable, nonatomic, strong) NSString *orgUid;
@property (nullable, nonatomic, strong) NSString *userId;
@property (nullable, nonatomic, strong) NSString *channelId;
@property (nullable, nonatomic, strong) NSMutableArray *appFixedPhrases;
@property (nullable, nonatomic, strong) NSMutableArray *orgFixedPhrases;
@property (nullable, nonatomic, strong) NSMutableArray *userFixedPhrases;
@property (nullable, nonatomic, weak) id delegate;

@end
