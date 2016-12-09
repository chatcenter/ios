//
//  CCDateTimeCollectionViewCell.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/09/13.
//  Copyright © 2015年 AppSocially Inc. All rights reserved.
//

#import "CCDateTimeCollectionViewCell.h"
#import "CCDateTimes.h"
#import "ChatCenterPrivate.h"

extern const int DATE_LABEL_HEIGHT;
extern const int DATE_LABEL_MARGIN;
extern const int CHOICE_HEIGHT;
extern const int CHOICE_MARGIN;

@implementation CCDateTimeCollectionViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.stickerContainer.layer.cornerRadius = 18.0f;
}

- (BOOL)setupWithIndex:(NSIndexPath *)indexPath message:(CCJSQMessage *)msg avatar:(CCJSQMessagesAvatarImage *)avatar delegate:(id<CCStickerCollectionViewCellActionProtocol>)delegate options:(CCStickerCollectionViewCellOptions)options {

    // Initialization code
    
    if(options & CCStickerCollectionViewCellOptionShowAsMyself) {
        self.stickerContainer.backgroundColor = [[CCConstants sharedInstance] baseColor];
    } else {
        self.stickerContainer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    }

    
    for (UIView *view in [self.choiceContainer subviews]) {
        [view removeFromSuperview];
    }
    
    
    if (!(options & CCStickerCollectionViewCellOptionShowAsMyself)){
        self.avatarImage.image = avatar.avatarImage;
        
        self.stickerContainer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    }else{
        self.stickerContainer.backgroundColor = [[CCConstants sharedInstance] baseColor];
    }
    
    ///Title View
    self.titleView.textContainer.lineFragmentPadding = 0;
    self.titleView.textContainerInset = UIEdgeInsetsMake(10, 10, 2, 10);
    NSString *titleString = NSLocalizedString(@"Here are some times that works for me.", @"");
    NSDictionary *titleStringAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14.0f]};
    NSMutableAttributedString *titleAttributeString = [[NSMutableAttributedString alloc] initWithString:titleString
                                                                                             attributes:titleStringAttributes];
    self.titleView.attributedText = titleAttributeString;
    if (!(options & CCStickerCollectionViewCellOptionShowAsMyself)){
        self.titleView.textColor = [UIColor whiteColor];
    }
    CGRect titleViewFrame = [titleAttributeString boundingRectWithSize:CGSizeMake(180, 1800)
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                               context:nil];
    titleViewFrame.size.width = titleViewFrame.size.width + 20; ///prevents UICollectionView's bug(UIEdgeInsetsMake height + width)
    titleViewFrame.size.height = titleViewFrame.size.height + 15;
    self.titleViewHeight.constant = titleViewFrame.size.height;
    titleViewFrame.origin.y = 0;
    titleViewFrame.origin.x = 0;
    self.titleView.frame = titleViewFrame;
    ///Discription View
    self.discriptionView.textContainer.lineFragmentPadding = 0;
    self.discriptionView.textContainerInset = UIEdgeInsetsMake(2, 10, 0, 10);
    NSString *discriptionString = NSLocalizedString(@"Choose a slot and tap to reply.",@"");
    NSDictionary *discriptionStringAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:11.0f]};
    NSMutableAttributedString *discriptionAttributeString = [[NSMutableAttributedString alloc] initWithString:discriptionString
                                                                                                   attributes:discriptionStringAttributes];
    self.discriptionView.attributedText = discriptionAttributeString;
    if (!(options & CCStickerCollectionViewCellOptionShowAsMyself)){
        self.discriptionView.textColor = [UIColor whiteColor];
    }
    CGRect discriptionViewFrame = [discriptionAttributeString boundingRectWithSize:CGSizeMake(180, 1800)
                                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                                           context:nil];
    discriptionViewFrame.size.width = discriptionViewFrame.size.width + 20; ///prevents UICollectionView's bug(UIEdgeInsetsMake height + width)
    discriptionViewFrame.size.height = discriptionViewFrame.size.height + 15;
    self.discriptionViewHeight.constant = discriptionViewFrame.size.height;
    discriptionViewFrame.origin.y = titleViewFrame.size.height;
    discriptionViewFrame.origin.x = 0;
    self.discriptionView.frame = discriptionViewFrame;
    ///Choice container
    NSArray *selectedDateTimes = msg.content[CC_CONTENTKEYDATETIMEAVAILABILITY];
    int offsetY = 0;
    
    for (int i = 0; i < selectedDateTimes.count; i++) {
        CCDateTimes *datetimes = selectedDateTimes[i];
        if (datetimes.times.count == 0) continue;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = NSLocalizedString(@"dateFormat",@"");
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = NSLocalizedString(@"timeChoiceDateFormat",@"");
        ///Date label
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, self.choiceContainer.bounds.size.width,DATE_LABEL_HEIGHT)];
        [dateLabel setFont:[UIFont systemFontOfSize:14.0f]];
        NSString *dateLabelText;
        if ([[ChatCenter sharedInstance] isLocaleJapanese] == YES) {
            dateLabelText = [[dateFormatter stringFromDate:datetimes.date] stringByAppendingFormat:@" %@", [CCConstants weekDayArrayMiddle][datetimes.weekIndex]];
        }else{
            dateLabelText = [[CCConstants weekDayArrayMiddle][datetimes.weekIndex] stringByAppendingFormat:@" %@", [dateFormatter stringFromDate:datetimes.date]];
        }
        dateLabel.text = dateLabelText;
        [self.choiceContainer addSubview:dateLabel];
        offsetY = offsetY + DATE_LABEL_HEIGHT + DATE_LABEL_MARGIN;
        ///Choice time button
        NSArray *times = datetimes.times;
        for (int j = 0; j < times.count; j++) {
            CCChoiceButton *choice = [CCChoiceButton buttonWithType:UIButtonTypeRoundedRect];
            choice.responseType = CC_RESPONSETYPEDATETIMEAVAILABILITY;
            [choice addTarget:delegate
                       action:@selector(pressCalendarChoiceBtn:)
             forControlEvents:UIControlEventTouchDown];
            choice.frame = CGRectMake(0, offsetY, self.choiceContainer.bounds.size.width, CHOICE_HEIGHT);
            NSString *from = [timeFormatter stringFromDate:times[j][@"from"]];
            NSString *to = [timeFormatter stringFromDate:times[j][@"to"]];
            NSString *title = [NSString stringWithFormat:@"%@ - %@ %@", from, to, [[NSTimeZone localTimeZone] abbreviation]];
            [choice setTitle:title forState:UIControlStateNormal];
            choice.answerText = [dateLabelText stringByAppendingFormat:@" %@", title];
            [choice.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
            [choice setTintColor:[UIColor whiteColor]]; ///#1e90ff
            [choice setBackgroundColor:[UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0]];
            [self.choiceContainer addSubview:choice];
            offsetY = offsetY + CHOICE_HEIGHT + CHOICE_MARGIN;
        }
    }
    ///Display name
    if (options & CCStickerCollectionViewCellOptionShowName) {
        self.stickerTopLabelHeight.constant = 20;
        self.stickerTopLabel.text = msg.senderDisplayName;
    }else{
        self.stickerTopLabelHeight.constant = 0;
    }
    ///Display date
    if (options & CCStickerCollectionViewCellOptionShowDate) {
        self.cellTopLabelHeight.constant = 20;
        self.cellTopLabel.attributedText = [[CCJSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:msg.date];
    }else{
        self.cellTopLabelHeight.constant = 0;
    }
    

    return YES;
}


@end
