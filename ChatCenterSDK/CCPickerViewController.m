//
//  CCPickerViewController.m
//  ChatCenterDemo
//
//  Created by VietHD on 6/2/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import "CCPickerViewController.h"
#import "CCConstants.h"
#import "CCJSQMessage.h"
#import "ChatCenterPrivate.h"

@interface CCPickerViewController () {
    CCJSQMessage * _msg;
    NSMutableArray<NSString *> *pickerDatas;
}
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UIButton *btnDone;
@property (strong, nonatomic) IBOutlet UIView *transparentView;

@end

@implementation CCPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    [self.btnCancel setTitle:CCLocalizedString(@"Cancel") forState:UIControlStateNormal];
    [self.btnDone setTitle:CCLocalizedString(@"Done") forState:UIControlStateNormal];
    [self.btnCancel setTintColor:[CCConstants sharedInstance].baseColor];
    [self.btnDone setTintColor:[CCConstants sharedInstance].baseColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTransparentView)];
    [self.transparentView addGestureRecognizer:tapGesture];
}

-(void)tapTransparentView {
    _chatViewController.isPulldownSelectBoxDisplayed = NO;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)sendSelectedChoice {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:^{
        if(self->_msg == nil || self->_msg.status == CC_MESSAGE_STATUS_DELIVERING || self->_msg.status == CC_MESSAGE_STATUS_SEND_FAILED) {
            return;
        }
        
        NSMutableArray<NSDictionary *> *items = [[NSMutableArray alloc] init];
        NSInteger selectedIndex = [self.pickerView selectedRowInComponent:0];
        NSArray<NSDictionary *>* actions = [self->_msg.content valueForKeyPath:@"sticker-action.action-data"];
        if (selectedIndex < actions.count) {
            NSDictionary *action = actions[selectedIndex];
            [items addObject:action];
        }
        
        NSDictionary *data = @{         @"msgId" : _msg.uid,
                                        @"action-type" : _msg.content[@"sticker-action"][@"action-type"],
                                        @"stickerActions" : items,
                                        @"sticker_type": _msg.type};
        if (_chatViewController != nil) {
            _chatViewController.isPulldownSelectBoxDisplayed = NO;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kCCNoti_UserSelectionToPulldownWidget object:self userInfo:data];
    }];
}

- (void)setupWithMessage:(CCJSQMessage *)msg {
    self->_msg = msg;
    NSArray<NSDictionary *>* actions = [msg.content valueForKeyPath:@"sticker-action.action-data"];
    self->pickerDatas = [[NSMutableArray alloc] init];
    if (actions != nil) {
        for (NSDictionary *action in actions) {
            NSString *label = [action valueForKeyPath:@"label"];
            if (label != nil) {
                [self->pickerDatas addObject:label];
            }
        }
    }
    [self.pickerView reloadAllComponents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIPickerViewDelegate, UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [pickerDatas count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return pickerDatas[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"didSelectRow %ld", (long)row);
}

- (IBAction)onButtonCancelClicked:(id)sender {
    _chatViewController.isPulldownSelectBoxDisplayed = NO;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onButtonDoneClicked:(id)sender {
    [self sendSelectedChoice];
}

@end
