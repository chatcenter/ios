//
//  CCHistoryFilterViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2016/04/19.
//  Copyright © 2016年 AppSocially Inc. All rights reserved.
//

#import "CCHistoryFilterViewController.h"

#import "CCConstants.h"
#import "CCCoredataBase.h"
#import "CCChannel.h"
#import "ChatCenterClient.h"

#import "CCUserDefaultsUtil.h"

#import "CCHistoryFilterViewItemCell.h"

// Business funnel string.
// All.
static NSString *CCHistoryFilterBusinessFunnelTypeAll = @"All";

// Cell height.
static CGFloat CCHistoryFilterItemCellHeight = 32.0;
static CGFloat CCHistoryFilterItemHeaderViewHeight = 21.0;

// TableView section type.
typedef NS_ENUM(NSUInteger, CCHistoryFilterViewSectionType) {
    // Business funnel.
    CCHistoryFilterViewSectionTypeFunnel = 0,
    // Message status.
    CCHistoryFilterViewSectionTypeStatus,
    // Max section count.
    CCHistoryFilterViewSectionTypeMax
};

// TableView creating entity.
@interface CCHistoryFilterCellEntity: NSObject
// Item title.
@property (nonatomic, strong) NSString *itemTitle;
// Count title.
@property (nonatomic, strong) NSString *countTitle;
// Funnel Id.
@property (nonatomic, strong) NSNumber *funnelId;
// Selected.
@property (nonatomic, assign) BOOL isSelected;
@end

@implementation CCHistoryFilterCellEntity

- (id)initWithItemTitle:(NSString *)itemTitle countTitle:(NSString *)countTitle isSelected:(BOOL)isSelected {
    self = [super init];
    if (self != nil) {
        self.itemTitle = itemTitle;
        self.countTitle = countTitle;
        self.isSelected = isSelected;
    }
    return self;
}

- (id)initWithItemTitle:(NSString *)itemTitle countTitle:(NSString *)countTitle funnelId:(NSNumber *)funnelId isSelected:(BOOL)isSelected {
    self = [super init];
    if (self != nil) {
        self.itemTitle = itemTitle;
        self.countTitle = countTitle;
        self.funnelId = funnelId;
        self.isSelected = isSelected;
    }
    return self;
}

@end


@interface CCHistoryFilterViewController () {
@private
    
    // TableView.
    __weak IBOutlet UITableView *_tableView;
    // TableView business funnel section header view.
    IBOutlet UIView *_businessFunnelSectionHeaderView;
    // TableView message status section header view.
    IBOutlet UIView *_messageStatusSectionHeaderView;
    // Content view.
    __weak IBOutlet UIView *_contentView;
    // Content view top layout constraint.
    __weak IBOutlet NSLayoutConstraint *_contentViewTop;
    // Content view bottom layout constraint.
    __weak IBOutlet NSLayoutConstraint *_contentViewBottom;
    
    // Business funnel Cells.
    NSArray<CCHistoryFilterCellEntity *> *_businessFunnelCells;
    // Message status Cells.
    NSArray<CCHistoryFilterCellEntity *> *_messageStatusCells;
    
    NSDictionary *_selectFunnel;
}
@end

@implementation CCHistoryFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateContentViewBottomLayoutConstraint];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// Setup.
- (void)setup {
    
    _businessFunnelCells = [self createBusinessFunnelEntitis];
    _messageStatusCells = [self createMessageStatusEntitis];
 
    [self updateBusinessFunnelCount];;
}

// Creating Business funnel entities.
- (NSArray<CCHistoryFilterCellEntity *> *)createBusinessFunnelEntitis {
    
    NSMutableArray<CCHistoryFilterCellEntity *> *entities = @[].mutableCopy;
    
    [entities addObject:[[CCHistoryFilterCellEntity alloc] initWithItemTitle:CCHistoryFilterBusinessFunnelTypeAll
                                                                  countTitle:@""
                                                                    funnelId:nil
                                                                  isSelected:NO]];
    
    for (NSDictionary *businessFunnel in [CCConstants sharedInstance].businessFunnels) {
        [entities addObject:[[CCHistoryFilterCellEntity alloc] initWithItemTitle:[businessFunnel objectForKey:@"name"]
                                                                      countTitle:@""
                                                                        funnelId:[businessFunnel objectForKey:@"id"]
                                                                      isSelected:NO]];
        
    }
    
    // Default select.
    _selectFunnel = [CCUserDefaultsUtil filterBusinessFunnel];
    if (_selectFunnel == nil || [_selectFunnel objectForKey:@"id"] == nil) {
        entities[0].isSelected = YES;
    } else {
        for (CCHistoryFilterCellEntity *entity in entities) {
            entity.isSelected = [entity.funnelId isEqual:[_selectFunnel objectForKey:@"id"]];
        }
    }
    
    return entities;
}

// Creating Messages status entities.
- (NSArray<CCHistoryFilterCellEntity *> *)createMessageStatusEntitis {
    
    NSMutableArray<CCHistoryFilterCellEntity *> *entities = @[].mutableCopy;

    // All.
    [entities addObject:[[CCHistoryFilterCellEntity alloc] initWithItemTitle:CCHistoryFilterMessagesStatusTypeAll
                                                                  countTitle:@""
                                                                  isSelected:NO]];
    // Unassigned.
    [entities addObject:[[CCHistoryFilterCellEntity alloc] initWithItemTitle:CCHistoryFilterMessagesStatusTypeUnassigned
                                                                  countTitle:@""
                                                                  isSelected:NO]];
    // Assigned to me.
    [entities addObject:[[CCHistoryFilterCellEntity alloc] initWithItemTitle:CCHistoryFilterMessagesStatusTypeAssignedToMe
                                                                  countTitle:@""
                                                                  isSelected:NO]];
    // Archived.
    [entities addObject:[[CCHistoryFilterCellEntity alloc] initWithItemTitle:CCHistoryFilterMessagesStatusTypeClosed
                                                                  countTitle:@""
                                                                  isSelected:NO]];

    // Default select.
    NSArray <NSString *> *selectedMessageStatus = [CCUserDefaultsUtil filterMessageStatus];
    if (selectedMessageStatus != nil && selectedMessageStatus.count > 0) {
        for (CCHistoryFilterCellEntity *entity in entities) {
            entity.isSelected = [selectedMessageStatus containsObject:entity.itemTitle];
        }
    } else {
        // Selected All.
        entities[0].isSelected = YES;
    }
    
    return entities;
}

- (NSString *)countTitleWithCount:(NSUInteger)count {
    if (count > 999) {
        return @"999+";
    }
    return [NSString stringWithFormat:@"%zd", count];
}

#pragma mark - TableView Delegate.

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case CCHistoryFilterViewSectionTypeFunnel:
        case CCHistoryFilterViewSectionTypeStatus:
            return CCHistoryFilterItemCellHeight;
        default:
            return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Deselect.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Saved select row.
    if (indexPath.section == CCHistoryFilterViewSectionTypeFunnel) {
        [self didSelectBusinessFunnelWithIndexPath:indexPath];
    } else if (indexPath.section == CCHistoryFilterViewSectionTypeStatus) {
        [self didSelectMessageStatusWithIndexPath:indexPath];
    }

    // Save filter condition.
    [self sevedFilterCondition];
    
    // Delegate.
    [_delegate pressFilterButton];
    
    // Close.
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case CCHistoryFilterViewSectionTypeFunnel:
            if (_businessFunnelCells.count <= 0) {
                return 0;
            }
            return CCHistoryFilterItemHeaderViewHeight;
        case CCHistoryFilterViewSectionTypeStatus:
            if (_messageStatusCells.count <= 0) {
                return 0;
            }
            return CCHistoryFilterItemHeaderViewHeight;
        default:
            return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case CCHistoryFilterViewSectionTypeFunnel:
            if (_businessFunnelCells.count <= 0) {
                return nil;
            }
            return _businessFunnelSectionHeaderView;
        case CCHistoryFilterViewSectionTypeStatus:
            if (_messageStatusCells.count <= 0) {
                return nil;
            }
            return _messageStatusSectionHeaderView;
        default:
            return nil;
    }
}

#pragma mark - TableView DataSource.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return CCHistoryFilterViewSectionTypeMax;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case CCHistoryFilterViewSectionTypeFunnel:
            return _businessFunnelCells.count;
        case CCHistoryFilterViewSectionTypeStatus:
            return _messageStatusCells.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case CCHistoryFilterViewSectionTypeFunnel:
        case CCHistoryFilterViewSectionTypeStatus: {
            
            CCHistoryFilterViewItemCell *cell =
            (CCHistoryFilterViewItemCell*)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CCHistoryFilterViewItemCell class])];
            
            CCHistoryFilterCellEntity *entity;
            if (indexPath.section == CCHistoryFilterViewSectionTypeFunnel) {
                entity = _businessFunnelCells[indexPath.row];
            } else {
                entity = _messageStatusCells[indexPath.row];
            }
            
            [cell setupWithItemTitle:entity.itemTitle count:entity.countTitle isChecked:entity.isSelected];
            
            return cell;
        }
        default:
            return nil;
    }
}

#pragma mark - Button action.

// Press close button.
- (IBAction)pressCloseButton:(id)sender {
    
    // Close.
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Private method.

// Business funnel select event.
- (void)didSelectBusinessFunnelWithIndexPath:(NSIndexPath*)indexPath {

    if (indexPath.row == 0 && _businessFunnelCells[0].isSelected) {
        return;
    }
    
    CCHistoryFilterViewItemCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    BOOL isSelected = !_businessFunnelCells[indexPath.row].isSelected;
    [cell setChecked:isSelected];
    _businessFunnelCells[indexPath.row].isSelected = isSelected;
    
    if (isSelected) {
        if (indexPath.row == 0) {
            _selectFunnel = nil;
        } else {
            _selectFunnel = @{
                              @"id": _businessFunnelCells[indexPath.row].funnelId,
                              @"name": _businessFunnelCells[indexPath.row].itemTitle
                              };
        }
        NSUInteger count = 0;
        for (CCHistoryFilterCellEntity *entity in _businessFunnelCells) {
            if (indexPath.row == count) {
                // Skip select funnel.
                count++;
                continue;
            }
            entity.isSelected = NO;
            CCHistoryFilterViewItemCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:count inSection:CCHistoryFilterViewSectionTypeFunnel]];
            [cell setChecked:entity.isSelected];
            count++;
        }
    } else {
        _selectFunnel = nil;
        
        _businessFunnelCells[0].isSelected = YES;
        CCHistoryFilterViewItemCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:CCHistoryFilterViewSectionTypeFunnel]];
        [cell setChecked:_businessFunnelCells[0].isSelected];
    }
}

// Message status select event.
- (void)didSelectMessageStatusWithIndexPath:(NSIndexPath*)indexPath {

    CCHistoryFilterViewItemCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    BOOL isSelected = _messageStatusCells[indexPath.row].isSelected;
    if (isSelected) {
        return;
    }
    isSelected = !isSelected;
    [cell setChecked:isSelected];
    _messageStatusCells[indexPath.row].isSelected = isSelected;
    
    NSUInteger count = 0;
    for (CCHistoryFilterCellEntity *entity in _messageStatusCells) {
        if (count == indexPath.row) {
            count++;
            continue;
        }
        entity.isSelected = NO;
        CCHistoryFilterViewItemCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:count inSection:CCHistoryFilterViewSectionTypeStatus]];
        [cell setChecked:entity.isSelected];
        count++;
    }
}

- (void)updateContentViewBottomLayoutConstraint {
    
    CGRect frame = _contentView.frame;
    frame.size.height = [self calculationViewHeight];
    _contentView.frame = frame;
    
    CGFloat constant = [UIScreen mainScreen].bounds.size.height - (frame.size.height + _contentViewTop.constant);
    _contentViewBottom.constant = constant;
}

- (CGFloat)calculationViewHeight {
    
    CGFloat height = 0;

    // Business funnel cells.
    if (_businessFunnelCells.count > 0) {
        height += CCHistoryFilterItemHeaderViewHeight;
        height += (CCHistoryFilterItemCellHeight * _businessFunnelCells.count);
    }
    
    // Message status cells.
    if (_messageStatusCells.count > 0) {
        height += CCHistoryFilterItemHeaderViewHeight;
        height += (CCHistoryFilterItemCellHeight * _messageStatusCells.count);
    }

    height += 8;
    
    if (height > [UIScreen mainScreen].bounds.size.height - _contentViewTop.constant) {
        height = [UIScreen mainScreen].bounds.size.height - _contentViewTop.constant;
    }
    
    return height;
}

- (void)sevedFilterCondition {
    // Bisiness funnel.
    [CCUserDefaultsUtil setFilterBusinessFunnel:_selectFunnel];
    // Message status.
    NSMutableArray <NSString *> *selectedMessageStatus = @[].mutableCopy;
    for (CCHistoryFilterCellEntity *entity in _messageStatusCells) {
        if (entity.isSelected) {
            [selectedMessageStatus addObject:entity.itemTitle];
        }
    }
    [CCUserDefaultsUtil setFilterMessageStatus:selectedMessageStatus];
}

- (void)updateBusinessFunnelCount {
    NSUInteger count = 0;
    __weak typeof(self) weakSelf = self;
    for (__weak CCHistoryFilterCellEntity *entity in _businessFunnelCells) {
        [[ChatCenterClient sharedClient]
         getChannelCount:nil
         funnelId:entity.funnelId
         completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
             if (result) {
                 entity.countTitle = [weakSelf countTitleWithCount:[result[@"all"] integerValue]];
             }
             [weakSelf updateMessageStatusCount];
         }];
        count++;
    }
}

- (void)updateMessageStatusCount {
    [[ChatCenterClient sharedClient]
     getChannelCount:nil
//     funnelId:[_selectFunnel objectForKey:@"id"]
     funnelId:nil
     completionHandler:^(NSDictionary *result, NSError *error, CCAFHTTPRequestOperation *operation) {
         if (result) {
             for (CCHistoryFilterCellEntity *entity in _messageStatusCells) {
                 if ([entity.itemTitle isEqualToString:CCHistoryFilterMessagesStatusTypeAll]) {
                     entity.countTitle = [self countTitleWithCount:[result[@"all"] integerValue]];
                 } else if ([entity.itemTitle isEqualToString:CCHistoryFilterMessagesStatusTypeUnassigned]) {
                     entity.countTitle = [self countTitleWithCount:[result[@"unassigned"] integerValue]];
                 } else if ([entity.itemTitle isEqualToString:CCHistoryFilterMessagesStatusTypeAssignedToMe]) {
                     entity.countTitle = [self countTitleWithCount:[result[@"mine"] integerValue]];
                 } else if ([entity.itemTitle isEqualToString:CCHistoryFilterMessagesStatusTypeClosed]) {
                     entity.countTitle = [self countTitleWithCount:[result[@"closed"] integerValue]];
                 }
             }
             dispatch_async(dispatch_get_main_queue(), ^() {
                 [_tableView reloadData];
             });
         }
     }];
}

@end
