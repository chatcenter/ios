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
#import "CCConnectionHelper.h"
#import "CCQuestionComponent.h"
#import "CCDefaultSelectionQuestionComponent.h"
#import "UIImage+CCSDKImage.h"
#import "CCLiveLocationTask.h"

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

    if (([CCConstants sharedInstance].isAgent && (options & CCStickerCollectionViewCellOptionShowAsAgent))
        || (![CCConstants sharedInstance].isAgent && !(options & CCStickerCollectionViewCellOptionShowAsAgent))) {
        options |= CCStickerCollectionViewCellOptionShowAsMyself;
    }
    
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
        self.stickerContainer.backgroundColor = [UIColor clearColor];
        //
        // Text chat is shown with conventional bubble style coloring
        //
        if(options & CCStickerCollectionViewCellOptionShowAsMyself) {
            self.stickerContainer.backgroundColor = [[CCConstants sharedInstance] baseColor];
            self.stickerContainer.layer.borderColor = [[CCConstants sharedInstance] baseColor].CGColor;
            self.stickerContainer.layer.borderWidth = 1.0;
        } else {
            stickerActionsContainer.layer.borderColor = [[CCConstants sharedInstance] baseColor].CGColor;
            self.stickerContainer.layer.borderColor = [[CCConstants sharedInstance] baseColor].CGColor;
            self.stickerContainer.layer.borderWidth = 1.0;
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
        self.cellTopLabel.text = [[CCJSQMessagesTimestampFormatter sharedFormatter] relativeDateForDate:msg.date];
    } else {
        self.cellTopLabelHeight.constant = 0;
    }
    

    
    index = indexPath.row;
    NSLog(@"index = %ld", (long)index);
    
    //------------------------------
    //
    // Part B: Sender name and time
    //
    
    if (options & CCStickerCollectionViewCellOptionShowName) {
        self.stickerTopLabelHeight.constant = 20;
        if (([CCConstants sharedInstance].isAgent && (options & CCStickerCollectionViewCellOptionShowAsAgent))
            || (![CCConstants sharedInstance].isAgent && !(options & CCStickerCollectionViewCellOptionShowAsAgent))) {
            self.stickerTopLabel.text = [NSString stringWithFormat:@"%@  %@", [[CCJSQMessagesTimestampFormatter sharedFormatter] timeForDate:msg.date], msg.senderDisplayName];
        } else {
            self.stickerTopLabel.text = [NSString stringWithFormat:@"%@  %@", msg.senderDisplayName, [[CCJSQMessagesTimestampFormatter sharedFormatter] timeForDate:msg.date]];
        }
    }else{
        self.stickerTopLabelHeight.constant = 0;
    }
    
    //------------------------------
    //
    // Part C: Message(or header)
    //
    
    NSAttributedString *message = [self createMessageString:msg];
    
    // Suggestion and image shouldn't have a message field
    if (message != nil && ![msg.type isEqualToString:CC_RESPONSETYPESUGGESTION] && ![msg.type isEqualToString:CC_STICKERTYPEIMAGE]) {
        CCMessageHeaderParameters *params = [[self class] getMessageHeaderParameterForMessage:msg];
        
        if(params.iconImage) {
            [headerImageView setImage:params.iconImage];
            [headerImageView setHidden:NO];
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
            self.discriptionView.textColor = [[CCConstants sharedInstance] defaultChatTextColor];
        } else if ( options & CCStickerCollectionViewCellOptionShowAsMyself ) {
            // For normal message cell, use white for outgoing cell
            self.discriptionView.textColor = [UIColor whiteColor];
        } else {
            // For normal message cell, use black for incoming cell
            self.discriptionView.textColor = [[CCConstants sharedInstance] defaultChatTextColor];
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
            [imageView sd_setImageWithURL:[NSURL URLWithString:[msg.content[CC_STICKERCONTENT][CC_THUMBNAILURL] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]] completed:^(UIImage *image, NSError *error, CCSDImageCacheType cacheType, NSURL *imageURL) {
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
        [imageView sd_setImageWithURL:[NSURL URLWithString:[[[msg.content[CC_STICKERCONTENT][CC_THUMBNAILURL] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] stringByReplacingOccurrencesOfString:@"|" withString:@""] ]  completed:^(UIImage *image, NSError *error, CCSDImageCacheType cacheType, NSURL *imageURL) {
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
    [self setupQuestionComponentWithMessage:msg];
    
    
    //------------------------------
    //
    // Part F: Status
    //
    [self setMessageStatusLabel:msg delegate:delegate];

    //------------------------------
    //
    // Part J: Live Label
    //
    NSString *stickerType = [msg getStringAtPath:@"sticker-type"];
    if(stickerType != nil && [stickerType isEqualToString:CC_STICKERTYPECOLOCATION]) {
        //
        // Show list users whom is sharing live location
        //
        NSDictionary *stickerData = [msg getDictionaryAtPath:@"sticker-content/sticker-data"];
        if (stickerData != nil) {
            int avatarWidth = 20;
            int avatarHeight = 20;
            int padding = 4;
            NSArray *users = stickerData[@"users"];
            if(users.count > 0) {
                self.headerLiveWidgetLabel.hidden = NO;
            } else {
                self.headerLiveWidgetLabel.hidden = YES;
            }
            for(int i = 0; i < users.count; i++) {
                NSDictionary *user = users[i];
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.backgroundColor = [UIColor whiteColor];
                imageView.frame = CGRectMake((avatarWidth + padding) * i, 0, avatarWidth, avatarHeight);
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [self setupAvatar:user imageView:imageView];
                imageView.layer.cornerRadius = avatarWidth / 2;
                imageView.clipsToBounds = YES;
                [self.liveUsersContainer addSubview:imageView];
            }
            self.liveUsersContainer.backgroundColor = [UIColor clearColor];
            float containerWidth = (avatarWidth + padding) * users.count > 60.0 ? 60.0:(avatarWidth + padding) * users.count;
            self.liveUserContainerWidth.constant = containerWidth;
            self.liveUsersContainer.contentSize = CGSizeMake((avatarWidth + padding) * users.count, avatarHeight);
            self.liveUsersContainer.hidden = NO;
        }
    } else {
        self.headerLiveWidgetLabel.hidden = YES;
        self.liveUsersContainer.hidden = YES;
    }

    return YES;
}

- (void)setupQuestionComponentWithMessage:(CCJSQMessage*)msg {
    [self setupQuestionComponentWithMessage:msg needRecreateSubviews:YES];
}

- (void)setupQuestionComponentWithMessage:(CCJSQMessage*)msg needRecreateSubviews:(BOOL)needRecreateSubviews {
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
                id obj;
                if ([stickerActionsResponses_wrapped[0] objectForKey:@"actions"] != nil) {
                    obj = [stickerActionsResponses_wrapped[0] objectForKey:@"actions"];
                }else{
                    obj = [stickerActionsResponses_wrapped[0] objectForKey:@"action"];
                }
                
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
        
        CCQuestionComponent *v;
        if (needRecreateSubviews) {
            v = [CCQuestionComponent componentForStickerAction:action  delegate:self];
        } else {
            for (UIView *view in stickerActionsContainer.subviews) {
                if ([view isKindOfClass:[CCQuestionComponent class]]) {
                    v = (CCQuestionComponent *)view;
                }
            }
        }
        
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

-(void)setupAvatar:(NSDictionary *)user imageView:(UIImageView *)imageView{
    NSString *userUid = user[@"id"];
    NSLog(@"Load avatar of user %@", userUid);
    NSString *firstCharacter = [user[@"display_name"] substringToIndex:1];
    UIImage *textImage = [[ChatCenter sharedInstance] createAvatarImage:firstCharacter width:32.0 height:32.0 color:[[ChatCenter sharedInstance] getRandomColor:user[@"id"]] fontSize:24 textOffset:1.5];
    if (textImage != nil) {
        imageView.image = textImage;
    }
    
    if (user[@"icon_url"] != nil && !([user[@"icon_url"] isEqual:[NSNull null]])) {
        if([[CCConnectionHelper sharedClient] getNetworkStatus] != CCNotReachable) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:user[@"icon_url"]]];
        }
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
    NSArray *stickerActions = [msg getArrayAtPath:@"sticker-action/action-data"];
    if (stickerActions != nil && stickerActions.count > 0) {
        img = [UIImage SDKImageNamed:@"questionBubbleIcon"];
    }
    NSString *stickerType = [msg getStringAtPath:@"sticker-type"];
    if (stickerType != nil && [stickerType isEqualToString:@"file"]) {
        img = [UIImage SDKImageNamed:@"CCmenu_icon_image"];
    }

    //
    // Map Widget
    //
    NSDictionary *location = [msg getDictionaryAtPath:@"sticker-content/sticker-data/location"];
    if(location) {
        NSString *stickerType = [msg getStringAtPath:@"sticker-type"];
        if (stickerType != nil && [stickerType isEqualToString:CC_STICKERTYPECOLOCATION]) {
            img = [UIImage SDKImageNamed:@"live-location-icon"];
        } else {
            img = [UIImage SDKImageNamed:@"CCmenu_icon_location"];
        }
    }
    
    //
    // Calendar Widget
    //
    NSNumber *st = [msg getNumberAtPath:@"sticker-action/action-data/0#/value/start"];
    if(st != nil ) {
        img = [UIImage SDKImageNamed:@"CCmenu_icon_calendar"];
    }
    
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

    NSString *stickerType = [msg.content objectForKey:CC_STICKER_TYPE];
    if ([stickerType isEqualToString:CC_STICKERTYPECOLOCATION]) {
        text = CCLocalizedString(@"Live Location");
    } else if ([stickerType isEqualToString:CC_STICKERTYPELOCATION] && (text == nil || [text isEqualToString:@""])) {
        text = CCLocalizedString(@"Venue");
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
    NSString * actionType = _msg.content[@"sticker-action"][@"action-type"];
    if (actionType != nil) {
        NSDictionary *data = @{         @"msgId" : _msg.uid,
                                        @"action-type" : actionType,
                                        @"stickerActions" : items,
                                        @"sticker_type": _msg.type ,
                                        @"reacted" : isReacted};
        [[NSNotificationCenter defaultCenter] postNotificationName:kCCNoti_UserReactionToSticker object:self userInfo:data];
    }
}

- (void)userDidReactOnPulldownWidget {
    if(_msg == nil || _msg.status == CC_MESSAGE_STATUS_DELIVERING || _msg.status == CC_MESSAGE_STATUS_SEND_FAILED) {
        return;
    }

    NSDictionary *data = @{         @"msgId" : _msg.uid,
                                    @"action-type" : _msg.content[@"sticker-action"][@"action-type"],
                                    
                                    @"sticker_type": _msg.type};
    [[NSNotificationCenter defaultCenter] postNotificationName:kCCNoti_UserReactionToPulldownWidget object:self userInfo:data];
}

- (void) onActionClicked:(UIButton*)sender {
    if(_msg == nil || _msg.status == CC_MESSAGE_STATUS_DELIVERING || _msg.status == CC_MESSAGE_STATUS_SEND_FAILED) {
        return;
    }
    NSLog(@"onActionClicked");
    NSInteger indexAction = [sender tag];
    NSArray *stickerActions = _msg.content[@"sticker-action"][@"action-data"];
    if (stickerActions != nil && indexAction < stickerActions.count) {
        
        //
        // The action just have chosen by the user
        //
        NSDictionary *stickerAction = [stickerActions objectAtIndex:indexAction];
        
        //
        // The reaction which already stored
        //
        NSArray *stickerActionsResponses = _msg.content[@"sticker-action"][@"action-response-data"];
        NSString *isReacted = @"false";
        
        for(int j=0; j<stickerActionsResponses.count; j++) {
            NSDictionary *responseAction = [stickerActionsResponses objectAtIndex:j];
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
    NSLog(@"Message content = %@", _msg.content);
    if (_msg.content[CC_STICKERCONTENT][CC_STICKERCONTENT_ACTION] != nil) {
        NSMutableDictionary *data = [@{ @"msgId":_msg.uid, CC_STICKERCONTENT_ACTION:_msg.content[CC_STICKERCONTENT][CC_STICKERCONTENT_ACTION]} mutableCopy];
        if(_msg.content[CC_STICKER_TYPE] != nil) {
            [data setValue:_msg.content[CC_STICKER_TYPE] forKey:CC_STICKER_TYPE];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kCCNoti_UserReactionToStickerContent object:nil userInfo:data];
    }
}

- (void)userDidBeginEditingTextView {
    NSDictionary *data = @{@"msgId" : _msg.uid};
    [[NSNotificationCenter defaultCenter] postNotificationName:kCCNoti_TextViewDidBeginEditing object:self userInfo:data];
}

+ (CGSize) estimateSizeForMessage:(CCJSQMessage *)msg
                      atIndexPath:(NSIndexPath *)indexPath
               hasPreviousMessage:(CCJSQMessage *)preMsg
                          options:(CCStickerCollectionViewCellOptions)options
                     withListUser:(NSArray *)users
{
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
    NSArray *stickerActions = msg.content[@"sticker-action"][@"action-data"];
    

    
    if (stickerActions != nil ) {
//    if (stickerActions != nil && [stickerActionType isEqualToString:@"confirm"]) {
        
        NSDictionary *action =  msg.content[@"sticker-action"];
        // If the stickerActionType is "confirm" convert it to YesNo Question Widget
        action = [self convertStickerActionToMoonStyleIfNeeded:action];


        CGFloat actionHeight = [CCQuestionComponent calculateHeightForStickerAction:action];
        
        height += actionHeight;
    }

    NSLog(@"WWW Height= %d", height);
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

- (void)resetSelection {
    // Reset sticker action container
    for (UIView *v in [stickerActionsContainer subviews]) {
        [v removeFromSuperview];
    }
    
    [self setupQuestionComponentWithMessage:_msg];
}

@end
