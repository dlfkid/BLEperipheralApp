//
//  NSError+LFDataMigrater.h
//  LFDataMigraterDemo
//
//  Created by LeonDeng on 2019/8/6.
//  Copyright © 2019 LeonDeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LFDataMigraterErrorCode) {
    LFDataMigraterErrorCodeVersionInvalid = 600,
    LFDataMigraterErrorCodeMethodNotImplement,
};

@interface NSError (LFDataMigrater)

+ (instancetype)migraterErrorWithCode:(LFDataMigraterErrorCode)code Description:(NSString *)description;

@end

NS_ASSUME_NONNULL_END
