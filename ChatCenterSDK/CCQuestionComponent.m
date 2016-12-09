//
//  CCQuestionComponent.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/09.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCQuestionComponent.h"
#import "CCDefaultSelectionQuestionComponent.h"
#import "CCCheckboxQuestionComponent.h"
#import "CCYesNoQuestionComponent.h"
#import "CCLinearScaleQuestionComponent.h"
#import "CCConstants.h"

@implementation CCQuestionComponent

+ (instancetype)componentForStickerAction:(NSDictionary*)stickerAction delegate:(id<CCQuestionComponentDelegate>)delegate {
    
    NSDictionary *vi = (NSDictionary*)[stickerAction objectForKey:@"view-info"];
    NSString *nibName = @"CCDefaultSelectionQuestionComponent";
    if ( vi != nil ) {
        NSString *type = [vi objectForKey:@"type"];
        if ([type isEqualToString:@"default"]) {
            nibName = @"CCDefaultSelectionQuestionComponent";
        } else if([type isEqualToString:@"checkbox"]) {
            nibName = @"CCCheckboxQuestionComponent";
        } else if([type isEqualToString:@"yesno"]) {
            nibName = @"CCYesNoQuestionComponent";
        } else if([type isEqualToString:@"linear"]) {
            nibName = @"CCLinearScaleQuestionComponent";
        }
    }
    NSArray *nibs = [SDK_BUNDLE loadNibNamed:nibName owner:nil options:0];
    CCQuestionComponent *instance = [nibs lastObject];
    
    [instance setupWithStickerAction:stickerAction delegate:delegate];
    
    return instance;
}


- (void)setupWithStickerAction:(NSDictionary*)stickerAction delegate:(id<CCQuestionComponentDelegate>)delegate {
    // Should be overridden by subclasses
}
- (void)setSelection:(NSArray*)selectedValues {
    // Should be overridden by subclasses
}


+ (CGFloat)calculateHeightForStickerAction:(NSDictionary *)stickerAction {

    NSDictionary *vi = (NSDictionary*)[stickerAction objectForKey:@"view-info"];
    if ( vi != nil ) {
        NSString *type = [vi objectForKey:@"type"];
        if ([type isEqualToString:@"default"]) {
            return [CCDefaultSelectionQuestionComponent calculateHeightForStickerAction:stickerAction];
        } else if ([type isEqualToString:@"checkbox"]) {
            return [CCCheckboxQuestionComponent calculateHeightForStickerAction:stickerAction];
        } else if ([type isEqualToString:@"yesno"]) {
            return [CCYesNoQuestionComponent calculateHeightForStickerAction:stickerAction];
        
        } else if ([type isEqualToString:@"linear"]) {
            return [CCLinearScaleQuestionComponent calculateHeightForStickerAction:stickerAction];
            
        }
    }
    
    return [CCDefaultSelectionQuestionComponent calculateHeightForStickerAction:stickerAction];
}


- (NSArray<NSNumber*> *)getSelectedIndeces:(NSArray*)selectedValues fromAvailableAction:(NSArray*)actionData {
    if (!actionData || actionData.count<1) {
        return @[];
    }
    
    NSInteger i = 0;
    NSMutableArray *retArray = [NSMutableArray new];
    
    for(NSDictionary *anAvailableAction in actionData) {
        for(NSDictionary *aSelectedAction in selectedValues) {
            
//            NSDictionary *v = [aSelectedAction objectForKey:@"action"];
//            if(!v){ continue; }
            
            if ([self compareAction:anAvailableAction withAction:aSelectedAction]) {
                [retArray addObject:@(i)];
            }
        }
        i++;
    }
    return retArray;
}

- (BOOL)compareAction:(NSDictionary*)actionA withAction:(NSDictionary*)actionB {
    
    id valueA = [actionA objectForKey:@"value"];
    id valueB = [actionB objectForKey:@"value"];
    
    NSString *labelA = [actionA objectForKey:@"label"];
    NSString *labelB = [actionB objectForKey:@"label"];
    
    if (!valueA || !valueB) {
        // If the values are not available try to compare with labels
        if (labelA != nil && labelB != nil) {
            return [labelA isEqualToString:labelB];
        }
    }
    
    if(![valueA isKindOfClass:[NSDictionary class]] || ![valueB isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    if ([(NSDictionary*)valueA isEqualToDictionary:(NSDictionary*)valueB]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setDefaultStyleToLabel:(UILabel*)label {
    [label setTextColor:[[CCConstants sharedInstance] baseColor]];
    [label setFont:[UIFont systemFontOfSize:14]];
}


@end
