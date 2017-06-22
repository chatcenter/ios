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
#import "CCConstants.h"

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
    self.noteTextView.delegate = self;
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
    [[CCConnectionHelper sharedClient] updateChannel:self.channelId channelInformations:nil note:self.noteTextView.text completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL reached = textView.text.length + (text.length - range.length) <= CCNoteInputtextLimit;
    if (!reached) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"Please input %d characters or less.", CCNoteInputtextLimit] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    return reached;
}

@end
