//
//  ServiceViewController.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/6.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "ServiceViewController.h"

// Helpers
#import <CoreBluetooth/CoreBluetooth.h>

@interface ServiceViewController ()<CBPeripheralManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CBService *sampleService;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

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
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)setupContents {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

#pragma mark - Actions

#pragma mark - CBPeripheralManagerDelegate

@end
