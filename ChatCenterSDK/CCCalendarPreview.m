//
//  CCCalendarPreview.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/09/07.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCCalendarPreview.h"
#import "CCCommonStickerPreviewCollectionViewCell.h"
#import "CCConstants.h"

@interface CCCalendarPreview()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)didTapCancel:(id)sender;
- (IBAction)didTapSend:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@end

@implementation CCCalendarPreview

const int DATE_LABEL_HEIGHT = 30;
const int DATE_LABEL_MARGIN = 0;
const int CHOICE_HEIGHT = 28;
const int CHOICE_MARGIN = 10;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (void)p_commonInit
{
    NSString *className = NSStringFromClass([self class]);
    [SDK_BUNDLE loadNibNamed:className owner:self options:0];
    
    self.contentView.frame = self.bounds;
    self.title.text = CCLocalizedString(@"Preview");
    [self.cancelBtn setTitle:CCLocalizedString(@"Cancel") forState:UIControlStateNormal];
    [self.sendBtn setTitle:CCLocalizedString(@"Send") forState:UIControlStateNormal];
    [self addSubview:self.contentView];
}

- (id)initWithFrameAndData:(CGRect)frame
         selectedDateTimes:(NSArray *)selectedDateTimes
{
    self = [self initWithFrame:frame];
    
    self.selectedDateTimes = selectedDateTimes;
    CGRect rect = [UIScreen mainScreen].bounds; ///calendarWeekScrollView.frame.size.width will be as same as screen width
    int width = rect.size.width;
    
    // create preview cell
    CCJSQMessage *msg = [self createMessageStickerFromDateTimes:selectedDateTimes];
    CGSize previewCellSize = [CCCommonStickerPreviewCollectionViewCell
                              estimateSizeForMessage:msg
                              atIndexPath:nil
                              hasPreviousMessage:nil
                              options:0
                              withListUser:nil];
    CCCommonStickerPreviewCollectionViewCell *previewCell = (CCCommonStickerPreviewCollectionViewCell *)[self viewFromNib:@"CCCommonStickerPreviewCollectionViewCell"];
    previewCell.frame = CGRectMake(width / 2 - previewCellSize.width / 2, 10, previewCellSize.width, previewCellSize.height);
    
    [previewCell setupWithIndex:nil message:msg avatar:nil delegate:nil options:0];
    
    [self.scrollView addSubview:previewCell];
    self.scrollView.contentSize = CGSizeMake(previewCellSize.width, previewCellSize.height + 30);
    
    return self;
}

- (UIView *)viewFromNib:(NSString *)nibName {
    NSArray *nibViews = [SDK_BUNDLE loadNibNamed:nibName owner:nil options:nil];
    UIView *view = [nibViews objectAtIndex:0];
    return view;
}

- (CCJSQMessage *)createMessageStickerFromDateTimes:(NSArray *)selectedDateTimes {
    NSMutableArray *actionsDatas = [NSMutableArray array];
    for (int i = 0; i < selectedDateTimes.count; i++) {
        CCDateTimes *datetimes = selectedDateTimes[i];
        if (datetimes.times.count == 0) continue;
        
        NSDateFormatter *formaterFrom = [[NSDateFormatter alloc] init];
        [formaterFrom setDateFormat:CCLocalizedString(@"calendar_sticker_time_format_from")];
        [formaterFrom setTimeZone:[NSTimeZone defaultTimeZone]];

        NSDateFormatter *formaterTo = [[NSDateFormatter alloc] init];
        [formaterTo setDateFormat:CCLocalizedString(@"calendar_sticker_time_format_to")];
        [formaterTo setTimeZone:[NSTimeZone defaultTimeZone]];
        
        ///Choice time button
        NSArray *times = datetimes.times;
        for (int j = 0; j < times.count; j++) {
            NSString *from = [formaterFrom stringFromDate:times[j][@"from"]];
            NSString *to = [formaterTo stringFromDate:times[j][@"to"]];
            NSString *label = [NSString stringWithFormat:CCLocalizedString(@"From %@ to %@ %@"), from, to, [[NSTimeZone defaultTimeZone] abbreviation]];
            
            // set data
            [actionsDatas addObject:@{@"label":label}];

        }
    }
    [actionsDatas addObject:@{@"label":CCLocalizedString(@"Propose other slots"), @"action":@[@"open:sticker/calender"]}];
    
    NSDictionary *content = @{@"message":@{@"text":CCLocalizedString(@"Please select your available time.")},
                              @"sticker-action":@{@"action-type":@"select",
                                                  @"action-data":actionsDatas},
                              @"sticker-type": @"schedule"
                              };
    
    // create message:sticker from data
    CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:@""
                                             senderDisplayName:@""
                                                          date:[NSDate date]
                                                          text:@""];
    msg.type = CC_RESPONSETYPESTICKER;
    msg.content = content;
    return msg;
}

- (IBAction)didTapCancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(calendarPreviewDidTapClose)]) {
        [self.delegate calendarPreviewDidTapClose];
    }
}

- (IBAction)didTapSend:(id)sender {
    if ([self.delegate respondsToSelector:@selector(calendarPreviewDidTapSend)]) {
        [self.delegate calendarPreviewDidTapSend];
    }
}
@end
