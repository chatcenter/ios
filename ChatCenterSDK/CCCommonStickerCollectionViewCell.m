//
//  CCCommonStickerCollectionViewCell.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2/25/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//


#import <CoreText/CoreText.h>

#import "CCCommonStickerCollectionViewCell.h"
#import "CCJSQMessagesTimestampFormatter.h"
#import "CCHightlightButton.h"
#import "CCConstants.h"
#import "CCCommonStickerCollectionViewCell.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CCLocationStickerViewController.h"
#import "UIImageView+CCWebCache.h"
#import "ChatCenterPrivate.h"
#import "CCImageHelper.h"
#import "ChatCenterPrivate.h"

#import "CCQuestionComponent.h"
#import "CCDefaultSelectionQuestionComponent.h"
#import "UIImage+CCSDKImage.h"


// Text area size calculation by NSAttributedString always underestimates the width
// and the text will be chopped at the drawing step.
// So we subtract this correction value when estimating
#define TEXTAREA_WIDTH_CALC_ERROR_CORRECTION 15


@interface CCMessageHeaderParameters : NSObject {
}
@property (nonatomic) CGFloat iconWidth;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic) UIEdgeInsets textInsets;
@property (nonatomic) CGSize textAreaSize;
@end

@implementation CCMessageHeaderParameters
@end



@implementation CCCommonStickerCollectionViewCell
{
    
    CCStickerCollectionViewCellOptions options;
    NSInteger index;
    
    __weak IBOutlet UIImageView *headerImageView;
    __weak IBOutlet NSLayoutConstraint *headerImageViewWidthConstraint;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.stickerStatusLabel.font = [UIFont systemFontOfSize:11.0f];
    self.stickerStatusLabel.text = @"";
}

- (BOOL)setupWithIndex:(NSIndexPath *)indexPath message:(CCJSQMessage *)msg avatar:(CCJSQMessagesAvatarImage *)avatar delegate:(id<CCStickerCollectionViewCellActionProtocol>)delegate options:(CCStickerCollectionViewCellOptions)inOptions {
    
    options = inOptions;
    self.avatarImage.image = avatar.avatarImage;

    //
    // Set color
    //
    if (options & CCStickerCollectionViewCellOptionShowAsWidget) {
        //
        // Widgets are shown only with border line
        //
        self.stickerContainer.backgroundColor = [UIColor clearColor];
        self.stickerContainer.layer.borderColor = [[CCConstants sharedInstance] baseColor].CGColor;
        self.stickerContainer.layer.borderWidth = 1.0;
        stickerActionsContainer.layer.borderWidth = 1.0;
        stickerActionsContainer.layer.borderColor = [[CCConstants sharedInstance] baseColor].CGColor;
    } else {
        //
        // Text chat is shown with conventional bubble style coloring
        //
        if(options & CCStickerCollectionViewCellOptionShowAsMyself) {
            self.stickerContainer.backgroundColor = [[CCConstants sharedInstance] baseColor];
        } else {
            self.stickerContainer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
        }
    }
    

    // Keep message object
    _msg = msg;
    
    // Bubble width
    stickerContainerWidth.constant = CC_STICKER_BUBBLE_WIDTH;

    //------------------------------
    //
    // Part A: Date
    //
    
    if(options & CCStickerCollectionViewCellOptionShowDate) {
        self.cellTopLabelHeight.constant = CC_STICKER_DATE_HEIGHT;
        self.cellTopLabel.attributedText = [[CCJSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:msg.date];
    } else {
        self.cellTopLabelHeight.constant = 0;
    }
    

    
    index = indexPath.row;
    NSLog(@"index = %ld", (long)index);
    
    //------------------------------
    //
    // Part B: Sender name
    //
    
    if (options & CCStickerCollectionViewCellOptionShowName) {
        self.stickerTopLabelHeight.constant = 20;
        self.stickerTopLabel.text = msg.senderDisplayName;
    }else{
        self.stickerTopLabelHeight.constant = 0;
    }

/* No longer shows this style of suggestion in Moon
    if ([msg.type isEqualToString:CC_RESPONSETYPESUGGESTION]) {
        self.stickerTopLabel.text = CCLocalizedString(@"This message is invisible to the customer.");
    } else {
        self.stickerTopLabel.text = msg.senderDisplayName;
    }
*/
    
    //------------------------------
    //
    // Part C: Message(or header)
    //
    
    NSAttributedString *message = [self createMessageString:msg];
    
    // Suggestion and image shouldn't have a message field
    if (message != nil && ![msg.type isEqualToString:CC_RESPONSETYPESUGGESTION] && ![msg.type isEqualToString:CC_STICKERTYPEIMAGE]) {
//        CGFloat textAreaWidth = CC_STICKER_BUBBLE_WIDTH - 25;
//        CGFloat textAreaHeight = [CCCommonStickerCollectionViewCell calculateTextHeightForAttributedString:message textWidth:textAreaWidth];

        CCMessageHeaderParameters *params = [[self class] getMessageHeaderParameterForMessage:msg];
        
        if(params.iconImage) {
            [headerImageView setImage:params.iconImage];
            headerImageView.tintColor = [[CCConstants sharedInstance] baseColor];
            headerImageViewWidthConstraint.constant = params.iconWidth;
        } else {
            [headerImageView setImage:nil];
            headerImageViewWidthConstraint.constant = 0;
        }
        
        self.discriptionView.textContainerInset = params.textInsets;
        
        //
        // Bubble width adjustment (for text-only bubble)
        // * The bubble won't look good with short text in a too wide bubble
        //
        if( !(options & CCStickerCollectionViewCellOptionShowAsWidget) ) {
            CGFloat newBubbleWidth = params.textAreaSize.width + params.textInsets.left + params.textInsets.right;// + TEXTAREA_WIDTH_CALC_ERROR_CORRECTION;
            stickerContainerWidth.constant = newBubbleWidth;
            self.discriptionView.textAlignment = NSTextAlignmentCenter;
        }
        
        
        self.discriptionView.attributedText = message;
        self.discriptionViewHeight.constant = params.textAreaSize.height + 5; // 5 for bottom margin
        
        //
        // Setting color 
        //
        if( options & CCStickerCollectionViewCellOptionShowAsWidget ) {
            // If it's a widget use baseColor no matter if it's outgoing or incoming
            self.discriptionView.textColor = [[CCConstants sharedInstance] baseColor];
        } else if ( options & CCStickerCollectionViewCellOptionShowAsMyself ) {
            // For normal message cell, use white for outgoing cell
            self.discriptionView.textColor = [UIColor whiteColor];
        } else {
            // For normal message cell, use black for outgoing cell
            self.discriptionView.textColor = [UIColor blackColor];
        }
        
        // Link is automatically detected by UITextView.  Just setting link style here
        if (self.discriptionView!=nil && self.discriptionView.textColor!=nil) {
            self.discriptionView.linkTextAttributes = @{ NSForegroundColorAttributeName : self.discriptionView.textColor,
                                                         NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
        }
        
    } else {
        self.discriptionViewHeight.constant = 0;
        self.discriptionView.text = @"";
    }
    
    
    //------------------------------
    //
    // Part D: Image (including map)
    //
    
    //
    // Set Thumbnail Image
    //
    NSString *thumURLStr = [msg getStringAtPath:@"sticker-content/thumbnail-url"];
    if (thumURLStr) {
        
        NSURL *thumbnailUrl = [NSURL URLWithString:[thumURLStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
        if (thumbnailUrl && thumbnailUrl.host && thumbnailUrl.scheme) { // Has a remote image URL...
            
            //
            // Setup container
            //
            CGRect stickerObjectContainerFrame = stickerObjectContainer.frame;
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                stickerObjectContainerHeight.constant = 255.0f;
                stickerObjectContainerFrame.size.height = 255.0f;
            }else {
                stickerObjectContainerHeight.constant =  150.0f;
                stickerObjectContainerFrame.size.height = 150.0f;
            }
            stickerObjectContainerFrame.size.width = CC_STICKER_BUBBLE_WIDTH;
            [stickerObjectContainer setFrame:stickerObjectContainerFrame];
            
            CGRect imageFrame = stickerObjectContainer.frame;
            imageFrame.origin = CGPointZero;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [imageView setClipsToBounds:YES];
            [stickerObjectContainer addSubview:imageView];
            
            //
            // Register Tap Action
            //
            if (msg.content[CC_STICKERCONTENT][CC_STICKERCONTENT_ACTION] != nil) {
                UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onStickerContentTap:)];
                [imageView addGestureRecognizer:tapGes];
                [imageView setUserInteractionEnabled:YES];
            }
            
            //
            // Loading Indicator
            //
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [indicator startAnimating];
            indicator.center = imageView.center;
            [imageView addSubview:indicator];
            
            
            //
            // Set image URL to imageView
            //
            [imageView sd_setImageWithURL:[NSURL URLWithString:[msg.content[CC_STICKERCONTENT][CC_THUMBNAILURL] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [indicator stopAnimating];
                [indicator removeFromSuperview];
            }];
        } else if ([msg.type isEqualToString:CC_STICKERTYPEIMAGE]) { // Local image
            
            //
            // Setup container
            //
            CGRect stickerObjectContainerFrame = stickerObjectContainer.frame;
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                stickerObjectContainerHeight.constant = 255.0f;
                stickerObjectContainerFrame.size.height = 255.0f;
            }else {
                stickerObjectContainerHeight.constant =  150.0f;
                stickerObjectContainerFrame.size.height = 150.0f;
            }
            stickerObjectContainerFrame.size.width = CC_STICKER_BUBBLE_WIDTH;
            [stickerObjectContainer setFrame:stickerObjectContainerFrame];
            CGRect imageFrame = stickerObjectContainer.frame;
            imageFrame.origin = CGPointZero;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [imageView setClipsToBounds:NO];
            
            //
            // Load image
            //
            [[CCImageHelper sharedInstance] loadLocalImage:msg.content[@"url"] completionHandler:^(UIImage *image) {
                if (image != nil) {
                    imageView.image = image;
                }
            }];
            [stickerObjectContainer addSubview:imageView];
            stickerActionsContainerHeight.constant = 0;
            
            ///display status
            [self setMessageStatusLabel:msg delegate:delegate];

            return YES; // End setup
        } else {
            stickerObjectContainerHeight.constant = 0;
        }
        
        //
        // Add container
        //
        CGRect imageFrame = stickerObjectContainer.frame;
        imageFrame.origin = CGPointZero;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [stickerObjectContainer addSubview:imageView];
        
        //
        // Add Action
        //
        if (msg.content[CC_STICKERCONTENT][CC_STICKERCONTENT_ACTION] != nil) {
            UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onStickerContentTap:)];
            [imageView addGestureRecognizer:tapGes];
            [imageView setUserInteractionEnabled:YES];
        }
        
        //
        // Loading indicator
        //
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator startAnimating];
        indicator.center = imageView.center;
        [imageView addSubview:indicator];
        
        //
        // Set image URL to imageView
        //
        [imageView sd_setImageWithURL:[NSURL URLWithString:[[[msg.content[CC_STICKERCONTENT][CC_THUMBNAILURL] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@"|" withString:@""] ]  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [indicator stopAnimating];
            [indicator removeFromSuperview];
        }];
    }else {
        stickerObjectContainerHeight.constant = 0;
    }
    
    
    
    //------------------------------
    //
    // Part E: Action
    //

    //
    // Extract sticker actions
    //
//    NSString *stickerActionType = [msg getStringAtPath:@"sticker-action/action-type"];
    NSArray *actionData = [msg getArrayAtPath:@"sticker-action/action-data"];
    NSArray *stickerActionsResponses_wrapped = [msg getArrayAtPath:@"sticker-action/action-response-data"];
    
    NSDictionary *action =  msg.content[@"sticker-action"];
    // If the stickerActionType is "confirm" convert it to YesNo Question Widget
    action = [[self class] convertStickerActionToMoonStyleIfNeeded:action];
    
    //
    // Unwrap the action response
    //
    
    //
    // "action-response-data" can come in two types of structure
    //
    ////// *** Single Type ***
    ////// Has an OBJECT under "action"
    //
    // (
    //    {
    //       "action" =  {
    //                      "label" = label
    //                      "value" = {
    //                                     //Any specific key-values
    //                                 }
    //                   }
    //
    //     }
    // )
    //
    ////// *** Multiple Type ***
    ////// Has an ARRAY under "action"
    //
    // (
    //    {
    //       "action" =  (
    //                      {
    //                        "label" = label
    //                        "value" = {
    //                                     //Any specific key-values
    //                                   }
    //                      },
    //                      {
    //                        "label" = label
    //                        "value" = {
    //                                     //Any specific key-values
    //                                   }
    //                      },
    //                      ...
    //                   )
    //     }
    // )

    NSArray <NSDictionary*> *stickerActionsResponses;
    if (stickerActionsResponses_wrapped) {
        if (stickerActionsResponses_wrapped.count>0) {
            if ([stickerActionsResponses_wrapped[0] isKindOfClass:[NSDictionary class]]) {
                id obj = [stickerActionsResponses_wrapped[0] objectForKey:@"action"];
                
                if ([obj isKindOfClass:[NSArray class]]) {
                    stickerActionsResponses = obj;
                } else if([obj isKindOfClass:[NSDictionary class]]) {
                    stickerActionsResponses = @[obj];
                }
                
            }
        }
    }
    
    if (actionData != nil && actionData.count > 0 ) {
        //
        // Create question component
        //
    
        NSDictionary *action =  msg.content[@"sticker-action"];
        // If the stickerActionType is "confirm" convert it to YesNo Question Widget
        action = [[self class] convertStickerActionToMoonStyleIfNeeded:action];
        
        
        CCQuestionComponent *v = [CCQuestionComponent componentForStickerAction:action  delegate:self];
        
        CGFloat height = [CCQuestionComponent calculateHeightForStickerAction:action];
        v.frame = CGRectMake(0, 0, self.bounds.size.width, height);
        v.translatesAutoresizingMaskIntoConstraints = NO;
        
        [stickerActionsContainer addSubview:v];
        
        // Add AutoLayout constraints
        NSArray *constraints1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":v}];
        NSArray *constraints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":v}];
        [stickerActionsContainer addConstraints:constraints1];
        [stickerActionsContainer addConstraints:constraints2];

        stickerActionsContainerHeight.constant = height;
        
        // Set selection state
        if(stickerActionsResponses != nil && stickerActionsResponses.count > 0) {
            [v setSelection:stickerActionsResponses];
        }
    } else {
        stickerActionsContainerHeight.constant = 0;
    }

    
    
    //------------------------------
    //
    // Part F: Status
    //
    [self setMessageStatusLabel:msg delegate:delegate];

    return YES;
}

- (void)setMessageStatusLabel:(CCJSQMessage*)msg delegate:(id<CCStickerCollectionViewCellActionProtocol>)delegate{
    if(options & CCStickerCollectionViewCellOptionShowStatus) {
        self.stickerStatusLabel.text = [delegate getStatusForMessage:msg];
        // notification when "delivering" pdf sticker
        if([self.stickerStatusLabel.text isEqualToString:CCLocalizedString(@"Delivering")]) {
            self.userInteractionEnabled = NO;
        } else {
            self.userInteractionEnabled = YES;
        }
    } else {
        self.stickerStatusLabel.text = @"";
        self.userInteractionEnabled = YES;
    }
}

//
// Convert sticker data if needed
//
+ (NSDictionary*)convertStickerActionToMoonStyleIfNeeded:(NSDictionary*)stickerAction {
    // If the stickerActionType is "confirm" convert it to YesNo Question Widget
    NSArray *actionData = stickerAction[@"action-data"];
    NSString *actionType = stickerAction[@"action-type"];
    
    if (actionData != nil && [actionType isEqualToString:@"confirm"] && actionData.count == 2 ) {
        NSDictionary *viewInfo = @{ @"type" : @"yesno" };
        NSMutableDictionary *newAction = [stickerAction mutableCopy];
        [newAction setObject:viewInfo forKey:@"view-info"];
        
        return newAction;
    }

    return stickerAction; // No conversion
}


+ (CCMessageHeaderParameters*)getMessageHeaderParameterForMessage:(CCJSQMessage*)msg {
    
    CCMessageHeaderParameters *params = [[CCMessageHeaderParameters alloc] init];
    
    UIImage *img = nil;
    //
    // Question Widget
    //
//    NSArray *stickerActions = msg.content[@"sticker-action"][@"action-data"];
    NSArray *stickerActions = [msg getArrayAtPath:@"sticker-action/action-data"];
    if (stickerActions != nil && stickerActions.count > 0) {
        img = [UIImage SDKImageNamed:@"questionBubbleIcon"];
    }

    //
    // Map Widget
    //
    NSDictionary *location = [msg getDictionaryAtPath:@"sticker-content/sticker-data/location"];
    if(location) {
        img = [UIImage SDKImageNamed:@"CCmenu_icon_location"];
    }
    
    //
    // Calendar Widget
    //
    NSString *st = [msg getStringAtPath:@"sticker-action/action-data/#0/value/start"];
    if(st != nil ) {
        img = [UIImage SDKImageNamed:@"CCmenu_icon_calendar"];
    }
    /*
    NSArray<NSDictionary*> *ad = msg.content[@"sticker-action"][@"action-data"];
    if(ad != nil && ad.count>0) {
        NSDictionary *value = [ad[0] objectForKey:@"value"];
        if (value != nil && ![value isEqual: [NSNull null]] && value[@"start"]) { // Has Time data
             img = [UIImage SDKImageNamed:@"CCmenu_icon_calendar"];
        }
    }*/
    
    NSAttributedString *message = [self createMessageString:msg];

    if (img) {
        params.iconImage = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];  // Set icon with tint color
        params.iconWidth = 45;
        
        params.textInsets = UIEdgeInsetsMake(10, 0, 0, 5);
        
        CGFloat textAreaWidth = CC_STICKER_BUBBLE_WIDTH - 50; // iconWidth + insets
        CGSize calculatedSize = [self calculateTextAreaSizeForAttributedString:message textWidth:textAreaWidth];
        params.textAreaSize = calculatedSize;
    } else {
    
        params.iconImage = nil;
        params.iconWidth = 0;
        
        params.textInsets = UIEdgeInsetsMake(10, 10, 0, 5);
        CGFloat textAreaWidth = CC_STICKER_BUBBLE_WIDTH - 15;
        CGSize calculatedSize = [self calculateTextAreaSizeForAttributedString:message textWidth:textAreaWidth];
        params.textAreaSize = calculatedSize;
    }
    
    return params;
    
}

+ (CGSize)calculateTextAreaSizeForAttributedString:(NSAttributedString*)message textWidth:(CGFloat)textWidth {
    
/* NG: CTFrameSetter underestimates the hight (at least with this parameter settings)
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)message);
    CGSize targetSize = CGSizeMake(textWidth - TEXTAREA_WIDTH_CALC_ERROR_CORRECTION , CGFLOAT_MAX);
    CGSize fitSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [message length]), NULL, targetSize, NULL);
    CFRelease(framesetter);
    return fitSize;
*/
    
/*  NG: NSAttributedText#boundingRectWithSize also underestimates the height
    CGRect rect = [message boundingRectWithSize:CGSizeMake(textWidth  - TEXTAREA_WIDTH_CALC_ERROR_CORRECTION, 1800)
                                        options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                        context:nil];
    return rect.size;
     
*/
    
    //
    // This works!
    //
    UITextView *dummyTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, textWidth, 1800)];
    [dummyTextView setAttributedText:message];
    
    CGSize size = [dummyTextView sizeThatFits:CGSizeMake(textWidth, 1800)];
    [dummyTextView sizeToFit];
    
    return size;

}


- (NSAttributedString*)createMessageString:(CCJSQMessage*)msg {
    return [[self class] createMessageString:msg];
}

+ (NSAttributedString*)createMessageString:(CCJSQMessage*)msg {
    NSString *text = [msg getStringAtPath:@"message/text"];
    
    if (!text) {
        text = [msg getStringAtPath:@"text"];
    }
    
    if (!text) {
        return nil;
    }

    NSDictionary *messageStringAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:15.0f]};
    
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:text attributes:messageStringAttributes];

    return message;
}

//
// Moon-style action handling
//
- (void)userDidSelectActionItems:(NSArray<NSDictionary *> *)items {
    
    if(_msg == nil || _msg.status == CC_MESSAGE_STATUS_DELIVERING || _msg.status == CC_MESSAGE_STATUS_SEND_FAILED) {
        return;
    }
    
    NSLog(@"action selected! %@", items);
    
    
    // "reacted" flag is basicly for Suggestion Widget.
    // - It prevents you from sending same message multiple times.
    // - Sending notification with reacted:"true" will let the chat view refresh(instead of sending)
    NSString *isReacted = @"false"; // TODO: Set a proper value
    
    
    // do action here!!!
    
    NSDictionary *data = @{         @"msgId" : _msg.uid,
                                    @"action-type" : _msg.content[@"sticker-action"][@"action-type"],
                                    @"stickerActions" : items,
                                    @"sticker_type": _msg.type ,
                                    @"reacted" : isReacted};
    [[NSNotificationCenter defaultCenter] postNotificationName:kCCNoti_UserReactionToSticker object:nil userInfo:data];

    
    
    
    /*
    
    NSInteger index = [sender tag];
    NSArray *stickerActions = _msg.content[@"sticker-action"][@"action-data"];
    
    
    if (stickerActions != nil && index < stickerActions.count) {
        
        
        
        NSDictionary *stickerAction = [stickerActions objectAtIndex:index];
        
        
        NSArray *stickerActionsResponses = _msg.content[@"sticker-action"][@"action-response-data"];
        
        NSString *isReacted = @"false";
        for(int j=0; j<stickerActionsResponses.count; j++) {
            //
            // Check if it's already reacted
            //
            NSDictionary *response = [stickerActionsResponses objectAtIndex:j];
            NSDictionary *responseAction = [response objectForKey:@"action"];
            if(responseAction != nil && ![responseAction isEqual:[NSNull null]]) {
                if(([responseAction objectForKey:@"value"] != nil && [stickerAction objectForKey:@"value"] != nil &&
                    [[responseAction objectForKey:@"value"] isKindOfClass:[NSDictionary class]] &&
                    [[responseAction objectForKey:@"value"] isEqualToDictionary:[stickerAction objectForKey:@"value"]]) ||
                   ([responseAction objectForKey:@"action"] != nil && [stickerAction objectForKey:@"action"] != nil &&
                    [[responseAction objectForKey:@"action"] isKindOfClass:[NSArray class]] &&
                    [[responseAction objectForKey:@"action"] isEqualToArray:[stickerAction objectForKey:@"action"]])) {
                       isReacted = @"true";
                       break;
                   } 
            }
        }
        // do action here!!!
        NSDictionary *data = @{         @"msgId" : _msg.uid,
                                        @"action-type" : _msg.content[@"sticker-action"][@"action-type"],
                                        @"stickerAction" : stickerAction,
                                        @"sticker_type": _msg.type ,
                                        @"reacted" : isReacted};
        [[NSNotificationCenter defaultCenter] postNotificationName:kCCNoti_UserReactionToSticker object:nil userInfo:data];
    }
    
    */    
    
}

- (void) onActionClicked:(UIButton*)sender {
    if(_msg == nil || _msg.status == CC_MESSAGE_STATUS_DELIVERING || _msg.status == CC_MESSAGE_STATUS_SEND_FAILED) {
        return;
    }
    NSLog(@"onActionClicked");
    NSInteger index = [sender tag];
    NSArray *stickerActions = _msg.content[@"sticker-action"][@"action-data"];
    if (stickerActions != nil && index < stickerActions.count) {
        
        //
        // The action just have chosen by the user
        //
        NSDictionary *stickerAction = [stickerActions objectAtIndex:index];
        
        //
        // The reaction which already stored
        //
        NSArray *stickerActionsResponses = _msg.content[@"sticker-action"][@"action-response-data"];
        NSString *isReacted = @"false";
        
        for(int j=0; j<stickerActionsResponses.count; j++) {
            NSDictionary *responseAction = [stickerActionsResponses objectAtIndex:j];
//            NSDictionary *response = [stickerActionsResponses objectAtIndex:j];
//            NSDictionary *responseAction = [response objectForKey:@"action"];   // The content of the reaction
            if(responseAction != nil && ![responseAction isEqual:[NSNull null]]) {
                if(([responseAction objectForKey:@"value"] != nil && [stickerAction objectForKey:@"value"] != nil &&
                    [[responseAction objectForKey:@"value"] isKindOfClass:[NSDictionary class]] &&
                    [[responseAction objectForKey:@"value"] isEqualToDictionary:[stickerAction objectForKey:@"value"]]) ||
                   ([responseAction objectForKey:@"action"] != nil && [stickerAction objectForKey:@"action"] != nil &&
                    [[responseAction objectForKey:@"action"] isKindOfClass:[NSArray class]] &&
                    [[responseAction objectForKey:@"action"] isEqualToArray:[stickerAction objectForKey:@"action"]])) {
                       isReacted = @"true"; // This action was already taken
                       break;
                   }
            }
        }
        // do action here!!!
        NSDictionary *data = @{         @"msgId" : _msg.uid,
                                  @"action-type" : _msg.content[@"sticker-action"][@"action-type"],
                                @"stickerAction" : stickerAction,
                                  @"sticker_type": _msg.type ,
                                      @"reacted" : isReacted};
        [[NSNotificationCenter defaultCenter] postNotificationName:kCCNoti_UserReactionToSticker object:nil userInfo:data];
    }
}

- (void)onStickerContentTap:(UIGestureRecognizer*)gestureRecognizer {
    if (_msg.content[CC_STICKERCONTENT][CC_STICKERCONTENT_ACTION] != nil) {
        NSDictionary *data = @{ @"msgId":_msg.uid, CC_STICKERCONTENT_ACTION:_msg.content[CC_STICKERCONTENT][CC_STICKERCONTENT_ACTION]};
        [[NSNotificationCenter defaultCenter] postNotificationName:kCCNoti_UserReactionToStickerContent object:nil userInfo:data];
    }
}

+ (CGSize) estimateSizeForMessage:(CCJSQMessage *)msg
                      atIndexPath:(NSIndexPath *)indexPath
               hasPreviousMessage:(CCJSQMessage *)preMsg
                          options:(CCStickerCollectionViewCellOptions)options
                     withListUser:(NSArray *)users
{
    // NGOCNH
    int height = 0;
    
    //------------------------------
    //
    // Part A: Date
    //
    if (options & CCStickerCollectionViewCellOptionShowDate) {
        height += CC_STICKER_DATE_HEIGHT;
    }

    //------------------------------
    //
    // Part B: Sender Name
    //
    if (options & CCStickerCollectionViewCellOptionShowName) {
        height += CC_STICKER_SENDER_NAME_HEIGHT;
    }
    
    //------------------------------
    //
    // Part C: Message
    //
    NSString *text = nil;
    if (msg.content[@"message"] != nil && ![msg.content[@"message"] isEqual:[NSNull null]]
        && msg.content[@"message"][@"text"] != nil && ![msg.content[@"message"][@"text"] isEqual:[NSNull null]]) {
        text = msg.content[@"message"][@"text"];
        
    } else if (msg.content[@"text"] != nil && ![msg.content[@"text"] isEqual:[NSNull null]]) {
        text = msg.content[@"text"];
    }
    
    if (text != nil && ![msg.type isEqualToString:CC_RESPONSETYPESUGGESTION] && ![msg.type isEqualToString:CC_STICKERTYPEIMAGE]) {
        
        CCMessageHeaderParameters *params = [self getMessageHeaderParameterForMessage:msg];
        
        height += params.textAreaSize.height + 5; // 5 for bottom margin
    } else {
//        height += 10;
    }
    
    //------------------------------
    //
    // Part D: Image (including map)
    //
    if (msg.content[CC_STICKERCONTENT] != nil && msg.content[CC_STICKERCONTENT][CC_THUMBNAILURL] != nil
        && ![msg.content[CC_STICKERCONTENT][CC_THUMBNAILURL] isEqual:[NSNull null]]) {
        NSURL *thumbnailUrl = [NSURL URLWithString:[msg.content[CC_STICKERCONTENT][CC_THUMBNAILURL] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        if (thumbnailUrl && thumbnailUrl.host && thumbnailUrl.scheme) {
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                height += 255.0f;
            }else {
                height += 150.0f;
            }
        } else if ([msg.type isEqualToString:CC_STICKERTYPEIMAGE]){
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                height += 255.0f;
            }else {
                height += 150.0f;
            }
        }
    }
    
    
    //------------------------------
    //
    // Part E: Action
    //
    NSString *stickerActionType = msg.content[@"sticker-action"][@"action-type"];
    NSArray *stickerActions = msg.content[@"sticker-action"][@"action-data"];
    
    NSDictionary *labelStringAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12.0f]};

    
    if (stickerActions != nil ) {
//    if (stickerActions != nil && [stickerActionType isEqualToString:@"confirm"]) {
        
        NSDictionary *action =  msg.content[@"sticker-action"];
        // If the stickerActionType is "confirm" convert it to YesNo Question Widget
        action = [self convertStickerActionToMoonStyleIfNeeded:action];


        CGFloat actionHeight = [CCQuestionComponent calculateHeightForStickerAction:action];
        
        height += actionHeight;
    }

    NSLog(@"WWW Height= %d", height);
    
    /*
    NSString *stickerActionType = msg.content[@"sticker-action"][@"action-type"];
    NSArray *stickerActions = msg.content[@"sticker-action"][@"action-data"];
    NSLog(@"Sticker action = %@", stickerActions);
    NSDictionary *labelStringAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12.0f]};
    if (stickerActions != nil && stickerActions.count == 2 && [stickerActionType isEqualToString:@"confirm"]) {
        int currButtonStartY = 0;
        for (int i=0; i<stickerActions.count; i++) {
            NSDictionary *stickerAction = [stickerActions objectAtIndex:i];
            NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString:[stickerAction objectForKey:@"label"] attributes:labelStringAttributes];
            int buttonHeight = MAX(CC_STICKER_ACTION_BUTTON_MIN_HEIGHT, [labelText boundingRectWithSize:CGSizeMake((CC_STICKER_BUBBLE_WIDTH - 10)/2, 1800) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height + 10);
            if (currButtonStartY < buttonHeight) {
                currButtonStartY = buttonHeight;
            }
        }
        height += currButtonStartY;
    }else if(![stickerActionType isEqualToString:@"text"] && stickerActions != nil && stickerActions.count > 0) {
        // add actions
        int currButtonStartY = 0;
        for (int i=0; i<stickerActions.count; i++) {
            NSDictionary *stickerAction = [stickerActions objectAtIndex:i];
            NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString:[stickerAction objectForKey:@"label"] attributes:labelStringAttributes];
            int buttonHeight = MAX(CC_STICKER_ACTION_BUTTON_MIN_HEIGHT, [labelText boundingRectWithSize:CGSizeMake(CC_STICKER_BUBBLE_WIDTH - 10, 1800) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height + 10);
            currButtonStartY += buttonHeight;
        }
        height += currButtonStartY;
    }
     */
    
    //------------------------------
    //
    // Part F: Status
    //
    
    // (Status is shown to the side of the cell, so doesn't affect to the height)

    
    // calculate cell width
    CGRect screenRect = [UIScreen mainScreen].applicationFrame;
    float cellWidth = screenRect.size.width;
    
    return CGSizeMake(cellWidth, height);
}

- (void)prepareForReuse {
    
    // Reset sticker object container
    for (UIView *v in [stickerObjectContainer subviews]) {
        [v removeFromSuperview];
    }
    
    // Reset sticker action container
    for (UIView *v in [stickerActionsContainer subviews]) {
        [v removeFromSuperview];
    }

   
}

@end
