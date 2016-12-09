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


#import "CCJSQMessagesLoadEarlierHeaderView.h"

#import "NSBundle+CCJSQMessages.h"


const CGFloat kJSQMessagesLoadEarlierHeaderViewHeight = 32.0f;


@interface CCJSQMessagesLoadEarlierHeaderView ()

@property (weak, nonatomic) IBOutlet UIButton *loadButton;

- (IBAction)loadButtonPressed:(UIButton *)sender;

@end



@implementation CCJSQMessagesLoadEarlierHeaderView

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([CCJSQMessagesLoadEarlierHeaderView class])
                          bundle:[NSBundle bundleForClass:[CCJSQMessagesLoadEarlierHeaderView class]]];
}

+ (NSString *)headerReuseIdentifier
{
    return NSStringFromClass([CCJSQMessagesLoadEarlierHeaderView class]);
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    self.backgroundColor = [UIColor clearColor];

    [self.loadButton setTitle:[NSBundle jsq_localizedStringForKey:@"load_earlier_messages"] forState:UIControlStateNormal];
    self.loadButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

- (void)dealloc
{
    _loadButton = nil;
    _delegate = nil;
}

#pragma mark - Reusable view

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.loadButton.backgroundColor = backgroundColor;
}

#pragma mark - Actions

- (IBAction)loadButtonPressed:(UIButton *)sender
{
    [self.delegate headerView:self didPressLoadButton:sender];
}

@end
