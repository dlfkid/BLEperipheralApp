//
//  ServiceTableViewCell.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/7.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

@class CBService;

#import "BaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ServiceTableViewCell : BaseTableViewCell

@property (nonatomic, assign, getter = isUnFold) BOOL unFold;
@property (nonatomic, strong) CBService *service;

@end

NS_ASSUME_NONNULL_END
