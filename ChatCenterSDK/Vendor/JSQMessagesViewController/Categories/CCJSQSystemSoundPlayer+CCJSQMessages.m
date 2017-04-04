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

#import "CCJSQSystemSoundPlayer+CCJSQMessages.h"

#import "NSBundle+CCJSQMessages.h"


static NSString * const kJSQMessageReceivedSoundName = @"message_received";
static NSString * const kJSQMessageSentSoundName = @"message_sent";


@implementation CCJSQSystemSoundPlayer (CCJSQMessages)

#pragma mark - Public

+ (void)jsq_playMessageReceivedSound
{
    [self jsq_playSoundFromJSQMessagesBundleWithName:kJSQMessageReceivedSoundName asAlert:NO];
}

+ (void)jsq_playMessageReceivedAlert
{
    [self jsq_playSoundFromJSQMessagesBundleWithName:kJSQMessageReceivedSoundName asAlert:YES];
}

+ (void)jsq_playMessageSentSound
{
    [self jsq_playSoundFromJSQMessagesBundleWithName:kJSQMessageSentSoundName asAlert:NO];
}

+ (void)jsq_playMessageSentAlert
{
    [self jsq_playSoundFromJSQMessagesBundleWithName:kJSQMessageSentSoundName asAlert:YES];
}

#pragma mark - Private

+ (void)jsq_playSoundFromJSQMessagesBundleWithName:(NSString *)soundName asAlert:(BOOL)asAlert
{
    //  save sound player original bundle
    NSString *originalPlayerBundleIdentifier = [CCJSQSystemSoundPlayer sharedPlayer].bundle.bundleIdentifier;
    
    //  search for sounds in this library's bundle
    [CCJSQSystemSoundPlayer sharedPlayer].bundle = [NSBundle jsq_messagesBundle];
    
    NSString *fileName = [NSString stringWithFormat:@"JSQMessagesAssets.bundle/Sounds/%@", soundName];
    
    if (asAlert) {
        [[CCJSQSystemSoundPlayer sharedPlayer] playAlertSoundWithFilename:fileName fileExtension:kJSQSystemSoundTypeAIFF completion:nil];
    }
    else {
        [[CCJSQSystemSoundPlayer sharedPlayer] playSoundWithFilename:fileName fileExtension:kJSQSystemSoundTypeAIFF completion:nil];
    }
    
    //  restore original bundle
    [CCJSQSystemSoundPlayer sharedPlayer].bundle = [NSBundle bundleWithIdentifier:originalPlayerBundleIdentifier];
}

@end