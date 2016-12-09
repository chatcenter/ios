//
//  CCPhraseStickerViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 1/29/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCSWTableViewCell.h"

#define CC_FIXED_PHRASE_INDEX       0
#define CC_EDITABLE_PHRASE_INDEX    1

#define CC_ALERT_STYLE_NONE             99
#define CC_ALERT_STYLE_ADD_PHRASE       0
#define CC_ALERT_STYLE_EDIT_PHRASE      1
#define CC_ALERT_STYLE_DELETE_PHRASE    2

@protocol ChoosedPhraseProtocol <NSObject>

- (void) receivedChoosenPhrase: (NSString *) choosenPhrase;

@end

@interface CCPhraseStickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, CCSWTableViewCellDelegate>
{
    NSMutableArray *fixedPhrases;
    NSMutableArray *editablePhrases;
    
    NSUInteger currentAlertStyle;
    NSIndexPath *selectingIndexPath;
}

@property (nonatomic, strong) NSString *orgUid;
@property (nonatomic, strong) id delegate;
@property (weak, nonatomic) IBOutlet UITableView *phraseListView;

- (void) addPrivatePhrase;

@end
