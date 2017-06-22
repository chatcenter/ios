//
//  CCFixedPhraseInputView.m
//  ChatCenterDemo
//
//  Created by GiapNH on 2017/05/15.
//  Copyright © 2017年 AppSocially Inc. All rights reserved.
//

#import "CCFixedPhraseInputView.h"
#import "CCFixedPhraseInputCell.h"
#import "CCChatViewController.h"
#import "CCCommonWidgetPreviewViewController.h"
#import "CCConstants.h"
#import "ChatCenterPrivate.h"

@interface CCFixedPhraseInputView () {
    NSArray<NSDictionary*> *fixedPhraseData;
}
@property (nonatomic,weak) CCChatViewController *owner;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation CCFixedPhraseInputView


- (void)setupWithData:(NSArray<NSDictionary *> *)data owner:(CCChatViewController *)owner {
    fixedPhraseData = data;
    _owner = owner;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"CCFixedPhraseInputCell" bundle:SDK_BUNDLE] forCellWithReuseIdentifier:@"cell"];
    
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!fixedPhraseData) {
        return 0;
    }
    return fixedPhraseData.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    
    CCFixedPhraseInputCell *cell = (CCFixedPhraseInputCell*)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if (row < fixedPhraseData.count) {
        NSLog(@"fixed phrase = %@", fixedPhraseData[row]);
        NSDictionary *message = fixedPhraseData[row];
        NSString *text ;
        if (message != nil && [message objectForKey:@"description"] != nil && ![[message objectForKey:@"description"] isEqual:[NSNull null]]) {
            text = [message objectForKey:@"description"];
        }
        if (text == nil || [text isEqual:[NSNull null]] || [[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
            text = CCLocalizedString(@"No Title");
        }
        NSString *contentType = CC_RESPONSETYPEMESSAGE;
        NSString *stickerType = CC_RESPONSETYPEMESSAGE;
        if (message != nil && [message valueForKey:@"content_type"] != nil) {
            contentType = [message valueForKey:@"content_type"];
            if (contentType != nil && ![contentType isEqual:[NSNull null]] && [contentType isEqualToString:CC_RESPONSETYPESTICKER]) {
                // for sticker
                NSMutableDictionary *content = [[message objectForKey:@"content"] mutableCopy];
                NSString *stickerTypeMsg = [content objectForKey:@"sticker-type"];
                if (stickerTypeMsg != nil && ![stickerType isEqual: [NSNull null]] &&
                    ([stickerTypeMsg isEqualToString:@"file"] || [stickerTypeMsg isEqualToString:@"location"]) ) {
                    stickerType = stickerTypeMsg;
                }
                if(([content objectForKey:@"message"] != nil && ![[message objectForKey:@"message"] isEqual:[NSNull null]])
                   || ([content objectForKey:@"sticker-action"] != nil && ![[message objectForKey:@"sticker-action"] isEqual:[NSNull null]])
                   || ([content objectForKey:@"sticker-content"] != nil && ![[message objectForKey:@"sticker-content"] isEqual:[NSNull null]]))
                {
                    contentType = CC_RESPONSETYPESTICKER;
                }
            }
        }
        [cell setupWithLabel:text contentType:contentType stickerType:stickerType];
    }

    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger row = indexPath.row;
 
    if (row >= fixedPhraseData.count) {
        return;
    }
    
    CCJSQMessage *msg = [self createMessage:fixedPhraseData[row]];
    CCCommonWidgetPreviewViewController *vc = [[CCCommonWidgetPreviewViewController alloc] initWithNibName:@"CCCommonWidgetPreviewViewController" bundle:SDK_BUNDLE];
    [vc setDelegate:self.owner];
    [vc setMessage:msg];
    
    UINavigationController *rootNC = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.owner presentViewController:rootNC animated:YES completion:^{
        self.owner.isReturnFromStickerView = YES;
    }];
}

- (CCJSQMessage *) createMessage: (NSDictionary *)message {
    NSString *contentType = [message objectForKey:@"content_type"];
    
    // create content
    CCJSQMessage *msg = nil;
    
    if (contentType != nil && ![contentType isEqual:[NSNull null]] && [contentType isEqualToString:CC_RESPONSETYPESTICKER]) {
        // for sticker
        NSMutableDictionary *content = [[message objectForKey:@"content"] mutableCopy];
        if(([content objectForKey:@"message"] != nil && ![[message objectForKey:@"message"] isEqual:[NSNull null]])
           || ([content objectForKey:@"sticker-action"] != nil && ![[message objectForKey:@"sticker-action"] isEqual:[NSNull null]])
           || ([content objectForKey:@"sticker-content"] != nil && ![[message objectForKey:@"sticker-content"] isEqual:[NSNull null]]))
        {
            [content setObject:[self generateMessageUniqueId] forKey:@"uid"];
            
            msg = [[CCJSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:@""];
            msg.content = [content copy];
            msg.type = CC_RESPONSETYPESTICKER;
        }
    } else {
        // for text message
        NSMutableDictionary *content = [NSMutableDictionary dictionary];
        [content setObject:[message objectForKey:@"content"] forKey:@"text"];
        [content setObject:[self generateMessageUniqueId] forKey:@"uid"];
        
        msg = [[CCJSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:[message objectForKey:@"content"]];
        msg.content = [content copy];
        msg.type = CC_RESPONSETYPEMESSAGE;
    }
    
    return msg;
}

- (NSString *)generateMessageUniqueId {
    NSString *generatedUniqueId = [NSString stringWithFormat:@"%@-%@-%f", _owner.channelId, _owner.uid, (double)([[NSDate date] timeIntervalSince1970] * 1000)];
    return generatedUniqueId;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return CGSizeMake(250, 60);
}



@end
