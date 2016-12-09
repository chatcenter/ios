//
//  CCLocationPreviewViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 3/17/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CCLocationPreviewViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
