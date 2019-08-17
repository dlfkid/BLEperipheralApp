//
//  LFDataMigrater.m
//  LFDataMigraterDemo
//
//  Created by LeonDeng on 2019/8/5.
//  Copyright © 2019 LeonDeng. All rights reserved.
//

#import "LFDataMigrater.h"
// Models
#import "LFDataInfo.h"
#import "NSError+LFDataMigrater.h"

@interface LFDataMigrater()

@property (nonatomic, strong) LFDataInfo *dbInfo;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation LFDataMigrater

- (instancetype)initWithDataBaseName:(NSString *)dataBaseName Path:(NSString *)dataBasePath toVersion:(NSNumber *)version {
    if ([super init]) {
        NSError *archiveError = nil;
        LFDataInfo *lfdataInfo = [LFDataInfo lf_loadDataInfoFromArchiveWithDataBaseName:dataBaseName Error:&archiveError];
        if (lfdataInfo) {
            _dbInfo = lfdataInfo;
        } else {
            _dbInfo = [[LFDataInfo alloc] init];
            _dbInfo.version = @0;
            _dbInfo.dataBaseFilePath = dataBasePath;
            _dbInfo.lastUpdate = [[NSDate alloc] init];
            _dbInfo.lastUpdateString = [self.dateFormatter stringFromDate:_dbInfo.lastUpdate];
        }
    }
    return self;
}

- (void)lf_migrateDataBaseToHigherVersion:(NSNumber *)dataBaseVersion Completion:(void (^)(NSError * _Nullable))completion {
    
    if (dataBaseVersion.integerValue == self.dbInfo.version.integerValue) { // 目标版本就是当前版本
        completion(nil);
        return;
    }
    
    if (dataBaseVersion.integerValue < self.dbInfo.version.integerValue) { // 目标版本低于当前版本，无需升级
        completion([NSError migraterErrorWithCode:LFDataMigraterErrorCodeVersionInvalid Description:@"Target version is lower than the current version, run migrate to lower instead"]);
        return;
    }
    
    // 判断数据库是否存在
    BOOL dataBaseExist = [[NSFileManager defaultManager] fileExistsAtPath:self.dbInfo.dataBaseFilePath];
    
    if (!dataBaseExist) { // 数据库不存在，需要重新创建
        // 重新创建数据库
        if([self.delegate respondsToSelector:@selector(lf_initDatabaseWithInfo:)]) {
            [self.delegate lf_initDatabaseWithInfo:self.dbInfo];
            // 创建数据库成功，重置版本号, 执行数据库升级
            self.dbInfo.version = @(0);
            for (int i = self.dbInfo.version.intValue; i <= dataBaseVersion.intValue; i ++) {
                if ([self.delegate respondsToSelector:@selector(lf_updateDataBaseWithVersion:)]) {
                    [self.delegate lf_updateDataBaseWithVersion:@(i)];
                } else {
                    completion([NSError migraterErrorWithCode:LFDataMigraterErrorCodeMethodNotImplement Description:@"Protocol method not implemented"]);
                    return;
                }
            }
            // 升级完毕，更新归档信息
            NSError *archiveError = nil;
            self.dbInfo.version = dataBaseVersion;
            _dbInfo.lastUpdate = [[NSDate alloc] init];
            _dbInfo.lastUpdateString = [self.dateFormatter stringFromDate:_dbInfo.lastUpdate];
            [self.dbInfo lf_savedToArchiveWithError:&archiveError];
            completion(archiveError);
        } else {
            completion([NSError migraterErrorWithCode:LFDataMigraterErrorCodeMethodNotImplement Description:@"Protocol method not implemented"]);
            return;
        }
    } else {
        for (int i = self.dbInfo.version.intValue; i <= dataBaseVersion.intValue; i ++) {
            if ([self.delegate respondsToSelector:@selector(lf_updateDataBaseWithVersion:)]) {
                [self.delegate lf_updateDataBaseWithVersion:@(i)];
            } else {
                completion([NSError migraterErrorWithCode:LFDataMigraterErrorCodeMethodNotImplement Description:@"Protocol method not implemented"]);
                return;
            }
        }
        // 升级完毕，更新归档信息
        NSError *archiveError = nil;
        self.dbInfo.version = dataBaseVersion;
        _dbInfo.lastUpdate = [[NSDate alloc] init];
        _dbInfo.lastUpdateString = [self.dateFormatter stringFromDate:_dbInfo.lastUpdate];
        [self.dbInfo lf_savedToArchiveWithError:&archiveError];
        completion(archiveError);
    }
}

- (void)lf_migrateDataBaseToLowerVersion:(NSNumber *)dataBaseVersion Completion:(void (^)(NSError * _Nullable))completion {
    if (dataBaseVersion.integerValue > self.dbInfo.version.integerValue) { // 目标版本高于当前版本
        completion([NSError migraterErrorWithCode:LFDataMigraterErrorCodeVersionInvalid Description:@"Target version is higher than the current version, run migrate to higher instead"]);
        return;
    }
    if (dataBaseVersion.integerValue == self.dbInfo.version.integerValue) { // 目标版本就是当前版本
        completion(nil);
        return;
    }
    // 判断数据库是否存在
    BOOL dataBaseExist = [[NSFileManager defaultManager] fileExistsAtPath:self.dbInfo.dataBaseFilePath];
    
    // 首先判断数据库是否存在
    if (dataBaseExist) { // 数据库存在需要删除
        NSError *fileManageError = nil;
        [[NSFileManager defaultManager] removeItemAtPath:self.dbInfo.dataBaseFilePath error:&fileManageError];
        if (fileManageError) { // 删除失败，直接返回
            completion(fileManageError);
            return;
        }
    }
    
    // 重新创建数据库
    if([self.delegate respondsToSelector:@selector(lf_initDatabaseWithInfo:)]) {
        [self.delegate lf_initDatabaseWithInfo:self.dbInfo];
        // 创建数据库成功，重置版本号, 执行数据库升级
        self.dbInfo.version = @(0);
        for (int i = self.dbInfo.version.intValue; i <= dataBaseVersion.intValue; i ++) {
            if ([self.delegate respondsToSelector:@selector(lf_updateDataBaseWithVersion:)]) {
                [self.delegate lf_updateDataBaseWithVersion:@(i)];
            } else {
                completion([NSError migraterErrorWithCode:LFDataMigraterErrorCodeMethodNotImplement Description:@"Protocol method not implemented"]);
                return;
            }
        }
        // 升级完毕，更新归档信息
        NSError *archiveError = nil;
        self.dbInfo.version = dataBaseVersion;
        _dbInfo.lastUpdate = [[NSDate alloc] init];
        _dbInfo.lastUpdateString = [self.dateFormatter stringFromDate:_dbInfo.lastUpdate];
        [self.dbInfo lf_savedToArchiveWithError:&archiveError];
        completion(archiveError);
    } else {
        completion([NSError migraterErrorWithCode:LFDataMigraterErrorCodeMethodNotImplement Description:@"Protocol method not implemented"]);
        return;
    }
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    }
    return _dateFormatter;
}




@end
