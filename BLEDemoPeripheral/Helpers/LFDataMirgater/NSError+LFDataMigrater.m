//
//  NSError+LFDataMigrater.m
//  LFDataMigraterDemo
//
//  Created by LeonDeng on 2019/8/6.
//  Copyright © 2019 LeonDeng. All rights reserved.
//

#import "NSError+LFDataMigrater.h"

static NSString * const kMigraterErorrDomain = @"com.LFDataMigrater.kMigraterErorrDomain";

@implementation NSError (LFDataMigrater)

+ (instancetype)migraterErrorWithCode:(LFDataMigraterErrorCode)code Description:(NSString *)description {
    NSError *error = [NSError errorWithDomain:kMigraterErorrDomain code:code userInfo:@{NSLocalizedDescriptionKey: description}];
    return error;
}

@end
