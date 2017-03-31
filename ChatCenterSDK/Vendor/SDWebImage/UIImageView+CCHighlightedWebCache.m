/*
 * This file is part of the CCSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+CCHighlightedWebCache.h"

#if SD_UIKIT

#import "UIView+CCWebCacheOperation.h"
#import "UIView+CCWebCache.h"

@implementation UIImageView (HighlightedWebCache)

- (void)sd_setHighlightedImageWithURL:(nullable NSURL *)url {
    [self sd_setHighlightedImageWithURL:url options:0 progress:nil completed:nil];
}

- (void)sd_setHighlightedImageWithURL:(nullable NSURL *)url options:(CCSDWebImageOptions)options {
    [self sd_setHighlightedImageWithURL:url options:options progress:nil completed:nil];
}

- (void)sd_setHighlightedImageWithURL:(nullable NSURL *)url completed:(nullable CCSDExternalCompletionBlock)completedBlock {
    [self sd_setHighlightedImageWithURL:url options:0 progress:nil completed:completedBlock];
}

- (void)sd_setHighlightedImageWithURL:(nullable NSURL *)url options:(CCSDWebImageOptions)options completed:(nullable CCSDExternalCompletionBlock)completedBlock {
    [self sd_setHighlightedImageWithURL:url options:options progress:nil completed:completedBlock];
}

- (void)sd_setHighlightedImageWithURL:(nullable NSURL *)url
                              options:(CCSDWebImageOptions)options
                             progress:(nullable CCSDWebImageDownloaderProgressBlock)progressBlock
                            completed:(nullable CCSDExternalCompletionBlock)completedBlock {
    __weak typeof(self)weakSelf = self;
    [self sd_internalSetImageWithURL:url
                    placeholderImage:nil
                             options:options
                        operationKey:@"UIImageViewImageOperationHighlighted"
                       setImageBlock:^(UIImage *image, NSData *imageData) {
                           weakSelf.highlightedImage = image;
                       }
                            progress:progressBlock
                           completed:completedBlock];
}

@end

#endif
