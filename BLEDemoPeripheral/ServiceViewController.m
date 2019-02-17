//
//  ServiceViewController.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/6.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "ServiceViewController.h"

// Controllers
#import "CharacteristicViewController.h"

// Views
#import "ServiceTableViewCell.h"
#import "CharacteristicTabeViewCell.h"
#import "SwitchTableViewCell.h"

// Models
#import "ViewModel.h"

// Helpers
#import <CoreBluetooth/CoreBluetooth.h>
#import "CBCharacteristic+StringExtensions.h"
#import "CBCharacteristic+ViewModel.h"
#import "CBService+ViewModel.h"

@interface ServiceViewController ()<CBPeripheralManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CBMutableService *sampleService;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) NSArray <ViewModel *> *viewModels;
// 此方法用于判断控制器是查看模式还是新建模式，如果是新建模式才允许用户操作内容。
@property (nonatomic, assign, getter = isAddingMode) BOOL addingMode;

// SampleValues
@property (nonatomic, copy) NSString *UUIDString;
@property (nonatomic, assign) BOOL primary;
@property (nonatomic, strong) NSArray <CBService *> *includedServices;
@property (nonatomic, strong) NSArray <CBCharacteristic *> *characteristics;

@end

@implementation ServiceViewController

- (void)setSampleService:(CBMutableService *)sampleService {
    _sampleService = sampleService;
    _includedServices = sampleService.includedServices;
    _characteristics = sampleService.characteristics;
}

- (NSArray<CBService *> *)includedServices {
    if (!_includedServices) {
        _includedServices = [NSArray array];
    }
    return _includedServices;
}

- (NSArray<CBCharacteristic *> *)characteristics {
    if (!_characteristics) {
        _characteristics = [NSArray array];
    }
    return _characteristics;
}

- (CBPeripheralManager *)peripheralManager {
    if (!_peripheralManager) {
        // 使用全局并发队列处理回调，涉及UI的部分需要调用主队列。
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return _peripheralManager;
}

#pragma mark - LifeCycle

- (instancetype)initWithService:(CBMutableService *)service {
    self = [super init];
    if (self) {
        _sampleService = service;
        // 判断是新增服务还是查看服务详情。
        self.addingMode = !self.sampleService;
        ViewModel *uuidModel = [[ViewModel alloc] init];
        uuidModel.title = NSLocalizedString(@"ServiceViewController.table.cell.UUID", "");
        uuidModel.subTitle = service.UUID.UUIDString;
        ViewModel *primaryModel = [[ViewModel alloc] init];
        primaryModel.title = NSLocalizedString(@"ServiceViewController.table.cell.primary", "");
        primaryModel.subTitle = service.isPrimary ? NSLocalizedString(@"Yes", "") : NSLocalizedString(@"No", "");
    
        _viewModels = @[uuidModel, primaryModel];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtnDidTappedAction)];

    UIBarButtonItem *editBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(saveButtonDidTappedAction)];
    UIBarButtonItem *deleteBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButtonDidTappedAction)];
    
    self.navigationItem.rightBarButtonItems = self.isAddingMode ? @[editBarItem] : @[deleteBarItem];
    self.navigationItem.title = self.sampleService.UUID.UUIDString ? self.sampleService.UUID.UUIDString : NSLocalizedString(@"ServiceViewController.title.default", "");
    [self setupContents];
}

- (void)setupContents {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kdefaultTableViewHeaderReuseIdentifier];
    [_tableView registerClass:[ServiceTableViewCell class] forCellReuseIdentifier:[ServiceTableViewCell reuseIdentifier]];
    [_tableView registerClass:[CharacteristicTabeViewCell class] forCellReuseIdentifier:[CharacteristicTabeViewCell reuseIdentifier]];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0).mas_offset(44);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0).mas_offset(- [DeviceScreenAdaptor bottomIndicatorMargin]);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

#pragma mark - Actions

- (void)cancelButtnDidTappedAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButtonDidTappedAction {
    self.sampleService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:self.UUIDString] primary:self.primary];
    [self.sampleService setIncludedServices:self.includedServices];
    // [self.sampleService setCharacteristics:self.characteristics];
    !self.serviceDidSavedHandler ?: self.serviceDidSavedHandler(self.sampleService);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteButtonDidTappedAction {
    PSTAlertController *controller = [PSTAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", "") message:NSLocalizedString(@"ServiceViewController.deleteButton.alert.text", "") preferredStyle:PSTAlertControllerStyleAlert];
    PSTAlertAction *deleteAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Delete", "") style:PSTAlertActionStyleDestructive handler:^(PSTAlertAction * _Nonnull action) {
        !self.serviceDidRemovedHandler ?: self.serviceDidRemovedHandler(self.sampleService);
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

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger addingCell = self.isAddingMode ? 1 : 0;
    switch (section) {
        case 0:
            return self.viewModels.count;
            break;
        case 1:
            return self.characteristics.count + addingCell;
            break;
        case 2:
            return self.includedServices.count + addingCell;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1: {
            if (indexPath.row < self.characteristics.count) {
                CharacteristicTabeViewCell *characteristicCell = [tableView dequeueReusableCellWithIdentifier:[CharacteristicTabeViewCell reuseIdentifier] forIndexPath:indexPath];
                characteristicCell.characteristic = self.characteristics[indexPath.row];
                characteristicCell.unFold = characteristicCell.characteristic.isUnfold;
                characteristicCell.foldButtonDidTappedHandler = ^(BOOL isUnfold) {
                    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                };
                return characteristicCell;
            } else {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kdefaultTableViewCellReuseIdentifier];
                }
                cell.textLabel.text = NSLocalizedString(@"CharacteristicTableViewCell.newCharacteristic", "");
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = [UIColor tintColor];
                return cell;
            }
        }
            break;
            
        case 2: {
            if (indexPath.row < self.includedServices.count) {
                ServiceTableViewCell *serviceCell = [tableView dequeueReusableCellWithIdentifier:[ServiceTableViewCell reuseIdentifier] forIndexPath:indexPath];
                // 此处强转是为了消除警告
                serviceCell.service = (CBMutableService *)self.includedServices[indexPath.row];
                serviceCell.unfold = serviceCell.service.isUnfold;
                serviceCell.foldButtonDidTappedHandler = ^(BOOL isUnfold) {
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                };
                return serviceCell;
            } else {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kdefaultTableViewCellReuseIdentifier];
                }
                cell.textLabel.text = NSLocalizedString(@"ServiceTableViewCell.newService", "");
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = [UIColor tintColor];
                return cell;
            }
        }
            break;
            
        default: {
            ViewModel *viewModel = self.viewModels[indexPath.row];
            if ([viewModel.title isEqualToString:NSLocalizedString(@"ServiceViewController.table.cell.primary", "")]) {
                SwitchTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if (!cell) {
                    cell = [[SwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kdefaultTableViewCellReuseIdentifier];
                }
                cell.switchControl.on = self.sampleService.isPrimary;
                cell.switchControl.enabled = self.isAddingMode;
                cell.title = viewModel.title;
                cell.switchValueDidChangedHandler = ^(BOOL switchState) {
                    self.primary = switchState;
                };
                return cell;
            } else {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kdefaultTableViewCellReuseIdentifier];
                }
                
                cell.textLabel.text = viewModel.title;
                cell.detailTextLabel.text = viewModel.subTitle;
                return cell;
            }
        }
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kdefaultTableViewHeaderReuseIdentifier];
    NSString *sectionTitle = @"";
    switch (section) {
        case 1:
            sectionTitle = NSLocalizedString(@"ServiceViewController.table.header.characteristic", "");
            break;
            
        case 2:
            sectionTitle = NSLocalizedString(@"ServiceViewController.table.header.includedServices", "");
            break;
            
        default:
            break;
    }
    header.textLabel.text = sectionTitle;
    return header;
}

#pragma mark - TaleViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ViewModel *model = self.viewModels[indexPath.row];
        if ([model.title isEqualToString:NSLocalizedString(@"ServiceViewController.table.cell.UUID", "")]) {
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
        return;
    } else if (indexPath.section == 1) {
        // 查看或添加特征
        CBCharacteristic *characteristic = indexPath.row < self.characteristics.count ? self.characteristics[indexPath.row] : nil;
        CharacteristicViewController *controller = [[CharacteristicViewController alloc] initWithCharacteristic:characteristic];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 2) {
        // 查看或添加服务
        CBMutableService *service = indexPath.row < self.includedServices.count ? (CBMutableService *)self.includedServices[indexPath.row] : nil;
        ServiceViewController *controller = [[ServiceViewController alloc] initWithService:service];
        controller.serviceDidSavedHandler = ^(CBMutableService * _Nonnull service) {
            NSArray *newIncludedServiceArray = [self.includedServices arrayByAddingObject:service];
            // 子服务添加的时候主服务的sampleService还是nil
            self.includedServices = newIncludedServiceArray;
            [tableView reloadData];
        };
        controller.serviceDidRemovedHandler = ^(CBMutableService * _Nonnull service) {
            if ([self.includedServices containsObject:service]) {
                NSMutableArray *newIncludedServiceArray = [NSMutableArray arrayWithArray:self.includedServices];
                [newIncludedServiceArray removeObject:service];
                self.includedServices = newIncludedServiceArray;
                [tableView reloadData];
            }
        };
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [BaseTableViewCell rowHeight];
    } else if (indexPath.section == 2) {
        if (indexPath.row < self.includedServices.count) {
            CBService *service = self.includedServices[indexPath.row];
            return service.isUnfold ? [ServiceTableViewCell rowUnfoldHeight] : [ServiceTableViewCell rowHeight];
        } else {
            return 50;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row < self.characteristics.count) {
            CBCharacteristic *charater = self.characteristics[indexPath.row];
            
            return charater.isUnfold ? [CharacteristicTabeViewCell rowUnfoldHeight] : [CharacteristicTabeViewCell rowHeight];
        } else {
            return 50;
        }
    } else {
        return 50;
    }
}

@end
