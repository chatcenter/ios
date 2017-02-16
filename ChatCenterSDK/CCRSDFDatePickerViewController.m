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
    
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithTitle:@"Done"
                               style:UIBarButtonItemStyleBordered
                               target:self
                               action:@selector(pressDone:)];
    self.navigationItem.leftBarButtonItem = button;
    self.markedDates = [[NSMutableDictionary alloc] init];
    [UINavigationBar appearance].tintColor    = [UIColor blackColor];
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
 * When clicked on Done button
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
}

@end
