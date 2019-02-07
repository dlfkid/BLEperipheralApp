//
//  ViewModel.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/7.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewModel : NSObject
// 控制Cell是否折叠的数据模型
@property (nonatomic, assign, getter = isUnfold) BOOL unfold;

@end

NS_ASSUME_NONNULL_END
