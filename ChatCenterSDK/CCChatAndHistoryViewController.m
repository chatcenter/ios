//
//  CCChatAndHistoryViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc.on 2015/07/09.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCChatAndHistoryViewController.h"
#import "CCSSKeychain.h"
#import "CCConnectionHelper.h"
#import "CCCoredataBase.h"
#import "CCConstants.h"

@interface CCChatAndHistoryViewController(){
    UIView *borderLine;
    
    BOOL _isFirtBoot;
}

@property (nonatomic) CCChannelType channelType;
@property (nonatomic, copy) void (^closeHistoryViewCallback)(void);
@property (nonatomic) CCHistoryViewController *historyView;

@end

@implementation CCChatAndHistoryViewController

- (id)initWithUserdata:(int)channelType provider:(NSString *)provider
         providerToken:(NSString *)providerToken
   providerTokenSecret:(NSString *)providerTokenSecret
  providerRefreshToken:(NSString *)providerRefreshToken
     providerCreatedAt:(NSDate *)providerCreatedAt
     providerExpiresAt:(NSDate *)providerExpiresAt
      closeViewHandler:(void (^)(void))closeViewHandler;
{
    CCChatAndHistoryViewController *instance;
    instance = [self init];
    if (self) {
        if ([CCSSKeychain passwordForService:@"ChatCenter" account:@"providerCreatedAt"])
        {
            [CCConnectionHelper sharedClient].providerOldCreatedAt = [CCSSKeychain passwordForService:@"ChatCenter" account:@"providerCreatedAt"];
        }
        if ([CCSSKeychain passwordForService:@"ChatCenter" account:@"providerExpiresAt"])
        {
            [CCConnectionHelper sharedClient].providerOldExpiresAt = [CCSSKeychain passwordForService:@"ChatCenter" account:@"providerExpiresAt"];
        }
        
        [CCConnectionHelper sharedClient].provider = provider;
        [CCConnectionHelper sharedClient].providerToken = providerToken;
        [CCConnectionHelper sharedClient].providerTokenSecret = providerTokenSecret;
        [CCConnectionHelper sharedClient].providerRefreshToken = providerRefreshToken;
        
        if (providerCreatedAt != nil)
        {
            double providerCreatedAtDouble = [providerCreatedAt timeIntervalSince1970];
            NSString *providerCreatedAtString = [NSString stringWithFormat:@"%f", providerCreatedAtDouble];
            [CCConnectionHelper sharedClient].providerCreatedAt = providerCreatedAtString;
        }
        if (providerExpiresAt != nil)
        {
            double providerExpiresAtDouble = [providerExpiresAt timeIntervalSince1970];
            NSString *providerExpiresAtString = [NSString stringWithFormat:@"%f", providerExpiresAtDouble];
            [CCConnectionHelper sharedClient].providerExpiresAt = providerExpiresAtString;
        }
        self.channelType = channelType;
        self.closeHistoryViewCallback = closeViewHandler;
    }
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupInitData];

    ///History View
    [CCConnectionHelper sharedClient].twoColumnLayoutMode = YES;
    
    _isFirtBoot = YES;
    
    NSDate *providerCreatedAtDate = nil;
    if ([CCConnectionHelper sharedClient].providerCreatedAt != nil) {
        NSString *providerCreatedAt = [CCConnectionHelper sharedClient].providerCreatedAt;
        double providerCreatedAtDouble = providerCreatedAt.doubleValue;
        providerCreatedAtDate = [NSDate dateWithTimeIntervalSince1970:providerCreatedAtDouble];
    }
    NSDate *providerExpiresAtDate = nil;
    if ([CCConnectionHelper sharedClient].providerExpiresAt != nil) {
        NSString *providerExpiresAt = [CCConnectionHelper sharedClient].providerExpiresAt;
        double providerExpiresAtDouble = providerExpiresAt.doubleValue;
        providerExpiresAtDate = [NSDate dateWithTimeIntervalSince1970:providerExpiresAtDouble];
    }
    self.historyView = [[CCHistoryViewController alloc] initWithUserdata:self.channelType
                                                                                    provider:[CCConnectionHelper sharedClient].provider
                                                                               providerToken:[CCConnectionHelper sharedClient].providerToken
                                                                         providerTokenSecret:[CCConnectionHelper sharedClient].providerTokenSecret
                                                                        providerRefreshToken:[CCConnectionHelper sharedClient].providerRefreshToken 
                                                                           providerCreatedAt:providerCreatedAtDate
                                                                           providerExpiresAt:providerExpiresAtDate
                                                                           completionHandler:self.closeHistoryViewCallback];
    self.historyView.chatAndHistoryViewController = self;
    
    ///Void Chat View
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter" bundle:SDK_BUNDLE];
    self.voidViewController = [storyboard instantiateViewControllerWithIdentifier:@"CCVoidViewController"];
    
    borderLine = [[UIView alloc] initWithFrame:CGRectMake(320, 0, 1, self.view.bounds.size.height)];
    [borderLine setBackgroundColor:[UIColor lightGrayColor]];
    
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(osVersion >= 8.0f)  {  //iOS8~
        [self displayContentController:self.historyView
                                cgrect:CGRectMake(0, -10, 320, self.view.bounds.size.height+10)];
    }else{
        [self displayContentController:self.historyView
                                cgrect:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_isFirtBoot) {
        _isFirtBoot = NO;
        ///These processes are not in viewDidLoad but in here for iOS7(can't get self.view.bounds.size)
        [self displayVoidViewController];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSLog(@"viewWillTransitionToSize: %.2f - %.2f", size.width, size.height);
        NSLog(@"historyView: %.2f - %.2f - %.2f - %.2f", self.historyView.view.frame.origin.x, self.historyView.view.frame.origin.y, self.historyView.view.frame.size.width, self.historyView.view.frame.size.height);
        // Reset history frame
        float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if(osVersion >= 8.0f)  {  //iOS8~
            [self.historyView.view setFrame:CGRectMake(0, -10, 320, size.height+10)];
        } else {
            [self.historyView.view setFrame:CGRectMake(0, 0, 320, size.height)];
        }
        // Reset border line frame
        [borderLine setFrame:CGRectMake(320, 0, 1, size.height)];
        // Reset void view & chat view frame
        [self.voidViewController.view setFrame:CGRectMake(320, 0, size.width-320, size.height)];
        NSLog(@"voidViewController: %.2f - %.2f - %.2f - %.2f", self.voidViewController.view.frame.origin.x, self.voidViewController.view.frame.origin.y, self.voidViewController.view.frame.size.width, self.voidViewController.view.frame.size.height);
        [self.chatViewController.view setFrame:CGRectMake(320, 0, size.width-320, size.height)];
        NSLog(@"chatViewController: %.2f - %.2f - %.2f - %.2f", self.chatViewController.view.frame.origin.x, self.chatViewController.view.frame.origin.y, self.chatViewController.view.frame.size.width, self.chatViewController.view.frame.size.height);
        [self.chatViewController updateViewOrientation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupInitData {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"ChatCenterUserdefaults_currentOrgUid"];
    [ud synchronize];
    [[CCCoredataBase sharedClient] deleteAllChannel];
    [[CCCoredataBase sharedClient] deleteAllOrg];
}

- (void)displayVoidViewController {
    [self displayContentController:self.voidViewController
                            cgrect:CGRectMake(320, 0, self.view.bounds.size.width - 320, self.view.bounds.size.height)];
    
}
- (void)displayContentController:(UIViewController *)content cgrect:(CGRect)cgrect
{
    // 自身のビューコントローラ階層に追加
    // 自動的に子ViewControllerの`willMoveToParentViewController:`メソッドが呼ばれる
    [self addChildViewController:content];
    
    // 子ViewControllerの表示領域を設定
//    content.view.frame = self.view.bounds;
    content.view.frame = cgrect;
    
    // 子ViewControllerのviewを、自身のview階層に追加
    [self.view addSubview:content.view];
    
    // 子ViewControllerに追加されたことを通知
    [content didMoveToParentViewController:self];
    
    if([borderLine isDescendantOfView:self.view]) {
        [borderLine removeFromSuperview];
    }
    [self.view addSubview:borderLine];
}

- (void)switchApp{
    [self displayContentController:self.voidViewController
                            cgrect:CGRectMake(320, 0, self.view.bounds.size.width - 320, self.view.bounds.size.height)];
}

- (void)switchOrg{
    [self displayContentController:self.voidViewController
                            cgrect:CGRectMake(320, 0, self.view.bounds.size.width - 320, self.view.bounds.size.height)];
}

- (void)switchChannel:(NSString *)channelUid{
    if (self.chatViewController != nil) {
        [self hideContentController:self.chatViewController];
    }
    self.chatViewController = [[CCChatViewController alloc] initWithUserdata:nil
                                                                   firstName:nil
                                                                  familyName:nil
                                                                       email:nil
                                                                    provider:nil
                                                               providerToken:nil
                                                         providerTokenSecret:nil
                                                        providerRefreshToken:nil
                                                           providerCreatedAt:nil
                                                           providerExpiresAt:nil
                                                         channelInformations:nil
                                                                 deviceToken:nil
                                                           completionHandler:nil];
    self.chatViewController.channelId = channelUid;
    [self displayContentController:self.chatViewController
                            cgrect:CGRectMake(320, 0, self.view.bounds.size.width - 320, self.view.bounds.size.height)];
}


// 指定したViewControllerを削除
- (void)hideContentController:(UIViewController *)content
{
    // これから取り除かれようとしていることを通知する
    [content willMoveToParentViewController:nil];
    
    // 子ViewControllerの`view`を取り除く
    [content.view removeFromSuperview];
    
    // 子ViewControllerを取り除く
    // 自動的に`didMoveToParentViewController:`が呼ばれる
    [content removeFromParentViewController];
}

- (void)close{
    self.parentViewController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
    [self dismissViewControllerAnimated:YES completion:nil];
    [[CCConnectionHelper sharedClient] setCurrentView:nil];
    [[CCConnectionHelper sharedClient] setDelegate:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
