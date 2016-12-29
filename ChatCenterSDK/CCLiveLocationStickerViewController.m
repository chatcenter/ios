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

@interface CCLiveLocationStickerViewController () <MKMapViewDelegate>{
    MKPointAnnotation *currentAnnotation;
    BOOL shouldAutoShowUserLocation;
    int durationIndex;
    BOOL tappedDoneButton;
}
@end

@implementation CCLiveLocationStickerViewController
int durationListSize = 16;
int durationList[] = {15, 30, 45, 60, 120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, INT_MAX};

- (void)viewDidLoad {
    [super viewDidLoad];
    tappedDoneButton = NO;
    [self.mapView setDelegate:self];
    [self.mapView setShowsUserLocation:YES];
    shouldAutoShowUserLocation = YES;
    
    self.navigationItem.title = CCLocalizedString(@"Share Live Location");
    
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(closeModal)];
    self.navigationItem.leftBarButtonItem = closeBtn;
    
    if (!_isOpenedFromWidgetMessage) {
        UIBarButtonItem *sendBtn = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Next") style:UIBarButtonItemStylePlain target:self action:@selector(selectLiveLocationSticker:)];
        self.navigationItem.rightBarButtonItem = sendBtn;
    } else {
        UIBarButtonItem *sendBtn = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Done") style:UIBarButtonItemStylePlain target:self action:@selector(doneLiveLocationSticker:)];
        self.navigationItem.rightBarButtonItem = sendBtn;
    }
    
    // setup location
    [self locationSetup];
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
    durationIndex = 3;
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
    if (hours >= 1) {
        if (minutes == 0) {
            return [NSString stringWithFormat:@"%d %@", hours, unit_hr];
        } else {
            return [NSString stringWithFormat:@"%d %@ %d %@", hours, unit_hr, minutes, unit_mn];
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


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    CLGeocoder *geo = [[CLGeocoder alloc] init];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    
    [geo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  if (!error){
                      CLPlacemark *placemark = [placemarks objectAtIndex:0];
                      NSString *address = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                      
                      NSArray *anotations = self.mapView.annotations;
                      [self.mapView removeAnnotations:anotations];
                      
                      MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                      annotation.coordinate = self.mapView.centerCoordinate;
                      annotation.title = CCLocalizedString(@"Tap here");
                      annotation.subtitle = address;
                      [self.mapView selectAnnotation:annotation animated:NO];
                      currentAnnotation = annotation;
                  }
                  else {
                      NSLog(@"Could not locate");
                  }
              }];
}

- (void)selectLiveLocationSticker:(id)sender {

    NSString *mapThumbURLStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%lf,%lf&size=450x230&zoom=15&sensor=true&markers=%lf,%lf&key=%@",currentAnnotation.coordinate.latitude,currentAnnotation.coordinate.longitude,currentAnnotation.coordinate.latitude,currentAnnotation.coordinate.longitude, CC_GOOGLEMAPS_API_KEY];
    
    NSString *text = CCLocalizedString(@"Location");
    
    NSDictionary *locationContent = @{@"uid":[self.delegate generateMessageUniqueId],
                                      @"message":@{@"text":text},
                                      @"sticker-type": CC_STICKERTYPECOLOCATION,
                                      CC_RESPONSETYPESTICKERCONTENT:
                                          @{@"sticker-data" :
                                                @{
                                                    @"type": @"start",
                                                    @"location" :
                                                      @{@"lat":[NSString stringWithFormat:@"%f", currentAnnotation.coordinate.latitude],
                                                        @"lng":[NSString stringWithFormat:@"%f", currentAnnotation.coordinate.longitude]}
                                                  },
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
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)doneLiveLocationSticker:(id)sender {
    if (!tappedDoneButton) {
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

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (shouldAutoShowUserLocation) {
        shouldAutoShowUserLocation = NO;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1500, 1500);
        MKCoordinateRegion newRegion = [self.mapView regionThatFits:viewRegion];
        [self.mapView setRegion:newRegion animated:YES];
    }
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
