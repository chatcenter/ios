//
//  CCCheckboxQuestionComponent.m
//  ChatCenterDemo
//
//  Created by 除村 武志 on 2016/11/09.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCCheckboxQuestionComponent.h"
#import "CCConstants.h"
#import "CCJSQMessage.h"
#import "ChatCenterPrivate.h"
#import "UIImage+CCSDKImage.h"

static const CGFloat defaultCellHeight = 42;
static const CGFloat textWidth =  172; // Subtracted the checkbox image width
static const CGFloat topMargin = 0;    //set this value when if you set a gap between tableView and its superview
static const CGFloat bottomMargin = 0; //set this value when if you set a gap between tableView and its superview

@interface CCCheckboxQuestionComponent () {
    NSArray<NSDictionary*> *actionData;
    id<CCQuestionComponentDelegate> delegate;
    
    NSMutableArray<NSNumber*> *selectedIndeces;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation CCCheckboxQuestionComponent

#pragma mark Required by CCQuestionComponent protocol
- (void)setupWithStickerAction:(NSDictionary*)stickerAction delegate:(id<CCQuestionComponentDelegate>)inDelegate {
    actionData = [stickerAction objectForKey:@"action-data"];
    delegate = inDelegate;
    self.tableView.separatorColor = [[CCConstants sharedInstance] baseColor];

    selectedIndeces = [NSMutableArray new];
    
    [self.tableView reloadData];
}


- (void)setSelection:(NSArray *)selectedValues {
    
    selectedIndeces = [[self getSelectedIndeces:selectedValues fromAvailableAction:actionData] mutableCopy];
    
    for (NSNumber *n in selectedIndeces) {
        NSInteger i = [n integerValue];
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        [cell setSelected:YES];
        [self setCheckboxStateForCell:cell state:YES];
        
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
    
    height += defaultCellHeight; // For OK button
    
    height += bottomMargin + topMargin;
    
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
        return [actionData count] + 1;
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
    [self setDefaultStyleToLabel:cell.textLabel];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.preservesSuperviewLayoutMargins = false;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    if(row<actionData.count) {
        [self setCheckboxStateForCell:cell state:NO];
        
        NSString *text = [[actionData objectAtIndex:row] objectForKey:@"label"];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.text = text;
        if (!text) {
            NSLog(@"label is empty");
        } else {
            NSLog(@"label = %@", text);
        }
    } else if (row == actionData.count) { // Add OK button at the bottom
        NSString *text = CCLocalizedString(@"OK");
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = text;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = [indexPath row];
    if (row >= actionData.count) {
        //
        // Finish the selection and send
        //
        NSMutableArray<NSDictionary*> *selectedActions = [NSMutableArray new];
        for(NSNumber *i in selectedIndeces) {
            NSDictionary *action = [actionData objectAtIndex:[i integerValue]];
            [selectedActions addObject:action];
        }
        
        [delegate userDidSelectActionItems:selectedActions];
    } else {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([selectedIndeces containsObject:@(row)]) {
            // Deselect
            [selectedIndeces removeObject:@(row)];
            [self setCheckboxStateForCell:cell state:NO];
        } else {
            // Add to selection
            [selectedIndeces addObject:@(row)];
            [self setCheckboxStateForCell:cell state:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = [indexPath row];
    
    if(row<actionData.count) {
        NSString *text = [[actionData objectAtIndex:row] objectForKey:@"label"];
        return [CCCheckboxQuestionComponent cellHeightForText:text];
    } else {
        return defaultCellHeight;
    }
}

- (void)setCheckboxStateForCell:(UITableViewCell*)cell state:(BOOL)isSelected {
    
    UIImage *img;
    if (isSelected) {
        img = [UIImage SDKImageNamed:@"checkboxOn"];
    } else {
        img = [UIImage SDKImageNamed:@"checkboxOff"];
    }
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.imageView setTintColor:[[CCConstants sharedInstance] baseColor]];
    [cell setContentMode:UIViewContentModeCenter];
    [cell.imageView setImage:img];
    
}


@end
