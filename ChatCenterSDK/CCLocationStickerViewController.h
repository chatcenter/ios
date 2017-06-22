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

@interface CCLocationStickerViewController : UIViewController <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) id<CCCommonWidgetEditorDelegate> delegate;
@property (nullable, nonatomic, copy) void (^closeLocationStickerCallback)(void);
@property BOOL isLocalLocationActive;
@end
