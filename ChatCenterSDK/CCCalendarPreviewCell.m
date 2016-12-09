//
//  CCCalendarPreviewCell.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/09/07.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCCalendarPreviewCell.h"
#import "CCConstants.h"

@interface CCCalendarPreviewCell()
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *discription;

@end

@implementation CCCalendarPreviewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
    [self addSubview:self.contentView];
}

- (id)initWithFrameAndData:(CGRect)frame
         selectedDateTimes:(NSArray *)selectedDateTimes
{
    self = [self initWithFrame:frame];

    self.contentView.backgroundColor = [[CCConstants sharedInstance] baseColor];
    self.title.text = CCLocalizedString(@"Here are some times that works for me.");
    self.title.textColor = [UIColor whiteColor];
    self.discription.text = CCLocalizedString(@"Choose a slot and tap to reply.");
    self.discription.textColor = [UIColor whiteColor];
    [self displayDateTimes:selectedDateTimes];
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds
                                     byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                           cornerRadii:CGSizeMake(18.0, 18.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.contentView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.contentView.layer.mask = maskLayer;
    
    return self;
}

- (void)displayDateTimes:(NSArray *)selectedDateTimes{
    int offsetY = 0;
    for (int i = 0; i < selectedDateTimes.count; i++) {
        CCDateTimes *datetimes = selectedDateTimes[i];
        if (datetimes.times.count == 0) continue;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = CCLocalizedString(@"dateFormat");
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = CCLocalizedString(@"timeChoiceDateFormat");
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
            UIButton *choice = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            choice.frame = CGRectMake(0, offsetY, self.choiceContainer.bounds.size.width, CHOICE_HEIGHT);
            NSString *from = [timeFormatter stringFromDate:times[j][@"from"]];
            NSString *to = [timeFormatter stringFromDate:times[j][@"to"]];
            NSString *title = [NSString stringWithFormat:@"%@ - %@ %@", from, to, [[NSTimeZone localTimeZone] abbreviation]];
            [choice setTitle:title forState:UIControlStateNormal];
            [choice.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
            [choice setTintColor:[UIColor whiteColor]];
            [choice setBackgroundColor:[UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0]];
            [self.choiceContainer addSubview:choice];
            offsetY = offsetY + CHOICE_HEIGHT + CHOICE_MARGIN;
        }
    }
}

@end
