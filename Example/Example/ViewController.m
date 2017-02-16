//
//  ViewController.m
//  Example
//
//  Created by AppSocially on 2016/08/29.
//  Copyright © 2016年 AppSocially inc. All rights reserved.
//

#import "ViewController.h"
#import "ChatCenter.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *familyName;
@property (weak, nonatomic) IBOutlet UITextField *email;

- (IBAction)didTapChat:(id)sender;
- (IBAction)didTapHistory:(id)sender;
- (IBAction)didTapLogout:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //-----------------
    // Set AppToken
    //-----------------
    [ChatCenter setAppToken:@"j4KmracFAqvaMpALRuSz" completionHandler:^{
        ///Please set design custmization
        ///セット完了のコールバックです
        ///SDKのデザインカスタマイズはここに記述してください
        [ChatCenter setHistoryViewTitle:@"Message"];
        [ChatCenter setHistoryViewVoidMessage:@"No chat"];
    }];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSoftKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if([[ud stringForKey:@"isPush"] isEqualToString:@"YES"]){
        UIViewController *historyViewController = [[ChatCenter sharedInstance] getHistoryView:nil];
        [self.navigationController pushViewController:historyViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapChat:(id)sender {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [ud stringForKey:@"deviceToken"];
    
    //-----------------
    // Set TeamID
    //-----------------
    NSString *orgId = @"developer_success";
    
    [[ChatCenter sharedInstance] presentChatView:self
                                          orgUid:orgId
                                       firstName:self.firstName.text
                                      familyName:self.familyName.text
                                           email:self.email.text
                             channelInformations:nil
                                     deviceToken:deviceToken
                               completionHandler:nil];
    
    self.firstName.text = nil;
    self.familyName.text = nil;
    self.email.text = nil;
    [self closeSoftKeyboard];
}

- (IBAction)didTapHistory:(id)sender {
    [[ChatCenter sharedInstance] presentHistoryView:self completionHandler:nil];
}

- (IBAction)didTapLogout:(id)sender {
    [[ChatCenter sharedInstance] signOut];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [ud stringForKey:@"deviceToken"];
    [[ChatCenter sharedInstance] signOutDeviceToken:deviceToken
                                  completionHandler:^(NSDictionary *result, NSError *error) {
                                      [[ChatCenter sharedInstance] signOut];
                                      [ud removeObjectForKey:@"deviceToken"];
                                  }];
}

- (void)closeSoftKeyboard {
    [self.view endEditing: YES];
}

@end
