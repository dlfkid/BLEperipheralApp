//
//  CharacteristicViewController.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/11.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "CharacteristicViewController.h"

// View
#import "CharacteristicTabeViewCell.h"

// Models
#import "ViewModel.h"

// Helpers
#import <CoreBluetooth/CBCharacteristic.h>

@interface CharacteristicViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CBCharacteristic *sampleCharacteristic;
@property (nonatomic, assign) CBCharacteristicProperties *currentProperties;
@property (nonatomic, assign) CBAttributePermissions *currentPermissions;
@property (nonatomic, strong) NSArray <ViewModel *> *baseAttributeArray;
@property (nonatomic, strong) NSArray <ViewModel *> *propertiesArray;
@property (nonatomic, strong) NSArray <ViewModel *> *permissionArray;


@end

@implementation CharacteristicViewController

- (NSArray<ViewModel *> *)baseAttributeArray {
    if (!_baseAttributeArray) {
        
    }
    return _baseAttributeArray;
}

- (NSArray<ViewModel *> *)propertiesArray {
    if (!_propertiesArray) {
        
    }
    return _propertiesArray;
}

- (NSArray<ViewModel *> *)permissionArray {
    if (!_permissionArray) {
        
    }
    return _permissionArray;
}

#pragma mark - LifeCycle

- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic {
    self = [super init];
    if (self) {
        _sampleCharacteristic = characteristic;
    }
    return self;
}

- (void)viewDidLoad {
    self.navigationItem.title = NSLocalizedString(@"CharacteristicController.title.default", "");
    [super viewDidLoad];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.baseAttributeArray.count;
            break;
        
        case 1:
            return self.propertiesArray.count;
            break;
            
        case 2:
            return self.permissionArray.count;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kdefaultTableViewCellReuseIdentifier forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0: {
            // 基本信息
        }
            break;
        
        case 1: {
            // 多选属性
        }
            break;
            
        case 2: {
            // 多选特征
        }
            break;
        default:
            break;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kdefaultTableViewHeaderReuseIdentifier];
    if (section == 0) {
        view.textLabel.text = NSLocalizedString(@"CoreBlueTableViewCell.header.info", "");
    } else if (section == 1) {
        view.textLabel.text = NSLocalizedString(@"CoreBlueTableViewCell.header.properties", "");
    } else if (section == 2) {
        view.textLabel.text = NSLocalizedString(@"CoreBlueTableViewCell.header.permissions", "");
    }
    return view;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            // 基本信息
        }
            break;
            
        case 1: {
            // 多选属性
        }
            break;
            
        case 2: {
            // 多选特征
        }
            break;
        default:
            break;
    }
}

@end
