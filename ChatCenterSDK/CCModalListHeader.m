//
//  CCModalListHeader.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/12/19.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCModalListHeader.h"
#import "CCConstants.h"

@implementation CCModalListHeader

- (void)setupWithSectionIndex:(NSInteger)index
                        label:(NSString*)label
                        image:(UIImage*)image
                  andDelegate:(id<CCModalListHeaderDelegate>)delg {

    self.sectionIndex = index;
    self.delegate = delg;
    
    self.label.text = label;
    self.iconView.image = image;
    
    if (!self.gestureRecognizers || self.gestureRecognizers.count<1) {
        UITapGestureRecognizer *r = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        [self addGestureRecognizer:r];
        
    }
    
    [self.contentView setBackgroundColor:[CCConstants sharedInstance].leftMenuViewNormalColor];
}

- (void)viewTapped:(UIGestureRecognizer*)gesture {
    [self.delegate headerCellTapped:self];
}

- (void)setArrowState:(CCArrowState)state {
    
    self.triangleView.tintColor = self.label.textColor;
    UIImage *img = [UIImage imageNamed:@"suggestionBubbleTriangle"];
    self.triangleView.image =     [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    switch (state) {
        case CCArrowStateHidden:
            self.triangleView.hidden = YES;
            break;
        case CCArrowStateOpen:
            self.triangleView.hidden = NO;
            self.triangleView.transform = CGAffineTransformMakeScale(1, -1); //Flipped
            break;
        case CCArrowStateClose:
            self.triangleView.hidden = NO;
            self.triangleView.transform = CGAffineTransformMakeScale(1, 1); //Normal
            break;
    }
}

@end
