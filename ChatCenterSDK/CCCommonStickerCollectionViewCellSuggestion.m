//
//  CCCommonStickerCollectionViewCellOutgoing.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 8/20/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCCommonStickerCollectionViewCellSuggestion.h"
#import "CCConstants.h"
#import "CCStickerCollectionViewCellActionProtocol.h"

@interface CCCommonStickerCollectionViewCellSuggestion () {
    CCJSQMessage *message;
    id<CCStickerCollectionViewCellActionProtocol> delegate;
}

@end

@implementation CCCommonStickerCollectionViewCellSuggestion

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (BOOL)setupWithIndex:(NSIndexPath *)indexPath message:(CCJSQMessage *)msg avatar:(CCJSQMessagesAvatarImage *)avatar textviewDelegate:(id<UITextViewDelegate>)textviewDelegate delegate:(id<CCStickerCollectionViewCellActionProtocol>)inDelegate options:(CCStickerCollectionViewCellOptions)options {
    
    message = msg;
    delegate = inDelegate;
    
    return YES;
}


- (IBAction)buttonPressed:(id)sender {
    
    NSArray<NSDictionary*> *actionData = [[[message content] objectForKey:@"sticker-action"] objectForKey:@"action-data"];
    
    [delegate displaySuggestionWithActionData:actionData];
}


@end
