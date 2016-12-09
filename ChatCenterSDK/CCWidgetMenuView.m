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
        UIScreen *screen = [UIScreen mainScreen];
        
//        CGRect stickersMenuFrame = CGRectMake(0.0, 0.0, screen.bounds.size.width, keyboardHeight);
        self.backgroundColor = [UIColor colorWithRed:242.0/256 green:242.0/256 blue:242.0/256 alpha:1];
        
        NSMutableArray *stickers = [[CCConstants sharedInstance].stickers mutableCopy];
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
                && ![stickers[i] isEqualToString:CC_STICKERTYPEVOICECHAT]){
                [stickers removeObject:stickers[i]];
                continue;
            }
            /* hide video chat sticker if:
             1. user me can't video chat or
             2. user me can video chat but all other users in channel can't video chat
             */
//            NSLog(@"meCanUseVideoChat: %d - channelUserCanVideoChat: %d", [self processUserMeVideoChatInfo], [self processChannelUserVideoChatInfo]);
            if([stickers[i] isEqualToString:CC_STICKERTYPEVIDEOCHAT]) {
                [stickers removeObject:stickers[i]];
            }
        }
        
        float stickerButtonWidth = screen.bounds.size.width / 3;
        float stickerButtonHeight = 80.0;
        float labelX = 0;
        float labelY = 50.0;
        float labelWidth = stickerButtonWidth;
        float labelHeight = 25.0;
        
        //
        // Add scroll view
        //
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
        scrollView.contentSize = CGSizeMake(screen.bounds.size.width, stickerButtonHeight * ceil((float)stickers.count / 3));
        scrollView.showsHorizontalScrollIndicator = YES;
        [self addSubview:scrollView];
        
        //Add top padding
        UIView *topPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen.bounds.size.width, 1)];
        topPaddingView.backgroundColor = [UIColor colorWithRed:227.0/256 green:227.0/256 blue:227.0/256 alpha:1];
        [scrollView addSubview:topPaddingView];
        
        
        for (int i = 0;i < stickers.count; i++) {
            UIButton *stickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect stickerButtonFrame = CGRectMake((i % 3) * stickerButtonWidth, ((int)floorf(i / 3)) * stickerButtonHeight, stickerButtonWidth, stickerButtonHeight);
            stickerButton.frame = stickerButtonFrame;
            stickerButton.opaque = YES;
            stickerButton.layer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
            
            UIView *rectangle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, stickerButtonWidth, stickerButtonHeight)];
            rectangle.userInteractionEnabled = NO;
            // Add padding
            UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(stickerButtonWidth - 1, 0, 1, stickerButtonHeight)];
            paddingView.backgroundColor = [UIColor colorWithRed:227.0/256 green:227.0/256 blue:227.0/256 alpha:1];
            [rectangle addSubview:paddingView];
            UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, stickerButtonHeight - 1, stickerButtonWidth, 1)];
            paddingView2.backgroundColor = [UIColor colorWithRed:227.0/256 green:227.0/256 blue:227.0/256 alpha:1];
            [rectangle addSubview:paddingView2];
            
            UIImageView *icon = [[UIImageView alloc] init];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelWidth, labelHeight)];
            label.userInteractionEnabled = NO;
            label.textColor = [CCConstants sharedInstance].baseColor;
            label.font = [UIFont systemFontOfSize:14.0];
            label.textAlignment = NSTextAlignmentCenter;
            UIImage *iconImage;
            if ([stickers[i] isEqualToString:CC_STICKERTYPEDATETIMEAVAILABILITY]) {
                iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_calendar"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                label.text = CCLocalizedString(@"Availability");
                [stickerButton addTarget:_owner action:@selector(pressCalendar) forControlEvents:UIControlEventTouchUpInside];
            }else if ([stickers[i] isEqualToString:CC_STICKERTYPELOCATION]) {
                iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                label.text = CCLocalizedString(@"Location");
                [stickerButton addTarget:_owner action:@selector(pressLocation) forControlEvents:UIControlEventTouchUpInside];
            }else if ([stickers[i] isEqualToString:CC_STICKERTYPETHUMB]) {
                iconImage = [[UIImage SDKImageNamed:@"questionBubbleIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                label.text = CCLocalizedString(@"Question");
                [stickerButton addTarget:_owner action:@selector(pressThumb) forControlEvents:UIControlEventTouchUpInside];
            }else if ([stickers[i] isEqualToString:CC_STICKERTYPEFILE]) {
                iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_image"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                label.text = CCLocalizedString(@"Image");
                [stickerButton addTarget:_owner action:@selector(pressImage) forControlEvents:UIControlEventTouchUpInside];
            }else if ([stickers[i] isEqualToString:CC_STICKERTYPECAMERA]) {
                iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                label.text = CCLocalizedString(@"Camera");
                [stickerButton addTarget:_owner action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
            }else if ([stickers[i] isEqualToString:CC_STICKERTYPEFIXEDPHRASE]) {
                iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_fixed_phrase"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                label.text = CCLocalizedString(@"Saved");
                [stickerButton addTarget:_owner action:@selector(pressPhrase) forControlEvents:UIControlEventTouchUpInside];
            } else if ([stickers[i] isEqualToString:CC_STICKERTYPEVIDEOCHAT]) {
                iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_videocall"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                label.text = CCLocalizedString(@"Videochat");
                CGRect oldFrame = label.frame;
                oldFrame.size.width = oldFrame.size.width + 40;
                oldFrame.origin.x = oldFrame.origin.x - 20;
                [label setFrame:oldFrame];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                [stickerButton addTarget:_owner action:@selector(pressVideoCall) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
            } else if ([stickers[i] isEqualToString:CC_STICKERTYPEVOICECHAT]) {
                iconImage = [[UIImage SDKImageNamed:@"CCmenu_icon_phone"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                label.text = CCLocalizedString(@"Voicechat");
                CGRect oldFrame = label.frame;
                oldFrame.size.width = oldFrame.size.width + 40;
                oldFrame.origin.x = oldFrame.origin.x - 20;
                [label setFrame:oldFrame];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                [stickerButton addTarget:_owner action:@selector(pressVoiceCall) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
            }
            float iconX = stickerButtonWidth/2 - iconImage.size.width/2;
            float iconY = stickerButtonHeight/2 - iconImage.size.height/2 - 10;
            icon.frame = CGRectMake(iconX, iconY, iconImage.size.width, iconImage.size.height);
            icon.image = iconImage;
            icon.tintColor = [CCConstants sharedInstance].baseColor;
            [rectangle addSubview:icon];
            [stickerButton addSubview:label];
            [stickerButton addSubview:rectangle];
            [scrollView addSubview:stickerButton];
        }
        

    }
    return self;
    
}


@end
