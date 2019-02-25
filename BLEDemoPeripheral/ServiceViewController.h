//
//  ServiceViewController.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/6.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

@class DPService, DPCharacteristic;

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ServiceViewController : BaseViewController

@property (nonatomic, copy) void(^serviceDidSavedHandler)(DPService *service);
@property (nonatomic, copy) void(^serviceDidRemovedHandler)(DPService *service);

- (instancetype)initWithService:(nullable DPService *)service;

@end

NS_ASSUME_NONNULL_END
