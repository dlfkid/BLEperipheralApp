//
//  CentralServiceTableViewCell.h
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/3/30.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

@class CBService;

#import "BaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface CentralServiceTableViewCell : BaseTableViewCell

@property (nonatomic, strong) CBService *service;

@end

NS_ASSUME_NONNULL_END
