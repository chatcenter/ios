//
//  CCWebViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/11/18.
//  Copyright © 2015年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCWebViewController : UIViewController<UIWebViewDelegate>

- (id)initWithURL:(NSString *)url title:(NSString *)title;
- (id)initWithURL:(NSString *)url title:(NSString *)title needAuthentication: (BOOL) needAuthentication;
@end
