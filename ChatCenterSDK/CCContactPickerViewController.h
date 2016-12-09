//
//  THContactPickerViewControllerDemo.h
//  ContactPicker
//
//  Created by Vladislav Kovtash on 12.11.13.
//  Copyright (c) 2013 Tristan Himmelman. All rights reserved.
//

#import "CCTHContactPickerView.h"

@interface CCContactPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CCTHContactPickerView *contactPickerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, readonly) NSArray *selectedContacts;
@property (nonatomic) NSInteger selectedCount;
@property (nonatomic, readonly) NSArray *filteredContacts;
@property BOOL isDirectMessage;
@property (nonatomic, copy) void (^closeContactPickerViewCallback)(NSString *channelId);

- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text;
- (void) didChangeSelectedItems;
- (NSString *) titleForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
