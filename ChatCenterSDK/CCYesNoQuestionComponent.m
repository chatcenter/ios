//
//  CCYesNoQuestionComponent.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/09.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCYesNoQuestionComponent.h"
#import "CCConstants.h"

static const int buttonTagBase = 100;

@interface CCYesNoQuestionComponent () {
    NSArray<NSDictionary*> *actionData;
    id<CCQuestionComponentDelegate> delegate;
}
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (strong, nonatomic) IBOutlet UIView *divideView;

@end

@implementation CCYesNoQuestionComponent

#pragma mark Required by CCQuestionComponent protocol
- (void)setupWithStickerAction:(NSDictionary*)stickerAction delegate:(id<CCQuestionComponentDelegate>)inDelegate {
    actionData = [stickerAction objectForKey:@"action-data"];
    delegate = inDelegate;
    
    if (actionData.count >= 2) {
        NSString *text1 = [[actionData objectAtIndex:0] objectForKey:@"label"];
        NSString *text2 = [[actionData objectAtIndex:1] objectForKey:@"label"];
        
        [self.button1 setTitle:text1 forState:UIControlStateNormal];
        [self.button2 setTitle:text2 forState:UIControlStateNormal];
    }
    
    [self.button1 setTintColor:[[CCConstants sharedInstance] baseColor]];
    [self.button2 setTintColor:[[CCConstants sharedInstance] baseColor]];
    [self.divideView setBackgroundColor:[[CCConstants sharedInstance] baseColor]];
}


- (void)setSelection:(NSArray *)selectedValues {
    
    NSArray<NSNumber*> *selectedIndeces = [self getSelectedIndeces:selectedValues fromAvailableAction:actionData];
    
    NSNumber *n = [selectedIndeces firstObject]; // Should be one
    NSInteger i = [n integerValue];
    [self showSelection:i];
}


+ (CGFloat)calculateHeightForStickerAction:(NSDictionary *)stickerAction {
    return 42;
    
}

- (void)showSelection:(NSInteger)index {
    
    UIColor *col = [[CCConstants sharedInstance] baseColor];
    CGFloat r, g, b, a;
    [col getRed:&r green:&g blue:&b alpha:&a];
    UIColor *newCol = [UIColor colorWithRed:r green:g blue:b alpha:0.25];

    if(index==0){
        [self.button1 setBackgroundColor:newCol];
        [self.button2 setBackgroundColor:[UIColor clearColor]];
    }
    if(index==1){
        [self.button1 setBackgroundColor:[UIColor clearColor]];
        [self.button2 setBackgroundColor:newCol];
    }
}

- (IBAction)buttonPressed:(UIButton *)sender {
    int index = sender.tag - buttonTagBase;
    
    [self showSelection:index];
    
    NSDictionary *selectedAction = [actionData objectAtIndex:index];
    [delegate userDidSelectActionItems:@[selectedAction]];

    
}

@end
