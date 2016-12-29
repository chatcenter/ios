//
//  CCModalListHeader.h
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/12/19.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CCArrowStateHidden,
    CCArrowStateOpen,
    CCArrowStateClose
} CCArrowState;


@class CCModalListHeader;
@protocol CCModalListHeaderDelegate <NSObject>
- (void)headerCellTapped:(CCModalListHeader*)header;

@end

@interface CCModalListHeader : UITableViewHeaderFooterView

@property (nonatomic, weak) id<CCModalListHeaderDelegate> delegate;
@property (nonatomic) NSInteger sectionIndex;
@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIImageView *iconView;
@property (nonatomic, weak) IBOutlet UIImageView *triangleView;

- (void)setupWithSectionIndex:(NSInteger)index
                        label:(NSString*)label
                        image:(UIImage*)image
                  andDelegate:(id<CCModalListHeaderDelegate>)delg;
- (void)setArrowState:(CCArrowState)state;

@end
