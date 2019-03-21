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

@interface PeripheralViewController () <UITableViewDataSource, UITableViewDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBService *service;
@property (nonatomic, strong) NSArray <DPService *> *services;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.peripheral.name;
    [self setupContents];
}

- (void)setupContents {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[ServiceTableViewCell class] forCellReuseIdentifier:[ServiceTableViewCell reuseIdentifier]];
    [self.view addSubview:self.tableView];
    
    
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
    return cell;
}

#pragma mark - TableViewDelegate



#pragma mark - PeripheralDelegate

@end
