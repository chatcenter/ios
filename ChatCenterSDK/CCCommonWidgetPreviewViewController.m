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
@property (weak, nonatomic) IBOutlet UIScrollView *widgetContainer;

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
    UIScreen *screen = [UIScreen mainScreen];
    float width = screen.bounds.size.width;
    float height = screen.bounds.size.height;

    CGSize previewCellSize = [CCCommonStickerPreviewCollectionViewCell estimateSizeForMessage:message atIndexPath:nil hasPreviousMessage:nil options:0 withListUser:nil];
    CCCommonStickerPreviewCollectionViewCell *previewCell = (CCCommonStickerPreviewCollectionViewCell *)[self viewFromNib:@"CCCommonStickerPreviewCollectionViewCell"];
    CCStickerCollectionViewCellOptions options = 0;
    options |= CCStickerCollectionViewCellOptionShowAsWidget;
    
    float previewFrameY = height / 2 - previewCellSize.height / 2 - 64> 0 ? height / 2 - previewCellSize.height / 2 - 64: 0; // 64 for navigation
    
    previewCell.frame = CGRectMake(width / 2 - previewCellSize.width / 2, previewFrameY, previewCellSize.width, previewCellSize.height);
    
    [previewCell setupWithIndex:nil message:message avatar:nil delegate:nil options:options];
    previewCell.userInteractionEnabled = NO;
    
    [_widgetContainer addSubview:previewCell];
    
    _widgetContainer.contentSize = CGSizeMake(previewCellSize.width, previewCellSize.height);
    _widgetContainer.contentInset = UIEdgeInsetsZero;
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

- (void) cancelButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
