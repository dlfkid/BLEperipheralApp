//
//  ViewModel.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/7.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "ViewModel.h"

@interface ViewModel()<NSCopying>


@end

@implementation ViewModel

- (id)copyWithZone:(NSZone *)zone {
    ViewModel *copiedModel = [[ViewModel alloc] init];
    copiedModel.title = self.title;
    copiedModel.unfold = self.isUnfold;
    return copiedModel;
}

@end
