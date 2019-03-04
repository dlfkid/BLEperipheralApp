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
#import "DPCharacteristic.h"

// Helpers
#import "CBCharacteristic+StringExtensions.h"

@interface CharacteristicViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

// 此方法用于判断控制器是查看模式还是新建模式，如果是新建模式才允许用户操作内容。
@property (nonatomic, assign, getter = isAddingMode) BOOL addingMode;

@property (nonatomic, strong) DPCharacteristic *sampleCharacteristic;
@property (nonatomic, strong) NSArray <ViewModel *> *baseAttributeArray;
@property (nonatomic, strong) NSArray <ViewModel *> *propertiesArray;
@property (nonatomic, strong) NSArray <ViewModel *> *permissionArray;

// SampleValues
@property (nonatomic, copy) NSString *valueString;
@property (nonatomic, copy) NSString *UUIDString;
@property (nonatomic, assign) CBCharacteristicProperties currentProperties;
@property (nonatomic, assign) CBAttributePermissions currentPermissions;
@property (nonatomic, copy) NSString *descriptionText;


@end

@implementation CharacteristicViewController

- (NSArray<ViewModel *> *)baseAttributeArray {
    if (!_baseAttributeArray) {
        ViewModel *UUIDModel = [[ViewModel alloc] init];
        UUIDModel.title = @"UUID";
        UUIDModel.subTitle = self.sampleCharacteristic.uuid;
        
        ViewModel *valueModel = [[ViewModel alloc] init];
        valueModel.title = NSLocalizedString(@"CharacteristicTableViewCell.value", "");
        valueModel.subTitle = self.sampleCharacteristic.value;
        
        ViewModel *descriptionModel = [[ViewModel alloc] init];
        descriptionModel.title = NSLocalizedString(@"ServiceViewController.tableView.cell.descriptionText", "");
        descriptionModel.subTitle = self.sampleCharacteristic.descriptionText;
        
        _baseAttributeArray = @[UUIDModel, valueModel, descriptionModel];
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
        
        _propertiesArray = @[
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.boardcast", ""), 0x01),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.read", ""), 0x02),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.writeWithoutResponse", ""), 0x04),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.write", ""), 0x08),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.notify", ""), 0x10),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.indicate", ""), 0x20),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.authendicatedSignedWrite", ""), 0x40),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.extendedProperties", ""), 0x80),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.notifyEncryptionRequired", ""), 0x100),
        generatePropertyViewModels(NSLocalizedString(@"Characteristic.propperty.indicateEncryptionRequired", ""), 0x200),
        ];
        
        for (ViewModel *model in _propertiesArray) {
            model.selected = self.sampleCharacteristic.properties & model.rawOptionValue;
        }
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
        
        _permissionArray = @[
                 generatePermissionViewModels(NSLocalizedString(@"Characteristic.permission.readable", ""), 0x01),
                 generatePermissionViewModels(NSLocalizedString(@"Characteristic.permission.writeable", ""), 0x02),
                 generatePermissionViewModels(NSLocalizedString(@"Characteristic.permission.readEncryptionRequired", ""), 0x04),
                 generatePermissionViewModels(NSLocalizedString(@"Characteristic.permission.writeEncryptionRequired", ""), 0x08),
                 ];
    }
    return _permissionArray;
}

#pragma mark - LifeCycle

- (instancetype)initWithCharacteristic:(DPCharacteristic *)characteristic {
    self = [super init];
    if (self) {
        self.sampleCharacteristic = characteristic;
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
    self.navigationItem.title = self.sampleCharacteristic.uuid ? self.sampleCharacteristic.uuid : NSLocalizedString(@"CharacteristicController.title.default", "");
    [self setupContents];
}

- (void)setupContents {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kdefaultTableViewHeaderReuseIdentifier];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kdefaultTableViewCellReuseIdentifier];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0).mas_offset(- [DeviceScreenAdaptor bottomIndicatorMargin]);
    }];
}

#pragma mark - Actions

- (BOOL)isReadOnly {
    return !((self.currentPermissions & CBAttributePermissionsWriteable) || (self.currentPermissions & CBAttributePermissionsWriteEncryptionRequired) ||  (self.currentProperties & CBCharacteristicPropertyWrite) || (self.currentProperties & CBCharacteristicPropertyWriteWithoutResponse) || (self.currentProperties & CBCharacteristicPropertyAuthenticatedSignedWrites));
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)setSampleCharacteristic:(DPCharacteristic *)sampleCharacteristic {
    _sampleCharacteristic = sampleCharacteristic;
    _valueString = sampleCharacteristic.uuid;
    _descriptionText = sampleCharacteristic.descriptionText;
    self.currentProperties = sampleCharacteristic.properties;
    self.currentPermissions = sampleCharacteristic.permission;
}

- (void)setCurrentProperties:(CBCharacteristicProperties)currentProperties {
    _currentProperties = currentProperties;
    NSLog(@"Current Properties was set to %lu", (unsigned long)currentProperties);
}

- (void)setCurrentPermissions:(CBAttributePermissions)currentPermissions {
    _currentPermissions = currentPermissions;
    NSLog(@"Current Perissions was set to %lu", (unsigned long)currentPermissions);
}

- (void)cancelButtnDidTappedAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButtonDidTappedAction {
    if ([self.UUIDString isEqualToString:@""] || self.UUIDString.length < 1) {
        PSTAlertController *controller = [PSTAlertController alertControllerWithTitle:NSLocalizedString(@"ServiceViewController.alert.title", "") message:nil preferredStyle:PSTAlertControllerStyleAlert];
        PSTAlertAction *okAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Ok", "") handler:^(PSTAlertAction * _Nonnull action) {
            
        }];
        
        [controller addAction:okAction];
        
        [controller showWithSender:nil controller:nil animated:YES completion:^{
            
        }];
        
        return;
    }
    
    // 如果不是只读属性的特征，无法写入当前值
    if (self.currentProperties & CBCharacteristicPropertyWrite || self.currentProperties & CBCharacteristicPropertyWriteWithoutResponse || self.currentProperties & CBCharacteristicPropertyAuthenticatedSignedWrites) {
        self.valueString = nil;
    }
    
    // 如果不是只读属性的权限，无法写入当前值
    if ([self isReadOnly]) {
        self.valueString = nil;
    }

    _sampleCharacteristic = [[DPCharacteristic alloc] initWithUUID:self.UUIDString];
    _sampleCharacteristic.properties = self.currentProperties;
    _sampleCharacteristic.permission = self.currentPermissions;
    _sampleCharacteristic.descriptionText = self.descriptionText;
//    _sampleCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:[CBCharacteristic uuidValid:self.UUIDString]] properties:self.currentProperties value:value permissions:self.currentPermissions];
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
    return self.isAddingMode ? 3 : 2;
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
    switch (indexPath.section) {
        
        case 1: {
            // 多选属性
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kdefaultTableViewCellReuseIdentifier];
            ViewModel *model = self.propertiesArray[indexPath.row];
            cell.textLabel.text = model.title;
            cell.accessoryType = model.isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return cell;
        }
            break;
            
        case 2: {
            // 多选权限
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kdefaultTableViewCellReuseIdentifier];
            ViewModel *model = self.permissionArray[indexPath.row];
            cell.textLabel.text = model.title;
            cell.accessoryType = model.isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return cell;
        }
            break;
        default: {
            // 基本信息
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
            }
            ViewModel *model = self.baseAttributeArray[indexPath.row];
            cell.textLabel.text = model.title;
            cell.detailTextLabel.text = model.subTitle;
            return cell;
        }
            break;
    }
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
    if (!self.isAddingMode) {
        return;
    }
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
                        [self reloadData];
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
            else if ([model.title isEqualToString:NSLocalizedString(@"ServiceViewController.tableView.cell.descriptionText", "")]) {
                PSTAlertController *controller = [PSTAlertController alertControllerWithTitle:NSLocalizedString(@"ServiceViewController.tableView.cell.descriptionAlert.title", "") message:@"" preferredStyle:PSTAlertControllerStyleAlert];
                PSTAlertAction *cancelAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Cancel", "") handler:^(PSTAlertAction * _Nonnull action) {
                    
                }];
                PSTAlertAction *comfirmAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Submit", "") style:PSTAlertActionStyleDefault handler:^(PSTAlertAction * _Nonnull action) {
                    UITextField *textField = controller.textField;
                    if (textField.text.length > 0) {
                        model.subTitle = textField.text;
                        self.descriptionText = textField.text;
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
                if ([self isReadOnly]) {
                    return;
                }
                
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
                        [self reloadData];
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
            model.selected = !model.isSelected;
            if (model.isSelected) {
                self.currentProperties = self.currentProperties | model.rawOptionValue;
            } else {
                self.currentProperties = self.currentProperties & (~model.rawOptionValue);
            }
            [self reloadData];
        }
            break;
            
        case 2: {
            // 多选权限
            ViewModel *model = self.permissionArray[indexPath.row];
            model.selected = !model.isSelected;
            if (model.isSelected) {
                self.currentPermissions = self.currentPermissions | model.rawOptionValue;
            } else {
                self.currentPermissions = self.currentPermissions & (~model.rawOptionValue);
            }
            [self reloadData];
        }
            break;
        default:
            break;
    }
}

@end
