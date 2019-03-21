//
//  DPCharacteristic.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/25.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

@class ViewModel, CBMutableCharacteristic, CBCharacteristic;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 蓝牙特征的中专类
 */
@interface DPCharacteristic : NSObject

@property (nonatomic, strong) ViewModel *viewModel;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, assign) NSUInteger properties;
@property (nonatomic, assign) NSUInteger permission;
@property (nonatomic, copy) NSString *descriptionText;
@property (nonatomic, assign, readonly) BOOL isReadOnly;

- (instancetype)initWithUUID:(NSString *)uuid;

- (instancetype)initWithCBCharacteristic:(CBCharacteristic *)characteristic;

+ (DPCharacteristic *)loadCharacteristicWithUUID:(NSString *)uuidString;

- (CBMutableCharacteristic *)convertToCBCharacteristic;

- (void)addCharacteristicToDB;

- (void)RemoveCharacteristicFromDB;

@end

NS_ASSUME_NONNULL_END
