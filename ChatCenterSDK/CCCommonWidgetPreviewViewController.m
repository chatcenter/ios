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
#import "CCConnectionHelper.h"

@interface CCCommonWidgetPreviewViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *widgetContainer;
@property CCCommonStickerPreviewCollectionViewCell *previewCell;


@end

@implementation CCCommonWidgetPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:CCLocalizedString(@"Preview")];
    self.navigationController.navigationBarHidden = NO;
    
    // cancel preview button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CCBackArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(pressBack)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationController.navigationBar.tintColor = [[CCConstants sharedInstance] baseColor];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Send")
                                               style:UIBarButtonItemStyleDone target:self action:@selector(sendMessage:)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    }
    
}

- (void) pressBack {
    if (self.navigationController != nil && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self updateWidgetPreview];
}

-(void)updateWidgetPreview {
    [_previewCell removeFromSuperview];
    UIScreen *screen = [UIScreen mainScreen];
    float width = screen.bounds.size.width;
    float height = screen.bounds.size.height;
    [self createWidgetCell:width withheight:height];
}
-(void)createWidgetCell: (float) width withheight: (float) height{
    
    CGSize previewCellSize = [CCCommonStickerPreviewCollectionViewCell estimateSizeForMessage:message atIndexPath:nil hasPreviousMessage:nil options:0 withListUser:nil];
    _previewCell = (CCCommonStickerPreviewCollectionViewCell *)[self viewFromNib:@"CCCommonStickerPreviewCollectionViewCell"];
    CCStickerCollectionViewCellOptions options = 0;
    options |= CCStickerCollectionViewCellOptionShowAsWidget;
    if(![[CCConnectionHelper sharedClient].shareLocationTasks objectForKey:channelId]) {
        options |= CCStickerCollectionViewCellOptionShowLiveIcon;
    }
    float previewFrameY = height / 2 - previewCellSize.height / 2 - 64> 0 ? height / 2 - previewCellSize.height / 2 - 64: 0;
    _previewCell.frame = CGRectMake(width / 2 - previewCellSize.width / 2, previewFrameY, previewCellSize.width, previewCellSize.height);
    
    [_previewCell setupWithIndex:nil message:message avatar:nil textviewDelegate:nil delegate:nil options:options];
    _previewCell.userInteractionEnabled = NO;
    
    [_widgetContainer addSubview:_previewCell];
    _widgetContainer.contentSize = CGSizeMake(previewCellSize.width, previewCellSize.height);
    _widgetContainer.contentInset = UIEdgeInsetsZero;
}
- (UIView *)createPreviewView {
    UIScreen *screen = [UIScreen mainScreen];
    float width = screen.bounds.size.width;
    float height = screen.bounds.size.height;
    
    [self createWidgetCell:width withheight:height];
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
        if ([message.type isEqualToString:CC_STICKERTYPEIMAGE]) {
            if (self.navigationController != nil) {
                [delegate sendWidgetWithType:message.type andContent:message.content];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            [delegate sendWidgetWithType:message.type andContent:message.content];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                if (self.closeWidgetPreviewCallback != nil) {
                    self.closeWidgetPreviewCallback();
                }
            }];
        }
    }
}

- (void) cancelButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
