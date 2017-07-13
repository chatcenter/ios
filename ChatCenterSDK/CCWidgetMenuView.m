//
//  CCWidgetMenuView.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/14.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCWidgetMenuView.h"
#import "CCConstants.h"
#import "ChatCenterPrivate.h"
#import "CCChatViewController.h"
#import "UIImage+CCSDKImage.h"

@implementation CCWidgetMenuView

- (instancetype)initWithFrame:(CGRect)frame owner:(CCChatViewController*)owner {
    if(self =[super initWithFrame:frame]) {
        self.shouldShowSuggestion = [CCConstants sharedInstance].isAgent;
        self.buttons = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];
        
        NSMutableArray *stickers = [[CCConstants sharedInstance].stickers mutableCopy];
        NSLog(@"stickers = %@", stickers);
        for (int i = 0;i < stickers.count; i++) {
            if ([stickers[i] isEqualToString:CC_STICKERTYPEFILE]) {
                [stickers insertObject: CC_STICKERTYPECAMERA atIndex:i + 1]; // user can upload file from library and camera
            }
        }
        
        ///Remove unexpected sticker
        for (int i = 0;i < stickers.count; i++) {
            if (![stickers[i] isEqualToString:CC_STICKERTYPEDATETIMEAVAILABILITY]
                && ![stickers[i] isEqualToString:CC_STICKERTYPELOCATION]
                && ![stickers[i] isEqualToString:CC_STICKERTYPETHUMB]
                && ![stickers[i] isEqualToString:CC_STICKERTYPEFILE]
                && ![stickers[i] isEqualToString:CC_STICKERTYPECAMERA]
                && ![stickers[i] isEqualToString:CC_STICKERTYPEFIXEDPHRASE]
                && ![stickers[i] isEqualToString:CC_STICKERTYPEVIDEOCHAT]
                && ![stickers[i] isEqualToString:CC_STICKERTYPEVOICECHAT]
                && ![stickers[i] isEqualToString:CC_STICKERTYPESPAYMENT]
                && ![stickers[i] isEqualToString:CC_STICKERLANDINGPAGE]
                && ![stickers[i] isEqualToString:CC_STICKERCONFIRM]){
                [stickers removeObject:stickers[i]];
                continue;
            }
        }
        
        ///
        /// Remove video chat sticker
        ///
        for (int i = 0; i < stickers.count; i++) {
            if([stickers[i] isEqualToString:CC_STICKERTYPEVIDEOCHAT]) {
                [stickers removeObject:stickers[i]];
                break;
            }
        }
        ///
        /// Remove voice chat sticker
        ///
        for (int i = 0; i < stickers.count; i++) {
            if([stickers[i] isEqualToString:CC_STICKERTYPEVOICECHAT]) {
                [stickers removeObject:stickers[i]];
                break;
            }
        }
        
        ///
        /// Remove location sticker if google api key is not set
        ///
        for (int i = 0; i < stickers.count; i++) {
            if([stickers[i] isEqualToString:CC_STICKERTYPELOCATION]) {
                if ([CCConstants sharedInstance].googleApiKey == nil) {
                    [stickers removeObject:stickers[i]];
                    break;
                }
            }
        }        
        
        float stickerButtonWidth = 50.0;
        float stickerButtonHeight = 44.0;

        //
        // Add scroll view
        //
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
        if (self.shouldShowSuggestion) {
            scrollView.contentSize = CGSizeMake((stickers.count + 2) * stickerButtonWidth, stickerButtonHeight);
        } else {
            scrollView.contentSize = CGSizeMake((stickers.count + 1) * stickerButtonWidth, stickerButtonHeight);
        }
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:scrollView];
        
        ///
        /// Add text mode button
        ///
        UIButton *textModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect textModeButtonFrame = CGRectMake(0, 0, stickerButtonWidth, stickerButtonHeight);
        textModeButton.frame = textModeButtonFrame;
        textModeButton.opaque = YES;
        textModeButton.layer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
        UIImage *iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_text"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [textModeButton addTarget:_owner action:@selector(switchToInputTextMode) forControlEvents:UIControlEventTouchUpInside];
        [textModeButton setImage:iconImage forState:UIControlStateNormal];
        [textModeButton setTintColor:[UIColor lightGrayColor]];
        [scrollView addSubview:textModeButton];
        [self.buttons addObject:textModeButton];
        ///
        /// Add suggestion mode button
        ///
        if (self.shouldShowSuggestion) {
            UIButton *suggestionModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect suggestionModeButtonFrame = CGRectMake(1 * stickerButtonWidth, 0, stickerButtonWidth, stickerButtonHeight);
            suggestionModeButton.frame = suggestionModeButtonFrame;
            suggestionModeButton.opaque = YES;
            suggestionModeButton.layer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
            UIImage *suggestionIconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_suggestion"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [suggestionModeButton addTarget:_owner action:@selector(switchToSuggestionMode) forControlEvents:UIControlEventTouchUpInside];
            [suggestionModeButton setImage:suggestionIconImage forState:UIControlStateNormal];
            [suggestionModeButton setTintColor:[CCConstants sharedInstance].baseColor];
            [scrollView addSubview:suggestionModeButton];
            [self.buttons addObject:suggestionModeButton];
        }
        
        for (int i = 0;i < stickers.count; i++) {
            UIButton *stickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect stickerButtonFrame;
            if (self.shouldShowSuggestion) {
                stickerButtonFrame = CGRectMake((i + 2) * stickerButtonWidth, 0, stickerButtonWidth, stickerButtonHeight);
            } else {
                stickerButtonFrame = CGRectMake((i + 1) * stickerButtonWidth, 0, stickerButtonWidth, stickerButtonHeight);
            }
            stickerButton.frame = stickerButtonFrame;
            stickerButton.opaque = YES;
            stickerButton.layer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;

            UIImage *iconImage;
            if ([stickers[i] isEqualToString:CC_STICKERTYPEDATETIMEAVAILABILITY]) {
                iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_calendar"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [stickerButton addTarget:_owner action:@selector(pressCalendar) forControlEvents:UIControlEventTouchUpInside];
            }else if ([stickers[i] isEqualToString:CC_STICKERTYPELOCATION]) {
                iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [stickerButton addTarget:_owner action:@selector(pressLocationWidget) forControlEvents:UIControlEventTouchUpInside];
            }else if ([stickers[i] isEqualToString:CC_STICKERTYPETHUMB]) {
                iconImage = [[UIImage SDKImageNamed:@"questionBubbleIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [stickerButton addTarget:_owner action:@selector(pressThumb) forControlEvents:UIControlEventTouchUpInside];
            }else if ([stickers[i] isEqualToString:CC_STICKERTYPEFILE]) {
                iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_image"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [stickerButton addTarget:_owner action:@selector(pressImage) forControlEvents:UIControlEventTouchUpInside];
            }else if ([stickers[i] isEqualToString:CC_STICKERTYPECAMERA]) {
                iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [stickerButton addTarget:_owner action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
            }else if ([stickers[i] isEqualToString:CC_STICKERTYPEFIXEDPHRASE]) {
                iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_fixed_phrase"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [stickerButton addTarget:_owner action:@selector(pressPhrase) forControlEvents:UIControlEventTouchUpInside];
            } else if ([stickers[i] isEqualToString:CC_STICKERTYPESPAYMENT]) {
                iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_payment"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [stickerButton addTarget:_owner action:@selector(pressStripePayment) forControlEvents:UIControlEventTouchUpInside];
            } else if ([stickers[i] isEqualToString:CC_STICKERLANDINGPAGE]) {
                iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_landingpage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [stickerButton addTarget:_owner action:@selector(pressLandingPage) forControlEvents:UIControlEventTouchUpInside];
            } else if ([stickers[i] isEqualToString:CC_STICKERCONFIRM]) {
                iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_confirm"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [stickerButton addTarget:_owner action:@selector(pressConfirmWidget) forControlEvents:UIControlEventTouchUpInside];
            }
            [stickerButton setTintColor:[UIColor lightGrayColor]];
            [stickerButton setImage:iconImage forState:UIControlStateNormal];
            [scrollView addSubview:stickerButton];
            [self.buttons addObject:stickerButton];
        }
    }
    return self;
}
@end
