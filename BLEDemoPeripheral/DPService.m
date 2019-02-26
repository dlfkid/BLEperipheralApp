//
//  DPService.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/25.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "DPService.h"

#import <FMDB/FMDB.h>
#import "ViewModel.h"
#import "DataBaseManager.h"
#import "DPCharacteristic.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface DPService()

@end

@implementation DPService

- (instancetype)initWithUUID:(NSString *)uuid Primary:(BOOL)primary {
    self= [super init];
    if (self) {
        _uuid = uuid;
        _primary = primary;
        _viewModel = [[ViewModel alloc] init];
    }
    return self;
}

+ (NSArray<DPService *> *)loadService {
    NSString *queryFormat = [NSString stringWithFormat:@"SELECT (uuid) FROM %@", kTableServices];
    [[DataBaseManager sharedDataBaseManager].dataBase open];
    FMResultSet *result = [[DataBaseManager sharedDataBaseManager].dataBase executeQuery:queryFormat];
    NSMutableArray *servicesArray = [NSMutableArray array];
    while ([result next]) {
        NSString *serviceUUID = [result stringForColumnIndex:0];
        DPService *service = [self loadServiceWithUUIDString:serviceUUID];
        [servicesArray addObject:service];
    }
    [[DataBaseManager sharedDataBaseManager].dataBase close];
    return servicesArray;
}

+ (DPService *)loadServiceWithUUIDString:(NSString *)uuidString {
    [[DataBaseManager sharedDataBaseManager].dataBase open];
    NSString *queryFormat = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uuid = '%@'", kTableServices, uuidString];
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
            if (includedService) {
                [includedServicesArray addObject:includedService];
            }
        }
        
        DPService *service = [[DPService alloc] initWithUUID:uuidString Primary:isPrimary];
        
        
        service.includedService = includedServicesArray;
        
        NSArray *characteristicsStringArray = [characteristics componentsSeparatedByString:@","];
        
        NSMutableArray *characteristicsArray = [NSMutableArray array];
        
        for (NSString *uuid in characteristicsStringArray) {
            DPCharacteristic *characteristic = [DPCharacteristic loadCharacteristicWithUUID:uuid];
            if (characteristic) {
                [characteristicsArray addObject:characteristic];
            }
        }
        
        service.characters = characteristicsArray;
        
        [services addObject:service];
    }
    [[DataBaseManager sharedDataBaseManager].dataBase close];
    return services.firstObject;
}

- (void)removeServiceFromDB {
    [[DataBaseManager sharedDataBaseManager].dataBase open];
    NSString *removeUUID = self.uuid;
    NSString *sqlStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE uuid = '%@'", kTableServices, removeUUID];
    [[DataBaseManager sharedDataBaseManager].dataBase executeUpdate:sqlStatement];
    [[DataBaseManager sharedDataBaseManager].dataBase close];
}

- (void)addServiceToDB {
    [[DataBaseManager sharedDataBaseManager].dataBase open];
    NSString *addUUID = self.uuid;
    NSInteger isPrimary = self.isPrimary;
    NSMutableArray *includedUUID = [NSMutableArray array];
    for (DPService *service in self.includedService) {
        NSString *uuid = service.uuid;
        [includedUUID addObject:uuid];
    }
    NSString *includedString = self.includedService.count > 0 ? [includedUUID componentsJoinedByString:@","] : @"";
    
    NSMutableArray *characters = [NSMutableArray array];
    for (DPCharacteristic *characteristic in self.characters) {
        NSString *uuid = characteristic.uuid;
        [characters addObject:uuid];
    }
    NSString *characterString = self.characters.count > 0 ? [characters componentsJoinedByString:@","] : @"";
    
    NSString *sqlStatement = [NSString stringWithFormat:@"INSERT INTO %@ (uuid, is_primary, included_services_uuid, characteristics_uuid) VALUES ('%@', %zd, '%@', '%@')",kTableServices , addUUID, isPrimary, includedString, characterString];
    
    [[DataBaseManager sharedDataBaseManager].dataBase executeUpdate:sqlStatement];
    [[DataBaseManager sharedDataBaseManager].dataBase close];
}

- (CBMutableService *)convertToCBService {
    CBUUID *cbUUID = [CBUUID UUIDWithString:self.uuid];
    CBMutableService *service = [[CBMutableService alloc] initWithType:cbUUID primary:self.isPrimary];
    NSMutableArray *characteristics = [NSMutableArray array];
    for (DPCharacteristic *character in self.characters) {
        CBCharacteristic *chara = [character convertToCBCharacteristic];
        [characteristics addObject:chara];
    }
    [service setCharacteristics:characteristics];
    
    NSMutableArray *includedServices = [NSMutableArray array];
    for (DPService *service in self.includedService) {
        CBService *cbService = [service convertToCBService];
        [includedServices addObject:cbService];
    }
    [service setIncludedServices:includedServices];
    
    return service;
}

@end
