//
//  DataBaseManager.h
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/2/21.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kTableDBVersion;
extern NSString * const kTableServices;
extern NSString * const kTableCharacteristics;

@interface DataBaseManager : NSObject

+ (instancetype)sharedDataBaseManager;

@end

NS_ASSUME_NONNULL_END
