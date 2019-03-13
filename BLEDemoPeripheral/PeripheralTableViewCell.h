//
//  PeripheralTableViewCell.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/3/12.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

@class CBPeripheral;

#import "BaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PeripheralTableViewCell : BaseTableViewCell

@property (nonatomic, strong) CBPeripheral *peripheral;

@end

NS_ASSUME_NONNULL_END
