//
//  CCCommonStickerCreatorViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 3/2/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCCommonStickerCreatorViewController.h"
#import "ChatCenterPrivate.h"
#import "CCJSQMessage.h"
#import "CCCommonStickerPreviewCollectionViewCell.h"
#import "CCConstants.h"


@interface CCCommonStickerCreatorViewController ()

@end

@implementation CCCommonStickerCreatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // disable tranclucent for navigation bar
    self.navigationController.navigationBar.translucent = NO;
    
    // show sticker creator view
    [self showStickerCreatorView];
}

- (void)showStickerCreatorView {
    if (previewView != nil) {
        [previewView removeFromSuperview];
        previewView = nil;
    }
    
    [self setTitle:[self getTitle]];
    
    // cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    // preview button
    UIBarButtonItem *previewButton = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Preview") style:UIBarButtonItemStylePlain target:self action:@selector(preview)];
    [self.navigationItem setRightBarButtonItem:previewButton];
}

- (void)showPreviewView {
    previewView = [self createPreviewView];
    [self.view addSubview:previewView];
    
    [self setTitle:CCLocalizedString(@"Preview")];
    
    // cancel preview button
    UIBarButtonItem *cancelPreviewButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPreview)];
    [self.navigationItem setLeftBarButtonItem:cancelPreviewButton];
    
    // send button
    UIBarButtonItem *previewButton = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Send") style:UIBarButtonItemStylePlain target:self action:@selector(send)];
    [self.navigationItem setRightBarButtonItem:previewButton];
}

- (UIView *)createPreviewView {
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    UIScrollView *view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5f]];
    
    // create preview cell
    CCJSQMessage *msg = [self createMessage];
    CGSize previewCellSize = [CCCommonStickerPreviewCollectionViewCell estimateSizeForMessage:msg atIndexPath:nil hasPreviousMessage:nil options:0 withListUser:nil];
    CCCommonStickerPreviewCollectionViewCell *previewCell = (CCCommonStickerPreviewCollectionViewCell *)[self viewFromNib:@"CCCommonStickerPreviewCollectionViewCell"];
    previewCell.frame = CGRectMake(width / 2 - previewCellSize.width / 2, 10, previewCellSize.width, previewCellSize.height);
//    [previewCell setMessage:msg atIndexPath:nil withListUser:nil];
    
    
    [previewCell setupWithIndex:nil message:msg avatar:nil textviewDelegate:nil delegate:nil options:0];
    
    view.contentSize = CGSizeMake(previewCellSize.width, previewCellSize.height + 20);
    [view addSubview:previewCell];
    
    return view;
}

- (UIView *)viewFromNib:(NSString *)nibName {
    NSArray *nibViews = [SDK_BUNDLE loadNibNamed:nibName owner:nil options:nil];
    UIView *view = [nibViews objectAtIndex:0];
    return view;
}

- (NSString *)getTitle {
    return @"";
}

- (CCJSQMessage *)createMessage {
    return nil;
}

- (BOOL)validInput {
    return NO;
}

- (void)setChannelId:(NSString *)newChannelId {
    channelId = newChannelId;
}

- (void)setUserId:(NSString *)newUserId {
    userId = newUserId;
}

- (void)setDelegate:(id<CCCommonStickerCreatorDelegate>)newDelegate {
    delegate = newDelegate;
}

- (void)cancel {
    NSLog(@"Cancel");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)preview {
    NSLog(@"Preview");
    if ([self validInput]) {
        [self showPreviewView];
    }
}

- (void)cancelPreview {
    NSLog(@"Preview_cancelPreview");
    [self showStickerCreatorView];
}

- (void)send {
    NSLog(@"Preview_send");
    if ([self validInput] && delegate != nil) {
        CCJSQMessage *msg = [self createMessage];
        [delegate sendStickerWithType:msg.type andContent:msg.content];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSString *)generateMessageUniqueId {
    NSString *generatedUniqueId = [NSString stringWithFormat:@"%@-%@-%ld", channelId, userId, (long)([[NSDate date] timeIntervalSince1970] * 1000)];
    return generatedUniqueId;
}

@end
