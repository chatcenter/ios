//
//  CCLocationStickerViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 3/14/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCLocationStickerViewController.h"
#import "ChatCenterPrivate.h"
#import "CCConstants.h"
#import "CCCommonWidgetPreviewViewController.h"
#import "UIImage+CCSDKImage.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <GooglePlacePicker/GooglePlacePicker.h>

@interface CCLocationStickerViewController () {
    GMSPlace *selectedPlace;
    BOOL returnFromPreview;
    BOOL isShowingPicker;
}
@property (nonatomic, strong) GMSPlacePicker *placePicker;
@property (nonatomic, strong) CLLocation *currentLocation;
@end

@implementation CCLocationStickerViewController

int mapTapCount = 0; // Count times tap on the MapView

- (void)viewDidLoad {
    [super viewDidLoad];
    isShowingPicker = NO;
    returnFromPreview = NO;
    // setup location
    [self locationSetup];
    self.navigationController.navigationBar.tintColor = [[CCConstants sharedInstance] baseColor];
}

- (void)viewWillAppear:(BOOL)animated {
    if (returnFromPreview) {
        [self showPlacePicker];
        returnFromPreview = NO;
    }
}

- (void)closeModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)locationSetup { ///for map sticker
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self checkLocationEnabled]) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
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
                NSLog(@"Location is denied");
                [self closeModal];
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
        }
    }
    
    return YES;
}

- (void)sendLocationMessage {
    NSString *googleApiKey = [CCConstants sharedInstance].googleApiKey;
    NSString *mapThumbURLStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%lf,%lf&size=450x230&zoom=15&sensor=true&markers=%lf,%lf&key=%@",selectedPlace.coordinate.latitude,selectedPlace.coordinate.longitude,selectedPlace.coordinate.latitude,selectedPlace.coordinate.longitude, googleApiKey];
    
    NSString *text = selectedPlace.name;
    if (!text) {
        text = @"";
    }
    
    NSDictionary *locationContent = @{@"uid":[self.delegate generateMessageUniqueId],
                                      @"message":@{@"text":text},
                                      CC_RESPONSETYPESTICKERCONTENT:
                                          @{@"sticker-data" :
                                                @{@"location" :
                                                      @{@"lat":[NSString stringWithFormat:@"%f", selectedPlace.coordinate.latitude],
                                                        @"lng":[NSString stringWithFormat:@"%f", selectedPlace.coordinate.longitude]}
                                                  },
                                            @"thumbnail-url" : mapThumbURLStr
                                            },
                                      @"sticker-type": @"location"
                                      };
    CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:@""];
    msg.type = CC_RESPONSETYPESTICKER;
    msg.content = locationContent;
    
    
    CCCommonWidgetPreviewViewController *vc = [[CCCommonWidgetPreviewViewController alloc] initWithNibName:@"CCCommonWidgetPreviewViewController" bundle:SDK_BUNDLE];
    [vc setDelegate:self.delegate];
    [vc setMessage:msg];
    vc.closeWidgetPreviewCallback = self.closeLocationStickerCallback;
    returnFromPreview = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) showPlacePicker {
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(_currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001);
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                         coordinate:southWest];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    _placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
    [UINavigationBar appearance].tintColor = [[CCConstants sharedInstance] baseColor];
    isShowingPicker = YES;
    [_placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        isShowingPicker = NO;
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            [self closeModal];
            return;
        }
        
        if (place != nil) {
            selectedPlace = place;
            ///
            /// Goto preview view
            ///
            [self sendLocationMessage];
        } else {
            NSLog(@"No place selected");
            [self closeModal];
        }
    }];
}

#pragma mark - Location Manager delegates
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
            [self closeModal];
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations.firstObject;
    _currentLocation = location;
    if ((isShowingPicker || _placePicker != nil) && [self checkLocationEnabled]) {
        return;
    }
    [self showPlacePicker];
}
@end
