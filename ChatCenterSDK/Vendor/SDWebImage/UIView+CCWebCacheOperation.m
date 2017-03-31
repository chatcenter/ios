/*
 * This file is part of the CCSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIView+CCWebCacheOperation.h"

#if SD_UIKIT || SD_MAC

#import "objc/runtime.h"

static char loadOperationKey;

typedef NSMutableDictionary<NSString *, id> CCSDOperationsDictionary;

@implementation UIView (WebCacheOperation)

- (CCSDOperationsDictionary *)operationDictionary {
    CCSDOperationsDictionary *operations = objc_getAssociatedObject(self, &loadOperationKey);
    if (operations) {
        return operations;
    }
    operations = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, &loadOperationKey, operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return operations;
}

- (void)sd_setImageLoadOperation:(nullable id)operation forKey:(nullable NSString *)key {
    if (key) {
        [self sd_cancelImageLoadOperationWithKey:key];
        if (operation) {
            CCSDOperationsDictionary *operationDictionary = [self operationDictionary];
            operationDictionary[key] = operation;
        }
    }
}

- (void)sd_cancelImageLoadOperationWithKey:(nullable NSString *)key {
    // Cancel in progress downloader from queue
    CCSDOperationsDictionary *operationDictionary = [self operationDictionary];
    id operations = operationDictionary[key];
    if (operations) {
        if ([operations isKindOfClass:[NSArray class]]) {
            for (id <CCSDWebImageOperation> operation in operations) {
                if (operation) {
                    [operation cancel];
                }
            }
        } else if ([operations conformsToProtocol:@protocol(CCSDWebImageOperation)]){
            [(id<CCSDWebImageOperation>) operations cancel];
        }
        [operationDictionary removeObjectForKey:key];
    }
}

- (void)sd_removeImageLoadOperationWithKey:(nullable NSString *)key {
    if (key) {
        CCSDOperationsDictionary *operationDictionary = [self operationDictionary];
        [operationDictionary removeObjectForKey:key];
    }
}

@end

#endif
