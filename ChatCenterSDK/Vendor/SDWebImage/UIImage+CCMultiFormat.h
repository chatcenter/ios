/*
 * This file is part of the CCSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CCSDWebImageCompat.h"
#import "NSData+ImageContentType.h"

@interface UIImage (MultiFormat)

+ (nullable UIImage *)sd_imageWithData:(nullable NSData *)data;
- (nullable NSData *)sd_imageData;
- (nullable NSData *)sd_imageDataAsFormat:(CCSDImageFormat)imageFormat;

@end
