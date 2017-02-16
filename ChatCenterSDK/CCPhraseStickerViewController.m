//
//  CCPhraseStickerViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 1/29/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "ChatCenterPrivate.h"
#import "CCPhraseStickerViewController.h"
#import "CCFixedPhraseTableViewCell.h"
#import "CCEditablePhraseTableViewCell.h"
#import "CCConstants.h"
#import "CCConnectionHelper.h"

@interface CCPhraseStickerViewController() {
    NSString *choosenPhrase;
}

@end

@implementation CCPhraseStickerViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.phraseListView.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    [self setupView];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // reload data
    [self reloadData:self.orgUid];
}

-(void)viewWillDisappear:(BOOL)animated {
    [delegate receivedChoosenPhrase:choosenPhrase];
}

-(void)reloadData: (NSString *) orgUid {
    [[CCConnectionHelper sharedClient] loadFixedPhrase:orgUid showProgress:NO
                                completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation)
     {
         if(result != nil) {
             //Received list of phrases, show them on tableview             
             fixedPhrases = [[NSMutableArray alloc] initWithArray:[result objectForKey:@"org"]];
             editablePhrases = nil;
             [self.phraseListView reloadData];
         }else{
             NSLog(@"Can not Get Fixed Phrases");
             
         }
     }];
}

- (void)closeModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setupView {
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self.phraseListView setTableHeaderView:v];
    [self.phraseListView setTableFooterView:v];
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
    [closeButton setTitle:CCLocalizedString(@"Cancel") forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor colorWithRed:64/255.0 green:116/255.0 blue:185/255.0 alpha:1.0] forState:UIControlStateNormal];
    [closeButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [closeButton addTarget:self action:@selector(closeModal) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:closeButton];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.navigationItem.titleView removeFromSuperview];
    [self setupView];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    
    switch (indexPath.section) {
        case CC_FIXED_PHRASE_INDEX: {
            identifier = @"CCFixedPhraseTableViewCell";
            CCFixedPhraseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[CCFixedPhraseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            NSArray *fixedPhraseTexts = [fixedPhrases valueForKeyPath:@"content"];
            cell.phraseTextView.text = fixedPhraseTexts[indexPath.row];
            return cell;
            break;
        }
            
        case CC_EDITABLE_PHRASE_INDEX: {
            identifier = @"CCEditablePhraseTableViewCell";
            CCEditablePhraseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[CCEditablePhraseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            NSArray *editablePhraseTexts = [editablePhrases valueForKeyPath:@"content"];
            cell.phraseTextView.text = editablePhraseTexts[indexPath.row];
            cell.rightUtilityButtons = [self rightButtons];
            cell.delegate = self;
            return cell;
            break;
        }
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case CC_FIXED_PHRASE_INDEX: {
            if (fixedPhrases == nil) {
                return 0;
            }
            return [fixedPhrases count];
            break;
        }
            
        case CC_EDITABLE_PHRASE_INDEX: {
            if (editablePhrases == nil || [editablePhrases count] == 0) {
                return 0;
            }
            return [editablePhrases count];
            break;
        }
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == CC_FIXED_PHRASE_INDEX) {
        return CCLocalizedString(@"Common Phrases");
    } else if(section == CC_EDITABLE_PHRASE_INDEX) {
        return CCLocalizedString(@"Custom Phrases");
    }
    
    // default value
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text;
    if(indexPath.section == CC_FIXED_PHRASE_INDEX) {
        NSArray *fixedPhraseTexts = [fixedPhrases valueForKeyPath:@"content"];
        text = fixedPhraseTexts[indexPath.row];
    } else if(indexPath.section == CC_EDITABLE_PHRASE_INDEX) {
        NSArray *editablePhrasesTexts = [editablePhrases valueForKeyPath:@"content"];
        text = editablePhrasesTexts[indexPath.row];
    } else {
        text = @"";
    }
    
    int MIN_HEIGHT = 59;
    int TEXT_MARGIN = 320 - 272;
    int TEXT_PADDING = 2;
    CGRect screenRect = [UIScreen mainScreen].applicationFrame;
    float width = screenRect.size.width - TEXT_MARGIN;
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(width, 20000)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}
                                         context:nil];
    
    float height = MAX(textRect.size.height + TEXT_PADDING*2, MIN_HEIGHT);
    return height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case CC_FIXED_PHRASE_INDEX: {
            NSArray *fixedPhraseTexts = [fixedPhrases valueForKeyPath:@"content"];
            choosenPhrase = fixedPhraseTexts[indexPath.row];
            break;
        }
        case CC_EDITABLE_PHRASE_INDEX: {
            NSArray *editablePhrasesTexts = [editablePhrases valueForKeyPath:@"content"];
            choosenPhrase = editablePhrasesTexts[indexPath.row];
            break;
        }
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) addPrivatePhrase {
    // create add phrase alert
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(osVersion >= 8.0f)  {
        // iOS >= 8
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"New") message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:nil];
        [alert addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleDefault handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // Add phrase
            NSString *text = alert.textFields[0].text;
            [self actionAddPhrase:text];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // iOS < 8
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:CCLocalizedString(@"New") message:nil delegate:self cancelButtonTitle:CCLocalizedString(@"Cancel") otherButtonTitles:CCLocalizedString(@"OK"), nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        // setting data & show alert
        currentAlertStyle = CC_ALERT_STYLE_ADD_PHRASE;
        selectingIndexPath = nil;
        [alert show];
    }
}

- (NSArray *)rightButtons {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:CCLocalizedString(@"Edit")];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:CCLocalizedString(@"Delete")];
    
    return rightUtilityButtons;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    [view setTintColor:[UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0]];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if((editablePhrases == nil || [editablePhrases count] == 0) && section == CC_EDITABLE_PHRASE_INDEX) {
        UITextView *footerView = [[UITextView alloc] init];
        footerView.textContainerInset = UIEdgeInsetsMake(0, 10, 0, 0);
        footerView.font = [UIFont systemFontOfSize:15.0];
        footerView.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
        footerView.text = CCLocalizedString(@"You have not created any fixed phrases.");
        footerView.editable = NO;
        footerView.userInteractionEnabled = NO;
        return footerView;
    }else{
        return nil;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if((editablePhrases == nil || [editablePhrases count] == 0) && section == CC_EDITABLE_PHRASE_INDEX) {
        return 30;
    }else{
        return 0;
    }
}

#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(CCSWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    const NSInteger EDIT_BUTTON_INDEX = 0;
    const NSInteger DELETE_BUTTON_INDEX = 1;
    
    NSIndexPath *indexPath = [self.phraseListView indexPathForCell:cell];
    switch (index) {
        case EDIT_BUTTON_INDEX: {
            // Edit phrase
            if(indexPath.section == CC_EDITABLE_PHRASE_INDEX) {
                // create edit phrase alert
                float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
                if(osVersion >= 8.0f)  {
                    // iOS >= 8
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Edit") message:nil preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                        textField.text = editablePhrases[indexPath.row];
                    }];
                    [alert addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleDefault handler:nil]];
                    [alert addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        NSString *text = alert.textFields[0].text;
                        [self actionEditPhrase:text forIndexPath:indexPath];
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                } else {
                    // iOS < 8
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:CCLocalizedString(@"Edit") message:nil delegate:self cancelButtonTitle:CCLocalizedString(@"Cancel") otherButtonTitles:CCLocalizedString(@"OK"), nil];
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert textFieldAtIndex:0].text = editablePhrases[indexPath.row];
                    
                    // setting data & show alert
                    currentAlertStyle = CC_ALERT_STYLE_EDIT_PHRASE;
                    selectingIndexPath = indexPath;
                    [alert show];
                }
            }
            break;
        }
            
        case DELETE_BUTTON_INDEX: {
            // remove phrase
            if(indexPath.section == CC_EDITABLE_PHRASE_INDEX) {
                // create confirm alert
                float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
                if(osVersion >= 8.0f)  {
                    // iOS >= 8
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:CCLocalizedString(@"Do you want to delete this phrase?")  preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alert addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel") style:UIAlertActionStyleDefault handler:nil]];
                    [alert addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        // delete phrase
                        [self actionDeletePhrase:nil forIndexPath:indexPath];
                    }]];
                    [self presentViewController:alert animated:YES completion:nil];
                } else {
                    // iOS < 8
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:CCLocalizedString(@"Do you want to delete this phrase?") delegate:self cancelButtonTitle:CCLocalizedString(@"Cancel") otherButtonTitles:CCLocalizedString(@"OK"), nil];
                    alert.alertViewStyle = UIAlertViewStyleDefault;
                    
                    // setting data & show alert
                    currentAlertStyle = CC_ALERT_STYLE_DELETE_PHRASE;
                    selectingIndexPath = indexPath;
                    [alert show];
                }
            }
            break;
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonText = [alertView buttonTitleAtIndex:buttonIndex];
    switch(currentAlertStyle) {
        case CC_ALERT_STYLE_ADD_PHRASE: {
            if([buttonText isEqualToString:CCLocalizedString(@"OK")]) {
                NSString *text = [alertView textFieldAtIndex:0].text;
                [self actionAddPhrase:text];
            }
            break;
        }
            
        case CC_ALERT_STYLE_EDIT_PHRASE: {
            if([buttonText isEqualToString:CCLocalizedString(@"OK")] && selectingIndexPath != nil && editablePhrases.count > selectingIndexPath.row) {
                NSString *text = [alertView textFieldAtIndex:0].text;
                [self actionEditPhrase:text forIndexPath:selectingIndexPath];
            }
            break;
        }
            
        case CC_ALERT_STYLE_DELETE_PHRASE: {
            if([buttonText isEqualToString:CCLocalizedString(@"OK")] && selectingIndexPath != nil) {
                [self actionDeletePhrase:nil forIndexPath:selectingIndexPath];
            }
            break;
        }
    }
    
    // clear data
    currentAlertStyle = CC_ALERT_STYLE_NONE;
    selectingIndexPath = nil;
}

-(void)actionAddPhrase:(NSString *)phrase {
    // check valid inputed text
    if(phrase == nil || phrase.length == 0) {
        // show error
        float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if(osVersion >= 8.0f)  {
            // iOS >= 8
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:CCLocalizedString(@"Please input phrase.") preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            // iOS < 8
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:CCLocalizedString(@"Please input phrase.") delegate:nil cancelButtonTitle:CCLocalizedString(@"OK") otherButtonTitles:nil];
            [alert show];
        }
        return;
    }
    
    // add new pharse
    [editablePhrases addObject:phrase];
    [self.phraseListView reloadData];
}

-(void)actionEditPhrase:(NSString *)phrase forIndexPath:(NSIndexPath *)indexPath {
    // check valid inputed text
    if(phrase == nil || phrase.length == 0) {
        // show error
        float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if(osVersion >= 8.0f)  {
            // iOS >= 8
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:CCLocalizedString(@"Please input phrase.") preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            // iOS < 8
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:CCLocalizedString(@"Please input phrase.") delegate:nil cancelButtonTitle:CCLocalizedString(@"OK") otherButtonTitles:nil];
            [alert show];
        }
        return;
    }
    
    // update pharse
    editablePhrases[selectingIndexPath.row] = phrase;
    [self.phraseListView reloadData];
}

-(void)actionDeletePhrase:(NSString *)phrase forIndexPath:(NSIndexPath *)indexPath {
    [editablePhrases removeObjectAtIndex:indexPath.row];
    if(editablePhrases.count > 0) {
        // remove with animation
        [self.phraseListView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        // remove with-out animation
        [self.phraseListView reloadData];
    }
}

@end
