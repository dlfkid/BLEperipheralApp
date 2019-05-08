//
//  UIButton+Reactive.h
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/5/8.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^EventHandler)(UIButton *);

@interface UIButton (Reactive)

- (void)addHandlerWithEvent:(UIControlEvents)event Handler:(EventHandler)handler;

@end

NS_ASSUME_NONNULL_END
