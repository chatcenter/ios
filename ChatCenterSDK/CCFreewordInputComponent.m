//
//  CCFreewordInputComponent.m
//  ChatCenterDemo
//
//  Created by VietHD on 6/2/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import "CCConstants.h"
#import "ChatCenterPrivate.h"
#import "CCFreewordInputComponent.h"

static const CGFloat defaultCellHeight = 42;
static const CGFloat textWidth =  180;
static const CGFloat topMargin = 0;    //set this value when if you set a gap between tableView and its superview
static const CGFloat bottomMargin = 0; //set this value when if you set a gap between tableView and its superview
static const CGFloat defaultInputViewHeight = 40;
static const CGFloat okButtonHeight = 40;

@interface CCFreewordInputComponent () {
    NSMutableArray<NSDictionary*> *actionDatas;
    id<CCQuestionComponentDelegate> delegate;
}
@property (strong, nonatomic) IBOutlet UITextField *freewordInputText;
@property (strong, nonatomic) IBOutlet UIButton *btnConfirm;

@end

@implementation CCFreewordInputComponent

#pragma mark Required by CCQuestionComponent protocol
- (void)setupWithStickerAction:(NSDictionary*)stickerAction delegate:(id<CCQuestionComponentDelegate>)inDelegate {
    self.freewordInputText.placeholder = CCLocalizedString(@"Type here");
    [self setSelectedColor:NO];
    self.freewordInputText.delegate = self;
    self.btnConfirm.layer.borderColor = [[CCConstants sharedInstance].baseColor CGColor];
    
    actionDatas = [[stickerAction objectForKey:@"action-data"] mutableCopy];
    NSArray *responseDatas = [stickerAction valueForKeyPath:@"action-response-data"];
    if (responseDatas != nil && [responseDatas count] > 0) {
        NSArray *responseActionDatas = [responseDatas[0] valueForKeyPath:@"actions"];
        // try get: action-response-data[].actions
        if (responseActionDatas != nil && [responseActionDatas count] > 0) {
            NSDictionary *actionData = responseActionDatas[0];
            if (actionData != nil) {
                NSString *inputedText = [actionData valueForKey:@"input"];
                if (inputedText != nil) {
                    self.freewordInputText.text = inputedText;
                    [self setSelectedColor:YES];
                }
            }
        } else {
            // try get: action-response-data[].action
            responseActionDatas = [responseDatas[0] valueForKeyPath:@"action"];
            if (responseActionDatas != nil) {
                if ([responseActionDatas isKindOfClass:[NSArray class]] && [responseActionDatas count] > 0) {
                    NSDictionary *actionData = responseActionDatas[0];
                    if (actionData != nil) {
                        NSString *inputedText = [actionData valueForKey:@"input"];
                        if (inputedText != nil) {
                            self.freewordInputText.text = inputedText;
                            [self setSelectedColor:YES];
                        }
                    }
                } else if ([responseActionDatas isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *actionData = (NSDictionary *)responseActionDatas;
                    if (actionData != nil) {
                        NSString *inputedText = [actionData valueForKey:@"input"];
                        if (inputedText != nil) {
                            self.freewordInputText.text = inputedText;
                            [self setSelectedColor:YES];
                        }
                    }
                }
            }
        }
    }

    delegate = inDelegate;
}

- (IBAction)onConfirmButtonClicked:(id)sender {
    if (self.freewordInputText.text == nil || [self.freewordInputText.text isEqualToString:@""]) {
        return;
    }
    
    if (actionDatas != nil && actionDatas.count > 0) {
        NSMutableDictionary *actionData = [actionDatas[0] mutableCopy];
        [actionData setValue:self.freewordInputText.text forKey:@"input"];
        NSArray<NSDictionary *> *items = [[NSArray alloc] initWithObjects:actionData, nil];
        [delegate userDidSelectActionItems:items];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [delegate userDidBeginEditingTextView];
}

+ (CGFloat)calculateHeightForStickerAction:(NSDictionary *)stickerAction {
    NSArray<NSDictionary*> *actions = [stickerAction objectForKey:@"action-data"];
    
    if (!actions || [actions count] == 0) {
        return 0;
    }
    
    CGFloat height = 0;
    NSDictionary *action = actions[0];
    NSString *text = [action objectForKey:@"label"];
    CGFloat h= [self cellHeightForText:text];
    if (h < defaultInputViewHeight) {
        h = defaultInputViewHeight;
    }
    height += h;
    
    height += topMargin + bottomMargin + okButtonHeight;
    
    return height;
    
}

#pragma mark Utilities
+ (CGFloat)cellHeightForText:(NSString*)text {
    //
    // Calculate actually according to text content
    //
    NSDictionary *messageStringAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:15.0f]};
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] initWithString:text attributes:messageStringAttributes];
    
    CGRect rect = [message boundingRectWithSize:CGSizeMake(textWidth, 1800)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
    if (rect.size.height < defaultCellHeight) {
        return defaultCellHeight;
    } else {
        return  rect.size.height;
    }
}

- (void)setSelectedColor:(BOOL)isSelected {
    UIColor *col = [[CCConstants sharedInstance] baseColor];
    CGFloat r, g, b, a;
    [col getRed:&r green:&g blue:&b alpha:&a];
    UIColor *newCol = [UIColor colorWithRed:r green:g blue:b alpha:0.25];
    if (isSelected) {
        self.backgroundColor = newCol;
    } else {
        UIColor *oldCol = [UIColor whiteColor];
        self.backgroundColor = oldCol;
    }
}
@end
