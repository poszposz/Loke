//
//  BluetoothManager.h
//  BeanProject
//
//  Created by Jan Posz on 02.10.2014.
//  Copyright (c) 2014 janposz. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

#define kDidConnectNotification @"succesfullyConnectedBeanNotification"

@interface BluetoothManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;

- (void)connectLockWithCompletionHandler:(void(^)(NSError *error))completionHandler;

- (void)unlockWithPassword:(NSString *)password unlockCompletionHandler:(void(^)(BOOL success))unlockHandler;
- (void)writeAnything;

@end
