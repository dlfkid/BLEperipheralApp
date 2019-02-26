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
    [[DataBaseManager sharedDataBaseManager].dataBase open];
    NSString *characterQuery = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uuid = '%@'", kTableCharacteristics, uuidString];
    FMResultSet *result = [[DataBaseManager sharedDataBaseManager].dataBase executeQuery:characterQuery];
    NSMutableArray *characterArray = [NSMutableArray array];
    while ([result next]) {
        NSString *uuid = [result stringForColumn:@"uuid"];
        NSString *value = [result stringForColumn:@"value"];
        NSUInteger properties = [result intForColumn:@"properties"];
        NSUInteger permission = [result intForColumn:@"permission"];
        
        DPCharacteristic *characteristic = [[DPCharacteristic alloc] initWithUUID:uuid];
        
        characteristic.value = value;
        
        characteristic.properties = properties;
        
        characteristic.permission = permission;
        
        [characterArray addObject:characteristic];
    }
    [[DataBaseManager sharedDataBaseManager].dataBase close];
    return characterArray.firstObject;
}

- (void)addCharacteristicToDB {
    [[DataBaseManager sharedDataBaseManager].dataBase open];
    NSString *sqlStatement = [NSString stringWithFormat:@"INSERT INTO %@ (uuid, value, properties, permission) VALUES ('%@', '%@', %zd, %zd)", kTableCharacteristics, self.uuid, self.value, self.properties, self.permission];
    [[DataBaseManager sharedDataBaseManager].dataBase executeUpdate:sqlStatement];
    [[DataBaseManager sharedDataBaseManager].dataBase close];
}

- (void)RemoveCharacteristicFromDB {
    [[DataBaseManager sharedDataBaseManager].dataBase open];
    NSString *uuid = self.uuid;
    NSString *sqlStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE uuid = '%@'", kTableCharacteristics, uuid];
    [[DataBaseManager sharedDataBaseManager].dataBase executeUpdate:sqlStatement];
    [[DataBaseManager sharedDataBaseManager].dataBase close];
}

- (CBMutableCharacteristic *)convertToCBCharacteristic {
    CBUUID *cbuuid = [CBUUID UUIDWithString:self.uuid];
    NSData *cbValue = [self.value dataUsingEncoding:NSUTF8StringEncoding];
    CBMutableCharacteristic *chacteristic = [[CBMutableCharacteristic alloc] initWithType:cbuuid properties:self.properties value:cbValue permissions:self.permission];
    return chacteristic;
}

@end
