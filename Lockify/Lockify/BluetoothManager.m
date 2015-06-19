//
//  BluetoothManager.m
//  BeanProject
//
//  Created by Jan Posz on 02.10.2014.
//  Copyright (c) 2014 janposz. All rights reserved.
//

#import "BluetoothManager.h"

static NSString *service_UUID = @"A495FF20-C5B1-4B44-B512-1370F02D74DE";
static NSString *charcteristic_UUID = @"A495FF21-C5B1-4B44-B512-1370F02D74DE";
static NSString *charcteristic_UUID2 = @"A495FF22-C5B1-4B44-B512-1370F02D74DE";

@interface BluetoothManager ()

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic, strong) CBCharacteristic *characteristicDebug;

@property (nonatomic, copy) void(^completionHandler)(NSError *eror);

@property (nonatomic, copy) void(^unlockHandler)(BOOL success);

@end

@implementation BluetoothManager

- (void)connectLockWithCompletionHandler:(void (^)(NSError *))completionHandler {
    
    self.completionHandler = completionHandler;
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"turn on bluetooth");
            break;
        case CBCentralManagerStatePoweredOn:
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"device dont have bluetooth 4.0");
            break;
        case CBCentralManagerStateUnknown:
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"name: %@", peripheral.name);
    if (self.peripheral == nil) {
        [self.centralManager connectPeripheral:peripheral options:nil];
        self.peripheral = peripheral;
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    peripheral.delegate = self;
    [self.centralManager stopScan];
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self cleanup];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"disconnect");
    [self cleanup];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    int count = 0;
    NSLog(@"Services");
    for (CBService *s in peripheral.services) {
        NSLog(@"%@", [s.UUID UUIDString]);
        if ([[[s.UUID UUIDString] uppercaseString] isEqualToString:service_UUID]) {
            [peripheral discoverCharacteristics:nil forService:s];
            count ++;
        }
    }
    if (count == 0) {
        [self cleanup];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    int count = 0;
    NSLog(@"Characteristics");
    for (CBCharacteristic *ch in service.characteristics) {
        if ([[[ch.UUID UUIDString] uppercaseString] isEqualToString:charcteristic_UUID]) {
            self.characteristic = ch;
            [self.peripheral setNotifyValue:YES forCharacteristic:ch];
            count ++;
        }
        if ([[[ch.UUID UUIDString] uppercaseString] isEqualToString:charcteristic_UUID2]) {
            self.characteristicDebug = ch;
            [self.peripheral setNotifyValue:YES forCharacteristic:ch];
            count ++;
        }
    }
    if (count == 2) {
        if (self.completionHandler) {
            NSLog(@"connection completed");
            self.completionHandler(nil);
        }
        [self.centralManager stopScan];
    }
    else {
        [self cleanup];
    }
}

- (void)cleanup {
    
    NSLog(@"Cleanup");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotificationCenter *cntr = [NSNotificationCenter defaultCenter];
        NSNotification *note = [NSNotification notificationWithName:kDidConnectNotification object:@NO];
        [cntr postNotification:note];
    });
    // See if we are subscribed to a characteristic on the peripheral
    if (self.peripheral.services != nil) {
        for (CBService *service in self.peripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"aaaa"]]) {
                        if (characteristic.isNotifying) {
                            [self.peripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }
            }
        }
    }
    
    [self.centralManager cancelPeripheralConnection:self.peripheral];
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    self.peripheral = nil;
}

- (NSData *)dataFromHexString:(NSString *)string
{
    NSMutableData *stringData = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [string length] / 2; i++) {
        byte_chars[0] = [string characterAtIndex:i*2];
        byte_chars[1] = [string characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [stringData appendBytes:&whole_byte length:1];
    }
    return stringData;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSData *data = characteristic.value;
    NSLog(@"%@", data);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

    NSLog(@"%@", characteristic.value);
    if (self.unlockHandler) {
        self.unlockHandler(YES);
    }
}

- (void)readSctracthc {
    [self.peripheral readValueForCharacteristic:self.characteristicDebug];
}

- (void)writeAnything {
    
    NSData *data = [self dataFromHexString:@"a"];
    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)unlockWithPassword:(NSString *)password unlockCompletionHandler:(void (^)(BOOL))unlockHandler {
    
    self.unlockHandler = unlockHandler;
    NSData *data = [self dataFromHexString:password];
    [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}

@end
