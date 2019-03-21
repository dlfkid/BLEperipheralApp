//
//  PeripheralViewController.h
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/3/21.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

@class CBPeripheral;

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PeripheralViewController : BaseViewController

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;

@end

NS_ASSUME_NONNULL_END
