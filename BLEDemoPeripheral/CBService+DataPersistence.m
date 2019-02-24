//
//  CBService+DataPersistence.m
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/2/24.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "CBService+DataPersistence.h"
#import "DataBaseManager.h"
#import <FMDB/FMDB.h>
#import "CBCharacteristic+DataPersistence.m"

@implementation CBService (DataPersistence)

+ (NSArray<CBService *> *)loadService {
    NSString *queryFormat = [NSString stringWithFormat:@"SELECT (uuid) FROM %@", kTableServices];
    FMResultSet *result = [[DataBaseManager sharedDataBaseManager].dataBase executeQuery:queryFormat];
    NSMutableArray *servicesArray = [NSMutableArray array];
    while ([result next]) {
        NSString *serviceUUID = [result stringForColumn:@"uuid"];
        CBService *service = [self loadServiceWithUUIDString:serviceUUID];
        [servicesArray addObject:service];
    }
    return servicesArray;
}

+ (CBService *)loadServiceWithUUIDString:(NSString *)uuidString {
    NSString *queryFormat = [NSString stringWithFormat:@"SELECT (uuid, is_primary, characteristics_uuid, included_services_uuid) FROM %@ WHERE uuid = '%@'", kTableServices, uuidString];
    FMResultSet *result = [[DataBaseManager sharedDataBaseManager].dataBase executeQuery:queryFormat];
    NSMutableArray *services = [NSMutableArray array];
    while ([result next]) {
        NSString *serviceUUID = [result stringForColumn:@"uuid"];
        NSString *characteristics = [result stringForColumn:@"characteristics_uuid"];
        NSString *includedServices = [result stringForColumn:@"included_services_uuid"];
        NSInteger isPrimary = [result intForColumn:@"is_primary"];
        
        NSArray *includedServicesStringArray = [includedServices componentsSeparatedByString:@","];
        
        NSMutableArray *includedServicesArray = [NSMutableArray array];
        
        for (NSString *uuid in includedServicesStringArray) {
            CBService *includedService = [self loadServiceWithUUIDString:uuid];
            [includedServicesArray addObject:includedService];
        }
        
        CBMutableService *service = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:serviceUUID] primary:isPrimary];
        
        
        [service setCharacteristics:includedServicesArray];
        
        NSArray *characteristicsStringArray = [characteristics componentsSeparatedByString:@","];
        
        NSMutableArray *characteristicsArray = [NSMutableArray array];
        
        for (NSString *uuid in characteristicsStringArray) {
            CBCharacteristic *characteristic = [CBCharacteristic loadCharacteristicWithUUID:uuid];
            [characteristicsArray addObject:characteristic];
        }
        
        [service setCharacteristics:characteristicsArray];
        
        [services addObject:service];
    }
    
    return services.firstObject;
}

- (BOOL)removeService {
    NSString *removeUUID = self.UUID.UUIDString;
    return [[DataBaseManager sharedDataBaseManager].dataBase executeQueryWithFormat:@"DELETE FROM %@ WHERE uuid = '%@'", kTableServices, removeUUID];
}

- (BOOL)addService {
    NSString *addUUID = self.UUID.UUIDString;
    NSInteger isPrimary = self.isPrimary;
    NSMutableArray *includedUUID = [NSMutableArray array];
    for (CBService *service in self.includedServices) {
        NSString *uuid = service.UUID.UUIDString;
        [includedUUID addObject:uuid];
    }
    NSString *includedString = [includedUUID componentsJoinedByString:@","];
    
    NSMutableArray *characters = [NSMutableArray array];
    for (CBService *characteristic in self.characteristics) {
        NSString *uuid = characteristic.UUID.UUIDString;
        [characters addObject:uuid];
    }
    NSString *characterString = [characters componentsJoinedByString:@","];
    
    return [[DataBaseManager sharedDataBaseManager].dataBase executeQueryWithFormat:@"INSERT INTO %@ (uuid, is_primary, inluded_services_uuid, characteristics_uuid) VALUES (%@, %zd, %@, %@)", kTableServices, addUUID, isPrimary, includedString, characterString];
}

@end
