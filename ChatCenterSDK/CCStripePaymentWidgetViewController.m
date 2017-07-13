//
//  CCStripePaymentWidgetViewController.m
//  ChatCenterDemo
//
//  Created by GiapNH on 6/21/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import "CCStripePaymentWidgetViewController.h"
#import "ChatCenterPrivate.h"
#import "CCConstants.h"
#import "CCJSQMessage.h"
#import "CCChatViewController.h"
#import "CCCommonWidgetPreviewViewController.h"

@interface CCStripePaymentWidgetViewController ()

@end

@implementation CCStripePaymentWidgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ///
    /// Cancel button
    ///
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CCcancel_btn"] style:UIBarButtonItemStyleDone target:self action: @selector(pressClose)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    ///
    /// Next button
    ///
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Next") style:UIBarButtonItemStylePlain target:self action:@selector(pressNext)];
    self.navigationItem.rightBarButtonItem = nextButton;
    
    ///
    /// Navigation title
    ///
    [self setTitle:CCLocalizedString(@"Ask for Payment")];
    
    [self.btnCurrency setTintColor:[CCConstants sharedInstance].baseColor];
    [self.btnCurrency.imageView setTintColor:[CCConstants sharedInstance].baseColor];
    self.tvPaymentTitle.delegate = self;
}

- (void) pressClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) pressNext {
    if ([self validateContent]) {
        CCCommonWidgetPreviewViewController *vc = [[CCCommonWidgetPreviewViewController alloc] initWithNibName:@"CCCommonWidgetPreviewViewController" bundle:nil];;
        [vc setMessage:[self createMessage]];
        vc.delegate = self.delegate;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) showAlert:(NSString *)alertMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:CCLocalizedString(@"OK")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL) validateContent {
    if ([[_tvPaymentTitle.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] isEqualToString:@""]) {
        [self showAlert:CCLocalizedString(@"Please fill in items.")];
        return NO;
    }
    
    NSString *amountString = _tfAmount.text;
    double amount = [amountString doubleValue];
    if ([_btnCurrency.titleLabel.text.lowercaseString isEqualToString:@"usd"]) {
        if (amount < 0.5) {
            [self showAlert:CCLocalizedString(@"Requires the payment amount to be at least 50 cent(or 100 JPY)")];
            return NO;
        }
    } else if ([_btnCurrency.titleLabel.text.lowercaseString isEqualToString:@"jpy"]) {
        if (amount < 100) {
            [self showAlert:CCLocalizedString(@"Requires the payment amount to be at least 50 cent(or 100 JPY)")];
            return NO;
        }
    }
    return YES;
}

- (CCJSQMessage *)createMessage {
    CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:@""];
    msg.type = CC_RESPONSETYPESTICKER;
    msg.content = @{
                    CC_MESSAGE: @{@"text":_tvPaymentTitle.text},
                    CC_STICKER_ACTION: [self getStickerAction],
                    CC_STICKER_TYPE:@"payment",
                    @"uid": [(CCChatViewController *)self.delegate generateMessageUniqueId]
                    };
    
    return msg;
}

-(NSDictionary *)getStickerAction {
    NSString *amountString = _tfAmount.text;
    double amount = [amountString doubleValue];
    NSString *label = @"Pay";
    if ([_btnCurrency.titleLabel.text.lowercaseString isEqualToString:@"usd"]) {
        label = [NSString stringWithFormat:CCLocalizedString(@"Pay %@ now"), [NSString stringWithFormat:@"$%.2f", amount]];
        amount *= 100; // 1usd = 100 cent
    } else if ([_btnCurrency.titleLabel.text.lowercaseString isEqualToString:@"jpy"]) {
        label = [NSString stringWithFormat:CCLocalizedString(@"Pay %@ now"), [NSString stringWithFormat:@"%d円", (int)amount]];
    }
    
    NSDictionary *stickerAction = @{
                                    @"action-type": @"select",
                                    @"action-data":
                                        @[
                                            @{
                                                @"label": label,
                                                @"currency": [_btnCurrency.titleLabel.text lowercaseString],
                                                @"amount": @((float)amount)
                                            }
                                        ]
                                    };
    return stickerAction;
}

- (IBAction)onChangeCurrencyButtonClicked:(id)sender {
    NSArray *currencies = @[@"USD", @"JPY"];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Please select a currency") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    for (NSString *currency in currencies) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:currency style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.btnCurrency setTitle:currency forState: UIControlStateNormal];
        }];
        [alertVC addAction:action];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Textview delegate
- (void)textViewDidChange:(UITextView *)textView {
    NSString *inputText = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    long textLenght = inputText.length;
    if (textLenght > CCWidgetInputTitleLimit) {
        textView.text = [inputText substringToIndex:CCWidgetInputTitleLimit];
        CCAlertView *alert = [[CCAlertView alloc] initWithController:self title:nil message:[NSString stringWithFormat:CCLocalizedString(@"Please input %d characters or less."), CCWidgetInputTitleLimit]];
        [alert addActionWithTitle:CCLocalizedString(@"OK") handler:nil];
        [alert show];
    }
}
@end
