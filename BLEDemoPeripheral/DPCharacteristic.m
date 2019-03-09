//
//  DPCharacteristic.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/25.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "DPCharacteristic.h"

#import <FMDB/FMDB.h>
#import "ViewModel.h"
#import "DataBaseManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface DPCharacteristic()

@end

@implementation DPCharacteristic

- (instancetype)initWithUUID:(NSString *)uuid {
    self= [super init];
    if (self) {
        _uuid = uuid;
        _viewModel = [[ViewModel alloc] init];
    }
    return self;
}

+ (DPCharacteristic *)loadCharacteristicWithUUID:(NSString *)uuidString {
    NSString *characterQuery = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uuid = '%@'", kTableCharacteristics, uuidString];
    FMResultSet *result = [[DataBaseManager sharedDataBaseManager].dataBase executeQuery:characterQuery];
    NSMutableArray *characterArray = [NSMutableArray array];
    while ([result next]) {
        NSString *uuid = [result stringForColumn:@"uuid"];
        NSString *value = [result stringForColumn:@"value"];
        NSUInteger properties = [result intForColumn:@"properties"];
        NSUInteger permission = [result intForColumn:@"permission"];
        NSString *descriptionText = [result stringForColumn:@"characteristic_descroption"];
        
        DPCharacteristic *characteristic = [[DPCharacteristic alloc] initWithUUID:uuid];
        
        characteristic.value = value;
        
        characteristic.properties = properties;
        
        characteristic.permission = permission;
        
        characteristic.descriptionText = descriptionText;
        
        [characterArray addObject:characteristic];
    }
    return characterArray.firstObject;
}

- (void)addCharacteristicToDB {
    NSString *sqlStatement = [NSString stringWithFormat:@"INSERT INTO %@ (uuid, value, properties, permission, characteristic_descroption) VALUES ('%@', '%@', %zd, %zd, '%@')", kTableCharacteristics, self.uuid, self.value, self.properties, self.permission, self.descriptionText];
    [[DataBaseManager sharedDataBaseManager].dataBase executeUpdate:sqlStatement];
}

- (void)RemoveCharacteristicFromDB {
    NSString *uuid = self.uuid;
    NSString *sqlStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE uuid = '%@'", kTableCharacteristics, uuid];
    [[DataBaseManager sharedDataBaseManager].dataBase executeUpdate:sqlStatement];
}

- (CBMutableCharacteristic *)convertToCBCharacteristic {
    CBUUID *cbuuid = [CBUUID UUIDWithString:self.uuid];
    NSData *cbValue = [self.value dataUsingEncoding:NSUTF8StringEncoding];
    if (!self.isReadOnly) {
        cbValue = nil;
    }
    CBMutableCharacteristic *chacteristic = [[CBMutableCharacteristic alloc] initWithType:cbuuid properties:self.properties value:cbValue permissions:self.permission];
    return chacteristic;
}

- (BOOL)isReadOnly {
    NSUInteger writableProperties = CBCharacteristicPropertyBroadcast | CBCharacteristicPropertyWrite | CBCharacteristicPropertyWriteWithoutResponse | CBCharacteristicPropertyAuthenticatedSignedWrites | CBCharacteristicPropertyIndicate | CBCharacteristicPropertyNotify | CBCharacteristicPropertyExtendedProperties | CBCharacteristicPropertyIndicateEncryptionRequired | CBCharacteristicPropertyNotifyEncryptionRequired;
    NSUInteger writablePermissions = CBAttributePermissionsWriteable | CBAttributePermissionsWriteEncryptionRequired;
    
    return !(self.permission & writablePermissions || self.properties & writableProperties);
}

@end
