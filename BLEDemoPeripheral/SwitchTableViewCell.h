//
//  SwitchTableViewCell.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/13.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "BaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SwitchTableViewCell : BaseTableViewCell

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UISwitch *switchControl;
@property (nonatomic, strong) void(^switchValueDidChangedHandler)(BOOL switchState);

@end

NS_ASSUME_NONNULL_END
