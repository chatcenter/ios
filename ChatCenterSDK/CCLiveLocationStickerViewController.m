//
//  CCLiveLocationStickerViewController.m
//  ChatCenterDemo
//
//  Created by VietHD on 12/21/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCLiveLocationStickerViewController.h"
#import "CCCommonWidgetPreviewViewController.h"
#import "ChatCenterPrivate.h"
#import "CCJSQMessage.h"
#import "CCConstants.h"
#import "CCSVProgressHUD.h"

@interface CCLiveLocationStickerViewController (){
    BOOL shouldAutoShowUserLocation;
    int durationIndex;
    BOOL tappedDoneButton;
    CLLocation *currentLocation;
}
@end

@implementation CCLiveLocationStickerViewController
int durationListSize = 4;
int durationList[] = {15, 30, 45, 60};
float MAP_ZOOM_LANDMASS = 5;
float MAP_ZOOM_CITY = 10;
float MAP_ZOOM_STREETS = 15;
float MAP_ZOOM_BUILDINGS = 20;

- (void)viewDidLoad {
    [super viewDidLoad];
    ///
    /// Google map set up
    ///
    self.mapView.myLocationEnabled = YES;
    // setup location
    [self locationSetup];

    self.navigationItem.title = CCLocalizedString(@"Share Live Location");
    
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CCcancel_btn"] style:UIBarButtonItemStylePlain target:self action:@selector(closeModal)];
    closeBtn.tintColor = [[CCConstants sharedInstance] baseColor];
    self.navigationItem.leftBarButtonItem = closeBtn;
    
    if (!_isOpenedFromWidgetMessage) {
        UIBarButtonItem *sendBtn = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Next") style:UIBarButtonItemStylePlain target:self action:@selector(selectLiveLocationSticker:)];
        sendBtn.tintColor = [[CCConstants sharedInstance] baseColor];
        self.navigationItem.rightBarButtonItem = sendBtn;
    } else {
        UIBarButtonItem *sendBtn = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Done") style:UIBarButtonItemStylePlain target:self action:@selector(doneLiveLocationSticker:)];
        sendBtn.tintColor = [[CCConstants sharedInstance] baseColor];
        self.navigationItem.rightBarButtonItem = sendBtn;
    }
    
    [self durationPickerSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeModal {
    if (!_isOpenedFromWidgetMessage) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)locationSetup { ///for map sticker
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self checkLocationEnabled]) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
}

-(void)durationPickerSetup {
    durationIndex = 0;
    [self updateDurationTitle];
}

-(void)updateDurationTitle {
    self.durationTitle.text = [self convertDurationToString:durationList[durationIndex]];
}

-(NSString *)convertDurationToString: (int)duration {
    if (duration <= 0) {
        duration = 60;
    }
    if(duration == INT_MAX) {
        return @"∞";
    }
    
    NSString *unit_hr = CCLocalizedString(@"hours");
    NSString *unit_mn = CCLocalizedString(@"minutes");
    
    int hours = duration / 60;
    int minutes = duration - hours * 60;
    if (hours > 1) {
        if (minutes == 0) {
            return [NSString stringWithFormat:@"%d %@", hours, unit_hr];
        } else {
            return [NSString stringWithFormat:@"%d %@ %d %@", hours, unit_hr, minutes, unit_mn];
        }
    } else if (hours == 1) {
        if (minutes == 0) {
            return [NSString stringWithFormat:@"%d %@", hours, CCLocalizedString(@"hour")];
        } else {
            return [NSString stringWithFormat:@"%d %@ %d %@", hours, CCLocalizedString(@"hour"), minutes, unit_mn];
        }
    }
    return [NSString stringWithFormat:@"%d %@", minutes, unit_mn];
}

-(BOOL)checkLocationEnabled {
    // Check if location services are available
    if ([CLLocationManager locationServicesEnabled] == NO) {
        
        // Display alert to the user.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Location services")
                                                                       message:CCLocalizedString(@"Location services are not enabled on this device. Please enable location services in settings.")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Dismiss") style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
        
    }
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) { //requestWhenInUseAuthorization can be used in iOS8
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusNotDetermined: {
                [self.locationManager requestWhenInUseAuthorization];
                return NO;
            }
                
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse: {
                return YES;
            }
                
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted: {
                // Display alert to the user.
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:CCLocalizedString(@"Location services")
                                                                               message:CCLocalizedString(@"Location services are not enabled on this device. Please enable location services in settings.")
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:CCLocalizedString(@"Dismiss") style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                NSLog(@"Location is denied");
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)selectLiveLocationSticker:(id)sender {
    NSString *googleApiKey = [CCConstants sharedInstance].googleApiKey;
    NSString *mapThumbURLStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%lf,%lf&size=450x230&zoom=15&sensor=true&markers=%lf,%lf&key=%@",self.mapView.myLocation.coordinate.latitude,self.mapView.myLocation.coordinate.longitude,self.mapView.myLocation.coordinate.latitude,self.mapView.myLocation.coordinate.longitude, googleApiKey];
    
    NSString *text = CCLocalizedString(@"Location");
    
    NSDictionary *locationContent = @{@"uid":[self.delegate generateMessageUniqueId],
                                      @"message":@{@"text":text},
                                      @"sticker-type": CC_STICKERTYPECOLOCATION,
                                      CC_RESPONSETYPESTICKERCONTENT:
                                          @{@"sticker-data" :
                                                @{
                                                    @"type": @"start",
                                                    @"location" :
                                                      @{@"lat":[NSString stringWithFormat:@"%f", self.mapView.myLocation.coordinate.latitude],
                                                        @"lng":[NSString stringWithFormat:@"%f", self.mapView.myLocation.coordinate.longitude]}
                                                  },
                                            @"sticker-type": @"location",
                                            @"thumbnail-url" : mapThumbURLStr
                                            }
                                      };
    CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:@""];
    msg.type = CC_RESPONSETYPESTICKER;
    msg.content = locationContent;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setInteger:durationList[durationIndex] forKey:kCCUserDefaults_liveLocationDuration];
    [userDefault synchronize];
    
    CCCommonWidgetPreviewViewController *vc = [[CCCommonWidgetPreviewViewController alloc] initWithNibName:@"CCCommonWidgetPreviewViewController" bundle:SDK_BUNDLE];
    [vc setDelegate:self.delegate];
    [vc setMessage:msg];
    vc.closeWidgetPreviewCallback = self.closeCoLocationStickerCallback;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)doneLiveLocationSticker:(id)sender {
    if (!tappedDoneButton) {
        [CCSVProgressHUD showWithStatus:nil];
        tappedDoneButton = YES;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setInteger:durationList[durationIndex] forKey:kCCUserDefaults_liveLocationDuration];
        [userDefault synchronize];
        
        if(self.liveLocationWidgetDelegate != nil) {
            [self.liveLocationWidgetDelegate didStartSharingLiveLocation];
        }
    }
}
#pragma mark - Location Manager Delegate
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"Location is denied");
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            NSLog(@"Location is denied");
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations.lastObject;
    currentLocation = location;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.coordinate.latitude
                                                            longitude:currentLocation.coordinate.longitude
                                                                 zoom:MAP_ZOOM_STREETS];
    [self.mapView setCamera:camera];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
}

#pragma mark - View Actions
- (IBAction)lessButtonClicked:(id)sender {
    if(durationIndex == 0) {
        return;
    }
    durationIndex --;
    [self updateDurationTitle];
}

- (IBAction)moreButtonClicked:(id)sender {
    if(durationIndex == durationListSize - 1) {
        return;
    }
    durationIndex ++;
    [self updateDurationTitle];
}
@end
