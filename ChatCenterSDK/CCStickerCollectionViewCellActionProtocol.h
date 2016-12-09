//
//  CCStickerCollectionViewCellActionProtocol.h
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/10/26.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#ifndef CCStickerCollectionViewCellActionProtocol_h
#define CCStickerCollectionViewCellActionProtocol_h

@class CCChoiceButton;

@protocol CCStickerCollectionViewCellActionProtocol <NSObject>

- (void)pressChoiceBtn:(CCChoiceButton*)btn;
- (void)pressPdfLinkBtn:(CCChoiceButton*)btn;
- (void)pressCalendarChoiceBtn:(CCChoiceButton*)btn;
- (void)thumbChoicePressed:(UIButton*)button;
- (void)calendarChoicePressed:(UIButton*)button;
- (void)displaySuggestionWithActionData:(NSArray<NSDictionary*> *)actionData;

- (NSString*)getStatusForMessage:(CCJSQMessage*)message;

@end



#endif /* CCStickerCollectionViewCellActionProtocol_h */
