/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "MKAnnotationView+CCWebCache.h"

#if SD_UIKIT || SD_MAC

#import "objc/runtime.h"
#import "UIView+CCWebCacheOperation.h"
#import "UIView+CCWebCache.h"

@implementation MKAnnotationView (CCWebCache)

- (void)sd_setImageWithURL:(nullable NSURL *)url {
    [self sd_setImageWithURL:url placeholderImage:nil options:0 completed:nil];
}

- (void)sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 completed:nil];
}

- (void)sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(CCSDWebImageOptions)options {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options completed:nil];
}

- (void)sd_setImageWithURL:(nullable NSURL *)url completed:(nullable CCSDExternalCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:nil options:0 completed:completedBlock];
}

- (void)sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable CCSDExternalCompletionBlock)completedBlock {
    [self sd_setImageWithURL:url placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)sd_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(CCSDWebImageOptions)options
                 completed:(nullable CCSDExternalCompletionBlock)completedBlock {
    __weak typeof(self)weakSelf = self;
    [self sd_internalSetImageWithURL:url
                    placeholderImage:placeholder
                             options:options
                        operationKey:nil
                       setImageBlock:^(UIImage *image, NSData *imageData) {
                           weakSelf.image = image;
                       }
                            progress:nil
                           completed:completedBlock];
}

@end

#endif
