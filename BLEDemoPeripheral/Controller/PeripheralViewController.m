//
//  PeripheralViewController.m
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/3/21.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "PeripheralViewController.h"

// Views
#import "ServiceTableViewCell.h"

// Models
#import <CoreBluetooth/CoreBluetooth.h>
#import "DPService.h"
#import "ViewModel.h"



@interface PeripheralViewController () <UITableViewDataSource, UITableViewDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong, readonly) NSArray <CBService *> *services;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation PeripheralViewController

#pragma mark - LifeCycle

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        _peripheral.delegate = self;
    }
    return self;
}

- (NSArray<CBService *> *)services {
    return self.peripheral.services;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.peripheral.name;
    [self setupContents];
    [self.peripheral discoverServices:nil];
}

- (void)setupContents {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[ServiceTableViewCell class] forCellReuseIdentifier:[ServiceTableViewCell reuseIdentifier]];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(- DSBottomMargin);
        make.top.mas_equalTo(DSStatusBarMargin + 44);
    }];
}

#pragma mark - Actions

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ServiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ServiceTableViewCell reuseIdentifier] forIndexPath:indexPath];
    cell.cbService = self.services[indexPath.row];
    return cell;
}

#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ServiceTableViewCell rowHeight];
}

#pragma mark - PeripheralDelegate

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    self.title = peripheral.name;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
