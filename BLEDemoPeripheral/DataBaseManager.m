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

@interface DataBaseManager()

@property (nonatomic, copy) NSString *dataBasePath;
@property (nonatomic, strong) FMDatabase *dataBase;

@end

static DataBaseManager * sharedInstance = nil;
static dispatch_once_t onceToken;
static NSInteger const lastestDBVersion = 1;

NSString * const kTableDBVersion = @"db_version";
NSString * const kTableServices = @"service_list";
NSString * const kTableCharacteristics = @"characteristic_list";

@implementation DataBaseManager

- (NSString *)dataBasePath {
    if (!_dataBasePath) {
        NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *paths = [documents objectAtIndex:0];
        NSString *dbPath = [paths stringByAppendingPathComponent:@"ble_peripheral_db"];
        NSLog(@"DataBase generated at path %@", dbPath);
        _dataBasePath = dbPath;
    }
    return _dataBasePath;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataBase = [FMDatabase databaseWithPath:self.dataBasePath];
    }
    return self;
}

+ (instancetype)sharedDataBaseManager {
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Actions
// 数据库初始化
- (void)dataBaseInitialization {
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
    NSString *createCBCharacteristicTable = @"CREATE TABLE IF NOT EXISTS characteristic_list (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT NOT NULL, value TEXT, properties INTEGER DEFAULT 0)";
    if (![self.dataBase executeUpdate:createCBCharacteristicTable]) {
        NSLog(@"DataBaseManager : %@", NSStringFromSelector(_cmd));
    }
    
    // 关闭数据库
    [self.dataBase close];
}

- (void)dataBaseUpdate {
    [self.dataBase open];
    NSInteger currentVersion = 1;
    NSString *queryDBVersion = [NSString stringWithFormat:@"SELECTE 'verision' FROM %@ ORDERD BY 'update_time' DESC", kTableDBVersion];
    FMResultSet *queryResult = [self.dataBase executeQuery:queryDBVersion];
    while ([queryResult next]) {
        // 根据查询结果获取当前最新版本
        NSInteger version = [queryResult intForColumn:@"version"];
        if (version > currentVersion) {
            currentVersion = version;
        }
    }
    // 执行升级操作
    
}

- (void)updateToLastestVersion:(NSInteger)currentVersion {
    for (NSInteger version = currentVersion; version < lastestDBVersion; version ++) {
        [self updateToNextDBVersion:version];
    }
    NSLog(@"DataBaseManager : DataBase Update Finished");
    // 更新完毕，将数据库更新信息插入数据库版本信息表
    NSString *updateTime = [NSDate date].description;
    if (![self.dataBase executeUpdateWithFormat:@"INSERT INTO %@ (version, update_time) VALUES (%zd, %@)", kTableDBVersion, lastestDBVersion, updateTime]) {
        NSLog(@"DataBaseManager : database version insert failed");
    }
}

- (void)updateToNextDBVersion:(NSInteger)currentVersion {
    switch (currentVersion) {
        case 1: {
            // 当前是第1版数据库，需要升级到第2版
        }
            break;
            
        case 2: {
            // 当前是第2版数据库，需要升级到第3版
        }
            break;
            
        default:
            // 未定义的版本不作处理
            break;
    }
}

@end