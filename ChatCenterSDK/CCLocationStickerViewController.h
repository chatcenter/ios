//
//  CCLocationStickerViewController.h
//  ChatCenterDemo
//
//  Created by AppSocially Inc. on 3/14/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CCCommonWidgetEditorDelegate.h"

@protocol CClocationStickerViewDelegate <NSObject>
@optional
- (void)didSelectLocationWithLatitude:(double)latitude longitude:(double)longitude address:(NSString*)address;
@end

@interface CCLocationStickerViewController : UIViewController <UISearchBarDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UISearchBar *searchInput;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *localLocation;
@property (nonatomic, weak) id<CCCommonWidgetEditorDelegate> delegate;
@property BOOL isLocalLocationActive;

@end
