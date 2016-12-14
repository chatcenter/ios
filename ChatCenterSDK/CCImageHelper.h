//
//  CCImageHelper.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 9/23/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CCImageHelper : NSObject

+ (CCImageHelper *)sharedInstance;
- (void)loadLocalImage:(NSURL *)url completionHandler:(void (^)(UIImage *image))completionHandler;
- (NSData *) compress: (UIImage *)image targetSize:(int)targetSize;
@end
