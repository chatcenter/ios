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
    
    /*
    self.stickerContainer.layer.borderWidth = 0.8f;
    self.stickerContainer.backgroundColor = [UIColor whiteColor];
    
    self.stickerContainer.backgroundColor = [[CCConstants sharedInstance] baseColor];
    stickerActionsContainer.backgroundColor = [UIColor whiteColor];
    stickerActionsContainer.backgroundColor = [UIColor whiteColor];
     */
}

- (BOOL)setupWithIndex:(NSIndexPath *)indexPath message:(CCJSQMessage *)msg avatar:(CCJSQMessagesAvatarImage *)avatar delegate:(id<CCStickerCollectionViewCellActionProtocol>)inDelegate options:(CCStickerCollectionViewCellOptions)options {
    
    message = msg;
    delegate = inDelegate;
    
    return YES;
}


- (IBAction)buttonPressed:(id)sender {
    
    NSArray<NSDictionary*> *actionData = [[[message content] objectForKey:@"sticker-action"] objectForKey:@"action-data"];
    
    [delegate displaySuggestionWithActionData:actionData];
}


@end
