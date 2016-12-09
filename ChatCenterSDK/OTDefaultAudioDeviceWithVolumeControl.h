//
//  OTDefaultAudioDeviceWithVolumeControl.h
//  ChatCenterDemo
//
//  Created by VietHD on 11/15/16.
//  Copyright © 2016 AppSocially Inc. All rights reserved.
//

#import "OTDefaultAudioDevice.h"

@interface OTDefaultAudioDeviceWithVolumeControl : OTDefaultAudioDevice

// value range - 0 (min) and 1 (max)
-(void)setPlayoutVolume:(float)value;
@end
