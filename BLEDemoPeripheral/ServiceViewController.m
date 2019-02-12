//
//  ServiceViewController.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/6.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "ServiceViewController.h"

// Views
#import "ServiceTableViewCell.h"
#import "CharacteristicTabeViewCell.h"

// Models
#import "ViewModel.h"

// Helpers
#import <CoreBluetooth/CoreBluetooth.h>

@interface ServiceViewController ()<CBPeripheralManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CBService *sampleService;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) NSArray <CBService *> *includedServices;
@property (nonatomic, strong) NSArray <CBCharacteristic *> *characteristics;
@property (nonatomic, strong) NSArray <ViewModel *> *viewModels;
@property (nonatomic, strong) NSArray <ViewModel *> *serviceCellFoldModel;
@property (nonatomic, strong) NSArray <ViewModel *> *characteristicCellFoldModel;

@property (nonatomic, copy) void(^serviceDidAddHandler)(CBService *);

@end

@implementation ServiceViewController

- (CBPeripheralManager *)peripheralManager {
    if (!_peripheralManager) {
        // 使用全局并发队列处理回调，涉及UI的部分需要调用主队列。
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return _peripheralManager;
}

#pragma mark - LifeCycle

- (instancetype)initWithService:(CBService *)service CompletionHandler:(void(^)(CBService *service))completion {
    self = [super init];
    if (self) {
        _sampleService = service;
        _serviceDidAddHandler = completion;
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
    self.navigationItem.rightBarButtonItem = self.sampleService ? [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", "") style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonDidTappedAction)] : [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonDidTappedAction)];
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
    
    if (self.sampleService) {
        self.characteristics = self.sampleService.characteristics;
        
        NSMutableArray *tmpCharacteristicModelArray = [NSMutableArray array];
        
        [self.characteristics enumerateObjectsUsingBlock:^(CBCharacteristic * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ViewModel *tmpCharacteristicViewModel = [[ViewModel alloc] init];
            [tmpCharacteristicModelArray addObject:tmpCharacteristicViewModel];
        }];
        
        self.characteristicCellFoldModel = tmpCharacteristicModelArray;
        
        self.includedServices = self.sampleService.includedServices;
        
        NSMutableArray *tmpServiceModelArray = [NSMutableArray array];
        [self.serviceCellFoldModel enumerateObjectsUsingBlock:^(ViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ViewModel *tmpServiceViewModel = [[ViewModel alloc] init];
            [tmpServiceModelArray addObject:tmpServiceViewModel];
        }];
        
        [self.tableView reloadData];
    }
    
    [super viewWillAppear:animated];
}

#pragma mark - Actions

- (void)cancelButtnDidTappedAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButtonDidTappedAction {
    // !self.serviceDidAddHandler ?: self.serviceDidAddHandler()
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteButtonDidTappedAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.viewModels.count;
            break;
        case 1:
            return self.characteristicCellFoldModel.count + 1;
            break;
        case 2:
            return self.serviceCellFoldModel.count + 1;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1: {
            if (indexPath.row < self.characteristicCellFoldModel.count) {
                CharacteristicTabeViewCell *characteristicCell = [tableView dequeueReusableCellWithIdentifier:[CharacteristicTabeViewCell reuseIdentifier] forIndexPath:indexPath];
                characteristicCell.characteristic = self.characteristics[indexPath.row];
                characteristicCell.unFold = self.characteristicCellFoldModel[indexPath.row].isUnfold;
                characteristicCell.foldButtonDidTappedHandler = ^(BOOL isUnfold) {
                    ViewModel *model = self.characteristicCellFoldModel[indexPath.row];
                    model.unfold = isUnfold;
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
            if (indexPath.row < self.serviceCellFoldModel.count) {
                ServiceTableViewCell *serviceCell = [tableView dequeueReusableCellWithIdentifier:[ServiceTableViewCell reuseIdentifier] forIndexPath:indexPath];
                serviceCell.service = self.includedServices[indexPath.row];
                serviceCell.unFold = self.serviceCellFoldModel[indexPath.row].isUnfold;
                serviceCell.foldButtonDidTappedHandler = ^(BOOL isUnfold) {
                    ViewModel *model = self.serviceCellFoldModel[indexPath.row];
                    model.unfold = isUnfold;
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
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kdefaultTableViewCellReuseIdentifier];
            }
            ViewModel *viewModel = self.viewModels[indexPath.row];
            cell.textLabel.text = viewModel.title;
            cell.detailTextLabel.text = viewModel.subTitle;
            return cell;
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
        return;
    } else if (indexPath.section == 2) {

    } else if (indexPath.section == 1) {

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [BaseTableViewCell rowHeight];
    } else if (indexPath.section == 2) {
        if (indexPath.row < self.serviceCellFoldModel.count) {
            ViewModel *foldModel = self.serviceCellFoldModel[indexPath.row];
            return foldModel.isUnfold ? [ServiceTableViewCell rowUnfoldHeight] : [ServiceTableViewCell rowHeight];
        } else {
            return 50;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row < self.characteristicCellFoldModel.count) {
            ViewModel *foldModel = self.characteristicCellFoldModel[indexPath.row];
            return foldModel.isUnfold ? [CharacteristicTabeViewCell rowUnfoldHeight] : [CharacteristicTabeViewCell rowHeight];
        } else {
            return 50;
        }
    } else {
        return 50;
    }
}


@end

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
