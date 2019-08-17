//
//  LFDataInfo.h
//  LFDataMigraterDemo
//
//  Created by LeonDeng on 2019/8/5.
//  Copyright © 2019 LeonDeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFDataInfo : NSObject

@property (nonatomic, copy) NSString *dataBaseName;
@property (nonatomic, copy) NSNumber *version;
@property (nonatomic, strong) NSDate *lastUpdate;
@property (nonatomic, copy) NSString *lastUpdateString;
@property (nonatomic, copy) NSString *dataBaseFilePath;

+ (instancetype)lf_loadDataInfoFromArchiveWithDataBaseName:(NSString *)dataBaseName Error:(NSError **)error;

- (void)lf_savedToArchiveWithError:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
