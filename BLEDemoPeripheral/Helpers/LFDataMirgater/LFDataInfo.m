//
//  LFDataInfo.m
//  LFDataMigraterDemo
//
//  Created by LeonDeng on 2019/8/5.
//  Copyright © 2019 LeonDeng. All rights reserved.
//

#import "LFDataInfo.h"

@interface LFDataInfo() <NSSecureCoding>

@end

@implementation LFDataInfo

#pragma mark - Public

- (void)lf_savedToArchiveWithError:(NSError *__autoreleasing  _Nullable *)error {
    if (@available(iOS 11.0, *)) {
        NSData *encrpytData = [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:YES error:error];
        [NSKeyedArchiver archiveRootObject:encrpytData toFile:[self archivePath]];
    } else {
        NSData *encrpytData = [NSKeyedArchiver archivedDataWithRootObject:self];
        [NSKeyedArchiver archiveRootObject:encrpytData toFile:[self archivePath]];
    }
}

+ (instancetype)lf_loadDataInfoFromArchiveWithDataBaseName:(NSString *)dataBaseName Error:(NSError *__autoreleasing  _Nullable *)error {
    NSData *encryptData = [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivePathWithDataBaseName:dataBaseName]];
    LFDataInfo *dataBaseInfo = nil;
    if (@available(iOS 11.0, *)) {
        dataBaseInfo = [NSKeyedUnarchiver unarchivedObjectOfClass:[LFDataInfo class] fromData:encryptData error:error];
    } else {
        // Fallback on earlier versions
        dataBaseInfo = [NSKeyedUnarchiver unarchiveObjectWithData:encryptData];
    }
    return dataBaseInfo;
}

#pragma mark - Private

- (NSString *)archivePath {
    return [LFDataInfo archivePathWithDataBaseName:self.dataBaseName];
}

+ (NSString *)archivePathWithDataBaseName:(NSString *)dataBaseName {
    NSString *sandBoxPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [sandBoxPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.data", dataBaseName]];
    return filePath;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.dataBaseName forKey:@"dataBaseName"];
    [coder encodeObject:self.version forKey:@"version"];
    [coder encodeObject:self.lastUpdate forKey:@"lastUpdate"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.dataBaseName = [coder decodeObjectForKey:@"dataBaseName"];
        self.version = [coder decodeObjectForKey:@"version"];
        self.lastUpdate = [coder decodeObjectForKey:@"lastUpdate"];
    }
    return self;
}

@end
