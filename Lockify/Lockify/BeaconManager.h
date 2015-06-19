//
//  BeaconManager.h
//  Lockify
//
//  Created by Jan Posz on 14.06.2015.
//  Copyright (c) 2015 lockify. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import <UIKit/UIKit.h>

@interface BeaconManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

- (void)loadManager;

@end
