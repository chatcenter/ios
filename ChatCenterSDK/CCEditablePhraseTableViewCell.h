//
//  CCEditablePhraseTableViewCell.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 1/29/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCSWTableViewCell.h"

@interface CCEditablePhraseTableViewCell : CCSWTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *phraseTextView;

- (IBAction)editPhrase:(id)sender;
- (IBAction)deletePhrase:(id)sender;

@end
