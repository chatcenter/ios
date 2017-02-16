//
//  CCWebViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/11/18.
//  Copyright © 2015年 AppSocially Inc. All rights reserved.
//

#import "CCWebViewController.h"
#import "CCConstants.h"

@interface CCWebViewController (){
}
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (nonatomic, strong) NSString *urlString;
@end

@implementation CCWebViewController

- (id)initWithURL:(NSString *)url title:(NSString *)title{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatCenter" bundle:SDK_BUNDLE];
    CCWebViewController *instance = [storyboard  instantiateViewControllerWithIdentifier:@"CCWebViewController"];
    instance.urlString = url;
    instance.title = title;
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSURL *URL = [NSURL URLWithString:self.urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self.webview loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidStartLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)webViewDidFinishLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    return YES;
}

@end
