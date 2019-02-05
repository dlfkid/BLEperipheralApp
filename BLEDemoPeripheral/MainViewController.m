//
//  MainViewController.m
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2017/8/7.
//  Copyright © 2017年 Ivan_deng. All rights reserved.
//

#define SERVICE_UUID @"CDD1"
#define CHARACTERISTIC_UUID @"CDD2"

#import "MainViewController.h"


@interface MainViewController () <CBPeripheralManagerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *boardCastButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UIView *stateView;
@property (nonatomic, strong) CBMutableCharacteristic *currentCharacteristic;
@property (nonatomic, strong) UITextField *textContent;
@property (nonatomic, assign, getter = isBoardcasting) BOOL boardcasting;

@end

@implementation MainViewController

- (CBPeripheralManager *)peripheralManager {
    if(!_peripheralManager) {
        self.peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    return _peripheralManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self UIBuild];
    // Do any additional setup after loading the view.
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
    
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectZero];
    textField.delegate = self;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.font = [UIFont systemFontOfSize:14];
    textField.layer.borderWidth = 1;
    _textContent = textField;
    [self.view addSubview:_textContent];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"BoardCast" style:UIBarButtonItemStyleDone target:self action:@selector(startBoardCast)];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    
    
    _boardCastButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_boardCastButton addTarget:self action:@selector(startBoardCast) forControlEvents:UIControlEventTouchUpInside];
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
    
    [self.boardCastButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(- 30);
        make.height.equalTo(@40);
        make.bottom.equalTo(@(-10)).mas_offset(- [DeviceScreenAdaptor bottomIndicatorMargin]);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.stateView.mas_bottom);
        make.left.right.equalTo(@0);
        make.bottom.mas_equalTo(self.boardCastButton.mas_top).mas_offset(-10);
    }];
}

#pragma mark - Actions

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

- (void)startBoardCast {
    [self setUpServiceAndCharacteristic];
    
}

- (void)setBoardcasting:(BOOL)boardcasting {
    _boardcasting = boardcasting;
    if (self.isBoardcasting) {
        [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:SERVICE_UUID]]}];
    } else {
        [self.peripheralManager stopAdvertising];
    }
}

- (void)setUpServiceAndCharacteristic {
    //创建服务
    CBUUID *serviceID = [CBUUID UUIDWithString:SERVICE_UUID];
    CBMutableService *service = [[CBMutableService alloc]initWithType:serviceID primary:true];
    //创建服务中的特征
    CBUUID *characteristicID = [CBUUID UUIDWithString:CHARACTERISTIC_UUID];
    CBMutableCharacteristic *characteristic = [[CBMutableCharacteristic alloc]initWithType:characteristicID properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
    //将特征添加到服务
    service.characteristics = @[characteristic];
    [self.peripheralManager addService:service];
    
    //为了手动给中心设备发送数据
    self.currentCharacteristic = characteristic;
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
    
    
    if(peripheral.state != CBManagerStatePoweredOn) {
        [self.peripheralManager stopAdvertising];
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"ManagerError" message:@"Manager state wrong" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"confirm" style:UIAlertActionStyleDefault handler:nil];
        [alertControl addAction:alertAction];
        [self presentViewController:alertControl animated:true completion:nil];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    request.value = [_textContent.text dataUsingEncoding:NSUTF8StringEncoding];
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests {
    CBATTRequest *request = requests.lastObject;
    self.textContent.text = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"%s",__FUNCTION__);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - textFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    return cell;
}

#pragma mark - TableViewDelegate


@end
