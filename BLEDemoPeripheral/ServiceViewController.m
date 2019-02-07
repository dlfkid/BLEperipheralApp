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

@interface ServiceViewController ()<CBPeripheralManagerDelegate, UITableViewDataSource, UITableViewDelegate>

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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtnDidTappedAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonDidTappedAction)];
    self.navigationItem.title = self.sampleService.UUID.UUIDString ? self.sampleService.UUID.UUIDString : NSLocalizedString(@"ServiceViewController.title.default", "");
    [self setupContents];
}

- (void)setupContents {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
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
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

#pragma mark - TaleViewDelegate

@end
