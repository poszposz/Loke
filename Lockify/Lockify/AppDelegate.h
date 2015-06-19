//
//  AppDelegate.h
//  Lockify
//
//  Created by Jan Posz on 12.06.2015.
//  Copyright (c) 2015 lockify. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BluetoothManager.h"
#import "BeaconManager.h"

static NSString *passwordKey = @"password";

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BluetoothManager *bluetoothManager;
@property (strong, nonatomic) BeaconManager *beaconManager;

@end

extern AppDelegate *getApp(void);

