//
//  BeaconManager.m
//  Lockify
//
//  Created by Jan Posz on 14.06.2015.
//  Copyright (c) 2015 lockify. All rights reserved.
//

#import "BeaconManager.h"

@implementation BeaconManager

- (void)loadManager {
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"A4951234-C5B1-4B44-B512-1370F02D74DE"];
    
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"test"];
    self.beaconRegion.notifyOnEntry = YES;
    self.beaconRegion.notifyOnExit = YES;
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {

    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.alertBody = @"Slide to open.";
    note.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
}

@end
