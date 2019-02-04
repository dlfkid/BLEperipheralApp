//
//  MainViewController.h
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2017/8/7.
//  Copyright © 2017年 Ivan_deng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BaseViewController.h"

@interface MainViewController : BaseViewController <CBPeripheralManagerDelegate,UITextFieldDelegate>

@property(nonatomic,strong) CBPeripheralManager *peripheralManager;
@property(nonatomic,strong) UILabel *stateLabel;
@property(nonatomic,strong) CBMutableCharacteristic *currentCharacteristic;
@property(nonatomic,strong) UITextField *textContent;

@end
