//
//  ServiceViewController.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/6.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

@class CBService;

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ServiceViewController : BaseViewController

- (instancetype)initWithService:(nullable CBService *)service CompletionHandler:(void(^)(CBService *service))completion;

@end

NS_ASSUME_NONNULL_END
