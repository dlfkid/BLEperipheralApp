//
//  CBCharacteristic+DataPersistence.h
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/2/24.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBCharacteristic (DataPersistence)

+ (CBCharacteristic *)loadCharacteristicWithUUID:(NSString *)uuidString;

@end

NS_ASSUME_NONNULL_END
