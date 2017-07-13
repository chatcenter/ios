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
#import "ChatCenterPrivate.h"

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
    if (suggestionData.count > 0) {
        [self.noMessageLable setHidden:YES];
    } else {
        [self.noMessageLable setHidden:NO];
    }
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
        NSDictionary *message = suggestionData[row];
        NSString *label = [message objectForKey:@"action-name"];
        if (label == nil || [label isEqual:[NSNull null]] || [[label stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            label = CCLocalizedString(@"No Title");
        }
        
        NSString *contentType = CC_RESPONSETYPEMESSAGE;
        NSString *stickerType = CC_RESPONSETYPEMESSAGE;
        if (message != nil && [message valueForKey:@"content_type"] != nil) {
            contentType = [message valueForKey:@"content_type"];
            if (contentType != nil && ![contentType isEqual:[NSNull null]] && [contentType isEqualToString:CC_RESPONSETYPESTICKER]) {
                // for sticker
                NSMutableDictionary *content = [[message objectForKey:@"content"] mutableCopy];
                if(([content objectForKey:@"message"] != nil && ![[message objectForKey:@"message"] isEqual:[NSNull null]])
                   || ([content objectForKey:@"sticker-action"] != nil && ![[message objectForKey:@"sticker-action"] isEqual:[NSNull null]])
                   || ([content objectForKey:@"sticker-content"] != nil && ![[message objectForKey:@"sticker-content"] isEqual:[NSNull null]]))
                {
                    contentType = CC_RESPONSETYPESTICKER;
                }
            }
        } else if (message != nil && [message objectForKey:@"sticker"] != nil
                   && ![[message objectForKey:@"sticker"] isEqual:[NSNull null]]
                   && [[message objectForKey:@"sticker"] objectForKey:@"sticker-type"] != nil
                   && ![[[message objectForKey:@"sticker"] objectForKey:@"sticker-type"] isEqual:[NSNull null]]) {
            stickerType = [message valueForKeyPath:@"sticker.sticker-type"];
        } else if (message != nil && [message valueForKey:@"type"] != nil) {
            stickerType = [message valueForKey:@"type"];
        }
        if (message != nil && [message objectForKey:@"type"] != nil && ![[message objectForKey:@"type"] isEqual:[NSNull null]]) {
            contentType = [message objectForKey:@"type"];
        }

        [cell setupWithLabel:label contentType:contentType stickerType:stickerType];
    }

    
    return cell;

}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger row = indexPath.row;
 
    if (row >= suggestionData.count) {
        return;
    }
    NSDictionary *sticerAction = suggestionData[row];
    [_owner performOpenAction:sticerAction stickerType:CC_RESPONSETYPESUGGESTION messageId:@(0) reacted:@"false" reactedOn:nil]; // TODO: send "true" if this reaction is already selected
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return CGSizeMake(250, 60);
}

@end
