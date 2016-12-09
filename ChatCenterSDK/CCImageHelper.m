//
//  CCImageHelper.m
//  ChatCenterDemo
//
//  Created by VietHD on 9/23/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCImageHelper.h"
#import "CCConstants.h"

@implementation CCImageHelper

+ (CCImageHelper *)sharedInstance {
    static CCImageHelper *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[CCImageHelper alloc] init];
    });
    return sharedClient;
}

- (void)loadLocalImage:(NSURL *)assetURL completionHandler:(void (^)(UIImage *image))completionHandler {
    __block UIImage *selectedImage;
    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:assetURL
        resultBlock:^(ALAsset *asset) {
            if (asset) {
                selectedImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                // Compress this image

                selectedImage = [[UIImage alloc] initWithData:[self compress:selectedImage targetSize:CCImageMaxSize]];
                if (selectedImage != nil) {
                    if(completionHandler != nil) completionHandler(selectedImage);
                } else {
                    if(completionHandler != nil) completionHandler(nil);
                }
               } else {
                   [assetslibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream
                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                            [group enumerateAssetsWithOptions:NSEnumerationReverse
                                       usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                                           selectedImage = [UIImage imageWithCGImage: [[asset defaultRepresentation] fullScreenImage]];
                                           // Compress this image
                                           selectedImage = [[UIImage alloc] initWithData:[self compress:selectedImage targetSize:CCImageMaxSize]];
                                           if (selectedImage != nil) {
                                               if(completionHandler != nil) completionHandler(selectedImage);
                                           } else {
                                               if(completionHandler != nil) completionHandler(nil);
                                           }
                                           *stop = YES;
                                   }];
                            if (group == nil) {
                                if(completionHandler != nil) completionHandler(nil);
                            }
                        }
                      failureBlock:^(NSError *error) {
                          NSLog(@"Error: Cannot load asset from photo stream - %@", [error localizedDescription]);
                      }];
               }
        }
        failureBlock:^(NSError *myerror) {
              NSLog(@"Can't get image - %@",[myerror localizedDescription]);
        }];
}

// targetSize: kb
- (NSData *) compress: (UIImage *)image targetSize:(int)targetSize {
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    CGFloat originalSize = imageData.length;
    
    if ([imageData length] > CCImageMaxSize)
    {
        CGFloat compression = (float)targetSize / originalSize;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    return imageData;
}
@end
