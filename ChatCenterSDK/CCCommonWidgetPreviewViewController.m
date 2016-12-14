//
//  CCCommonWidgetPreviewViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 11/10/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCCommonWidgetPreviewViewController.h"
#import "ChatCenterPrivate.h"
#import "CCCommonStickerPreviewCollectionViewCell.h"
#import "CCCommonWidgetEditorDelegate.h"
#import "CCJSQMessage.h"
#import "CCConstants.h"

@interface CCCommonWidgetPreviewViewController ()
@property (weak, nonatomic) IBOutlet UIView *widgetContainer;

@end

@implementation CCCommonWidgetPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:CCLocalizedString(@"Preview")];
    self.navigationController.navigationBarHidden = NO;
    
    // cancel preview button
    self.navigationController.navigationBar.tintColor = [[CCConstants sharedInstance] baseColor];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Send")
                                               style:UIBarButtonItemStyleDone target:self action:@selector(sendMessage:)];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self viewSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewSetup {
    _sendButton.titleLabel.text = CCLocalizedString(@"Send");
    _sendButton.backgroundColor = [[CCConstants sharedInstance] baseColor];
    _sendButton.layer.cornerRadius = 5.0f;
    [self createPreviewView];
//    [self.view addSubview:[self createPreviewView]];
}

- (UIView *)createPreviewView {
    float width = _widgetContainer.frame.size.width;
    float height = _widgetContainer.frame.size.height;
    /*
    UIScrollView *view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, width, height - 144)]; // 80 for send button height and 64 for navigation bar
    [view setBackgroundColor:[UIColor whiteColor]];
    */
    // create preview cell
    CGSize previewCellSize = [CCCommonStickerPreviewCollectionViewCell estimateSizeForMessage:message atIndexPath:nil hasPreviousMessage:nil options:0 withListUser:nil];
    CCCommonStickerPreviewCollectionViewCell *previewCell = (CCCommonStickerPreviewCollectionViewCell *)[self viewFromNib:@"CCCommonStickerPreviewCollectionViewCell"];
    CCStickerCollectionViewCellOptions options = 0;
    options |= CCStickerCollectionViewCellOptionShowAsWidget;
    
    previewCell.frame = CGRectMake(width / 2 - previewCellSize.width / 2, (height - 144)/ 2 - previewCellSize.height / 2, previewCellSize.width, previewCellSize.height);
    //    [previewCell setMessage:msg atIndexPath:nil withListUser:nil];
    [previewCell setupWithIndex:nil message:message avatar:nil delegate:nil options:options];
    previewCell.userInteractionEnabled = NO;
    
    previewCell.translatesAutoresizingMaskIntoConstraints = NO;

    
    [_widgetContainer addSubview:previewCell];

    NSLayoutConstraint *xCenterConstraint = [NSLayoutConstraint constraintWithItem:previewCell attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_widgetContainer attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [_widgetContainer addConstraint:xCenterConstraint];
    NSLayoutConstraint *yCenterConstraint = [NSLayoutConstraint constraintWithItem:previewCell attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_widgetContainer attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [_widgetContainer addConstraint:yCenterConstraint];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:previewCell
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:previewCellSize.height];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:previewCell
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:previewCellSize.width];
    
    [previewCell addConstraint:heightConstraint];
    [previewCell addConstraint:widthConstraint];
    
    
//    _widgetContainer.contentSize = CGSizeMake(previewCellSize.width, previewCellSize.height + 20);
    
    return _widgetContainer;
}

- (UIView *)viewFromNib:(NSString *)nibName {
    NSArray *nibViews = [SDK_BUNDLE loadNibNamed:nibName owner:nil options:nil];
    UIView *view = [nibViews objectAtIndex:0];
    return view;
}

- (void)setMessage:(CCJSQMessage *)msg {
    message = msg;
}

- (void)setDelegate:(id)newDelegate {
    delegate = newDelegate;
}

- (IBAction)sendMessage:(id)sender {
    NSLog(@"delegate = %@", delegate);
    if (delegate != nil) {
        NSLog(@"send message");
        [delegate sendWidgetWithType:message.type andContent:message.content];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
