//
//  CCCommonWidgetEditorViewController.m
//  ChatCenterDemo
//
//  Created by VietHD on 11/10/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCCommonWidgetEditorViewController.h"
#import "ChatCenterPrivate.h"
#import "CCCommonWidgetPreviewViewController.h"
#import "CCCommonWidgetEditorDelegate.h"
#import "CCConstants.h"

@interface CCCommonWidgetEditorViewController ()

@end
@implementation CCCommonWidgetEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    cancelButton.tintColor = [UIColor blackColor];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    self.navigationItem.rightBarButtonItem.tintColor = [[CCConstants sharedInstance] baseColor];
    
    self.navigationItem.title = CCLocalizedString(@"Question");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)setDelegate:(id)newDelegate {
    delegate = newDelegate;
}

- (void)preview {
    if ([self validInput]) {
        [self showPreviewView];
//        [self.navigationController performSegueWithIdentifier:@"preview" sender:self];
    }
}

- (void) showPreviewView {
    CCCommonWidgetPreviewViewController *previewController = [[CCCommonWidgetPreviewViewController alloc] initWithNibName:@"CCCommonWidgetPreviewViewController" bundle:SDK_BUNDLE];    
    [previewController setMessage:[self createMessage]];
    previewController.delegate = delegate;
    [self.navigationController pushViewController:previewController animated:YES];
}

- (CCJSQMessage *)createMessage {
    return nil;
}

- (void)cancel {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)generateMessageUniqueId {
    NSString *generatedUniqueId = [NSString stringWithFormat:@"%@-%@-%ld", channelId, userId, (long)([[NSDate date] timeIntervalSince1970] * 1000)];
    return generatedUniqueId;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"preview"]) {
        if ([self validInput]) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"preview"]) {
        CCCommonWidgetPreviewViewController *vc= [segue destinationViewController];
        [vc setMessage:[self createMessage]];
        vc.delegate = delegate;
    }
}

@end
