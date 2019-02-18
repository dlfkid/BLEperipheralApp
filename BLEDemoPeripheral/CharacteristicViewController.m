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
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBCharacteristic+StringExtensions.h"

@interface CharacteristicViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

// 此方法用于判断控制器是查看模式还是新建模式，如果是新建模式才允许用户操作内容。
@property (nonatomic, assign, getter = isAddingMode) BOOL addingMode;

@property (nonatomic, strong) CBCharacteristic *sampleCharacteristic;
@property (nonatomic, strong) NSArray <ViewModel *> *baseAttributeArray;
@property (nonatomic, strong) NSArray <ViewModel *> *propertiesArray;
@property (nonatomic, strong) NSArray <ViewModel *> *permissionArray;

// SampleValues
@property (nonatomic, copy) NSString *valueString;
@property (nonatomic, copy) NSString *UUIDString;
@property (nonatomic, assign) CBCharacteristicProperties currentProperties;
@property (nonatomic, assign) CBAttributePermissions currentPermissions;


@end

@implementation CharacteristicViewController

- (NSArray<ViewModel *> *)baseAttributeArray {
    if (!_baseAttributeArray) {
        ViewModel *UUIDModel = [[ViewModel alloc] init];
        UUIDModel.title = @"UUID";
        UUIDModel.subTitle = self.sampleCharacteristic.UUID.UUIDString;
        
        ViewModel *valueModel = [[ViewModel alloc] init];
        valueModel.title = NSLocalizedString(@"CharacteristicTableViewCell.value", "");
        valueModel.subTitle = [[NSString alloc] initWithData:self.sampleCharacteristic.value encoding:NSUTF8StringEncoding];
        
        return @[UUIDModel, valueModel];
    }
    return _baseAttributeArray;
}

// 添加服务需要UUID, 是否主要服务, 子服务和特征四个参数。
// UUID以弹出输入控制器的形式提供输入
// 是否主要服务用switch实现
// 特征和自服务需要各开一个section
// 添加子服务实现为模态再展示一个同样的控制器
// 添加新特征以子窗口的形式呈现
// 所有特征的属性
/*
 CBCharacteristicPropertyBroadcast                                                = 0x01,
 CBCharacteristicPropertyRead                                                    = 0x02,
 CBCharacteristicPropertyWriteWithoutResponse                                    = 0x04,
 CBCharacteristicPropertyWrite                                                    = 0x08,
 CBCharacteristicPropertyNotify                                                    = 0x10,
 CBCharacteristicPropertyIndicate                                                = 0x20,
 CBCharacteristicPropertyAuthenticatedSignedWrites                                = 0x40,
 CBCharacteristicPropertyExtendedProperties                                        = 0x80,
 CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(10_9, 6_0)    = 0x100,
 CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(10_9, 6_0)    = 0x200
 */

- (NSArray<ViewModel *> *)propertiesArray {
    if (!_propertiesArray) {
        ViewModel * (^generatePropertyViewModels)(NSString * modelTitle, NSUInteger propertyValue) = ^(NSString *modelTitle, NSUInteger propertyValue){
            ViewModel *model = [[ViewModel alloc] init];
            model.title = modelTitle;
            model.rawOptionValue = propertyValue;
            return model;
        };
        
        return @[
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.boardcast", ""), 1),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.read", ""), 2),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.writeWithoutResponse", ""), 4),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.write", ""), 8),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.notify", ""), 10),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.indicate", ""), 20),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.authendicatedSignedWrite", ""), 40),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.extendedProperties", ""), 80),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.notifyEncryptionRequired", ""), 100),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.indicateEncryptionRequired", ""), 200),
        ];
    }
    return _propertiesArray;
}


//    CBAttributePermissionsReadable                    = 0x01,
//    CBAttributePermissionsWriteable                    = 0x02,
//    CBAttributePermissionsReadEncryptionRequired    = 0x04,
//    CBAttributePermissionsWriteEncryptionRequired    = 0x08

- (NSArray<ViewModel *> *)permissionArray {
    if (!_permissionArray) {
        ViewModel * (^generatePermissionViewModels)(NSString *modelTitle, NSUInteger permissionValue) = ^(NSString *modelTitle, NSUInteger permissionValue){
            ViewModel *model = [[ViewModel alloc] init];
            model.title = modelTitle;
            model.rawOptionValue = permissionValue;
            return model;
        };
        
        return @[
                 generatePermissionViewModels(NSLocalizedString(@"Characteristic.permission.readable", ""), 1),
                 generatePermissionViewModels(NSLocalizedString(@"Characteristic.permission.writeable", ""), 2),
                 generatePermissionViewModels(NSLocalizedString(@"Characteristic.permission.readEncryptionRequired", ""), 4),
                 generatePermissionViewModels(NSLocalizedString(@"Characteristic.permission.writeEncryptionRequired", ""), 8),
                 ];
    }
    return _permissionArray;
}

#pragma mark - LifeCycle

- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic {
    self = [super init];
    if (self) {
        _sampleCharacteristic = characteristic;
        // 判断是新增服务还是查看服务详情。
        self.addingMode = !self.sampleCharacteristic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtnDidTappedAction)];
    
    UIBarButtonItem *editBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(saveButtonDidTappedAction)];
    UIBarButtonItem *deleteBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButtonDidTappedAction)];
    
    self.navigationItem.rightBarButtonItems = self.isAddingMode ? @[editBarItem] : @[deleteBarItem];
    self.navigationItem.title = self.sampleCharacteristic.UUID.UUIDString ? self.sampleCharacteristic.UUID.UUIDString : NSLocalizedString(@"CharacteristicController.title.default", "");
    [self setupContents];
}

- (void)setupContents {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kdefaultTableViewHeaderReuseIdentifier];
    [_tableView registerClass:[UITableViewCell class] forHeaderFooterViewReuseIdentifier:kdefaultTableViewCellReuseIdentifier];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0).mas_offset(44);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0).mas_offset(- [DeviceScreenAdaptor bottomIndicatorMargin]);
    }];
}

#pragma mark - Actions

- (void)cancelButtnDidTappedAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButtonDidTappedAction {
    self.sampleCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:[CBCharacteristic uuidValid:self.UUIDString]] properties:self.currentProperties value:[self.valueString dataUsingEncoding:NSUTF8StringEncoding] permissions:self.currentPermissions];
    !self.characteristicDidSavedHandler ?: self.characteristicDidSavedHandler(self.sampleCharacteristic);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteButtonDidTappedAction {
    PSTAlertController *controller = [PSTAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", "") message:NSLocalizedString(@"ServiceViewController.deleteButton.alert.text", "") preferredStyle:PSTAlertControllerStyleAlert];
    PSTAlertAction *deleteAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Delete", "") style:PSTAlertActionStyleDestructive handler:^(PSTAlertAction * _Nonnull action) {
        !self.characteristicDidDeletedHandler ?: self.characteristicDidDeletedHandler(self.sampleCharacteristic);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    PSTAlertAction *cancelAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Cancel", "") style:PSTAlertActionStyleCancel handler:^(PSTAlertAction * _Nonnull action) {
        
    }];
    
    [controller addAction:cancelAction];
    [controller addAction:deleteAction];
    
    [controller showWithSender:nil controller:nil animated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
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
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kdefaultTableViewCellReuseIdentifier];
            }
            ViewModel *model = self.baseAttributeArray[indexPath.row];
            cell.textLabel.text = model.title;
            cell.detailTextLabel.text = model.subTitle;
            return cell;
        }
            break;
        
        case 1: {
            // 多选属性
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kdefaultTableViewCellReuseIdentifier];
            ViewModel *model = self.propertiesArray[indexPath.row];
            cell.textLabel.text = model.title;
            if (self.currentProperties & model.rawOptionValue) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            return cell;
        }
            break;
            
        case 2: {
            // 多选权限
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kdefaultTableViewCellReuseIdentifier];
            ViewModel *model = self.permissionArray[indexPath.row];
            cell.textLabel.text = model.title;
            if (self.currentPermissions & model.rawOptionValue) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            return cell;
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
            ViewModel *model = self.baseAttributeArray[indexPath.row];
            if ([model.title isEqualToString:NSLocalizedString(@"ServiceViewController.table.cell.UUID", "")]) {
                // 修改UUID
                PSTAlertController *controller = [PSTAlertController alertControllerWithTitle:NSLocalizedString(@"CoreBlueTableViewCell.UUID.alert.text", "") message:@"" preferredStyle:PSTAlertControllerStyleAlert];
                PSTAlertAction *cancelAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Cancel", "") handler:^(PSTAlertAction * _Nonnull action) {
                    
                }];
                PSTAlertAction *comfirmAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Submit", "") style:PSTAlertActionStyleDefault handler:^(PSTAlertAction * _Nonnull action) {
                    UITextField *textField = controller.textField;
                    if (textField.text.length > 0) {
                        NSString *uuid = [CBCharacteristic uuidValid:textField.text];
                        model.subTitle = uuid;
                        self.UUIDString = uuid;
                        [tableView reloadData];
                    }
                }];
                
                [controller addAction:cancelAction];
                [controller addAction:comfirmAction];
                
                [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                }];
                
                [controller showWithSender:nil controller:nil animated:YES completion:^{
                    
                }];
            }
            
            else {
                // 修改当前值
                PSTAlertController *controller = [PSTAlertController alertControllerWithTitle:NSLocalizedString(@"CharacteristicTableViewCell.value", "") message:@"" preferredStyle:PSTAlertControllerStyleAlert];
                PSTAlertAction *cancelAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Cancel", "") handler:^(PSTAlertAction * _Nonnull action) {
                    
                }];
                PSTAlertAction *comfirmAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Submit", "") style:PSTAlertActionStyleDefault handler:^(PSTAlertAction * _Nonnull action) {
                    UITextField *textField = controller.textField;
                    if (textField.text.length > 0) {
                        NSString *value = [CBCharacteristic uuidValid:textField.text];
                        model.subTitle = value;
                        self.valueString = value;
                        [tableView reloadData];
                    }
                }];
                
                [controller addAction:cancelAction];
                [controller addAction:comfirmAction];
                
                [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                }];
                
                [controller showWithSender:nil controller:nil animated:YES completion:^{
                    
                }];
            }
        }
            break;
            
        case 1: {
            // 多选属性
            ViewModel *model = self.propertiesArray[indexPath.row];
            if (self.currentProperties & model.rawOptionValue) {
                // 已选中，则取消选中
                self.currentProperties -= model.rawOptionValue;
            } else {
                // 未选中，则选中
                self.currentProperties += model.rawOptionValue;
            }
        }
            break;
            
        case 2: {
            // 多选权限
            ViewModel *model = self.permissionArray[indexPath.row];
            if (self.currentPermissions & model.rawOptionValue) {
                // 已选中，则取消选中
                self.currentPermissions -= model.rawOptionValue;
            } else {
                // 未选中，则选中
                self.currentPermissions += model.rawOptionValue;
            }
        }
            break;
        default:
            break;
    }
}

@end
