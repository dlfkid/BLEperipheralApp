//
//  DataBaseManager.m
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/2/21.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "DataBaseManager.h"

// Helpers
#import <FMDB/FMDB.h>
#import "LFDataMigrater.h"

@interface DataBaseManager() <LFDataMigraterDelegate>

@property (nonatomic, copy) NSString *dataBasePath;
@property (nonatomic, strong) LFDataMigrater *dataMigrater;
@property (nonatomic, strong) FMDatabase *dataBase;

@end

static DataBaseManager * sharedInstance = nil;
static dispatch_once_t onceToken;

// 最新数据库版本，每次更新版本需要在这里备注
// 第1版数据库建立时间：2019-02-23
static NSInteger const lastestDBVersion = 1;

static NSString * const kdataBaseName = @"ble_peripheral_db.sqlite";
NSString * const kTableDBVersion = @"db_version";
NSString * const kTableServices = @"service_list";
NSString * const kTableCharacteristics = @"characteristic_list";

@implementation DataBaseManager

#pragma mark - Actions

- (void)dbOpen {
    [self.dataBase open];
}

- (void)dbClose {
    [self.dataBase close];
}

#pragma mark - LFDataMigraterDelegate

/**
 创建数据库
 */

- (void)lf_initDatabaseWithInfo:(LFDataInfo *)dataBaseInfo {
    _dataBase = [FMDatabase databaseWithPath:self.dataBasePath];
    
    // 打开数据库
    if (![self.dataBase open]) {
        NSLog(@"DataBaseManager : Failed to open data base!");
        return;
    }
    // 创建表格
    
    // 1.数据库版本管理表
    NSString *createDBVersionTabel = @"CREATE TABLE IF NOT EXISTS db_version (id INTEGER PRIMARY KEY AUTOINCREMENT, update_time TEXT NOT NULL, version INTEGER DEFAULT 1)";
    if (![self.dataBase executeUpdate:createDBVersionTabel]) {
        NSLog(@"DataBaseManager : %@", NSStringFromSelector(_cmd));
    }
    
    // 2.蓝牙服务表
    NSString *createCBServiceTable = @"CREATE TABLE IF NOT EXISTS service_list (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT NOT NULL, is_primary INTEGER DEFAULT 0, characteristics_uuid TEXT, included_services_uuid TEXT)";
    if (![self.dataBase executeUpdate:createCBServiceTable]) {
        NSLog(@"DataBaseManager : %@", NSStringFromSelector(_cmd));
    }
    
    // 3.蓝牙特征表
    NSString *createCBCharacteristicTable = @"CREATE TABLE IF NOT EXISTS characteristic_list (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT NOT NULL, value TEXT, properties INTEGER DEFAULT 0, permission INTEGER DEFAULT 0)";
    if (![self.dataBase executeUpdate:createCBCharacteristicTable]) {
        NSLog(@"DataBaseManager : %@", NSStringFromSelector(_cmd));
    }
}

- (void)lf_updateDataBaseWithVersion:(NSNumber *)version {
    switch (version.integerValue) {
        case 0: {
            // 当前是第1版数据库，需要升级到第2版
            // 改动内容：1.为服务和特征增加描述内容 2.为服务增加是否是子服务标识
            NSString *addServiceIncluded = [NSString stringWithFormat:@"ALTER TABLE %@ ADD is_included INTEGER DEFAULT 0", kTableServices];
            NSString *addServiceDescription = [NSString stringWithFormat:@"ALTER TABLE %@ ADD service_description TEXT", kTableServices];
            NSString *addCharacterDescription = [NSString stringWithFormat:@"ALTER TABLE %@ ADD characteristic_descroption TEXT", kTableCharacteristics];
            
            [self.dataBase executeUpdate:addServiceIncluded];
            [self.dataBase executeUpdate:addServiceDescription];
            [self.dataBase executeUpdate:addCharacterDescription];
        }
            break;
            
        case 1: {
            // 当前是第2版数据库，需要升级到第3版
        }
            break;
            
        default:
            // 未定义的版本不作处理
            break;
    }
}

#pragma mark - LazyLoads

+ (instancetype)sharedDataBaseManager {
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.dataMigrater.delegate = sharedInstance;
        [sharedInstance.dataMigrater lf_migrateDataBaseToHigherVersion:@1 Completion:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"Data base migrated to : %ld", lastestDBVersion);
            } else {
                NSLog(@"Data base migrate failed with error: %@", error.localizedDescription);
            }
        }];
    });
    return sharedInstance;
}

- (NSString *)dataBasePath {
    if (!_dataBasePath) {
        NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *paths = [documents objectAtIndex:0];
        NSString *dbPath = [paths stringByAppendingPathComponent:kdataBaseName];
        NSLog(@"DataBase generated at path %@", dbPath);
        _dataBasePath = dbPath;
    }
    return _dataBasePath;
}

- (LFDataMigrater *)dataMigrater {
    if (!_dataMigrater) {
        _dataMigrater = [[LFDataMigrater alloc] initWithDataBaseName:kdataBaseName Path:self.dataBasePath toVersion:@1];
    }
    return _dataMigrater;
}

@end
