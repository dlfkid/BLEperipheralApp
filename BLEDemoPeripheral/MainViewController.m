//
//  MainViewController.m
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2017/8/7.
//  Copyright © 2017年 Ivan_deng. All rights reserved.
//

#import "MainViewController.h"

// Controllers
#import "ServiceViewController.h"

// Views
#import "ServiceTableViewCell.h"

// Models
#import "ViewModel.h"
#import "DPService.h"
#import "DPCharacteristic.h"


@interface MainViewController () <CBPeripheralManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *boardCastButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UIView *stateView;
@property (nonatomic, strong) CBMutableCharacteristic *currentCharacteristic;
@property (nonatomic, strong) UITextField *textContent;
@property (nonatomic, assign, getter = isBoardcasting) BOOL boardcasting;

@property (nonatomic, strong) NSArray <DPService *> *serviceArray;

@end

static NSString * const kSampleServiceUUID = @"CDD1";
static NSString * const kSampleCharacteristicUUID = @"CDD2";

@implementation MainViewController

- (CBPeripheralManager *)peripheralManager {
    if(!_peripheralManager) {
        self.peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    return _peripheralManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonDidTappedAction)];
    // [self setUpServiceAndCharacteristic];
    [self UIBuild];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"BLEDemoPeripheral";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)UIBuild {
    _stateView = [[UIView alloc] initWithFrame:CGRectZero];
    _stateView.backgroundColor = [UIColor colorWithR:224 G:180 B:62];
    [self.view addSubview:_stateView];
    
    _stateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _stateLabel.textAlignment = NSTextAlignmentCenter;
    _stateLabel.textColor = [UIColor whiteColor];
    _stateLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    _stateLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MainViewController.stateLabel.text", @""), [self peripherialStateString:self.peripheralManager.state]];
    [self.stateView addSubview:_stateLabel];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    NSString *reuseIdentfier = [ServiceTableViewCell reuseIdentifier];
    [_tableView registerClass:[ServiceTableViewCell class] forCellReuseIdentifier:reuseIdentfier];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kdefaultTableViewHeaderReuseIdentifier];
    [self.view addSubview:self.tableView];
    _boardCastButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_boardCastButton addTarget:self action:@selector(boardcastButtonDidTappedAction:) forControlEvents:UIControlEventTouchUpInside];
    _boardCastButton.backgroundColor = [UIColor tintColor];
    [_boardCastButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_boardCastButton setTitle:NSLocalizedString(@"MainViewController.boardcastButton.title", @"") forState:UIControlStateNormal];
    [_boardCastButton setTitle:NSLocalizedString(@"MainViewController.boardcastButton.title.selected", @"") forState:UIControlStateSelected];
    _boardCastButton.layer.cornerRadius = 10;
    [self.view addSubview:self.boardCastButton];
    
    [self.stateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo([DeviceScreenAdaptor statusBarMargin] + 44);
        make.left.right.equalTo(@0);
        make.height.equalTo(@30);
    }];
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.right.equalTo(@(-10));
        make.centerY.equalTo(@0);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.stateView.mas_bottom);
        make.left.right.equalTo(@0);
        make.bottom.mas_equalTo(0).mas_offset(- [DeviceScreenAdaptor bottomIndicatorMargin]);
    }];
    
    [self.boardCastButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(- 30);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.tableView.mas_bottom).mas_offset(- 30);
    }];
}

- (void)updateViewConstraints {

    [super updateViewConstraints];
}

#pragma mark - Actions

- (void)addButtonDidTappedAction {
    ServiceViewController *serviceVC = [[ServiceViewController alloc] initWithService:nil];
    serviceVC.serviceDidSavedHandler = ^(DPService * _Nonnull service) {
        // 此处传入服务被创建成功后的回调
        NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.serviceArray];
        if (![tmpArray containsObject:service]) {
            [tmpArray addObject:service];
            self.serviceArray = tmpArray;
            [self.tableView reloadData];
        }
    };
    serviceVC.serviceDidRemovedHandler = ^(DPService * _Nonnull service) {
        NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.serviceArray];
        if ([tmpArray containsObject:service]) {
            [tmpArray removeObject:service];
            self.serviceArray = tmpArray;
            [self.tableView reloadData];
        }
    };
    [self.navigationController pushViewController:serviceVC animated:YES];
}

- (NSString *)peripherialStateString:(CBManagerState)state {
    NSString *currentState = NSLocalizedString(@"peripheralState.unknown", @"");
    switch (state) {
        case CBManagerStateUnknown:
            currentState = NSLocalizedString(@"peripheralState.unknown", @"");
            break;
        case CBManagerStateUnsupported:
            currentState = NSLocalizedString(@"peripheralState.unsupported", @"");
            break;
        case CBManagerStateUnauthorized:
            currentState = NSLocalizedString(@"peripheralState.unauthorzied", @"");
            break;
        case CBManagerStateResetting:
            currentState = NSLocalizedString(@"peripheralState.resetting", @"");
            break;
        case CBManagerStatePoweredOff:
            currentState = NSLocalizedString(@"peripheralState.powerOff", @"");
            break;
        case CBManagerStatePoweredOn:
            currentState = NSLocalizedString(@"peripheralState.powerOn", @"");
            break;
        default:
            break;
    }
    return currentState;
}

- (void)didClickPost {
    BOOL sendSuccess = [self.peripheralManager updateValue:[self.textContent.text dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.currentCharacteristic onSubscribedCentrals:nil];
    
    if(sendSuccess) {
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"DataPost" message:@"Success" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"confirm" style:UIAlertActionStyleDefault handler:nil];
        [alertControl addAction:alertAction];
        [self presentViewController:alertControl animated:true completion:nil];
    }else {
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"DataPost" message:@"Failure" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"confirm" style:UIAlertActionStyleDefault handler:nil];
        [alertControl addAction:alertAction];
        [self presentViewController:alertControl animated:true completion:nil];
    }
}

- (void)boardcastButtonDidTappedAction:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    self.boardcasting = sender.isSelected;
}

// 广播当前所有服务
- (void)setBoardcasting:(BOOL)boardcasting {
    if(self.peripheralManager.state != CBManagerStatePoweredOn) {
        [self.peripheralManager stopAdvertising];
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"ManagerError" message:@"Manager state wrong" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"confirm" style:UIAlertActionStyleDefault handler:nil];
        [alertControl addAction:alertAction];
        [self presentViewController:alertControl animated:true completion:nil];
    }
    _boardcasting = boardcasting;
    if (self.isBoardcasting) {
        NSMutableArray *boardcastingServices = [NSMutableArray array];
        for (CBMutableService *service in self.serviceArray) {
            [boardcastingServices addObject:service.UUID];
        }
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:boardcastingServices}];
    } else {
        [self.peripheralManager stopAdvertising];
    }
}

- (void)setUpServiceAndCharacteristic {
    //创建样例服务
    CBUUID *serviceID = [CBUUID UUIDWithString:kSampleServiceUUID];
    CBMutableService *service = [[CBMutableService alloc]initWithType:serviceID primary:true];
    //创建服务中的特征
    CBUUID *characteristicID = [CBUUID UUIDWithString:kSampleCharacteristicUUID];
    CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc]initWithType:characteristicID properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
    // NSString *sampleValue = @"sampleValue";
    // 只有将特征设置为只读时才能为特征赋初始值
    // characteristic.value = [sampleValue dataUsingEncoding:NSUTF8StringEncoding];
    // characteristic.permissions = CBAttributePermissionsReadable | CBAttributePermissionsWriteable;
    //将特征添加到服务
    service.characteristics = @[characteristic];
    [self.peripheralManager addService:service];
    
    //为了手动给中心设备发送数据
    self.currentCharacteristic = characteristic;
    
    self.serviceArray = @[service];
}

# pragma mark - BLEDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    UIColor *errorColor = [UIColor colorWithHexString:@"#FADFDF"];
    UIColor *warningColor = [UIColor colorWithR:224 G:180 B:62];
    UIColor *normalColor = [UIColor colorWithR:99 G:207 B:173];
    switch (peripheral.state) {
        case CBManagerStateUnknown:
            self.stateView.backgroundColor = warningColor;
            break;
        case CBManagerStateUnsupported:
            self.stateView.backgroundColor = errorColor;
            break;
        case CBManagerStateUnauthorized:
            self.stateView.backgroundColor = errorColor;
            break;
        case CBManagerStateResetting:
            self.stateView.backgroundColor = warningColor;
            break;
        case CBManagerStatePoweredOff:
            self.stateView.backgroundColor = warningColor;
            break;
        case CBManagerStatePoweredOn:
            self.stateView.backgroundColor = normalColor;
            break;
        default:
            break;
    }
    
    self.stateLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"MainViewController.stateLabel.text", @""), [self peripherialStateString:peripheral.state]];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    request.value = [_textContent.text dataUsingEncoding:NSUTF8StringEncoding];
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    CBATTRequest *request = requests.lastObject;
    self.textContent.text = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBMutableCharacteristic *)characteristic {
    NSLog(@"%s",__FUNCTION__);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBMutableCharacteristic *)characteristic {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.serviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ServiceTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[ServiceTableViewCell reuseIdentifier]];
    cell.service = self.serviceArray[indexPath.row];
    cell.unfold = cell.service.viewModel.isUnfold;
    cell.foldButtonDidTappedHandler = ^(BOOL isUnfold) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    };
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kdefaultTableViewHeaderReuseIdentifier];
    view.textLabel.text = NSLocalizedString(@"MainViewController.tableView.header", "");
    return view;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DPService *service = self.serviceArray[indexPath.row];
    ServiceViewController *viewController = [[ServiceViewController alloc] initWithService:service];
    viewController.serviceDidSavedHandler = ^(DPService * _Nonnull service) {
        NSMutableArray *services = [NSMutableArray arrayWithArray:self.serviceArray];
        if (![services containsObject:service]) {
            [services addObject:service];
            self.serviceArray = services;
            [self.tableView reloadData];
        }
    };
    viewController.serviceDidRemovedHandler = ^(DPService * _Nonnull service) {
        NSMutableArray *services = [NSMutableArray arrayWithArray:self.serviceArray];
        if ([services containsObject:service]) {
            [services removeObject:service];
            self.serviceArray = services;
            [self.tableView reloadData];
        }
    };
    [self.navigationController pushViewController:viewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DPService *service = self.serviceArray[indexPath.row];
    return service.viewModel.isUnfold ? [ServiceTableViewCell rowUnfoldHeight] : [ServiceTableViewCell rowHeight];
}

@end
