//
//  CCPulldownSelectionQuestionComponent.m
//  ChatCenterDemo
//
//  Created by VietHD on 6/2/17.
//  Copyright © 2017 AppSocially Inc. All rights reserved.
//

#import "ChatCenterPrivate.h"
#import "CCPulldownSelectionQuestionComponent.h"

static const CGFloat defaultCellHeight = 42;
static const CGFloat textWidth =  170;
static const CGFloat topMargin = 0;    //set this value when if you set a gap between tableView and its superview
static const CGFloat bottomMargin = 0; //set this value when if you set a gap between tableView and its superview

@interface CCPulldownSelectionQuestionComponent () {
    NSMutableArray<NSDictionary*> *actionDatas;
    id<CCQuestionComponentDelegate> delegate;
}

@property (strong, nonatomic) IBOutlet UILabel *lbDefaultSelection;
@property (strong, nonatomic) IBOutlet UIImageView *iconSelectBox;

@end

@implementation CCPulldownSelectionQuestionComponent

#pragma mark Required by CCQuestionComponent protocol
- (void)setupWithStickerAction:(NSDictionary*)stickerAction delegate:(id<CCQuestionComponentDelegate>)inDelegate {
    [self.iconSelectBox setTintColor:[CCConstants sharedInstance].baseColor];
    
    NSArray *responseDatas = [stickerAction valueForKeyPath:@"action-response-data"];
    if (responseDatas != nil && [responseDatas count] > 0) {
        NSArray *responseActionDatas = [responseDatas[0] valueForKeyPath:@"actions"];
        // try get: action-response-data[].actions
        if (responseActionDatas != nil && [responseActionDatas count] > 0) {
            actionDatas = [responseActionDatas mutableCopy];
        } else {
            // try get: action-response-data[].action
            responseActionDatas = [responseDatas[0] valueForKeyPath:@"action"];
            if (responseActionDatas != nil) {
                if ([responseActionDatas isKindOfClass:[NSArray class]] && [responseActionDatas count] > 0) {
                    actionDatas = [responseActionDatas mutableCopy];
                } else if ([responseActionDatas isKindOfClass:[NSDictionary class]]) {
                    actionDatas = [[NSArray arrayWithObject:responseActionDatas] mutableCopy];
                }
            }
        }
    }
    delegate = inDelegate;
    if (actionDatas != nil && [actionDatas count] > 0) {
        [self setupDefaultSelectionWithAction:actionDatas[0]];
    } else {
        [self setupDefaultSelectionWithAction:nil];
    }
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPickerView)];
    [self addGestureRecognizer:tapGesture];
}

-(void)showPickerView {
    [delegate userDidReactOnPulldownWidget];
}

-(void)setupDefaultSelectionWithAction:(NSDictionary *)action {
    if (action == nil) {
        self.lbDefaultSelection.text = CCLocalizedString(@"Select a choice");
        [self setSelectedColor:NO];
        return;
    }
    NSString *label = [action valueForKey:@"label"];
    self.lbDefaultSelection.text = label;
    [self setSelectedColor:YES];
}

+ (CGFloat)calculateHeightForStickerAction:(NSDictionary *)stickerAction {
    if (stickerAction == nil) {
        return defaultCellHeight;
    }
    NSArray<NSDictionary*> *actions = [stickerAction objectForKey:@"action-response-data"];
    NSMutableArray<NSDictionary *> * actionDatas;
    if (actions != nil && [actions count] > 0) {
        NSArray *responseActionDatas = [actions[0] valueForKeyPath:@"actions"];
        // try get: action-response-data[].actions
        if (responseActionDatas != nil && [responseActionDatas count] > 0) {
            actionDatas = [responseActionDatas mutableCopy];
        } else {
            // try get: action-response-data[].action
            responseActionDatas = [actions[0] valueForKeyPath:@"action"];
            if (responseActionDatas != nil) {
                if ([responseActionDatas isKindOfClass:[NSArray class]] && [responseActionDatas count] > 0) {
                    actionDatas = [responseActionDatas mutableCopy];
                } else if ([responseActionDatas isKindOfClass:[NSDictionary class]]) {
                    actionDatas = [[NSArray arrayWithObject:responseActionDatas] mutableCopy];
                }
            }
        }
    }

    if (!actionDatas || [actionDatas count] == 0) {
        return defaultCellHeight;
    }
    
    CGFloat height = 0;
    NSDictionary *action = actionDatas[0];
    NSString *text = [action objectForKey:@"label"];
    CGFloat h= [self cellHeightForText:text];
    height += h;
    
    height += topMargin + bottomMargin;
    
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

- (void)setSelection:(NSArray*)selectedValues {
    if (selectedValues != nil && selectedValues.count > 0) {
        NSDictionary *selectedAction = selectedValues[0];
        [self setupDefaultSelectionWithAction:selectedAction];
    } else {
        [self setupDefaultSelectionWithAction:nil];
    }
}
@end
