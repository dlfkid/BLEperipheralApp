//
//  UIButton+Reactive.m
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/5/8.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "UIButton+Reactive.h"

@implementation UIButton (Reactive)

- (void)addHandlerWithEvent:(UIControlEvents)event Handler:(EventHandler)handler {
    [self addTarget:nil action:@selector(eventDidHandle:) forControlEvents:event];
}

- (void)eventDidHandle:(UIButton *)sender {
    
}


@end
