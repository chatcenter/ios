//
//  CCNoteEditorViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 11/25/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCNoteEditorViewController.h"
#import "ChatCenterPrivate.h"
#import "CCConnectionHelper.h"

@interface CCNoteEditorViewController ()

@end

@implementation CCNoteEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:CCLocalizedString(@"Note")];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Save") style:UIBarButtonItemStylePlain target:self action:@selector(pressSave)];
    self.navigationItem.rightBarButtonItem = saveButton;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CCBackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(closeModal)];
    self.navigationItem.leftBarButtonItem = closeBtn;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.noteTextView.layer.borderWidth = 1;
    self.noteTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    if (self.noteContent != nil) {
        self.noteTextView.text = self.noteContent;
    }
}

- (void)closeModal {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) pressSave {
    [[CCConnectionHelper sharedClient] updateChannel:self.channelId channelInformations:nil note:self.noteTextView.text completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
