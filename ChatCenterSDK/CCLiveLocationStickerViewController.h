//
//  CCLiveLocationStickerViewController.h
//  ChatCenterDemo
//
//  Created by VietHD on 12/21/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCCommonWidgetEditorDelegate.h"
#import "CCChatViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface CCLiveLocationStickerViewController : UIViewController<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *changeTimeTitle;
@property (strong, nonatomic) IBOutlet UILabel *durationTitle;
@property (nonatomic, copy) void (^closeCoLocationStickerCallback)(void);
///
/// To check if other user share live location on existing widget
///
@property (nonatomic) BOOL isOpenedFromWidgetMessage;

@property (nonatomic, weak) id<CCCommonWidgetEditorDelegate> delegate;
@property (nonatomic, weak) id<CCLiveLocationWidgetDelegate> liveLocationWidgetDelegate;
@property BOOL isLocalLocationActive;
@end
