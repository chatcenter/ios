//
//  CCStickerWidgetViewController.m
//  ChatCenterDemo
//
//  Created by GiapNH on 4/18/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import "CCStickerWidgetViewController.h"
#import "CCConnectionHelper.h"
#import "CCConstants.h"
#import "CCRSDFDatePickerViewController.h"
#import "CCCoredataBase.h"
#import "ChatCenterPrivate.h"
#import "CCSSKeychain.h"
#import "CCStickerCollectionViewCell.h"
#import "CCThumbCollectionViewCell.h"
#import "CCYesNoCollectionViewCell.h"
#import "CCChoiceButton.h"
#import "CCIDMPhoto.h"
#import "CCIDMPhotoBrowser.h"
#import "CCCalendarTimePickerController.h"
#import "CCSVProgressHUD.h"
#import "CCPhraseStickerViewController.h"
#import "CCPropertyCollectionViewCell.h"
#import "CCCommonStickerPreviewCollectionViewCell.h"
#import "ChatCenterClient.h"
#import "CCLocationPreviewViewController.h"
#import "CCConstants.h"
#import "CCYesNoQuestionCreatorViewController.h"
#import "CCCommonWidgetPreviewViewController.h"
#import "CCPhoneStickerCollectionViewCell.h"
#import "CCParseUtils.h"
#import "CCCommonWidgetCollectionViewCell.h"

@interface CCStickerWidgetViewController () {
    NSDictionary *cellNibNames;
    NSMutableArray *channelUsers;
    NSString *identifier;
}

@end

@implementation CCStickerWidgetViewController

NSString *kCCCommonStickerWidgetCollectionViewCell = @"CCCommonStickerPreviewCollectionViewCell";
NSString *kCCStickerWidgetNoContentView = @"CCStickerWidgetNoContentView";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messages = [[NSMutableArray alloc] init];
    self.navigationItem.title = self.titleNavigation;
    self.noDataMessage.text = CCLocalizedString(@"No Message yet");
    self.noDataMessage.font = [UIFont systemFontOfSize:14.0f];
    self.noDataMessage.textAlignment = NSTextAlignmentCenter;
    self.noDataMessage.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    identifier = @"CCCommonWidgetCollectionViewCell";
    self.noDataMessage.hidden = YES;
    [self.noDataMessage setTextContainerInset:UIEdgeInsetsMake(0, 5.0, 0, 5.0)];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    channelUsers = [[NSMutableArray alloc] init];
    UINib *nib = [UINib nibWithNibName:@"CCCommonWidgetCollectionViewCell" bundle:SDK_BUNDLE];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[CCConnectionHelper sharedClient] setCurrentView:self];
    
    // reload data
    [self loadData:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load Data

- (void) loadData:(NSNumber *)lastId {
    [[CCConnectionHelper sharedClient] loadSticker:YES channelId:self.channelId stickerType:self.stickerType limit:CCloadLoacalMessageLimit lastId:lastId completionHandler:^(NSArray *result, NSError *error, NSURLSessionDataTask *task) {
        if (result != nil) {
            NSMutableArray *data = [result mutableCopy];
            [self createMessageObjects:data lastId:lastId];
        }
        [self.collectionView reloadData];
        if (_messages.count == 0) {
            self.noDataMessage.hidden = NO;
        } else {
            self.noDataMessage.hidden = YES;
        }
    }];
}

#pragma mark -- Scroll Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        long index = [self.messages count] - 1;
        if (indexPath.item == index) {
            if ([self.messages count] > 0) {
                CCJSQMessage *msg = self.messages[index];
                NSNumber *lastId = msg.uid;
                [self loadData:lastId];
            }
            break;
        }
    }
}

#pragma mark - Collection View

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _messages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CCJSQMessage *msg = self.messages[indexPath.row];
    CCJSQMessage *preMsg;
    if(indexPath.item > 1) preMsg = [self.messages objectAtIndex:indexPath.item-1];
    
    NSLog(@"Index: %ld - type: %@", (long)indexPath.item, msg.type);
    
    //
    // Get cell options
    CCStickerCollectionViewCellOptions options = [self getStickerCellOptionsForIndexPath:indexPath message:msg previousMessage:preMsg];
    // Specify identifier
    //
    CCCommonWidgetCollectionViewCell *cell;
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    //
    // Initialization
    //
    if (cell) {
        BOOL success = [cell setupWithIndex:indexPath message:msg avatar:nil delegate:nil options:options];
        if(success) {
            [cell setUserInteractionEnabled:NO];
            return cell;
        } else {
            NSLog(@"Had an issue in cell initialization at indexPath %@. Try creating generic cell", indexPath);
        }
    }
   
    return cell;
}

#pragma mark - Collection view delegate flow layout overrides

- (CGSize)collectionView:(CCJSQMessagesCollectionView *)collectionView
                  layout:(CCJSQMessagesCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCJSQMessage *msg = self.messages[indexPath.row];
    CCJSQMessage *preMsg;
    if (indexPath.item > 1) {
        preMsg = [self.messages objectAtIndex:indexPath.item - 1];
    }
    
    CCStickerCollectionViewCellOptions options = [self getStickerCellOptionsForIndexPath:indexPath message:msg previousMessage:preMsg];
    
    CGSize size = [CCCommonWidgetCollectionViewCell estimateSizeForMessage:msg atIndexPath:indexPath hasPreviousMessage:nil options:options withListUser:channelUsers];

    return size;
}

- (CGFloat)collectionView:(CCJSQMessagesCollectionView *)collectionView
                   layout:(CCJSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self checkShowDateForMessageAtIndexPath:indexPath]) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(CCJSQMessagesCollectionView *)collectionView
                   layout:(CCJSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    CCJSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.uid]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        CCJSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(CCJSQMessagesCollectionView *)collectionView
                   layout:(CCJSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}


- (CCStickerCollectionViewCellOptions)getStickerCellOptionsForIndexPath:(NSIndexPath*)indexPath message:(CCJSQMessage*)msg previousMessage:(CCJSQMessage*)preMsg {
    
    CCStickerCollectionViewCellOptions options = 0;
    
    //--------------------------------------------------------------------
    //
    // Cell options
    //
    //--------------------------------------------------------------------
    
    ///Display name?
    if (preMsg != nil || msg.senderDisplayName != nil) {
        options |= CCStickerCollectionViewCellOptionShowName;
    }
    ///is myself?
    if ([msg.senderId isEqual:self.uid]){
        options |= CCStickerCollectionViewCellOptionShowAsMyself;
    }
    ///Is Widget?
    if ([msg.content objectForKey:@"sticker-action"] || [msg.content objectForKey:@"sticker-content"]) {
        options |= CCStickerCollectionViewCellOptionShowAsWidget;
    }
    ///Is Agent?
    if (msg.isAgent) {
        options |= CCStickerCollectionViewCellOptionShowAsAgent;
    }
    
    return options;
}


-(void)createMessageObjects:(NSMutableArray *)messages lastId: (NSNumber *)lastId
{
    if (messages == nil || [messages isEqual:[NSNull null]]) {
        return;
    }
    if (lastId == nil) {
        self.messages = [NSMutableArray array];
    }
    for (NSDictionary* message in messages) {
        
        if ([message objectForKey:@"content"] == nil
            || [[message objectForKey:@"content"] isEqual:[NSNull null]]
            || [message objectForKey:@"type"] == nil) {
            continue;
        }
        
        NSString *contentType = [message objectForKey:@"type"];
        
        // create content
        CCJSQMessage *msg = nil;
        
        if (contentType != nil && ![contentType isEqual:[NSNull null]] && [contentType isEqualToString:CC_RESPONSETYPESTICKER]) {
            // for sticker
            NSMutableDictionary *content = [[message objectForKey:@"content"] mutableCopy];
            if(([content objectForKey:@"message"] != nil && ![[message objectForKey:@"message"] isEqual:[NSNull null]])
               || ([content objectForKey:@"sticker-action"] != nil && ![[message objectForKey:@"sticker-action"] isEqual:[NSNull null]])
               || ([content objectForKey:@"sticker-content"] != nil && ![[message objectForKey:@"sticker-content"] isEqual:[NSNull null]]))
            {
                long createDate = [CCParseUtils longTryGet:message  key:@"created"];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:createDate];
                NSString *displayName = message[@"user"][@"display_name"];
                NSString *senderId = [message[@"user"][@"id"] respondsToSelector:@selector(stringValue)] ? [message[@"user"][@"id"] stringValue]: message[@"user"][@"id"];
                
                msg = [[CCJSQMessage alloc] initWithSenderId:senderId senderDisplayName:displayName date:date text:@""];
                
                int admin = [message[@"user"][@"admin"] intValue];
                NSNumber *uid = message[@"id"];
                BOOL userAdmin = (admin == 1)? YES: NO;
                msg.content = [content copy];
                msg.type = CC_RESPONSETYPESTICKER;
                msg.isAgent = userAdmin;
                msg.uid = uid;
                NSDictionary * user = message[@"user"];
                BOOL isContainsUser = NO;
                for (NSDictionary *channelUser in channelUsers) {
                    if ([[channelUser[@"id"] stringValue] isEqualToString:senderId]) {
                        isContainsUser = YES;
                        break;
                    }
                }
                if (!isContainsUser) {
                    [channelUsers addObject:user];
                }
                
            } else {
                // Nothing was set in sticker content
                continue;
            }
            
        } else {
            // for text message
            continue;
        }
        if ([self.messages count] > 0) {
            for (CCJSQMessage *message in self.messages) {
                if (![message.uid isEqual:msg.uid]) {
                    [self.messages addObject: msg];
                    break;
                }
            }
        } else {
            [self.messages addObject: msg];
        }
    }
}

- (BOOL) checkShowDateForMessageAtIndexPath:(NSIndexPath *)indexPath {
    // check date of current message & previous message
    NSInteger startIndex = 0;
    if(indexPath.item > 1) {
        CCJSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
        CCJSQMessage *preMsg = [self.messages objectAtIndex:indexPath.item - 1];
        NSDate *msgDate = msg.date;
        NSDate *preMsgDate = preMsg.date;
        startIndex = [self checkStartMessageForDate:msgDate];
        if(msgDate == nil || preMsgDate == nil) {
            return YES;
        } else {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
            NSString *msgDateString = [formatter stringFromDate:msgDate];
            NSString *preMsgDateString = [formatter stringFromDate:preMsgDate];
            if(msgDateString != nil && ![msgDateString isEqualToString:preMsgDateString]) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    
    // other case
    return NO;
}

- (NSInteger) checkStartMessageForDate: (NSDate *) date {
    for(NSInteger i = 0; i < self.messages.count ; i++) {
        CCJSQMessage *msg = [self.messages objectAtIndex:i];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
        NSString *msgDateString = [formatter stringFromDate:msg.date];
        NSString *currentDateString = [formatter stringFromDate:date];
        if(msgDateString != nil && [msgDateString isEqualToString:currentDateString]) {
            return i;
        }
    }
    return 0;
}


@end
