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
// Cell的标题
@property (nonatomic, copy) NSString *title;
// Cell的副标题
@property (nonatomic, copy) NSString *subTitle;
// 控制Cell是否折叠的数据模型
@property (nonatomic, assign, getter = isUnfold) BOOL unfold;
// 点击事件的Block
@property (nonatomic, copy) dispatch_block_t didSelectedHandler;

@end

NS_ASSUME_NONNULL_END
