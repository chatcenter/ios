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


@interface CCLocationStickerViewController () <MKMapViewDelegate, UIGestureRecognizerDelegate> {
    MKPointAnnotation *currentAnnotation;
    BOOL shouldAutoShowUserLocation;
}
@property (nonatomic, strong) MKLocalSearch *localSearch;
@end

@implementation CCLocationStickerViewController

int mapTapCount = 0; // Count times tap on the MapView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mapView setDelegate:self];
    [self.mapView setShowsUserLocation:YES];
    shouldAutoShowUserLocation = YES;
    
    self.navigationItem.title = CCLocalizedString(@"Location");
    
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(closeModal)];
    self.navigationItem.leftBarButtonItem = closeBtn;

    
    UIBarButtonItem *sendBtn = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Preview") style:UIBarButtonItemStylePlain target:self action:@selector(selectLocationSticker:)];
    self.navigationItem.rightBarButtonItem = sendBtn;

    
    // Map single tap handle
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.mapView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [singleTap requireGestureRecognizerToFail: doubleTap];
    [self.mapView addGestureRecognizer:singleTap];
    
    mapTapCount = 0;
    
    // setup location
    [self locationSetup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSArray *anotations = self.mapView.annotations;
    [self.mapView removeAnnotations:anotations];
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

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (shouldAutoShowUserLocation) {
        shouldAutoShowUserLocation = NO;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1500, 1500);
        MKCoordinateRegion newRegion = [self.mapView regionThatFits:viewRegion];
        [self.mapView setRegion:newRegion animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    // don't hide anotations when move map or zoom map
//    NSArray *anotations = self.mapView.annotations;
//    [self.mapView removeAnnotations:anotations];
//    currentAnnotation = nil;
    
    if (self.isLocalLocationActive) {
        // First time of region change when isLocalLocationActive, is moved automatically to current location
        // Next time of region change, is moved by user interaction
        self.isLocalLocationActive = NO;
    } else {
        [self.localLocation setImage:[UIImage SDKImageNamed:@"CCcurrent-location"] forState:UIControlStateNormal];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    mapTapCount = 0; // reset count
    
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
                      [self.mapView addAnnotation:annotation];
                      [self.mapView selectAnnotation:annotation animated:NO];
                      currentAnnotation = annotation;
                  }
                  else {
                      NSLog(@"Could not locate");
                  }
              }];
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;
    
    mapTapCount += 1;
    
    if (mapTapCount % 2 == 0) {
        // Remove all anotations and add new one
        NSArray *anotations = self.mapView.annotations;
        [self.mapView removeAnnotations:anotations];
        
        [self.mapView addAnnotation:currentAnnotation];
        [self.mapView selectAnnotation:currentAnnotation animated:NO];
    }
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
//    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectLocationSticker:)];
//    [view addGestureRecognizer:tapGes];
}

- (void)selectLocationSticker:(id)sender {
    
    NSString *mapThumbURLStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%lf,%lf&size=450x230&zoom=15&sensor=true&markers=%lf,%lf&key=%@",currentAnnotation.coordinate.latitude,currentAnnotation.coordinate.longitude,currentAnnotation.coordinate.latitude,currentAnnotation.coordinate.longitude, CC_GOOGLEMAPS_API_KEY];
    
    NSString *text = currentAnnotation.subtitle;
    if (!text) {
        text = @"";
    }
    
    NSDictionary *locationContent = @{@"uid":[self.delegate generateMessageUniqueId],
                                      @"message":@{@"text":text},
                                      CC_RESPONSETYPESTICKERCONTENT:
                                          @{@"sticker-data" :
                                                @{@"location" :
                                                      @{@"lat":[NSString stringWithFormat:@"%f", currentAnnotation.coordinate.latitude],
                                                        @"lng":[NSString stringWithFormat:@"%f", currentAnnotation.coordinate.longitude]}
                                                  },
                                            @"thumbnail-url" : mapThumbURLStr
                                            }
                                      };
    CCJSQMessage *msg = [[CCJSQMessage alloc] initWithSenderId:@"" senderDisplayName:@"" date:[NSDate date] text:@""];
    msg.type = CC_RESPONSETYPESTICKER;
    msg.content = locationContent;
    
    
    CCCommonWidgetPreviewViewController *vc = [[CCCommonWidgetPreviewViewController alloc] initWithNibName:@"CCCommonWidgetPreviewViewController" bundle:SDK_BUNDLE];
    [vc setDelegate:self.delegate];
    [vc setMessage:msg];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    /*
    
    if ([self.delegate respondsToSelector:@selector(didSelectLocationWithLatitude:longitude:address:)]){
        [self.delegate didSelectLocationWithLatitude:currentAnnotation.coordinate.latitude longitude:currentAnnotation.coordinate.longitude address:currentAnnotation.subtitle];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
     */
}


#pragma mark - UISearchBar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self startSearch:searchBar.text];
}

- (void)startSearch:(NSString *)searchString {
    if (self.localSearch.searching)
    {
        [self.localSearch cancel];
    }
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    
    request.naturalLanguageQuery = searchString;
    request.region = self.mapView.region;
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error) {
        if (error != nil) {
            NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CCLocalizedString(@"Could not find places")
                                                            message:errorStr
                                                           delegate:nil
                                                  cancelButtonTitle:CCLocalizedString(@"OK")
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance([[response mapItems] firstObject].placemark.coordinate, 1000, 1000);
            MKCoordinateRegion newRegion = [self.mapView regionThatFits:viewRegion];
            [self.mapView setRegion:newRegion animated:YES];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    if (self.localSearch != nil) {
        self.localSearch = nil;
    }
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [self.localSearch startWithCompletionHandler:completionHandler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (IBAction)showLocalLocation:(id)sender {
    if (![self checkLocationEnabled]) {
        return;
    }
    
    self.isLocalLocationActive = YES;
    [self.localLocation setImage:[UIImage SDKImageNamed:@"CCcurrent-location-active"] forState:UIControlStateNormal];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
    MKCoordinateRegion newRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:newRegion animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    shouldAutoShowUserLocation = NO;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Location Sticker

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


@end
