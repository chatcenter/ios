//
//  CCYesNoQuestionCreatorViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 3/2/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCYesNoQuestionCreatorViewController.h"
#import "ChatCenterPrivate.h"
#import "CCJSQMessage.h"
#import "CCConstants.h"

@interface CCYesNoQuestionCreatorViewController ()

@end

@implementation CCYesNoQuestionCreatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    instructionText.text = CCLocalizedString(@"Please input question");
    
    // hide keyboard if user tap outside of input-area
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [self.navigationController.navigationBar addGestureRecognizer:tap2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getTitle {
    return CCLocalizedString(@"Yes/No");
}

- (void)dismissKeyboard {
    [questionContent resignFirstResponder];
}

- (CCJSQMessage *)createMessage {
    CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:@""];
    msg.type = CC_RESPONSETYPESTICKER;
    msg.content = @{
                    @"message": @{@"text":questionContent.text},
                    @"sticker-action": @{
                            @"action-type": @"confirm",
                            @"action-data": @[@{
                                                  @"label": CCLocalizedString(@"Yes"),
                                                  @"value":@{@"answer":@"true"}
                                                  }, @{
                                                  @"label": CCLocalizedString(@"No"),
                                                  @"value": @{@"answer":@"false"}
                                                  }]
                            }, // END Sticker action
                    @"uid": [self generateMessageUniqueId]
                    };
    return msg;
}

- (BOOL)validInput {
    if (questionContent.text != nil && [questionContent.text length] > 0) {
        return YES;
    } else {
        //TODO Show dialog
        return NO;
    }
}

- (void)cancel {
    [self dismissKeyboard];
    [super cancel];
}

- (void)preview {
    [self dismissKeyboard];
    [super preview];
}

@end
