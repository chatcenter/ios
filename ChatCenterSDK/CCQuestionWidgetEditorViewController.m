//
//  CCQuestionWidgetEditorViewController.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/09.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCQuestionWidgetEditorViewController.h"
#import "CCYesNoQuestionPaneController.h"
#import "CCSingleSelectionPaneController.h"
#import "CCCheckboxPaneController.h"
#import "CCLinearScalePaneController.h"
#import "ChatCenterPrivate.h"
#import "CCConstants.h"
#import "UIImage+CCSDKImage.h"

typedef enum{
    YesNo,
    MultipleChoise,
    Checkbox,
    LinearScale
}AnswerType;


@interface CCQuestionWidgetEditorViewController () {
    __weak IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
}
@property int answerType;
@end

@implementation CCQuestionWidgetEditorViewController
#define kOFFSET_FOR_KEYBOARD 200.0
static const float TOP_VIEW_HEIGHT = 255;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self.childViewControllers lastObject] performSegueWithIdentifier:@"yesno" sender:self];
    _answerType = YesNo;
    [self viewSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewSetup {
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];

    UITapGestureRecognizer *selectTypeAnswerTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTypeAnswerSelector:)];
    [typeAnswerSelectorView addGestureRecognizer:selectTypeAnswerTapGesture];
    
    UITapGestureRecognizer *tapOusideOfKeyboardGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedOutsideOfKeyboard:)];
    tapOusideOfKeyboardGesture.delegate = self;
    [self.view addGestureRecognizer:tapOusideOfKeyboardGesture];
    [self setScrollviewContentHeight:TOP_VIEW_HEIGHT + 250];
    
    questionContent.delegate = self;
}

- (void) tapedOutsideOfKeyboard:(UITapGestureRecognizer *)gestureRecognizer {
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (_answerType == YesNo) {
        UINavigationController *navigationController = (UINavigationController *)[self.childViewControllers lastObject];
        CCYesNoQuestionPaneController *paneController = (CCYesNoQuestionPaneController *) [[navigationController viewControllers] lastObject];
        if ([touch.view isDescendantOfView:paneController.tableView]) {
            return NO;
        }
        return YES;
    } else {
        if ([touch.view isDescendantOfView:self.view]) {
            return YES;
        }
    }
    
    return NO;
}

- (void) tapTypeAnswerSelector:(UITapGestureRecognizer *)gestureRecognizer {
    ///
    /// Show list answer type to select
    ///
    UIAlertController *actionSheet = nil;
    actionSheet = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Choose type of answer")
                                                          message:nil
                                                   preferredStyle:UIAlertControllerStyleActionSheet];
    
    //
    // Yes / No
    //
    [actionSheet addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"Yes / No")
                                                    style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action){
                                                        [self yesnoAnswer];
                                                    }]];
    //
    // Multiple choise
    //
    [actionSheet addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"Multiple Choice")
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action){
                                                      [self multipleChoiseAnswer];
                                                  }]];
    
    //
    // Checkbox
    //
    [actionSheet addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"Checkbox")
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action){
                                                      [self checkboxAnswer];
                                                  }]];
    
    //
    // Linear Scale
    //
    [actionSheet addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"Linear Scale")
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action){
                                                      [self linearScaleAnswer];
                                                  }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"Cancel")
                                                    style:UIAlertActionStyleDestructive
                                                  handler:nil]];
    
    actionSheet.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *pop = actionSheet.popoverPresentationController;
    pop.sourceView = typeAnswerSelectorView;
    pop.sourceRect = typeAnswerSelectorView.bounds;
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)dismissKeyboard {
    [questionContent resignFirstResponder];
}

#pragma mark - Textview delegate
- (void)textViewDidChange:(UITextView *)textView {
    NSString *inputText = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    long textLenght = inputText.length;
    if (textLenght > CCWidgetInputTitleLimit) {
        textView.text = [inputText substringToIndex:CCWidgetInputTitleLimit];
    }
}


#pragma mark - Override super class methods
- (BOOL)validInput {
    if (questionContent.text != nil && [questionContent.text length] > 0) {
        if (_answerType == YesNo) {
            UINavigationController *navigationController = (UINavigationController *)[self.childViewControllers lastObject];
            CCYesNoQuestionPaneController *paneController = (CCYesNoQuestionPaneController *) [[navigationController viewControllers] lastObject];
            return [paneController validInput];
        } else if (_answerType == MultipleChoise) {
            UINavigationController *navigationController = (UINavigationController *)[self.childViewControllers lastObject];
            CCSingleSelectionPaneController *paneController = (CCSingleSelectionPaneController *) [[navigationController viewControllers] lastObject];
            return [paneController validInput];
        } else if (_answerType == Checkbox) {
            UINavigationController *navigationController = (UINavigationController *)[self.childViewControllers lastObject];
            CCCheckboxPaneController *paneController = (CCCheckboxPaneController *) [[navigationController viewControllers] lastObject];
            return [paneController validInput];
        } else if (_answerType == LinearScale) {
            UINavigationController *navigationController = (UINavigationController *)[self.childViewControllers lastObject];
            CCLinearScalePaneController *paneController = (CCLinearScalePaneController *) [[navigationController viewControllers] lastObject];
            return [paneController validInput];
        }
        return YES;
    } else {
        return NO;
    }
}

- (IBAction)nextButtonPressed:(id)sender {
    [self dismissKeyboard];
    [super preview];
}

- (void)preview {
    [self dismissKeyboard];
    [super preview];
}

- (CCJSQMessage *)createMessage {
    NSLog(@"Create message");
    CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:@""];
    msg.type = CC_RESPONSETYPESTICKER;
    msg.content = @{
                    @"message": @{@"text":questionContent.text},
                    @"sticker-action": [self getStickerAction],
                    @"uid": [delegate generateMessageUniqueId]
                    };
    
    return msg;

}

#pragma mark - Switch type answer
- (void) yesnoAnswer {
    _answerType = YesNo;
    typeAnswerIcon.image = [UIImage SDKImageNamed:@"yesnoIcon"];
    typeAnswerLabel.text = CCLocalizedString(@"Yes / No");
    [[self.childViewControllers lastObject] performSegueWithIdentifier:@"yesno" sender:self];
    [self setScrollViewDelegate];
}

- (void) multipleChoiseAnswer {
    _answerType = MultipleChoise;
    typeAnswerIcon.image = [UIImage SDKImageNamed:@"multipleChoiceIcon"];
    typeAnswerLabel.text = CCLocalizedString(@"Multiple Choice");
    [[self.childViewControllers lastObject] performSegueWithIdentifier:@"singleSelection" sender:self];
    [self setScrollViewDelegate];
}

- (void) checkboxAnswer {
    _answerType = Checkbox;
    typeAnswerIcon.image = [UIImage SDKImageNamed:@"checkboxIcon"];
    typeAnswerLabel.text = CCLocalizedString(@"Checkbox");
    [[self.childViewControllers lastObject] performSegueWithIdentifier:@"checkbox" sender:self];
    [self setScrollViewDelegate];
}

- (void) linearScaleAnswer {
    _answerType = LinearScale;
    typeAnswerIcon.image = [UIImage SDKImageNamed:@"linearScaleIcon"];
    typeAnswerLabel.text = CCLocalizedString(@"Linear Scale");
    [[self.childViewControllers lastObject] performSegueWithIdentifier:@"linear" sender:self];
    [self setScrollViewDelegate];
}

- (void) setScrollViewDelegate {
    UINavigationController *navigationController = (UINavigationController *)[self.childViewControllers lastObject];
    if (_answerType == YesNo) {
        CCYesNoQuestionPaneController *paneController = (CCYesNoQuestionPaneController *) [[navigationController viewControllers] lastObject];
        paneController.scrollViewDelegate = self;
    } else if (_answerType == MultipleChoise) {
        CCSingleSelectionPaneController *paneController = (CCSingleSelectionPaneController *) [[navigationController viewControllers] lastObject];
        paneController.scrollViewDelegate = self;
    } else if (_answerType == Checkbox) {
        CCCheckboxPaneController *paneController = (CCCheckboxPaneController *) [[navigationController viewControllers] lastObject];
        paneController.scrollViewDelegate = self;
    } else if (_answerType == LinearScale) {
        CCLinearScalePaneController *paneController = (CCLinearScalePaneController *) [[navigationController viewControllers] lastObject];
        paneController.scrollViewDelegate = self;
    }
}

#pragma mark - CCQuestionEditorScrollViewDelegate
- (void)setScrollviewContentHeight:(float)height {
    NSLog(@"ScrollViewContentHeight = %f", height);
    scrollViewHeightConstraint.constant = height;
    [self.view setNeedsUpdateConstraints];
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(CGFloat)movedAmount viewToShow:(UIView *)view
{
    [UIView animateWithDuration:0.3 animations:^{
        scrollViewBottomConstraint.constant = movedAmount;
    } completion:^(BOOL finished) {
        [self bringViewToVisibleArea:view];
    }];
}

- (void)bringViewToVisibleArea:(UIView *)view {
    
    CGRect convertedRect = [view convertRect:view.bounds toView:containerView];
    CGFloat containerY = containerView.frame.origin.y;
    CGRect newRect = CGRectMake(convertedRect.origin.x, convertedRect.origin.y + containerY, convertedRect.size.width, convertedRect.size.height);
    
    [scrollView scrollRectToVisible:newRect animated:YES];
}

#pragma mark - Navigation
- (NSDictionary *) getStickerAction {
    if (_answerType == YesNo) {
        UINavigationController *navigationController = (UINavigationController *)[self.childViewControllers lastObject];
        CCYesNoQuestionPaneController *paneController = (CCYesNoQuestionPaneController *) [[navigationController viewControllers] lastObject];
        return [paneController getStickerAction];
    } else if (_answerType == MultipleChoise) {
        UINavigationController *navigationController = (UINavigationController *)[self.childViewControllers lastObject];
        CCSingleSelectionPaneController *paneController = (CCSingleSelectionPaneController *) [[navigationController viewControllers] lastObject];
        return [paneController getStickerAction];
    } else if (_answerType == Checkbox) {
        UINavigationController *navigationController = (UINavigationController *)[self.childViewControllers lastObject];
        CCCheckboxPaneController *paneController = (CCCheckboxPaneController *) [[navigationController viewControllers] lastObject];
        return [paneController getStickerAction];
    } else if (_answerType == LinearScale) {
        UINavigationController *navigationController = (UINavigationController *)[self.childViewControllers lastObject];
        CCLinearScalePaneController *paneController = (CCLinearScalePaneController *) [[navigationController viewControllers] lastObject];
        return [paneController getStickerAction];
    }
    return nil;
}

@end
