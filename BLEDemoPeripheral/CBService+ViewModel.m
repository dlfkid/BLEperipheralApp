//
//  CBService+ViewModel.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/14.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "CBService+ViewModel.h"
#import <objc/message.h>

@interface CBService()

@property (nonatomic, strong) NSNumber *boolNumber;

@end

@implementation CBService (ViewModel)

- (BOOL)isUnfold {
    NSNumber *boolNumber = objc_getAssociatedObject(self, @"boolNumber");
    if (!boolNumber) {
        [self setUnfold:NO];
        return NO;
    }
    return boolNumber.boolValue;
}

- (void)setUnfold:(BOOL)unfold {
    NSNumber *boolNumber = [NSNumber numberWithBool:unfold];
    objc_setAssociatedObject(self, @"boolNumber", boolNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
