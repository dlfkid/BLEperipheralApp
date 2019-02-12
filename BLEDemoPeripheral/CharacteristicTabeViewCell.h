//
//  Characteristic.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/5.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

@class CBCharacteristic;

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface CharacteristicTabeViewCell : BaseTableViewCell

@property (nonatomic, assign, getter = isUnFold) BOOL unFold;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic, copy) void(^foldButtonDidTappedHandler)(BOOL isUnfold);

@end

NS_ASSUME_NONNULL_END
