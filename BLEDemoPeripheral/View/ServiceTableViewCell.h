//
//  ServiceTableViewCell.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/7.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

@class DPService, CBService;

#import "BaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ServiceTableViewCell : BaseTableViewCell

@property (nonatomic, assign, getter = isUnfold) BOOL unfold;
@property (nonatomic, strong) DPService *service;
@property (nonatomic, strong) CBService *cbService;
@property (nonatomic, copy) void(^foldButtonDidTappedHandler)(BOOL isUnfold);

@end

NS_ASSUME_NONNULL_END
