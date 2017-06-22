//
//  CCDefaultSelectionQuestionComponent.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/02.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCDefaultSelectionQuestionComponent.h"
#import "CCConstants.h"
#import "CCJSQMessage.h"

static const CGFloat defaultCellHeight = 42;
static const CGFloat textWidth =  210;
static const CGFloat topMargin = 0;    //set this value when if you set a gap between tableView and its superview
static const CGFloat bottomMargin = 0; //set this value when if you set a gap between tableView and its superview


@interface CCDefaultSelectionQuestionComponent () {
    NSArray<NSDictionary*> *actionData;
    id<CCQuestionComponentDelegate> delegate;
    NSInteger selectedIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation CCDefaultSelectionQuestionComponent

#pragma mark Required by CCQuestionComponent protocol
- (void)setupWithStickerAction:(NSDictionary*)stickerAction delegate:(id<CCQuestionComponentDelegate>)inDelegate {
    actionData = [stickerAction objectForKey:@"action-data"];
    delegate = inDelegate;
    
    self.tableView.separatorColor = [[CCConstants sharedInstance] baseColor];
    selectedIndex = -1;
    
    [self.tableView reloadData];
}


- (void)setSelection:(NSArray *)selectedValues {
    
    NSArray<NSNumber*> *selectedIndeces = [self getSelectedIndeces:selectedValues fromAvailableAction:actionData];

    for (NSNumber *n in selectedIndeces) {
        NSInteger i = [n integerValue];
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        [cell setSelected:YES];
        selectedIndex = [n integerValue];
        [self setSelectedColorForCell:cell isSelected:YES];
    }
}

+ (CGFloat)calculateHeightForStickerAction:(NSDictionary *)stickerAction {
    NSArray<NSDictionary*> *actions = [stickerAction objectForKey:@"action-data"];
    
    if (!actions) {
        return 0;
    }
    
    CGFloat height = 0;
    for(NSDictionary *action in actions) {
        NSString *text = [action objectForKey:@"label"];
        CGFloat h= [self cellHeightForText:text];
        height += h;
    }
    
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

#pragma mark UITableView delegate/datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (actionData) {
        if (actionData.count==0) {
            NSLog(@"Count is zero");
        }
        return [actionData count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    // Styles which cannot be set in XIB
    [self setDefaultStyleToLabel:cell.textLabel];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.preservesSuperviewLayoutMargins = false;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    //...
    if (row == selectedIndex) {
        [self setSelectedColorForCell:cell isSelected:YES];
    } else {
        [self setSelectedColorForCell:cell isSelected:NO];
    }
    if(row<actionData.count) {
        NSString *text = [[actionData objectAtIndex:row] objectForKey:@"label"];
        cell.textLabel.text = text;
        if (!text) {
            NSLog(@"label is empty");
        } else {
            NSLog(@"label = %@", text);
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath row] >= actionData.count) {
        return;
    }
    
    for(UITableViewCell* cell in [self.tableView visibleCells]) {
        [cell setSelected:NO];
        [self setSelectedColorForCell:cell isSelected:NO];
    }
    
    NSDictionary *selectedAction = [actionData objectAtIndex:[indexPath row]];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:YES];
    [self setSelectedColorForCell:cell isSelected:YES];
    [delegate userDidSelectActionItems:@[selectedAction]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = [indexPath row];
    
    if(row<actionData.count) {
        NSString *text = [[actionData objectAtIndex:row] objectForKey:@"label"];
        CGFloat h = [CCDefaultSelectionQuestionComponent cellHeightForText:text];
        return h;
    } else {
        return 0;
    }
}


- (void)setSelectedColorForCell:(UITableViewCell *)cell isSelected:(BOOL)isSelected {
    UIColor *col = [[CCConstants sharedInstance] baseColor];
    CGFloat r, g, b, a;
    [col getRed:&r green:&g blue:&b alpha:&a];
    UIColor *newCol = [UIColor colorWithRed:r green:g blue:b alpha:0.25];
    if (isSelected) {
        cell.contentView.backgroundColor = newCol;
        cell.backgroundColor = newCol;
    } else {
        UIColor *oldCol = [UIColor whiteColor];
        cell.contentView.backgroundColor = oldCol;
        cell.backgroundColor = oldCol;
    }
}


@end
