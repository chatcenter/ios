/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "CCSDWebImageCompat.h"

typedef NS_ENUM(NSInteger, CCSDImageFormat) {
    CCSDImageFormatUndefined = -1,
    CCSDImageFormatJPEG = 0,
    CCSDImageFormatPNG,
    CCSDImageFormatGIF,
    CCSDImageFormatTIFF,
    CCSDImageFormatWebP
};

@interface NSData (ImageContentType)

/**
 *  Return image format
 *
 *  @param data the input image data
 *
 *  @return the image format as `CCSDImageFormat` (enum)
 */
+ (CCSDImageFormat)sd_imageFormatForImageData:(nullable NSData *)data;

@end
