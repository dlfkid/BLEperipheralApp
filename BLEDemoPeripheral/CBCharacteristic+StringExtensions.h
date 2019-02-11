//
//  CBCharacteristic+StringExtensions.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/11.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBCharacteristic (StringExtensions)

+ (NSString *)propertiesString:(CBCharacteristicProperties)properties;

+ (NSString *)permissionString:(CBAttributePermissions)permissions;

@end

NS_ASSUME_NONNULL_END
