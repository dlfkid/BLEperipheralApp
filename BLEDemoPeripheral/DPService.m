//
//  DPService.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/25.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "DPService.h"

#import <FMDB/FMDB.h>
#import "DataBaseManager.h"
#import "DPCharacteristic.h"

@interface DPService()

@end

@implementation DPService

- (instancetype)initWithUUID:(NSString *)uuid Primary:(BOOL)primary {
    self= [super init];
    if (self) {
        _uuid = uuid;
        _primary = primary;
    }
    return self;
}

+ (NSArray<DPService *> *)loadService {
    NSString *queryFormat = [NSString stringWithFormat:@"SELECT (uuid) FROM %@", kTableServices];
    FMResultSet *result = [[DataBaseManager sharedDataBaseManager].dataBase executeQuery:queryFormat];
    NSMutableArray *servicesArray = [NSMutableArray array];
    while ([result next]) {
        NSString *serviceUUID = [result stringForColumn:@"uuid"];
        DPService *service = [self loadServiceWithUUIDString:serviceUUID];
        [servicesArray addObject:service];
    }
    return servicesArray;
}

+ (DPService *)loadServiceWithUUIDString:(NSString *)uuidString {
    NSString *queryFormat = [NSString stringWithFormat:@"SELECT (uuid, is_primary, characteristics_uuid, included_services_uuid) FROM %@ WHERE uuid = '%@'", kTableServices, uuidString];
    FMResultSet *result = [[DataBaseManager sharedDataBaseManager].dataBase executeQuery:queryFormat];
    NSMutableArray *services = [NSMutableArray array];
    while ([result next]) {
        NSString *characteristics = [result stringForColumn:@"characteristics_uuid"];
        NSString *includedServices = [result stringForColumn:@"included_services_uuid"];
        NSInteger isPrimary = [result intForColumn:@"is_primary"];
        
        NSArray *includedServicesStringArray = [includedServices componentsSeparatedByString:@","];
        
        NSMutableArray *includedServicesArray = [NSMutableArray array];
        
        for (NSString *uuid in includedServicesStringArray) {
            DPService *includedService = [self loadServiceWithUUIDString:uuid];
            [includedServicesArray addObject:includedService];
        }
        
        DPService *service = [[DPService alloc] initWithUUID:uuidString Primary:isPrimary];
        
        
        service.includedService = includedServicesArray;
        
        NSArray *characteristicsStringArray = [characteristics componentsSeparatedByString:@","];
        
        NSMutableArray *characteristicsArray = [NSMutableArray array];
        
        for (NSString *uuid in characteristicsStringArray) {
            DPCharacteristic *characteristic = [DPCharacteristic loadCharacteristicWithUUID:uuid];
            [characteristicsArray addObject:characteristic];
        }
        
        service.characters = characteristicsArray;
        
        [services addObject:service];
    }
    
    return services.firstObject;
}

- (void)removeServiceFromDB {
    NSString *removeUUID = self.uuid;
    [[DataBaseManager sharedDataBaseManager].dataBase executeQuery:@"DELETE FROM %@ WHERE uuid = ?", kTableServices, removeUUID];
}

- (void)addServiceToDB {
    NSString *addUUID = self.uuid;
    NSInteger isPrimary = self.isPrimary;
    NSMutableArray *includedUUID = [NSMutableArray array];
    for (DPService *service in self.includedService) {
        NSString *uuid = service.uuid;
        [includedUUID addObject:uuid];
    }
    NSString *includedString = [includedUUID componentsJoinedByString:@","];
    
    NSMutableArray *characters = [NSMutableArray array];
    for (DPCharacteristic *characteristic in self.characters) {
        NSString *uuid = characteristic.uuid;
        [characters addObject:uuid];
    }
    NSString *characterString = [characters componentsJoinedByString:@","];
    
    [[DataBaseManager sharedDataBaseManager].dataBase executeQueryWithFormat:@"INSERT INTO %@ (uuid, is_primary, inluded_services_uuid, characteristics_uuid) VALUES ('%@', %zd, '%@', '%@')", kTableServices, addUUID, isPrimary, includedString, characterString];
}

@end
