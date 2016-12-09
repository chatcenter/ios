//
//  CCCommonStickerCreatorDelegate.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 3/2/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#ifndef CCCommonStickerCreatorDelegate_h
#define CCCommonStickerCreatorDelegate_h

@protocol CCCommonStickerCreatorDelegate <NSObject>
@required
- (void)sendStickerWithType:(NSString *)msgType andContent:(NSDictionary *)content;
@optional

@end


#endif /* CCCommonStickerCreatorDelegate_h */
