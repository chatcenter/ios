//
//  CCCommonStickerCreatorDelegate.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 3/2/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

@protocol CCCommonWidgetEditorDelegate <NSObject>
- (NSString*)generateMessageUniqueId;
- (void)sendWidgetWithType:(NSString *)msgType andContent:(NSDictionary *)content;
@end
