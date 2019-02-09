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
        ViewModel *primaryModel = [[ViewModel alloc] init];
        primaryModel.title = NSLocalizedString(@"ServiceViewController.table.cell.primary", "");
        _viewModels = @[uuidModel, primaryModel];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtnDidTappedAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonDidTappedAction)];
    self.navigationItem.title = self.sampleService.UUID.UUIDString ? self.sampleService.UUID.UUIDString : NSLocalizedString(@"ServiceViewController.title.default", "");
    [self setupContents];
}

- (void)setupContents {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kdefaultTableViewHeaderReuseIdentifier];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kdefaultTableViewCellReuseIdentifier];
    [_tableView registerClass:[ServiceTableViewCell class] forCellReuseIdentifier:[ServiceTableViewCell reuseIdentifier]];
    [_tableView registerClass:[CharacteristicTabeViewCell class] forCellReuseIdentifier:[CharacteristicTabeViewCell reuseIdentifier]];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0).mas_offset([DeviceScreenAdaptor statusBarMargin] + 44);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0).mas_offset(- [DeviceScreenAdaptor bottomIndicatorMargin]);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

#pragma mark - Actions

- (void)cancelButtnDidTappedAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveButtonDidTappedAction {
    // !self.serviceDidAddHandler ?: self.serviceDidAddHandler()
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CBPeripheralManagerDelegate

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
            return self.characteristics.count;
            break;
        case 2:
            return self.includedServices.count;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1: {
            CharacteristicTabeViewCell *characteristicCell = [tableView dequeueReusableCellWithIdentifier:[CharacteristicTabeViewCell reuseIdentifier] forIndexPath:indexPath];
            return characteristicCell;
        }
            break;
            
        case 2: {
            ServiceTableViewCell *serviceCell = [tableView dequeueReusableCellWithIdentifier:[ServiceTableViewCell reuseIdentifier] forIndexPath:indexPath];
            return serviceCell;
        }
            break;
            
        default: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kdefaultTableViewCellReuseIdentifier forIndexPath:indexPath];
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
