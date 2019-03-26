//
//  CentralViewController.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/3/12.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "CentralViewController.h"

// Controllers
#import "PeripheralViewController.h"

// Views
#import <SVProgressHUD/SVProgressHUD.h>
#import "StatusBarView.h"
#import "PeripheralTableViewCell.h"

// Helpers
#import <CoreBluetooth/CoreBluetooth.h>
#import <PKRevealController/PKRevealController.h>

@interface CentralViewController () <UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong, readonly) NSArray <CBPeripheral *> *peripherals;
@property (nonatomic, strong) NSMutableSet <CBPeripheral *> *peripheralSet;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) StatusBarView *statusBar;

@end

@implementation CentralViewController

#pragma mark - LifeCycle

- (CBCentralManager *)centralManager {
    if (!_centralManager) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_queue_create("CBCentralManagerQueue", DISPATCH_QUEUE_CONCURRENT)];
    }
    return _centralManager;
}

- (NSMutableSet<CBPeripheral *> *)peripheralSet {
    if (!_peripheralSet) {
        _peripheralSet = [NSMutableSet set];
    }
    return _peripheralSet;
}

- (NSArray<CBPeripheral *> *)peripherals {
    return [self.peripheralSet allObjects];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"CentralViewController.title", "");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CentralViewController.rightItem.scan", "") style:UIBarButtonItemStylePlain target:self action:@selector(scanButtonDidTappedAction)];
    UIButton *aboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *icon = [UIImage imageScaledFromImage:[UIImage imageNamed:@"edit"] Size:CGSizeMake(DSAdaptedValue(30), DSAdaptedValue(28))];
    [aboutButton setBackgroundImage:icon forState:UIControlStateNormal];
    [aboutButton addTarget:self action:@selector(menuButtonDidTappedAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aboutButton];
    [self setupContent];
}

- (void)setupContent {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[PeripheralTableViewCell class] forCellReuseIdentifier:[PeripheralTableViewCell reuseIdentifier]];
    [self.view addSubview:self.tableView];
    
    _statusBar = [[StatusBarView alloc] initWithPosition:StatusBarPositionTop Frame:CGRectZero];
    _statusBar.hidden = YES;
    [self.tableView addSubview:self.statusBar];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(DSStatusBarMargin + 44);
        make.bottom.mas_equalTo(- DSBottomMargin);
    }];
    
    [self.statusBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.tableView.mas_top);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(self.statusBar.intrinsicContentSize.height);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.centralManager.isScanning) {
        [self.centralManager stopScan];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Actions

- (void)menuButtonDidTappedAction {
    [self.revealController showViewController:self.revealController.leftViewController];
}

- (void)scanButtonDidTappedAction {
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)showConnectAlert:(CBPeripheral *)peripheral {
    PSTAlertController *controller = [PSTAlertController alertControllerWithTitle:peripheral.name message:NSLocalizedString(@"CentralViewController.alert.connect", "") preferredStyle:PSTAlertControllerStyleAlert];
    
    PSTAlertAction *cancelAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"No", "") handler:^(PSTAlertAction * _Nonnull action) {
        
    }];
    
    PSTAlertAction *okAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Yes", "") handler:^(PSTAlertAction * _Nonnull action) {
        self.tableView.userInteractionEnabled = NO;
        [SVProgressHUD show];
        [self.centralManager connectPeripheral:peripheral options:nil];
    }];
    
    [controller addAction:cancelAction];
    [controller addAction:okAction];
    
    [controller showWithSender:nil controller:nil animated:YES completion:^{
        
    }];
}

- (void)showDisconnectAlert:(CBPeripheral *)peripheral {
    PSTAlertController *controller = [PSTAlertController alertControllerWithTitle:peripheral.name message:NSLocalizedString(@"CentralViewController.alert.disconnect", "") preferredStyle:PSTAlertControllerStyleAlert];
    
    PSTAlertAction *cancelAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"No", "") handler:^(PSTAlertAction * _Nonnull action) {
        
    }];
    
    PSTAlertAction *okAction = [PSTAlertAction actionWithTitle:NSLocalizedString(@"Yes", "") handler:^(PSTAlertAction * _Nonnull action) {
        self.tableView.userInteractionEnabled = NO;
        [SVProgressHUD show];
        [self.centralManager cancelPeripheralConnection:peripheral];
    }];
    
    [controller addAction:cancelAction];
    [controller addAction:okAction];
    
    [controller showWithSender:nil controller:nil animated:YES completion:^{
        
    }];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PeripheralTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[PeripheralTableViewCell reuseIdentifier] forIndexPath:indexPath];
    cell.peripheral = self.peripherals[indexPath.row];
    cell.detialButtonDidTappedHandler = ^(CBPeripheral * _Nonnull peripheral) {
        if (peripheral.state == CBPeripheralStateConnected) {
            PeripheralViewController *controller = [[PeripheralViewController alloc] initWithPeripheral:peripheral];
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"CentralViewController.cell.detailButton.error", "")];
        }
    };
    return cell;
}

#pragma mark - Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [PeripheralTableViewCell rowHeight];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = self.peripherals[indexPath.row];
    
    if (peripheral.state == CBPeripheralStateConnected) {
        [self showDisconnectAlert:peripheral];
    }
    else if (peripheral.state == CBPeripheralStateDisconnected) {
        [self showConnectAlert:peripheral];
    }
}

#pragma mark - CentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSString *stateString = nil;
    switch (central.state) {
        case CBManagerStateUnknown:
            stateString = NSLocalizedString(@"peripheralState.unknown", "");
            break;
            
        case CBManagerStatePoweredOn:
            stateString = NSLocalizedString(@"peripheralState.powerOn", "");
            break;
            
        case CBManagerStateResetting:
            stateString = NSLocalizedString(@"peripheralState.resetting", "");
            break;
            
        case CBManagerStatePoweredOff:
            stateString = NSLocalizedString(@"peripheralState.powerOff", "");
            break;
            
        case CBManagerStateUnsupported:
            stateString = NSLocalizedString(@"peripheralState.unsupported", "");
            break;
            
        case CBManagerStateUnauthorized:
            stateString = NSLocalizedString(@"peripheralState.unauthorzied", "");
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.statusBar showWithMessage:stateString ForSeconds:3];
    });
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    [self.peripheralSet addObject:peripheral];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.tableView.userInteractionEnabled = YES;
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"CentralViewController.hud.connect.success", "")];
        [self.tableView reloadData];
    });
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.tableView.userInteractionEnabled = YES;
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"CBPeripheralState.disconnected", "")];
        [self.tableView reloadData];
    });
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.tableView.userInteractionEnabled = YES;
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"CentralViewController.hud.connect.failure", ""), error.localizedDescription]];
        [self.tableView reloadData];
    });
}

@end
