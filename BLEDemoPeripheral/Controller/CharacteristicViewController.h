//
//  CharacteristicViewController.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/11.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

@class DPCharacteristic;

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CharacteristicViewController : BaseViewController

@property (nonatomic, copy) void(^characteristicDidSavedHandler)(DPCharacteristic *characteristic);
@property (nonatomic, copy) void(^characteristicDidDeletedHandler)(DPCharacteristic *characteristic);

- (instancetype)initWithCharacteristic:(nullable DPCharacteristic *)characteristic;

@end

NS_ASSUME_NONNULL_END
