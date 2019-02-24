//
//  CBCharacteristic+DataPersistence.m
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/2/24.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "CBCharacteristic+DataPersistence.h"
#import "DataBaseManager.h"
#import <FMDB/FMDB.h>

@implementation CBCharacteristic (DataPersistence)

+ (CBCharacteristic *)loadCharacteristicWithUUID:(NSString *)uuidString {
    NSString *characterQuery = [NSString stringWithFormat:@"SELECT (uuid, value, properties, permission) FROM %@ WHERE uuid = '%@'", kTableCharacteristics, uuidString];
    FMResultSet *result = [[DataBaseManager sharedDataBaseManager].dataBase executeQuery:characterQuery];
    NSMutableArray *characterArray = [NSMutableArray array];
    while ([result next]) {
        NSString *uuid = [result stringForColumn:@"uuid"];
        NSString *value = [result stringForColumn:@"value"];
        NSUInteger properties = [result intForColumn:@"properties"];
        NSUInteger permission = [result intForColumn:@"permission"];
        
        CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:uuid] properties:properties value:[value dataUsingEncoding:NSUTF8StringEncoding] permissions:permission];
        
        [characterArray addObject:characteristic];
    }
    return characterArray.firstObject;
}

- (BOOL)addCharacteristicToDB:(NSUInteger)permission {
    NSString *uuid = self.UUID.UUIDString;
    NSString *value = [[NSString alloc] initWithData:self.value encoding:NSUTF8StringEncoding];
    NSUInteger properties = self.properties;
    
    return [[DataBaseManager sharedDataBaseManager].dataBase executeUpdateWithFormat:@"INSERT INTO %@ (uuid, value, properties, permission) VALUES ('%@', '%@', %lud, %lud)", kTableCharacteristics, uuid, value, properties, permission];
}

- (BOOL)RemoveCharacteristicFromDB {
    NSString *uuid = self.UUID.UUIDString;
    return [[DataBaseManager sharedDataBaseManager].dataBase executeUpdateWithFormat:@"DELETE FROM %@ WHERE uuid = '%@'", kTableCharacteristics, uuid];
}

@end
