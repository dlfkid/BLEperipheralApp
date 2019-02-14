//
//  CBCharacteristic+ViewModel.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/14.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBCharacteristic (ViewModel)

@property (nonatomic, assign, getter = isUnfold) BOOL unfold;

@end

NS_ASSUME_NONNULL_END
