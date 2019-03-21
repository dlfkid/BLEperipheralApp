//
//  SideMenuViewController.h
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/3/11.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SideMenuViewController : BaseViewController

+ (instancetype)sharedMenuController;

+ (CGFloat)sideMenuWidth;

+ (void)showAboutViewController;

+ (void)showBLEPeripheralViewController;

+ (void)showBLECentralViewController;

@end

NS_ASSUME_NONNULL_END
