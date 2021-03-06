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
#import "DPCharacteristic.h"
#import "DPService.h"

// Helpers
#import "CBCharacteristic+StringExtensions.h"
#import "DataBaseManager.h"

@interface ServiceViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DPService *sampleService;
// @property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) NSArray <ViewModel *> *viewModels;
// 此方法用于判断控制器是查看模式还是新建模式，如果是新建模式才允许用户操作内容。
@property (nonatomic, assign, getter = isAddingMode) BOOL addingMode;

// SampleValues
@property (nonatomic, copy) NSString *UUIDString;
@property (nonatomic, assign) BOOL primary;
@property (nonatomic, strong) NSArray <DPService *> *includedServices;
@property (nonatomic, strong) NSArray <DPCharacteristic *> *characteristics;

@end

@implementation ServiceViewController

- (void)setSampleService:(DPService *)sampleService {
    _sampleService = sampleService;
    _primary = sampleService.isPrimary;
    _includedServices = sampleService.includedService;
    _characteristics = sampleService.characters;
}

- (NSArray<DPService *> *)includedServices {
    if (!_includedServices) {
        _includedServices = [NSArray array];
    }
    return _includedServices;
}

- (NSArray<DPCharacteristic *> *)characteristics {
    if (!_characteristics) {
        _characteristics = [NSArray array];
    }
    return _characteristics;
}

#pragma mark - LifeCycle

- (instancetype)initWithService:(DPService *)service {
    self = [super init];
    if (self) {
        self.sampleService = service;
        // 判断是新增服务还是查看服务详情。
        self.addingMode = !self.sampleService;
        ViewModel *uuidModel = [[ViewModel alloc] init];
        uuidModel.title = NSLocalizedString(@"ServiceViewController.table.cell.UUID", "");
        uuidModel.subTitle = service.uuid;
        ViewModel *primaryModel = [[ViewModel alloc] init];
        primaryModel.title = NSLocalizedString(@"ServiceViewController.table.cell.primary", "");
        primaryModel.subTitle = service.isPrimary ? NSLocalizedString(@"Yes", "") : NSLocalizedString(@"No", "");
        ViewModel *descriptionModel = [[ViewModel alloc] init];
        descriptionModel.title = NSLocalizedString(@"ServiceViewController.tableView.cell.descriptionText", "");
        descriptionModel.subTitle = service.descriptionText;
    
        _viewModels = @[uuidModel, primaryModel, descriptionModel];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtnDidTappedAction)];

    UIBarButtonItem *editBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(saveButtonDidTappedAction)];
    UIBarButtonItem *deleteBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButtonDidTappedAction)];
    
    self.navigationItem.rightBarButtonItems = self.isAddingMode ? @[editBarItem] : @[deleteBarItem];
    self.navigationItem.title = self.sampleService.uuid ? self.sampleService.uuid : NSLocalizedString(@"ServiceViewController.title.default", "");
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
        make.top.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0).mas_offset(- [DeviceScreenAdaptor bottomIndicatorMargin]);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

#pragma mark - Actions

- (void)cancelButtnDidTappedAction {
    if (!self.sampleService && (self.includedServices.count > 0 || self.characteristics.count > 0)) {
        PSTAlertController *controller = [PSTAlertController alertWithTitle:NSLocalizedString(@"ServiceViewController.cancelButton.alert.text", "") message:nil];
        PSTAlertAction *yesAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Yes", "") handler:^(PSTAlertAction * _Nonnull action) {
            for (DPCharacteristic *character in self.characteristics) {
                [character RemoveCharacteristicFromDB];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
        PSTAlertAction *noAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"No", "") handler:^(PSTAlertAction * _Nonnull action) {
            return;
        }];
        
        [controller addAction:noAction];
        [controller addAction:yesAction];
        
        [controller showWithSender:nil controller:nil animated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    // 不能调用Set方法，否则会重置子服务和特征
    _sampleService = [[DPService alloc] initWithUUID:self.UUIDString Primary:self.primary];
    ViewModel *descriptionModel = self.viewModels[2];
    self.sampleService.descriptionText = descriptionModel.subTitle;
    self.sampleService.includedService = self.includedServices;
    self.sampleService.characters = self.characteristics;
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
                characteristicCell.unFold = characteristicCell.characteristic.viewModel.isUnfold;
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
                serviceCell.service = (DPService *)self.includedServices[indexPath.row];
                serviceCell.unfold = serviceCell.service.viewModel.isUnfold;
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
                cell.switchControl.on = self.primary;
                cell.switchControl.enabled = self.isAddingMode;
                cell.title = viewModel.title;
                cell.switchValueDidChangedHandler = ^(BOOL switchState) {
                    self.primary = switchState;
                };
                return cell;
            }
            else if ([viewModel.title isEqualToString:NSLocalizedString(@"ServiceViewController.tableView.cell.descriptionText", "")]) {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kdefaultTableViewCellReuseIdentifier];
                }
                cell.textLabel.text = viewModel.title;
                cell.detailTextLabel.text = viewModel.subTitle;
                return cell;
            }
            else {
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
        if (!self.sampleService && [model.title isEqualToString:NSLocalizedString(@"ServiceViewController.table.cell.UUID", "")]) {
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
        else if ([model.title isEqualToString:NSLocalizedString(@"ServiceViewController.tableView.cell.descriptionText", "")]) {
            PSTAlertController *controller = [PSTAlertController alertControllerWithTitle:NSLocalizedString(@"ServiceViewController.tableView.cell.descriptionAlert.title", "") message:@"" preferredStyle:PSTAlertControllerStyleAlert];
            PSTAlertAction *cancelAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Cancel", "") handler:^(PSTAlertAction * _Nonnull action) {
                
            }];
            PSTAlertAction *comfirmAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Submit", "") style:PSTAlertActionStyleDefault handler:^(PSTAlertAction * _Nonnull action) {
                UITextField *textField = controller.textField;
                if (textField.text.length > 0) {
                    model.subTitle = textField.text;
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
        DPCharacteristic *characteristic = indexPath.row < self.characteristics.count ? self.characteristics[indexPath.row] : nil;
        CharacteristicViewController *controller = [[CharacteristicViewController alloc] initWithCharacteristic:characteristic];
        
        controller.characteristicDidDeletedHandler = ^(DPCharacteristic * _Nonnull characteristic) {
            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.characteristics];
            if ([tempArray containsObject:characteristic]) {
                [tempArray removeObject:characteristic];
                self.characteristics = tempArray;
                [tableView reloadData];
                [characteristic RemoveCharacteristicFromDB];
            }
        };
        
        controller.characteristicDidSavedHandler = ^(DPCharacteristic * _Nonnull characteristic) {
            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.characteristics];
            [tempArray addObject:characteristic];
            self.characteristics = tempArray;
            [tableView reloadData];
            [characteristic addCharacteristicToDB];
        };
        
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 2) {
        // 查看或添加服务
        DPService *service = indexPath.row < self.includedServices.count ? (DPService *)self.includedServices[indexPath.row] : nil;
        ServiceViewController *controller = [[ServiceViewController alloc] initWithService:service];
        controller.serviceDidSavedHandler = ^(DPService * _Nonnull service) {
            service.subService = YES;
            NSArray *newIncludedServiceArray = [self.includedServices arrayByAddingObject:service];
            // 子服务添加的时候主服务的sampleService还是nil
            self.includedServices = newIncludedServiceArray;
            [tableView reloadData];
            [service addServiceToDB];
        };
        controller.serviceDidRemovedHandler = ^(DPService * _Nonnull service) {
            if ([self.includedServices containsObject:service]) {
                NSMutableArray *newIncludedServiceArray = [NSMutableArray arrayWithArray:self.includedServices];
                [newIncludedServiceArray removeObject:service];
                self.includedServices = newIncludedServiceArray;
                [tableView reloadData];
                [service removeServiceFromDB];
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
            DPService *service = self.includedServices[indexPath.row];
            return service.viewModel.isUnfold ? [ServiceTableViewCell rowUnfoldHeight] : [ServiceTableViewCell rowHeight];
        } else {
            return 50;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row < self.characteristics.count) {
            DPCharacteristic *charater = self.characteristics[indexPath.row];
            
            return charater.viewModel.isUnfold ? [CharacteristicTabeViewCell rowUnfoldHeight] : [CharacteristicTabeViewCell rowHeight];
        } else {
            return 50;
        }
    } else {
        return 50;
    }
}

@end
