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

#ifndef JSQMessages_JSQMessages_h
#define JSQMessages_JSQMessages_h

#import "CCJSQMessagesViewController.h"

//  Views
#import "CCJSQMessagesCollectionView.h"
#import "CCJSQMessagesCollectionViewCellIncoming.h"
#import "CCJSQMessagesCollectionViewCellOutgoing.h"
#import "CCJSQMessagesTypingIndicatorFooterView.h"
#import "CCJSQMessagesLoadEarlierHeaderView.h"

//  Layout
#import "CCJSQMessagesCollectionViewFlowLayout.h"
#import "CCJSQMessagesCollectionViewLayoutAttributes.h"
#import "CCJSQMessagesCollectionViewFlowLayoutInvalidationContext.h"

//  Toolbar
#import "CCJSQMessagesComposerTextView.h"
#import "CCJSQMessagesInputToolbar.h"
#import "CCJSQMessagesToolbarContentView.h"

//  Model
#import "CCJSQMessageOriginal.h"

#import "CCJSQMediaItem.h"
#import "CCJSQPhotoMediaItem.h"
#import "CCJSQLocationMediaItem.h"
#import "CCJSQVideoMediaItem.h"

#import "CCJSQMessagesBubbleImage.h"
#import "CCJSQMessagesAvatarImage.h"

//  Protocols
#import "CCJSQMessageData.h"
#import "CCJSQMessageMediaData.h"
#import "CCJSQMessageAvatarImageDataSource.h"
#import "CCJSQMessageBubbleImageDataSource.h"
#import "CCJSQMessagesCollectionViewDataSource.h"
#import "CCJSQMessagesCollectionViewDelegateFlowLayout.h"

//  Factories
#import "CCJSQMessagesAvatarImageFactory.h"
#import "CCJSQMessagesBubbleImageFactory.h"
#import "CCJSQMessagesMediaViewBubbleImageMasker.h"
#import "CCJSQMessagesTimestampFormatter.h"
#import "CCJSQMessagesToolbarButtonFactory.h"

//  Categories
#import "JSQSystemSoundPlayer+CCJSQMessages.h"
#import "NSString+CCJSQMessages.h"
#import "UIColor+CCJSQMessages.h"
#import "UIImage+CCJSQMessages.h"
#import "UIView+CCJSQMessages.h"
#import "NSBundle+CCJSQMessages.h"

#endif
