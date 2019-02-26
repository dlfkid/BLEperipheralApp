//
//  DPService.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/25.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

@class ViewModel, DPCharacteristic, CBMutableService;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 蓝牙服务的中转类
 */
@interface DPService : NSObject

@property (nonatomic, strong) ViewModel *viewModel;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, assign, getter = isPrimary) BOOL primary;
@property (nonatomic, strong) NSArray <DPCharacteristic *> *characters;
@property (nonatomic, strong) NSArray <DPService *> *includedService;
@property (nonatomic, copy) NSString *descriptionText;

- (instancetype)initWithUUID:(NSString *)uuid Primary:(BOOL)primary;

- (CBMutableService *)convertToCBService;

+ (NSArray<DPService *> *)loadService;
- (void)addServiceToDB;
- (void)removeServiceFromDB;

@end

NS_ASSUME_NONNULL_END
