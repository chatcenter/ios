//
//  CCNoteEditorViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 11/25/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCNoteEditorViewController : UIViewController
@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *noteContent;
@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@end
