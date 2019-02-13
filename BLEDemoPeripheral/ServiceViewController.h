//
//  ServiceViewController.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/6.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

@class CBMutableService;

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ServiceViewController : BaseViewController

@property (nonatomic, copy) void(^serviceDidSavedHandler)(CBMutableService *service);
@property (nonatomic, copy) void(^serviceDidRemovedHandler)(CBMutableService *service);

- (instancetype)initWithService:(nullable CBMutableService *)service;

@end

NS_ASSUME_NONNULL_END
