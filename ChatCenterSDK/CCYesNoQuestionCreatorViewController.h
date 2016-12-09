//
//  CCYesNoQuestionCreatorViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 3/2/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCommonStickerCreatorViewController.h"

@interface CCYesNoQuestionCreatorViewController : CCCommonStickerCreatorViewController
{
    __weak IBOutlet UITextView *questionContent;
    __weak IBOutlet UILabel *instructionText;
}

@end
