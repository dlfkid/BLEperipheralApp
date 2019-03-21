//
//  CentralViewController.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/3/12.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "CentralViewController.h"

// Controllers
#import "ServiceViewController.h"

// Helpers
#import <CoreBluetooth/CoreBluetooth.h>
#import <PKRevealController/PKRevealController.h>

@interface CentralViewController () <UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong, readonly) NSArray <CBPeripheral *> *peripherals;
@property (nonatomic, strong) NSMutableSet <CBPeripheral *> *peripheralSet;
@property (nonatomic, strong) CBCentralManager *centralManager;

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
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(DSStatusBarMargin + 44);
        make.bottom.mas_equalTo(- DSBottomMargin);
    }];
}

#pragma mark - Actions

- (void)menuButtonDidTappedAction {
    [self.revealController showViewController:self.revealController.leftViewController];
}

- (void)scanButtonDidTappedAction {
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    }
    return cell;
}

#pragma mark - Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - CentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    [self.peripheralSet addObject:peripheral];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
