//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "NSBundle+CCJSQMessages.h"

#import "CCJSQMessagesViewController.h"

@implementation NSBundle (CCJSQMessages)

+ (NSBundle *)jsq_messagesBundle
{
    return [NSBundle bundleForClass:[CCJSQMessagesViewController class]];
}

+ (NSBundle *)jsq_messagesAssetBundle
{
    NSString *bundleResourcePath = [NSBundle jsq_messagesBundle].resourcePath;
    NSString *assetPath = [bundleResourcePath stringByAppendingPathComponent:@"JSQMessagesAssets.bundle"];
    return [NSBundle bundleWithPath:assetPath];
}

+ (NSString *)jsq_localizedStringForKey:(NSString *)key
{
    return NSLocalizedStringFromTableInBundle(key, @"JSQMessages", [NSBundle jsq_messagesAssetBundle], nil);
}

@end
