//
//  CentralCharacteristicTableViewCell.h
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/3/30.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

@class CBCharacteristic;

#import "BaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface CentralCharacteristicTableViewCell : BaseTableViewCell

@property (nonatomic, strong) CBCharacteristic *character;

@end

NS_ASSUME_NONNULL_END
