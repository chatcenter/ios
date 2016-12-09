//
//  CCLocationPreviewViewController.m
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 3/17/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "CCLocationPreviewViewController.h"
#import "ChatCenterPrivate.h"
#import "UIImage+CCSDKImage.h"

@interface CCLocationPreviewViewController ()<UIActionSheetDelegate>

@end

@implementation CCLocationPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = CCLocalizedString(@"Location");
    
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:CCLocalizedString(@"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(closeModal)];
    self.navigationItem.leftBarButtonItem = closeBtn;
    
    UIBarButtonItem *optionBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage SDKImageNamed:@"CCmenu_thin-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showActionSheet)];
    self.navigationItem.rightBarButtonItem = optionBtn;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showLocation];
}

- (void)showActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:CCLocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:@"Google", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if ([[UIApplication sharedApplication] canOpenURL:
                 [NSURL URLWithString:@"comgooglemaps://"]]) {
                NSString *urlString = [NSString stringWithFormat:@"comgooglemaps://?center=%f,%f&zoom=16&views=traffic",self.coordinate.latitude, self.coordinate.longitude];
                [[UIApplication sharedApplication] openURL:
                 [NSURL URLWithString:urlString]];
            } else {
                NSLog(@"Can't use comgooglemaps://");
                UIAlertView *alertView;
                alertView = [[UIAlertView alloc] initWithTitle:CCLocalizedString(@"Cannot open Google Maps")
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:CCLocalizedString(@"OK")
                                             otherButtonTitles:nil, nil];
                [alertView show];
            }
            break;
        case 1:
            break;
        default:
            break;
    }
}

- (void)showLocation {
    CLGeocoder *geo = [[CLGeocoder alloc] init];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    
    [geo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  if (!error){
                      CLPlacemark *placemark = [placemarks objectAtIndex:0];
                      NSString *address = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                      
                      MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                      annotation.coordinate = self.coordinate;
                      annotation.title = CCLocalizedString(@"Address");
                      annotation.subtitle = address;
                      [self.mapView addAnnotation:annotation];
                      [self.mapView selectAnnotation:annotation animated:NO];
                  }
                  else {
                      NSLog(@"Could not locate");
                  }
              }];

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.coordinate, 1000, 1000);
    MKCoordinateRegion newRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:newRegion animated:YES];
}

- (void)closeModal {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)showTargetLocation:(id)sender {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.coordinate, 1000, 1000);
    MKCoordinateRegion newRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:newRegion animated:YES];
}
- (IBAction)showLocalLocation:(id)sender {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
    MKCoordinateRegion newRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:newRegion animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
