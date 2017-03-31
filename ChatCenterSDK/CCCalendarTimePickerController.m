//
//  CCCalendarTimePickerController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 2015/08/17.
//  Copyright (c) 2015年 AppSocially Inc. All rights reserved.
//

#import "CCCalendarTimePickerController.h"
#import "CCCommonStickerCollectionViewCell.h"
#import "CCCommonWidgetPreviewViewController.h"

@interface CCCalendarTimePickerController (){
    CCCalendarWeekView *lastView;
    CCCalendarWeekView *crntView;
    CCCalendarWeekView *nextView;
    CCCalendarPreview *preview;
    NSMutableArray *weekViews;
    int currentPage;
    NSMutableArray *numOfDays;
    NSMutableArray *crtViewDayArray;
    NSInteger crtWeekIndex;
    NSDate *seletedDate;
    NSDateFormatter *dateFormatter;
    BOOL isRotating;
}
@end

@implementation CCCalendarTimePickerController

const int VIEW_COUNT = 3;

- (instancetype)initWithDelegate:(id<CCCommonWidgetEditorDelegate>)delegate {
    if(self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.titleLabel.text = CCLocalizedString(@"Schedule");
    self.titleDiscriptionLabel.text = CCLocalizedString(@"Choose dates and times you are available");
    [self.cancelButton setImage:[[UIImage imageNamed:@"CCcancel_btn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.cancelButton.tintColor = [[CCConstants sharedInstance] baseColor];
    [self.doneButton setTitle:CCLocalizedString(@"Next") forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[[CCConstants sharedInstance] baseColor] forState:UIControlStateNormal];
    CALayer *topBorderDate = [CALayer layer];
    topBorderDate.frame = CGRectMake(0.0f, 0.0f, self.CCCalendarDateLabel.frame.size.width, 1.0f);
    topBorderDate.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0].CGColor;
    [self.CCCalendarDateLabel.layer addSublayer:topBorderDate];
    
    [self setUpWeekView];
    [self setUpTimeView];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = CCLocalizedString(@"dateFormat");
    
    [self updateDateLabelText]; ///Update date
    
    currentPage = 1;
    
    ///Commented out because of unexpected behavior when the device(UIInterfaceOrientationMaskPortrait) rotated
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    //---------------------------------------------------------------------------------------------------
    //
    // After autolayout(viewDidAppear), caluculate the position of current line in calendarTimeScrollView
    //
    //---------------------------------------------------------------------------------------------------
    [self displayTimeCurrentLine];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    isRotating = YES;
    // redraw weekview
    [crntView removeFromSuperview];
    [lastView removeFromSuperview];
    [nextView removeFromSuperview];
    [self setUpWeekView];
    // redraw timeview
    [self.calendarTimeScrollView awakeFromNib];
    [self.calendarTimeScrollView updateSelections:self.calendarTimeScrollView.selectedHourTimes];
    [self.calendarTimeScrollView scrollRectToVisible:self.calendarTimeScrollView.frame animated:YES];
    isRotating = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.tag == 0) {
        ///Judging page is turned or not
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        ///Update view contents
        if (page == 0) {
            ///Turned back
            [self movePageBack:weekViews];
            currentPage --;
        }else if (page == VIEW_COUNT-1) {
            ///Turned forward
            [self movePageForward:weekViews];
            currentPage ++;
        }
        ///Returning scroll view offset to the center
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * 1;
        frame.origin.y = 0;
        [scrollView scrollRectToVisible:frame animated:NO];
    }
}

#pragma mark - Weekly view

- (void)setUpWeekView{
    weekViews = [NSMutableArray array];
    numOfDays = [NSMutableArray array];
    
    CGRect rect = [UIScreen mainScreen].bounds; ///calendarWeekScrollView.frame.size.width will be as same as screen width
    int width = rect.size.width;
    int height = self.calendarWeekScrollView.frame.size.height;
    
    self.calendarWeekScrollView.pagingEnabled = YES;
    self.calendarWeekScrollView.contentSize = CGSizeMake(width * VIEW_COUNT, height);
    self.calendarWeekScrollView.showsHorizontalScrollIndicator = NO;
    self.calendarWeekScrollView.showsVerticalScrollIndicator = NO;
    self.calendarWeekScrollView.clipsToBounds = NO;
    [self.calendarWeekScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    CGRect frame = self.calendarWeekScrollView.frame;
    frame.origin.x = width;
    frame.origin.y = 0;
    [self.calendarWeekScrollView scrollRectToVisible:frame animated:NO];
    [self.calendarWeekScrollView setDelegate:self];
    
    ///Current month
    NSDate *crtDate;
    if (seletedDate == nil) {
        crtDate = [NSDate date];
        seletedDate = crtDate;
    } else {
        crtDate = seletedDate;
    }
    NSUInteger flags;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (osVersion >= 8.0f)  {
        flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay;
    } else {
        flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit;
    }
#else
    flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit;
#endif
    NSDateComponents *crtComponents = [[NSCalendar currentCalendar] components:flags fromDate:crtDate];
    NSInteger year = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] component:NSCalendarUnitYear fromDate:crtDate];
    NSInteger crtYear = year;
    NSInteger crtMonth = crtComponents.month;
    NSInteger crtWeekDay = crtComponents.weekday;
    NSInteger crtDay = crtComponents.day;
    NSRange crtRangeOfDay = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay
                                                               inUnit:NSCalendarUnitMonth
                                                              forDate:crtDate];
    NSUInteger crtNumberOfDay = crtRangeOfDay.length;
    NSDictionary *crtNumOfDayDictionary = @{@"year":[NSString stringWithFormat:@"%ld", (long)crtYear],
                                            @"month":[NSString stringWithFormat:@"%ld", (long)crtMonth],
                                            @"numOfDay":[NSString stringWithFormat:@"%ld", (long)crtNumberOfDay]};
    [numOfDays addObject:crtNumOfDayDictionary];
    
    ///Last month
    NSInteger lastYear;
    NSInteger lastMonth;
    NSDateComponents* lastComponents = [[NSDateComponents alloc] init];
    if (crtMonth == 1) {
        ///last month => last year
        lastYear = crtYear - 1;
        lastMonth = 12;
    }else{
        ///last month => current year
        lastYear = crtYear;
        lastMonth = crtMonth - 1;
    }
    lastComponents.year = lastYear;
    lastComponents.month = lastMonth;
    NSDate *lastDate = [[NSCalendar currentCalendar] dateFromComponents:lastComponents];
    NSRange lastRangeOfDay = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay
                                                                inUnit:NSCalendarUnitMonth
                                                               forDate:lastDate];
    NSUInteger lastNumberOfDay = lastRangeOfDay.length;
    NSDictionary *lastNumOfDayDictionary = @{@"year":[NSString stringWithFormat:@"%ld", (long)lastYear],
                                             @"month":[NSString stringWithFormat:@"%ld", (long)lastMonth],
                                             @"numOfDay":[NSString stringWithFormat:@"%ld", (long)lastNumberOfDay]};
    [numOfDays addObject:lastNumOfDayDictionary];
    
    ///crtView
    crtViewDayArray = [NSMutableArray array];
    NSInteger crtViewStartDay;
    if (crtWeekDay == 1) { ///Sunday
        crtWeekIndex = 6;
    }else{
        crtWeekIndex = crtWeekDay - 2;
    }
    crtViewStartDay = crtDay - crtWeekIndex;
    NSLog(@"crtViewStartDay: %ld", (long)crtViewStartDay);
    if (crtViewStartDay < 1) {
        ///start day => last month
        crtViewStartDay = lastNumberOfDay + crtViewStartDay;
        int newMonthDay = 0;
        for (int i = 0; i < 7; i++) {
            int numberOfDay;
            int numberOfMonth;
            int numberOfYear;
            if ((int)crtViewStartDay + i > lastNumberOfDay) {
                ///current month
                newMonthDay++;
                numberOfDay = newMonthDay;
                numberOfMonth = (int)crtMonth;
                numberOfYear = (int)crtYear;
            }else{
                ///last month
                numberOfDay = (int)crtViewStartDay + i;
                numberOfMonth = (int)lastMonth;
                numberOfYear = (int)lastYear;
            }
            NSString *day = [NSString stringWithFormat:@"%d", numberOfDay];
            NSString *month = [NSString stringWithFormat:@"%d", numberOfMonth];
            NSString *year = [NSString stringWithFormat:@"%d", numberOfYear];
            NSLog(@"crtView day: %@", day);
            NSDateComponents* components = [[NSDateComponents alloc] init];
            components.year = numberOfYear;
            components.month = numberOfMonth;
            components.day = numberOfDay;
            NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:components];
            [crtViewDayArray addObject:@{@"year":year,
                                         @"month":month,
                                         @"day":day,
                                         @"nsdate":date}];
        }
    }else{
        ///start day => current month
        int newMonthDay = 0;
        for (int i = 0; i < 7; i++) {
            int numberOfDay;
            int numberOfMonth;
            int numberOfYear;
            if ((int)crtViewStartDay + i > crtNumberOfDay) {
                ///next month
                newMonthDay++;
                numberOfDay = newMonthDay;
                if (crtMonth == 12) {
                    numberOfMonth = 1;
                    numberOfYear = (int)crtYear + 1;
                }else{
                    numberOfMonth = (int)crtMonth + 1;
                    numberOfYear = (int)crtYear;
                }
            }else{
                ///current month
                numberOfDay = (int)crtViewStartDay + i;
                numberOfMonth = (int)crtMonth;
                numberOfYear = (int)crtYear;
            }
            NSString *day = [NSString stringWithFormat:@"%d", numberOfDay];
            NSString *month = [NSString stringWithFormat:@"%d", numberOfMonth];
            NSString *year = [NSString stringWithFormat:@"%d", numberOfYear];
            NSLog(@"crtView day: %@", day);
            NSDateComponents* components = [[NSDateComponents alloc] init];
            components.year = numberOfYear;
            components.month = numberOfMonth;
            components.day = numberOfDay;
            NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:components];
            [crtViewDayArray addObject:@{@"year":year,
                                         @"month":month,
                                         @"day":day,
                                         @"nsdate":date}];
        }
    }
    crntView = [[CCCalendarWeekView alloc] initWithFrame:CGRectMake(width,0,width,height)];
    [crntView setUp:[crtViewDayArray copy] dayOfWeek:crtWeekIndex];
    crntView.delegate = self;
    [weekViews addObject:crntView];
    [self.calendarWeekScrollView addSubview:crntView];
    
    ///Adjusting days
    NSInteger targetNumberOfDay;
    NSInteger targetYear;
    NSInteger targetMonth;
    if([crtViewDayArray[0][@"month"] isEqualToString:crtViewDayArray[crtWeekIndex][@"month"]]){
        targetNumberOfDay = crtNumberOfDay;
        targetYear = crtYear;
        targetMonth = crtMonth;
    }else{
        targetNumberOfDay = lastNumberOfDay; ///Fisrt day of week must be last month compare to current day
        targetYear = lastYear;
        targetMonth = lastMonth;
    }
    
    ///lastView
    NSMutableArray *lastViewDayArray = [NSMutableArray array];
    NSInteger lastViewStartDay;
    lastViewStartDay = crtViewStartDay - 7;
    if (lastViewStartDay < 1) {
        ///start day => last month
        lastViewStartDay = lastNumberOfDay + lastViewStartDay;
        int newMonthDay = 0;
        for (int i = 0; i < 7; i++) {
            int numberOfDay;
            int numberOfMonth;
            int numberOfYear;
            if ((int)lastViewStartDay + i > lastNumberOfDay) {
                ///current month
                newMonthDay++;
                numberOfDay = newMonthDay;
                numberOfMonth = (int)targetMonth;
                numberOfYear = (int)targetYear;
            }else{
                ///last month
                numberOfDay = (int)lastViewStartDay + i;
                if (targetMonth == 1) {
                    numberOfMonth = 12;
                    numberOfYear = (int)targetYear - 1;
                }else{
                    numberOfMonth = (int)targetMonth - 1;
                    numberOfYear = (int)targetYear;
                }
            }
            NSString *day = [NSString stringWithFormat:@"%d", numberOfDay];
            NSString *month = [NSString stringWithFormat:@"%d", numberOfMonth];
            NSString *year = [NSString stringWithFormat:@"%d", numberOfYear];
            NSLog(@"latView day: %@", day);
            NSLog(@"latView month: %@", month);
            NSLog(@"latView year: %@", year);
            NSDateComponents* components = [[NSDateComponents alloc] init];
            components.year = numberOfYear;
            components.month = numberOfMonth;
            components.day = numberOfDay;
            NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:components];
            [lastViewDayArray addObject:@{@"year":year,
                                          @"month":month,
                                          @"day":day,
                                          @"nsdate":date}];
        }
    }else{
        ///start day => current month
        int numberOfMonth = (int)targetMonth;
        int numberOfYear = (int)targetYear;
        for (int i = 0; i < 7; i++) {
            NSString *day = [NSString stringWithFormat:@"%d", (int)lastViewStartDay + i];
            NSString *month = [NSString stringWithFormat:@"%d", numberOfMonth];
            NSString *year = [NSString stringWithFormat:@"%d", numberOfYear];
            NSLog(@"latView day: %@", day);
            NSLog(@"latView month: %@", month);
            NSLog(@"latView year: %@", year);
            NSDateComponents* components = [[NSDateComponents alloc] init];
            components.year = numberOfYear;
            components.month = numberOfMonth;
            components.day = (int)lastViewStartDay + i;
            NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:components];
            [lastViewDayArray addObject:@{@"year":year,
                                          @"month":month,
                                          @"day":day,
                                          @"nsdate":date}];
        }
    }
    lastView = [[CCCalendarWeekView alloc] initWithFrame:CGRectMake(0,0,width,height)];
    [lastView setUp:[lastViewDayArray copy] dayOfWeek:-1];
    lastView.delegate = self;
    [weekViews insertObject:lastView atIndex:0];
    [self.calendarWeekScrollView addSubview:lastView];
    
    ///nextView
    NSMutableArray *nextViewDayArray = [NSMutableArray array];
    NSInteger nextViewStartDay;
    nextViewStartDay = crtViewStartDay + 7;
    if (nextViewStartDay > targetNumberOfDay) {
        ///start day => next month
        nextViewStartDay = nextViewStartDay - targetNumberOfDay;
        int numberOfMonth;
        int numberOfYear;
        if (targetMonth == 12) {
            numberOfMonth = 1;
            numberOfYear = (int)targetYear + 1;
        }else{
            numberOfMonth = (int)targetMonth + 1;
            numberOfYear = (int)targetYear;
        }
        for (int i = 0; i < 7; i++) {
            NSString *day = [NSString stringWithFormat:@"%d", (int)nextViewStartDay + i];
            NSString *month = [NSString stringWithFormat:@"%d", numberOfMonth];
            NSString *year = [NSString stringWithFormat:@"%d", numberOfYear];
            NSLog(@"nextView day: %@", day);
            NSDateComponents* components = [[NSDateComponents alloc] init];
            components.year = numberOfYear;
            components.month = numberOfMonth;
            components.day = (int)nextViewStartDay + i;
            NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:components];
            [nextViewDayArray addObject:@{@"year":year,
                                          @"month":month,
                                          @"day":day,
                                          @"nsdate":date}];
        }
    }else{
        ///start day => current month
        int newMonthDay = 0;
        for (int i = 0; i < 7; i++) {
            int numberOfDay;
            int numberOfMonth;
            int numberOfYear;
            if ((int)nextViewStartDay + i > targetNumberOfDay) {
                ///next month
                newMonthDay++;
                numberOfDay = newMonthDay;
                if (targetMonth == 12) {
                    numberOfMonth = 1;
                    numberOfYear = (int)targetYear + 1;
                }else{
                    numberOfMonth = (int)targetMonth + 1;
                    numberOfYear = (int)targetYear;
                }
            }else{
                ///current month
                numberOfDay = (int)nextViewStartDay + i;
                numberOfMonth = (int)targetMonth;
                numberOfYear = (int)targetYear;
            }
            NSString *day = [NSString stringWithFormat:@"%d", numberOfDay];
            NSString *month = [NSString stringWithFormat:@"%d", numberOfMonth];
            NSString *year = [NSString stringWithFormat:@"%d", numberOfYear];
            NSLog(@"nextView day: %@", day);
            NSDateComponents* components = [[NSDateComponents alloc] init];
            components.year = numberOfYear;
            components.month = numberOfMonth;
            components.day = numberOfDay;
            NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:components];
            [nextViewDayArray addObject:@{@"year":year,
                                          @"month":month,
                                          @"day":day,
                                          @"nsdate":date}];
        }
    }
    nextView = [[CCCalendarWeekView alloc] initWithFrame:CGRectMake(width*2,0,width,height)];
    [nextView setUp:[nextViewDayArray copy] dayOfWeek:-1];
    nextView.delegate = self;
    [weekViews addObject:nextView];
    [self.calendarWeekScrollView addSubview:nextView];
}

- (CGRect)correctRectOfPageView:(int)pageViewNum
{
    CGRect rect = [UIScreen mainScreen].bounds; ///calendarWeekScrollView.frame.size.width will be as same as screen width
    int width = rect.size.width;
    int height = self.calendarWeekScrollView.frame.size.height;
    float x = width * (pageViewNum - 1);
    return CGRectMake(x, 0, width, height);
}

- (void)movePageForward:(NSMutableArray *)views{
    if (isRotating) return;
    [self updateSelectedDateTimes]; ///Store selected hours
    NSMutableArray *newWeekViews = [NSMutableArray array];
    for (int i = 0; i < views.count; i++) {
        CCCalendarWeekView *weekView = views[i];
        int newScrollPos;
        if(i == 0){
            CCCalendarWeekView *crtNextView = (CCCalendarWeekView *)weekViews[views.count-1];
            NSArray *newNextViewDayArray = [self getNextViewDayArray:crtNextView.dayArray];
            [weekView updateDateTxt:newNextViewDayArray];
            newScrollPos = (int)views.count;
            [newWeekViews addObject:weekView];
        }else{
            newScrollPos = (i + 1) - 1;
            [newWeekViews insertObject:weekView atIndex:(newScrollPos - 1)];
        }
        weekView.frame = [self correctRectOfPageView:newScrollPos];
    }
    weekViews = newWeekViews;
    CCCalendarWeekView *crtWeekView = (CCCalendarWeekView *)weekViews[1];
    crtViewDayArray = [crtWeekView.dayArray mutableCopy];
    [crtWeekView updateWeekDay:crtWeekIndex]; ///Update circle
    [(CCCalendarWeekView *)weekViews[0] updateWeekDay:-1]; ///Clear circle
    [(CCCalendarWeekView *)weekViews[2] updateWeekDay:-1]; ///Clear circle
    [self updateSelections]; ///Update selected hours
    [self updateDateLabelText]; ///Update date
    seletedDate = crtViewDayArray[crtWeekIndex][@"nsdate"];
}

- (void)movePageBack:(NSMutableArray *)views{
    if (isRotating) return;
    [self updateSelectedDateTimes]; ///Store selected hours
    NSMutableArray *newWeekViews = [NSMutableArray array];
    for (int i = 0; i < views.count; i++) {
        CCCalendarWeekView *weekView = views[i];
        int newScrollPos;
        if(i != views.count - 1){
            newScrollPos = (i + 1) + 1;
            [newWeekViews addObject:weekView];
        }else{
            CCCalendarWeekView *crtLastView = (CCCalendarWeekView *)views[0];
            NSArray *newLastViewDayArray = [self getLastViewDayArray:crtLastView.dayArray];
            [weekView updateDateTxt:newLastViewDayArray];
            newScrollPos = 1;
            [newWeekViews insertObject:weekView atIndex:0];
        }
        weekView.frame = [self correctRectOfPageView:newScrollPos];
    }
    weekViews = newWeekViews;
    CCCalendarWeekView *crtWeekView = (CCCalendarWeekView *)weekViews[1];
    crtViewDayArray = [crtWeekView.dayArray mutableCopy];
    [crtWeekView updateWeekDay:crtWeekIndex]; ///Update circle
    [(CCCalendarWeekView *)weekViews[0] updateWeekDay:-1]; ///Clear circle
    [(CCCalendarWeekView *)weekViews[2] updateWeekDay:-1]; ///Clear circle
    [self updateSelections]; ///Update selected hours
    [self updateDateLabelText]; ///Update date
    seletedDate = crtViewDayArray[crtWeekIndex][@"nsdate"];
}

- (NSArray *)getNextViewDayArray:(NSArray *)dayArray{
    NSMutableArray *nextViewDayArray = [NSMutableArray array];
    NSInteger nextViewStartDay;
    NSDictionary *dayDictionary = (NSDictionary *)dayArray[0];
    NSInteger crtViewStartDay = [(NSString *)dayDictionary[@"day"] integerValue];
    nextViewStartDay = crtViewStartDay + 7;
    ///get crtNumberOfDay
    NSString *crtYear = (NSString *)dayDictionary[@"year"];
    NSString *crtMonth = (NSString *)dayDictionary[@"month"];
    NSInteger crtNumberOfDay;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@ AND month == %@", crtYear , crtMonth];
    NSArray *resultArray = [numOfDays filteredArrayUsingPredicate:predicate];
    if (resultArray.count > 0) {
        NSDictionary *resultDic = [resultArray firstObject];
        crtNumberOfDay = [(NSString *)resultDic[@"numOfDay"] integerValue];
    }else{
        ///Create crtNumberOfDay
        NSDateComponents* crtComponents = [[NSDateComponents alloc] init];
        crtComponents.year = crtYear.integerValue;
        crtComponents.month = crtMonth.integerValue;
        NSDate *lastDate = [[NSCalendar currentCalendar] dateFromComponents:crtComponents];
        NSRange crtRangeOfDay = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay
                                                                   inUnit:NSCalendarUnitMonth
                                                                  forDate:lastDate];
        crtNumberOfDay = crtRangeOfDay.length;
        NSDictionary *crtNumOfDayDictionary = @{@"year":[NSString stringWithFormat:@"%ld", (long)crtComponents.year],
                                                @"month":[NSString stringWithFormat:@"%ld", (long)crtComponents.month],
                                                @"numOfDay":[NSString stringWithFormat:@"%ld", (long)crtNumberOfDay]};
        [numOfDays addObject:crtNumOfDayDictionary];
    }
    if (nextViewStartDay > crtNumberOfDay) {
        ///start day => next month
        nextViewStartDay = nextViewStartDay - crtNumberOfDay;
        int numberOfYear = crtYear.intValue;
        int numberOfMonth = crtMonth.intValue;
        if ([crtMonth isEqualToString:@"12"]) {
            numberOfYear++;
            numberOfMonth = 1;
        }else{
            numberOfMonth++;
        }
        for (int i = 0; i < 7; i++) {
            NSString *day = [NSString stringWithFormat:@"%d", (int)nextViewStartDay + i];
            NSString *month = [NSString stringWithFormat:@"%d", numberOfMonth];
            NSString *year = [NSString stringWithFormat:@"%d", numberOfYear];
            NSLog(@"getNextViewDayArray day: %@", day);
            NSLog(@"getNextViewDayArray month: %@", month);
            NSLog(@"getNextViewDayArray year: %@", year);
            NSDateComponents* components = [[NSDateComponents alloc] init];
            components.year = numberOfYear;
            components.month = numberOfMonth;
            components.day = (int)nextViewStartDay + i;
            NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:components];
            [nextViewDayArray addObject:@{@"year":year,
                                          @"month":month,
                                          @"day":day,
                                          @"nsdate":date}];
        }
    }else{
        ///start day => current month
        int newMonthDay = 0;
        for (int i = 0; i < 7; i++) {
            int numberOfYear = crtYear.intValue;
            int numberOfMonth = crtMonth.intValue;
            int numberOfDay;
            if ((int)nextViewStartDay + i > crtNumberOfDay) {
                ///next month
                if ([crtMonth isEqualToString:@"12"]){
                    numberOfYear++;
                    numberOfMonth = 1;
                }else{
                    numberOfMonth++;
                }
                newMonthDay++;
                numberOfDay = newMonthDay;
            }else{
                ///current month
                numberOfDay = (int)nextViewStartDay + i;
            }
            NSString *day = [NSString stringWithFormat:@"%d", numberOfDay];
            NSString *month = [NSString stringWithFormat:@"%d", numberOfMonth];
            NSString *year = [NSString stringWithFormat:@"%d", numberOfYear];
            NSLog(@"getNextViewDayArray day: %@", day);
            NSLog(@"getNextViewDayArray month: %@", month);
            NSLog(@"getNextViewDayArray year: %@", year);
            NSDateComponents* components = [[NSDateComponents alloc] init];
            components.year = numberOfYear;
            components.month = numberOfMonth;
            components.day = numberOfDay;
            NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:components];
            [nextViewDayArray addObject:@{@"year":year,
                                          @"month":month,
                                          @"day":day,
                                          @"nsdate":date}];
        }
    }
    return [nextViewDayArray copy];
}

- (NSArray *)getLastViewDayArray:(NSArray *)dayArray{
    NSMutableArray *lastViewDayArray = [NSMutableArray array];
    NSInteger lastViewStartDay;
    NSDictionary *dayDictionary = (NSDictionary *)dayArray[0];
    NSInteger crtViewStartDay = [(NSString *)dayDictionary[@"day"] integerValue];
    lastViewStartDay = crtViewStartDay - 7;
    if (lastViewStartDay < 1) {
        ///start day => last month
        ///get lastNumberOfDay
        NSString *lastMonth;
        NSString *lastYear;
        NSInteger lastNumberOfDay;
        if ([(NSString *)dayDictionary[@"month"] isEqualToString:@"1"]) {
            ///start day => last year
            lastMonth = @"12";
            NSInteger lastYearInteger = [(NSString *)dayDictionary[@"year"] integerValue] - 1;
            lastYear = [NSString stringWithFormat:@"%ld", (long)lastYearInteger];
        }else{
            NSInteger lastMonthInteger = [(NSString *)dayDictionary[@"month"] integerValue] - 1;
            lastMonth = [NSString stringWithFormat:@"%ld", (long)lastMonthInteger];
            lastYear = (NSString *)dayDictionary[@"year"];
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@ AND month == %@", lastYear , lastMonth];
        NSDictionary *resultDic = [[numOfDays filteredArrayUsingPredicate:predicate] firstObject];
        if (resultDic == nil) {
            ///Create lastNumberOfDay
            NSDateComponents* lastComponents = [[NSDateComponents alloc] init];
            lastComponents.year = lastYear.integerValue;
            lastComponents.month = lastMonth.integerValue;
            NSDate *lastDate = [[NSCalendar currentCalendar] dateFromComponents:lastComponents];
            NSRange lastRangeOfDay = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay
                                                                       inUnit:NSCalendarUnitMonth
                                                                      forDate:lastDate];
            lastNumberOfDay = lastRangeOfDay.length;
            NSDictionary *lastNumOfDayDictionary = @{@"year":[NSString stringWithFormat:@"%ld", (long)lastComponents.year],
                                                     @"month":[NSString stringWithFormat:@"%ld", (long)lastComponents.month],
                                                     @"numOfDay":[NSString stringWithFormat:@"%ld", (long)lastNumberOfDay]};
            [numOfDays addObject:lastNumOfDayDictionary];
        }else{
            lastNumberOfDay = [(NSString *)resultDic[@"numOfDay"] integerValue];
        }
        lastViewStartDay = lastNumberOfDay + lastViewStartDay;
        int newMonthDay = 0;
        for (int i = 0; i < 7; i++) {
            int numberOfYear = lastYear.intValue;
            int numberOfMonth = lastMonth.intValue;
            int numberOfDay;
            if ((int)lastViewStartDay + i > lastNumberOfDay) {
                if ([lastMonth isEqualToString:@"12"]){
                    numberOfYear++;
                    numberOfMonth = 1;
                }else{
                    numberOfMonth++;
                }
                newMonthDay++;
                numberOfDay = newMonthDay;
            }else{
                numberOfDay = (int)lastViewStartDay + i;
            }
            NSString *day = [NSString stringWithFormat:@"%d", numberOfDay];
            NSString *month = [NSString stringWithFormat:@"%d", numberOfMonth];
            NSString *year = [NSString stringWithFormat:@"%d", numberOfYear];
            NSLog(@"getLastViewDayArray day: %@", day);
            NSLog(@"getLastViewDayArray month: %@", month);
            NSLog(@"getLastViewDayArray year: %@", year);
            NSDateComponents* components = [[NSDateComponents alloc] init];
            components.year = numberOfYear;
            components.month = numberOfMonth;
            components.day = numberOfDay;
            NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:components];
            [lastViewDayArray addObject:@{@"year":year,
                                          @"month":month,
                                          @"day":day,
                                          @"nsdate":date}];
        }
    }else{
        ///start day => current month
        for (int i = 0; i < 7; i++) {
            NSString *day = [NSString stringWithFormat:@"%d", (int)lastViewStartDay + i];
            NSDateComponents* components = [[NSDateComponents alloc] init];
            components.year = [(NSString *)dayDictionary[@"year"] integerValue];
            components.month = [(NSString *)dayDictionary[@"month"] integerValue];
            components.day = (int)lastViewStartDay + i;
            NSDate* date = [[NSCalendar currentCalendar] dateFromComponents:components];
            [lastViewDayArray addObject:@{@"year":dayDictionary[@"year"],
                                          @"month":dayDictionary[@"month"],
                                          @"day":day,
                                          @"nsdate":date}];
            NSLog(@"getLastViewDayArray day: %@", day);
            NSLog(@"getLastViewDayArray month: %@", dayDictionary[@"month"]);
            NSLog(@"getLastViewDayArray year: %@", dayDictionary[@"year"]);
        }
    }
    return [lastViewDayArray copy];
}

#pragma mark - Time view

- (void)setUpTimeView{
    self.selectedDateTimes = [NSMutableArray array];
//    [self.calendarTimeScrollView setDelegate:self];
    [self.calendarTimeScrollView setTimeScrollViewDelegate:self];
    [self.calendarTimeScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
}

- (void)displayTimeCurrentLine{
    [self.calendarTimeScrollView displayCurrentLine];
}

- (void)moveForward{
    NSLog(@"moveForward");
    [self updateSelectedDateTimes]; ///Store selected hours
    if (crtWeekIndex == 6) {
        crtWeekIndex = 0;
        [self movePageForward:weekViews];
    }else{
        crtWeekIndex++;
    }
    [(CCCalendarWeekView *)weekViews[1] updateWeekDay:crtWeekIndex]; ///Update circle
    [self updateSelections]; ///Update selected hours
    [self updateDateLabelText]; ///Update date
    seletedDate = crtViewDayArray[crtWeekIndex][@"nsdate"];
};

- (void)moveBack{
    NSLog(@"moveBack");
    [self updateSelectedDateTimes]; ///Store selected hours
    if (crtWeekIndex == 0) {
        crtWeekIndex = 6;
        [self movePageBack:weekViews];
    }else{
        crtWeekIndex--;
    }
    [(CCCalendarWeekView *)weekViews[1] updateWeekDay:crtWeekIndex]; ///Update circle
    [self updateSelections]; ///Update selected hours
    [self updateDateLabelText]; ///Update date
    seletedDate = crtViewDayArray[crtWeekIndex][@"nsdate"];
};

- (void)moveWeekDay:(NSInteger)dayOfWeek{
    NSLog(@"moveWeekDay");
    [self updateSelectedDateTimes]; ///Store selected hours
    crtWeekIndex = dayOfWeek;
    [(CCCalendarWeekView *)weekViews[1] updateWeekDay:crtWeekIndex]; ///Update circle
    [self updateSelections]; ///Update selected hours
    [self updateDateLabelText]; ///Update date
    seletedDate = crtViewDayArray[crtWeekIndex][@"nsdate"];
};

- (void)updateSelections{
    NSDictionary *nextDay = crtViewDayArray[crtWeekIndex];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"year == %@ AND month == %@ AND day == %@", nextDay[@"year"], nextDay[@"month"], nextDay[@"day"]];
    NSMutableArray *selectedHourTimes;
    CCDateTimes *result = [[self.selectedDateTimes filteredArrayUsingPredicate:predicate] firstObject];
    if (result == nil) {
        selectedHourTimes = [NSMutableArray array];
    }else{
        selectedHourTimes = [[result times] mutableCopy];
    }
    [self.calendarTimeScrollView updateSelections:selectedHourTimes];
}

- (void)updateSelectedDateTimes{
    NSDictionary *today = crtViewDayArray[crtWeekIndex];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"year == %@ AND month == %@ AND day == %@", today[@"year"], today[@"month"], today[@"day"]];
    CCDateTimes *result = [[self.selectedDateTimes filteredArrayUsingPredicate:predicate] firstObject];
    if (result != nil) {
        [self.selectedDateTimes removeObject:result];
    }
    CCDateTimes *newDateTime = [[CCDateTimes alloc] initWithDate:today[@"year"]
                                                           month:today[@"month"]
                                                             day:today[@"day"]
                                                       weekIndex:crtWeekIndex
                                                            date:today[@"nsdate"]
                                                           times:[self.calendarTimeScrollView.selectedHourTimes copy]];
    [self.selectedDateTimes addObject:newDateTime];
    
    // sort selected date times
    NSArray *sortedSelectedDateTimes;
    if (self.selectedDateTimes != nil && [self.selectedDateTimes respondsToSelector:@selector(sortedArrayUsingSelector:)]
        && [self.selectedDateTimes count] > 0 && [[self.selectedDateTimes objectAtIndex:0] respondsToSelector:@selector(compare:)]) {
        sortedSelectedDateTimes = [self.selectedDateTimes sortedArrayUsingSelector:@selector(compare:)];
    }else{
        sortedSelectedDateTimes = self.selectedDateTimes;
    }
    self.selectedDateTimes = [NSMutableArray arrayWithArray:sortedSelectedDateTimes];
}

#pragma mark - Preview

- (void)calendarPreviewDidTapClose{
    [preview removeFromSuperview];
    self.closeCalendarTimePickerCallback(nil);
}

- (void)calendarPreviewDidTapSend{
    [preview removeFromSuperview];
    NSMutableArray *sendDateTimes = [NSMutableArray array];
    for (CCDateTimes *dateTimes in preview.selectedDateTimes) {
        for (NSDictionary *fromTo in dateTimes.times) {
            NSTimeInterval fromInterval = [fromTo[@"from"] timeIntervalSince1970];
            NSString *fromString = [NSString stringWithFormat:@"%f", fromInterval];
            NSTimeInterval toInterval = [fromTo[@"to"] timeIntervalSince1970];
            NSString *toString = [NSString stringWithFormat:@"%f", toInterval];
            NSDictionary *sendFromTo = @{@"from":fromString, @"to":toString};
            [sendDateTimes addObject:sendFromTo];
        }
    }
    self.parentViewController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
    [self dismissViewControllerAnimated:YES completion:^{
      self.closeCalendarTimePickerCallback(sendDateTimes);
    }];
}

#pragma mark - Header action
-(void)didTapCancelButton:(id)sender {
    self.parentViewController.modalTransitionStyle = UIModalPresentationOverCurrentContext;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didTapDecideButton:(id)sender {
}

- (IBAction)didTapDoneButton:(id)sender {
    [self updateSelectedDateTimes]; ///Store selected hours
    ///Calculate times And add start and end
    NSArray *aggregatedDateTimes = [self aggregateSelectedDateTimes];
    
    if (aggregatedDateTimes.count == 0) {
        float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if(osVersion >= 8.0f)  { ///iOS8
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Please select at least 1 time slot.") message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:CCLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }else{ ///iOS7
            UIAlertView *alertView;
                    alertView = [[UIAlertView alloc] initWithTitle:CCLocalizedString(@"Please select at least 1 time slot.")
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:CCLocalizedString(@"OK")
                                                 otherButtonTitles:nil, nil];
            alertView.tag = normalAlertTag;
            [alertView show];
        }
        return;
    }

    
    
    
    
    
    
    
    CCCommonWidgetPreviewViewController *previewController = [[CCCommonWidgetPreviewViewController alloc] initWithNibName:@"CCCommonWidgetPreviewViewController" bundle:SDK_BUNDLE];
    
    CCJSQMessage *msg = [self createMessageStickerFromDateTimes:aggregatedDateTimes];
    
    [previewController setMessage:msg];
    previewController.delegate = self.delegate;
    [self.navigationController pushViewController:previewController animated:YES];
}

- (CCJSQMessage *)createMessageStickerFromDateTimes:(NSArray *)selectedDateTimes {
    NSMutableArray *actionsDatas = [NSMutableArray array];
    for (int i = 0; i < selectedDateTimes.count; i++) {
        CCDateTimes *datetimes = selectedDateTimes[i];
        if (datetimes.times.count == 0) continue;
        
        NSDateFormatter *formaterFrom = [[NSDateFormatter alloc] init];
        [formaterFrom setDateFormat:CCLocalizedString(@"calendar_sticker_time_format_from")];
        [formaterFrom setTimeZone:[NSTimeZone defaultTimeZone]];
        
        NSDateFormatter *formaterWithDate = [[NSDateFormatter alloc] init];
        [formaterWithDate setDateFormat:CCLocalizedString(@"calendar_sticker_time_format")];
        [formaterWithDate setTimeZone:[NSTimeZone defaultTimeZone]];
        
        NSDateFormatter *formaterTo = [[NSDateFormatter alloc] init];
        [formaterTo setDateFormat:CCLocalizedString(@"calendar_sticker_time_format_to")];
        [formaterTo setTimeZone:[NSTimeZone defaultTimeZone]];
        
        ///Choice time button
        NSArray *times = datetimes.times;
        for (int j = 0; j < times.count; j++) {
            NSDate *startDate = times[j][@"from"];
            NSDate *endDate = times[j][@"to"];
            // set data
            double start = [startDate timeIntervalSince1970];
            double end = [endDate timeIntervalSince1970];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *endDateComponents = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:endDate];
            NSString *from;
            NSString *to;
            if (endDateComponents.hour == 0 && endDateComponents.minute == 0) {
                from = [formaterWithDate stringFromDate:startDate];
                to = [formaterWithDate stringFromDate:endDate];
            } else {
                to = [formaterTo stringFromDate:endDate];
                from = [formaterFrom stringFromDate:startDate];
            }
            NSString *label = [NSString stringWithFormat:CCLocalizedString(@"From %@ to %@ %@"), from, to, [[NSTimeZone defaultTimeZone] abbreviation]];
            
            [actionsDatas addObject:@{@"label":label,
                                      @"value":@{@"start":[NSNumber numberWithDouble:start],
                                                 @"end":[NSNumber numberWithDouble:end]}}];
        }
    }
    [actionsDatas addObject:@{@"label":CCLocalizedString(@"Propose other slots"), @"action":@[@"open:sticker/calender"]}];
    
    NSString *uid = [self.delegate generateMessageUniqueId];
    
    NSDictionary *content = @{@"uid":uid,
                              @"message":@{@"text":CCLocalizedString(@"Please select your available time.")},
                              @"sticker-action":@{@"action-type":@"select",
                                                  @"action-data":actionsDatas}
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Other
- (NSArray *)aggregateSelectedDateTimes{
    NSMutableArray *aggregatedDateTimes = [NSMutableArray array];
    for (CCDateTimes *dateTimes in self.selectedDateTimes) {
        if (dateTimes.times.count == 0) continue;
        
        CCDateTimes *newDateTimes = [dateTimes copy];
        NSMutableArray *newTimes = [NSMutableArray array];
        NSString *startHour, *startTime, *endHour, *endTime;
        NSMutableArray *times = [newDateTimes.times mutableCopy];
        while (times.count > 0) {
            if (startHour == nil || startTime == nil || endHour == nil || endTime == nil) {
                ///Update time
                CCHourTime *hourTime = times[0];
                startHour = hourTime.startHour;
                startTime = hourTime.startTime;
                endHour = hourTime.endHour;
                endTime = hourTime.endTime;
                [times removeObject:hourTime];
            }
            BOOL aggregated = YES;

            /// Aggregate dates finish
            if (aggregated == YES || times.count == 0) {
                ///Aggregated Add fromTo to newTimes
                NSDateComponents* components = [[NSDateComponents alloc] init];
                components.year = newDateTimes.year.integerValue;
                components.month = newDateTimes.month.integerValue;
                components.day = newDateTimes.day.integerValue;
                components.hour = startHour.integerValue;
                components.minute = startTime.integerValue;
                NSDate* from = [[NSCalendar currentCalendar] dateFromComponents:components];
                components.hour = endHour.integerValue;
                components.minute = endTime.integerValue;
                NSDate* to = [[NSCalendar currentCalendar] dateFromComponents:components];
                [newTimes addObject:@{@"from":from,
                                      @"to":to}];
                startHour = nil;
                startTime = nil;
                endHour = nil;
                endTime = nil;
            }
        }
        newDateTimes.times = [newTimes copy];
        [aggregatedDateTimes addObject:newDateTimes];
    }
    return [aggregatedDateTimes copy];
}

-(void)updateDateLabelText{
    NSString *dateLabelText;
    if ([[ChatCenter sharedInstance] isLocaleJapanese] == YES) {
        dateLabelText = [[dateFormatter stringFromDate:crtViewDayArray[crtWeekIndex][@"nsdate"]] stringByAppendingFormat:@" %@", [CCConstants weekDayArray][crtWeekIndex]];
    }else{
        dateLabelText = [[CCConstants weekDayArray][crtWeekIndex] stringByAppendingFormat:@", %@", [dateFormatter stringFromDate:crtViewDayArray[crtWeekIndex][@"nsdate"]]];
    }
    self.CCCalendarDateLabel.text = dateLabelText;
}
@end
