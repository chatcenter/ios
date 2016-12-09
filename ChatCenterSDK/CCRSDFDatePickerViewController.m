#import "CCRSDFDatePickerViewController.h"
#import "CCConnectionHelper.h"

@interface CCRSDFDatePickerViewController() <RSDFDatePickerViewDelegate, RSDFDatePickerViewDataSource>
@property (nonatomic, strong) NSMutableDictionary *markedDates;

@end

@implementation CCRSDFDatePickerViewController

@synthesize datePickerView = _datePickerView;

#pragma mark - Lifecycle

- (void) viewDidLoad
{
	[super viewDidLoad];
	
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.title = @"Date Picker";

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.opaque = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248/255.0f green:248/255.0f blue:248/255.0f alpha:1.0f];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f]};
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    [self.view addSubview:self.datePickerView];
    
    
    /*
     * added by shingo
     */
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithTitle:@"Done"
                               style:UIBarButtonItemStyleBordered
                               target:self
                               action:@selector(pressDone:)];
    self.navigationItem.leftBarButtonItem = button;
    self.markedDates = [[NSMutableDictionary alloc] init];
    [UINavigationBar appearance].tintColor    = [UIColor blackColor];
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *todayComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
//    NSDate *today = [calendar dateFromComponents:todayComponents];
//    
//    NSArray *numberOfDaysFromToday = @[@(-8), @(-2), @(-1), @(0), @(2), @(4), @(8), @(13), @(22)];
//    
//    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//    self.markedDates = [[NSMutableDictionary alloc] initWithCapacity:[numberOfDaysFromToday count]];
//    [numberOfDaysFromToday enumerateObjectsUsingBlock:^(NSNumber *numberOfDays, NSUInteger idx, BOOL *stop) {
//        dateComponents.day = [numberOfDays integerValue];
//        NSDate *date = [calendar dateByAddingComponents:dateComponents toDate:today options:0];
//        if ([date compare:today] == NSOrderedAscending) {
//            self.markedDates[date] = @YES;
//        } else {
//            self.markedDates[date] = @NO;
//        }
//    }];
}

#pragma mark - Custom Accessors

- (CCRSDFDatePickerView *)datePickerView
{
	if (!_datePickerView) {
		_datePickerView = [CCRSDFDatePickerView new];
        _datePickerView.delegate = self;
        _datePickerView.dataSource = self;
		_datePickerView.frame = self.view.bounds;
		_datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
	return _datePickerView;
}

#pragma mark - RSDFDatePickerViewDelegate

- (void)datePickerView:(CCRSDFDatePickerView *)view didSelectDate:(NSDate *)date
{
//    [[[UIAlertView alloc] initWithTitle:@"Picked Date" message:[date description] delegate:nil cancelButtonTitle:@":D" otherButtonTitles:nil] show];
    [self.markedDates setObject:@"1" forKey:date];
    [_datePickerView reloadData];
}

- (UIColor *)datePickerView:(CCRSDFDatePickerView *)view markImageColorForDate:(NSDate *)date
{
    return [UIColor greenColor];
}


#pragma mark - RSDFDatePickerViewDataSource

- (NSDictionary *)datePickerViewMarkedDates:(CCRSDFDatePickerView *)view
{
//	NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *todayComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
//    NSDate *today = [calendar dateFromComponents:todayComponents];
//    
//    NSArray *numberOfDaysFromToday = @[@(-8), @(-2), @(-1), @(0), @(2), @(4), @(8), @(13), @(22)];
//    
//    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//    self.markedDates = [[NSMutableDictionary alloc] initWithCapacity:[numberOfDaysFromToday count]];
//    [numberOfDaysFromToday enumerateObjectsUsingBlock:^(NSNumber *numberOfDays, NSUInteger idx, BOOL *stop) {
//        dateComponents.day = [numberOfDays integerValue];
//        NSDate *date = [calendar dateByAddingComponents:dateComponents toDate:today options:0];
//        if ([date compare:today] == NSOrderedAscending) {
//            self.markedDates[date] = @YES;
//        } else {
//            self.markedDates[date] = @NO;
//        }
//    }];
    
    return [self.markedDates copy];
}

- (BOOL)datePickerView:(CCRSDFDatePickerView *)view shouldMarkDate:(NSDate *)date
{
    if(self.markedDates[date]){
        return YES;
    }else{
        return NO;
    }
}


/**
 * 次へボタンがタップされたとき
 */
- (void)pressDone:(id)sender
{
    NSLog(@"CCRSDFDatePickerViewController-pressDone");
    NSMutableArray *str   = [[NSMutableArray alloc] init];

    for (NSDate *date in [self.markedDates keyEnumerator]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd"];
        NSString *dateStr = [formatter stringFromDate:date];
        [str addObject:dateStr];
    }
    [[CCConnectionHelper sharedClient] setDatepicker:str];
    [self dismissViewControllerAnimated:YES completion:nil];
    
//    [[[UIAlertView alloc] initWithTitle:@"Picked Date"
//                                message:str
//                               delegate:nil
//                      cancelButtonTitle:@":D"
//                      otherButtonTitles:nil] show];
}

@end
