//
//  CCLinearScaleQuestionComponent.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/10.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCLinearScaleQuestionComponent.h"
#import "CCLinearScaleQuestionComponentCell.h"
#import "UIImage+CCSDKImage.h"

static const CGFloat cellHeight = 125;

@interface CCLinearScaleQuestionComponent () {
    NSArray<NSDictionary*> *actionData;
    id<CCQuestionComponentDelegate> delegate;
    
    NSInteger selectedIndex;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxLabel;

@end

@implementation CCLinearScaleQuestionComponent

#define LINEAR_CELL_WIDTH   36
#define LINEAR_CELL_HEIGHT  48

#pragma mark Required by CCQuestionComponent protocol
- (void)setupWithStickerAction:(NSDictionary*)stickerAction delegate:(id<CCQuestionComponentDelegate>)inDelegate {
    actionData = [stickerAction objectForKey:@"action-data"];
    delegate = inDelegate;
    
    
    NSDictionary *vi = (NSDictionary*)[stickerAction objectForKey:@"view-info"];
    NSString *lbl1 = [vi objectForKey:@"min-label"];
    NSString *lbl2 = [vi objectForKey:@"max-label"];
    self.minLabel.text = lbl1;
    self.maxLabel.text = lbl2;
    [self setDefaultStyleToLabel:self.minLabel];
    [self setDefaultStyleToLabel:self.maxLabel];
    selectedIndex = -1;
    
    UINib *nib = [UINib nibWithNibName:@"CCLinearScaleQuestionComponentCell" bundle:SDK_BUNDLE];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"cell"];
    
    [self.collectionView reloadData];
}


- (void)setSelection:(NSArray *)selectedValues {
    
    NSArray<NSNumber*> *selectedIndeces = [self getSelectedIndeces:selectedValues fromAvailableAction:actionData];
    if (selectedIndeces.count>0) {
        selectedIndex = [selectedIndeces[0] integerValue]; // Should be one
    } else {
        selectedIndex = -1;
    }
    
    for (NSNumber *n in selectedIndeces) {
        NSInteger i = [n integerValue];
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        CCLinearScaleQuestionComponentCell *cell = (CCLinearScaleQuestionComponentCell*)[self.collectionView cellForItemAtIndexPath:path];
        [cell setSelected:YES];
        [self setRadioButtonImageForCell:cell state:YES];
    }
}

+ (CGFloat)calculateHeightForStickerAction:(NSDictionary *)stickerAction {
    
    NSDictionary *actionData = [stickerAction objectForKey:@"action-data"];
    if (actionData.count == 0) {
        return cellHeight;
    }
    CGFloat labelHeightDefault = 21;
    NSDictionary *vi = (NSDictionary*)[stickerAction objectForKey:@"view-info"];
    NSString *lbl1 = [vi objectForKey:@"min-label"];
    NSString *lbl2 = [vi objectForKey:@"max-label"];
    
    NSDictionary *labelStringAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:14]};
    NSMutableAttributedString *minLabel = [[NSMutableAttributedString alloc] initWithString:lbl1 attributes:labelStringAttributes];
    CGRect discriptionMinLabelFrame = [minLabel boundingRectWithSize:CGSizeMake(CC_STICKER_BUBBLE_WIDTH / actionData.count , 1800)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                        context:nil];
    NSMutableAttributedString *maxLabel = [[NSMutableAttributedString alloc] initWithString:lbl2 attributes:labelStringAttributes];
    CGRect discriptionMaxLabelFrame = [maxLabel boundingRectWithSize:CGSizeMake(CC_STICKER_BUBBLE_WIDTH / actionData.count , 1800)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                             context:nil];
    
    CGFloat height = 0;
    if (discriptionMaxLabelFrame.size.height > discriptionMinLabelFrame.size.height) {
        height = discriptionMaxLabelFrame.size.height;
    } else {
        height = discriptionMinLabelFrame.size.height;
    }
    
    if (height > labelHeightDefault) {
        return cellHeight + height - labelHeightDefault;
    }
    
    return cellHeight;
}

#pragma mark UICollectionView delegate/datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (actionData) {
        if (actionData.count==0) {
            NSLog(@"Count is zero");
        }
        return [actionData count];
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    
    CCLinearScaleQuestionComponentCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [self setDefaultStyleToLabel:cell.label];
    
    if (row == 0) {
      self.constraintLabelWidth.constant = cell.frame.size.width;
    }
    
    if(row<actionData.count) {
        id textObj = [[actionData objectAtIndex:row] objectForKey:@"label"];
        NSString *text = [textObj respondsToSelector:@selector(stringValue)] ? [textObj stringValue]: textObj;
        cell.label.text = text;
        if (!text) {
            NSLog(@"label is empty");
        } else {
            NSLog(@"label = %@", text);
        }
    }
    
    if (row == selectedIndex) {
        [self setRadioButtonImageForCell:cell state:YES];
    } else {
        [self setRadioButtonImageForCell:cell state:NO];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if ([indexPath row] >= actionData.count) {
        return;
    }
    
    for(CCLinearScaleQuestionComponentCell* cell in [self.collectionView visibleCells]) {
        [self setRadioButtonImageForCell:cell state:NO];
    }
    
    CCLinearScaleQuestionComponentCell *cell = (CCLinearScaleQuestionComponentCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    [self setRadioButtonImageForCell:cell state:YES];
    [cell setSelected:YES];
    
    NSDictionary *selectedAction = [actionData objectAtIndex:[indexPath row]];
    [delegate userDidSelectActionItems:@[selectedAction]];

}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = self.bounds.size.width;
    
    if (!actionData || actionData.count < 1) {
        return CGSizeMake(width, 48);
    }
    
    CGFloat optionWidth = width / (CGFloat)actionData.count;
    return CGSizeMake(optionWidth, 48);
}


- (void)setRadioButtonImageForCell:(CCLinearScaleQuestionComponentCell*)cell state:(BOOL)isSelected {
    
    UIImage *img;
    if (isSelected) {
        img = [UIImage SDKImageNamed:@"radioButtonOn"];
    } else {
        img = [UIImage SDKImageNamed:@"radioButtonOff"];
    }
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.radioButton setTintColor:[[CCConstants sharedInstance] baseColor]];
    [cell setContentMode:UIViewContentModeCenter];
    [cell.radioButton setImage:img];
    
}

@end
