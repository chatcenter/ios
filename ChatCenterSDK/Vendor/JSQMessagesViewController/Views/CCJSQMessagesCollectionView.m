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

#import "CCJSQMessagesCollectionView.h"

#import "CCJSQMessagesCollectionViewFlowLayout.h"
#import "CCJSQMessagesCollectionViewCellIncoming.h"
#import "CCJSQMessagesCollectionViewCellOutgoing.h"

#import "CCJSQMessagesTypingIndicatorFooterView.h"
#import "CCJSQMessagesLoadEarlierHeaderView.h"

#import "UIColor+CCJSQMessages.h"


@interface CCJSQMessagesCollectionView () <CCJSQMessagesLoadEarlierHeaderViewDelegate>

- (void)jsq_configureCollectionView;

@end


@implementation CCJSQMessagesCollectionView

@dynamic dataSource;
@dynamic delegate;
@dynamic collectionViewLayout;

#pragma mark - Initialization

- (void)jsq_configureCollectionView
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    self.backgroundColor = [UIColor whiteColor];
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    self.alwaysBounceVertical = YES;
    self.bounces = YES;
    
    [self registerNib:[CCJSQMessagesCollectionViewCellIncoming nib]
          forCellWithReuseIdentifier:[CCJSQMessagesCollectionViewCellIncoming cellReuseIdentifier]];
    
    [self registerNib:[CCJSQMessagesCollectionViewCellOutgoing nib]
          forCellWithReuseIdentifier:[CCJSQMessagesCollectionViewCellOutgoing cellReuseIdentifier]];
    
    [self registerNib:[CCJSQMessagesCollectionViewCellIncoming nib]
          forCellWithReuseIdentifier:[CCJSQMessagesCollectionViewCellIncoming mediaCellReuseIdentifier]];
    
    [self registerNib:[CCJSQMessagesCollectionViewCellOutgoing nib]
          forCellWithReuseIdentifier:[CCJSQMessagesCollectionViewCellOutgoing mediaCellReuseIdentifier]];
    
    [self registerNib:[CCJSQMessagesTypingIndicatorFooterView nib]
          forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
          withReuseIdentifier:[CCJSQMessagesTypingIndicatorFooterView footerReuseIdentifier]];
    
    [self registerNib:[CCJSQMessagesLoadEarlierHeaderView nib]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
          withReuseIdentifier:[CCJSQMessagesLoadEarlierHeaderView headerReuseIdentifier]];

    _typingIndicatorDisplaysOnLeft = YES;
    _typingIndicatorMessageBubbleColor = [UIColor jsq_messageBubbleLightGrayColor];
    _typingIndicatorEllipsisColor = [_typingIndicatorMessageBubbleColor jsq_colorByDarkeningColorWithValue:0.3f];

    _loadEarlierMessagesHeaderTextColor = [UIColor jsq_messageBubbleBlueColor];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self jsq_configureCollectionView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self jsq_configureCollectionView];
}

#pragma mark - Typing indicator

- (CCJSQMessagesTypingIndicatorFooterView *)dequeueTypingIndicatorFooterViewForIndexPath:(NSIndexPath *)indexPath
{
    CCJSQMessagesTypingIndicatorFooterView *footerView = [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                 withReuseIdentifier:[CCJSQMessagesTypingIndicatorFooterView footerReuseIdentifier]
                                                                                        forIndexPath:indexPath];

    [footerView configureWithEllipsisColor:self.typingIndicatorEllipsisColor
                        messageBubbleColor:self.typingIndicatorMessageBubbleColor
                       shouldDisplayOnLeft:self.typingIndicatorDisplaysOnLeft
                         forCollectionView:self];

    return footerView;
}

#pragma mark - Load earlier messages header

- (CCJSQMessagesLoadEarlierHeaderView *)dequeueLoadEarlierMessagesViewHeaderForIndexPath:(NSIndexPath *)indexPath
{
    CCJSQMessagesLoadEarlierHeaderView *headerView = [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                             withReuseIdentifier:[CCJSQMessagesLoadEarlierHeaderView headerReuseIdentifier]
                                                                                    forIndexPath:indexPath];

    headerView.loadButton.tintColor = self.loadEarlierMessagesHeaderTextColor;
    headerView.delegate = self;

    return headerView;
}

#pragma mark - Load earlier messages header delegate

- (void)headerView:(CCJSQMessagesLoadEarlierHeaderView *)headerView didPressLoadButton:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(collectionView:header:didTapLoadEarlierMessagesButton:)]) {
        [self.delegate collectionView:self header:headerView didTapLoadEarlierMessagesButton:sender];
    }
}

#pragma mark - Messages collection view cell delegate

- (void)messagesCollectionViewCellDidTapAvatar:(CCJSQMessagesCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }

    [self.delegate collectionView:self
            didTapAvatarImageView:cell.avatarImageView
                      atIndexPath:indexPath];
}

- (void)messagesCollectionViewCellDidTapMessageBubble:(CCJSQMessagesCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }

    [self.delegate collectionView:self didTapMessageBubbleAtIndexPath:indexPath];
}

- (void)messagesCollectionViewCellDidTapCell:(CCJSQMessagesCollectionViewCell *)cell atPosition:(CGPoint)position
{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }

    [self.delegate collectionView:self
            didTapCellAtIndexPath:indexPath
                    touchLocation:position];
}

- (void)messagesCollectionViewCell:(CCJSQMessagesCollectionViewCell *)cell didPerformAction:(SEL)action withSender:(id)sender
{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }

    [self.delegate collectionView:self
                    performAction:action
               forItemAtIndexPath:indexPath
                       withSender:sender];
}

@end
