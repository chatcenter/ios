//
//  CCPhraseStickerCollectionViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 4/20/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCPhraseStickerCollectionViewController.h"
#import "CCConnectionHelper.h"
#import "CCConstants.h"
#import "CCRSDFDatePickerViewController.h"
#import "CCCoredataBase.h"
#import "ChatCenterPrivate.h"
#import "CCSSKeychain.h"
#import "CCStickerCollectionViewCell.h"
#import "CCThumbCollectionViewCell.h"
#import "CCYesNoCollectionViewCell.h"
#import "CCChoiceButton.h"
#import "CCIDMPhoto.h"
#import "CCIDMPhotoBrowser.h"
#import "CCCalendarTimePickerController.h"
#import "CCSVProgressHUD.h"
#import "CCPhraseStickerViewController.h"
#import "CCPropertyCollectionViewCell.h"
#import "CCCommonStickerPreviewCollectionViewCell.h"
#import "ChatCenterClient.h"
#import "CCLocationPreviewViewController.h"
#import "CCConstants.h"
#import "CCYesNoQuestionCreatorViewController.h"
#import "CCCommonWidgetPreviewViewController.h"

@interface CCPhraseStickerCollectionViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation CCPhraseStickerCollectionViewController

NSString *kCCCommonStickerPreviewCollectionViewCell = @"CCCommonStickerPreviewCollectionViewCell";

NSString *kCCFixedPhraseSectionTitleView = @"CCFixedPhraseSectionTitleView";
NSString *kCCFixedPhraseSectionNoContentView = @"CCFixedPhraseSectionNoContentView";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    // register nib for CCCommonStickerViewCell
    UINib *nib = [UINib nibWithNibName:kCCCommonStickerPreviewCollectionViewCell bundle:SDK_BUNDLE];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kCCCommonStickerPreviewCollectionViewCell];

    ((UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout).minimumInteritemSpacing = 10.0;
    
    [self setupView];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[CCConnectionHelper sharedClient] setCurrentView:self];
    
    // reload data
    [self reloadData:self.orgUid];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadData: (NSString *) orgUid {
    [[CCConnectionHelper sharedClient] loadFixedPhrase:orgUid showProgress:YES
                                     completionHandler:^(NSDictionary *result, NSError *error, NSURLSessionDataTask *task)
     {
         if(result != nil) {
             //Received list of phrases, show them on tableview
             [self createFixedPhraseMessageObjects:result];
             [self.collectionView reloadData];
         }else{
             NSLog(@"Can not Get Fixed Phrases");
             
         }
     }];
}

-(void) registerNibWithName:(NSString *)nibName {
    UINib *nib = [UINib nibWithNibName:nibName bundle:SDK_BUNDLE];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:nibName];
}

-(void) setupView {
    // Do any additional setup after loading the view.
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    int xpos = screenBounds.size.width/2-240/2-5;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width, 40)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.opaque = NO;
    self.navigationItem.titleView = titleView;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xpos, 0, 240, 20)];
    titleLabel.font = [UIFont systemFontOfSize:16.0f];
    titleLabel.text = CCLocalizedString(@"Fixed Phrases Controller Title");;
    titleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [titleView addSubview:titleLabel];
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xpos, 20, 240, 20)];
    subtitleLabel.font = [UIFont systemFontOfSize:9.0f];
    subtitleLabel.text = CCLocalizedString(@"Tap to select");
    subtitleLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.backgroundColor = [UIColor clearColor];
    subtitleLabel.adjustsFontSizeToFitWidth = YES;
    [titleView addSubview:subtitleLabel];
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    [closeButton setImage:[[UIImage imageNamed:@"CCcancel_btn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    closeButton.tintColor = [[CCConstants sharedInstance] baseColor];
    [closeButton setTitleColor:[UIColor colorWithRed:64/255.0 green:116/255.0 blue:185/255.0 alpha:1.0] forState:UIControlStateNormal];
    [closeButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [closeButton addTarget:self action:@selector(closeModal) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:closeButton];
    
    [self.collectionView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.navigationItem.titleView removeFromSuperview];
    [self setupView];
}


- (IBAction)segmentedControlDidChange:(UISegmentedControl *)sender {
    [self.collectionView reloadData];
}



#pragma mark - UICollectionView DataSource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    section = self.segmentedControl.selectedSegmentIndex;
    NSArray *phrases;

    switch (section) {
        case CC_APP_FIXED_PHRASE_INDEX: {
            phrases = self.appFixedPhrases;
            break;
        }
            
        case CC_ORG_FIXED_PHRASE_INDEX: {
            phrases = self.orgFixedPhrases;
            break;
        }
            
        case CC_USER_FIXED_PHRASE_INDEX: {
            phrases = self.userFixedPhrases;
            break;
        }
    }

    NSInteger count = (phrases != nil) ? phrases.count : 0;

    return count;
}

- (UICollectionViewCell *)collectionView:(CCJSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCJSQMessage *message = [self getMessageBySectionIndexPath:indexPath];
    
    CCCommonStickerCollectionViewCell *cell;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCCommonStickerPreviewCollectionViewCell forIndexPath:indexPath];
    
    [cell setupWithIndex:nil message:message avatar:nil delegate:nil options:CCStickerCollectionViewCellOptionShowAsWidget];
    
    UITapGestureRecognizer* cellTappGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
    [cell addGestureRecognizer:cellTappGes];
    for (UIView* subView in cell.subviews) {
        subView.userInteractionEnabled = NO;
    }
    
    cell.stickerTopLabelHeight.constant = 20;
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        // section title view
        reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCCFixedPhraseSectionTitleView forIndexPath:indexPath];
        UITextView *title = [reusableview.subviews objectAtIndex:0];
        NSString *titleStr = nil;
        if(indexPath.section == CC_APP_FIXED_PHRASE_INDEX) {
            titleStr = CCLocalizedString(@"App's Recommendation");
        } else if(indexPath.section == CC_ORG_FIXED_PHRASE_INDEX) {
            titleStr = CCLocalizedString(@"Team's Recommendation");
        } else if(indexPath.section == CC_USER_FIXED_PHRASE_INDEX) {
            titleStr = CCLocalizedString(@"Mine");
        } else {
            titleStr = @"";
        }
        title.text = titleStr;
        [self addLineSpliterForView:reusableview];
        
    } else if (kind == UICollectionElementKindSectionFooter) {
        // no content view
        NSInteger section = self.segmentedControl.selectedSegmentIndex;

        reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kCCFixedPhraseSectionNoContentView forIndexPath:indexPath];
        UITextView *title = [reusableview.subviews objectAtIndex:0];
        NSString *messageStr = nil;
        if(section == CC_APP_FIXED_PHRASE_INDEX) {
            messageStr = CCLocalizedString(@"You have not any app's recommendation fixed phrases.");
        } else if(section == CC_ORG_FIXED_PHRASE_INDEX) {
            messageStr = CCLocalizedString(@"You have not any org's recommendation fixed phrases.");
        } else if(section == CC_USER_FIXED_PHRASE_INDEX) {
            messageStr = CCLocalizedString(@"You have not created any fixed phrases.");
        } else {
            messageStr = @"";
        }
        title.text = messageStr;
    }
    
    return reusableview;
}



- (void)cellTapped:(UITapGestureRecognizer*) sender{
    
    NSIndexPath* selectedIndexPath = [self.collectionView indexPathForCell:(UICollectionViewCell*)sender.view];
    CCJSQMessage* message = [self getMessageBySectionIndexPath:selectedIndexPath];
    
    
    CCCommonWidgetPreviewViewController *vc = [[CCCommonWidgetPreviewViewController alloc] initWithNibName:@"CCCommonWidgetPreviewViewController" bundle:SDK_BUNDLE];
    [vc setDelegate:self.delegate];
    [vc setMessage:message];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Collection view delegate flow layout overrides

- (CGSize)collectionView:(CCJSQMessagesCollectionView *)collectionView
                  layout:(CCJSQMessagesCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCJSQMessage* message = [self getMessageBySectionIndexPath:indexPath];
    
    CGSize size = [CCCommonStickerPreviewCollectionViewCell estimateSizeForMessage:message atIndexPath:nil hasPreviousMessage:nil options:0 withListUser:nil];
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    section = self.segmentedControl.selectedSegmentIndex;
    NSArray *phrases;

    switch (section) {
        case CC_APP_FIXED_PHRASE_INDEX: {
            phrases = self.appFixedPhrases;
            break;
        }
            
        case CC_ORG_FIXED_PHRASE_INDEX: {
            phrases = self.orgFixedPhrases;
            break;
        }
            
        case CC_USER_FIXED_PHRASE_INDEX: {
            phrases = self.userFixedPhrases;
            break;
        }
    }

    if (phrases == nil || phrases.count == 0) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 70);
        
    }
    return CGSizeZero;
}



-(CCJSQMessage *)getMessageBySectionIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = self.segmentedControl.selectedSegmentIndex;
    NSArray *phrases;
    
    switch (section) {
        case CC_APP_FIXED_PHRASE_INDEX: {
            phrases = self.appFixedPhrases;
            break;
        }
            
        case CC_ORG_FIXED_PHRASE_INDEX: {
            phrases = self.orgFixedPhrases;
            break;
        }
            
        case CC_USER_FIXED_PHRASE_INDEX: {
            phrases = self.userFixedPhrases;
            break;
        }
    }

    if (!phrases || phrases.count<1) {
        return nil;
    }
    
    return [phrases objectAtIndex:indexPath.item];
    
}

-(void)createFixedPhraseMessageObjects:(NSDictionary *)data
{
    if (data == nil || [data isEqual:[NSNull null]]) {
        self.orgFixedPhrases = nil;
        self.appFixedPhrases = nil;
        self.userFixedPhrases = nil;
        return;
    }
    NSMutableArray *appMessages = [data objectForKey:@"app"];
    self.appFixedPhrases = [self createMessageObjects:appMessages];
    
    NSMutableArray *orgMessages = [data objectForKey:@"org"];
    self.orgFixedPhrases = [self createMessageObjects:orgMessages];
    
    NSMutableArray *userMessages = [data objectForKey:@"user"];
    self.userFixedPhrases = [self createMessageObjects:userMessages];
}

-(NSMutableArray *)createMessageObjects:(NSMutableArray *)messages
{
    if (messages == nil || [messages isEqual:[NSNull null]]) {
        return nil;
    }
    
    NSMutableArray* results = [NSMutableArray array];
    
    for (NSDictionary* message in messages) {
        
        if ([message objectForKey:@"content"] == nil
            || [[message objectForKey:@"content"] isEqual:[NSNull null]]
            || [message objectForKey:@"content_type"] == nil) {
            continue;
        }
        
        NSString *contentType = [message objectForKey:@"content_type"];
        
        // create content
        CCJSQMessage *msg = nil;
        
        if (contentType != nil && ![contentType isEqual:[NSNull null]] && [contentType isEqualToString:CC_RESPONSETYPESTICKER]) {
            // for sticker
            NSMutableDictionary *content = [[message objectForKey:@"content"] mutableCopy];
            if(([content objectForKey:@"message"] != nil && ![[message objectForKey:@"message"] isEqual:[NSNull null]])
               || ([content objectForKey:@"sticker-action"] != nil && ![[message objectForKey:@"sticker-action"] isEqual:[NSNull null]])
               || ([content objectForKey:@"sticker-content"] != nil && ![[message objectForKey:@"sticker-content"] isEqual:[NSNull null]]))
            {
                [content setObject:[self generateMessageUniqueId] forKey:@"uid"];
                
                msg = [[CCJSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:@""];
                msg.content = [content copy];
                msg.type = CC_RESPONSETYPESTICKER;
            } else {
                // Nothing was set in sticker content
                continue;
            }
            
        } else {
            // for text message
            NSMutableDictionary *content = [NSMutableDictionary dictionary];
            [content setObject:[message objectForKey:@"content"] forKey:@"text"];
            [content setObject:[self generateMessageUniqueId] forKey:@"uid"];
            
            msg = [[CCJSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:[message objectForKey:@"content"]];
            msg.content = [content copy];
            msg.type = CC_RESPONSETYPEMESSAGE;
        }
        
        [results addObject: msg];
    }
    
    return results;
}

- (void)closeModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)generateMessageUniqueId {
    NSString *generatedUniqueId = [NSString stringWithFormat:@"%@-%@-%ld", _channelId, _userId, (long)([[NSDate date] timeIntervalSince1970] * 1000)];
    return generatedUniqueId;
}

- (void)addLineSpliterForView:(UIView *)root
{
    // add spliter if needed
    UIView *spliter = nil;
    for (UIView* subView in root.subviews) {
        if (subView.tag == CC_COLLECTION_VIEW_LINE_SEPARATOR_TAG) {
            spliter = subView;
            break;
        }
    }
    if (spliter == nil) {
        float width = [UIScreen mainScreen].bounds.size.width;
        float height = 1/[[UIScreen mainScreen] scale];
        UIView *spliter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        spliter.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
        spliter.tag = CC_COLLECTION_VIEW_LINE_SEPARATOR_TAG;
        [root addSubview:spliter];
    }
}

@end
