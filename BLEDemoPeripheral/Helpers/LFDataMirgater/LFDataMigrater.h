//
//  LFDataMigrater.h
//  LFDataMigraterDemo
//
//  Created by LeonDeng on 2019/8/5.
//  Copyright © 2019 LeonDeng. All rights reserved.
//

@class LFDataInfo;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LFDataMigraterDelegate <NSObject>

/// Update your database from one version to another
/// @param version targetVersion
- (void)lf_updateDataBaseWithVersion:(NSNumber *)version;

/// Initialize your database
/// @param dataBaseInfo the database info you passed to Migrater before
- (void)lf_initDatabaseWithInfo:(LFDataInfo *)dataBaseInfo;

@end

@interface LFDataMigrater : NSObject

@property (nonatomic, weak) NSObject <LFDataMigraterDelegate> *delegate;

@property (nonatomic, strong, readonly) LFDataInfo *dbInfo;

/// Initialize migrater
/// @param dataBaseName dataBasename
/// @param dataBasePath dataBasePath
/// @param version dataBaseVersion
- (instancetype)initWithDataBaseName:(NSString *)dataBaseName Path:(NSString *)dataBasePath toVersion:(NSNumber *)version;

/// Migrate your database to heigher version
/// @param dataBaseVersion target version
/// @param completion callback with errror
- (void)lf_migrateDataBaseToHigherVersion:(NSNumber *)dataBaseVersion Completion:(void (^)(NSError * _Nullable error))completion;

/// Migrate your database to lower version THIS METHOD WILL ERASE ENTIRE DATABASE AND RECREATE IT
/// @param dataBaseVersion target version
/// @param completion callback with error
- (void)lf_migrateDataBaseToLowerVersion:(NSNumber *)dataBaseVersion Completion:(void (^)(NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
