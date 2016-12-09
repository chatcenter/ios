//
//  CCSuggestionInputView.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/14.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCSuggestionInputView.h"
#import "CCSuggestionInputCell.h"
#import "CCChatViewController.h"
#import "CCConstants.h"

@interface CCSuggestionInputView () {
    NSArray<NSDictionary*> *suggestionData;
}
@property (nonatomic,weak) CCChatViewController *owner;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation CCSuggestionInputView


- (void)setupWithData:(NSArray<NSDictionary *> *)data owner:(CCChatViewController *)owner {
    suggestionData = data;
    _owner = owner;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"CCSuggestionInputCell" bundle:SDK_BUNDLE] forCellWithReuseIdentifier:@"cell"];
    
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!suggestionData) {
        return 0;
    }
    return suggestionData.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    
    CCSuggestionInputCell *cell = (CCSuggestionInputCell*)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if (row < suggestionData.count) {
        NSString *label = [suggestionData[row] objectForKey:@"label"];
        [cell setupWithLabel:label];
    }

    
    return cell;

}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger row = indexPath.row;
 
    if (row >= suggestionData.count) {
        return;
    }
    NSDictionary *sticerAction = suggestionData[row];
    [_owner performOpenAction:sticerAction stickerType:CC_RESPONSETYPESUGGESTION messageId:@(0) reacted:@"false"]; // TODO: send "true" if this reaction is already selected
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return CGSizeMake(250, self.bounds.size.height);
}



@end
