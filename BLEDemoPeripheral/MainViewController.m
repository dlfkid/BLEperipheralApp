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


@interface MainViewController ()

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
    self.navigationItem.title = @"BLEPeripheral";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 CBManagerStateUnknown = 0,
	CBManagerStateResetting,
	CBManagerStateUnsupported,
	CBManagerStateUnauthorized,
	CBManagerStatePoweredOff,
	CBManagerStatePoweredOn,
 
*/


- (void)UIBuild {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenheight = [UIScreen mainScreen].bounds.size.height;
    CGFloat topView = 64;
    CGFloat labelHeight = 44;
    _stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, topView, screenWidth, labelHeight)];
    _stateLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_stateLabel];
    
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(10, topView + 60, screenWidth - 20, screenheight/2)];
    textField.delegate = self;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.font = [UIFont systemFontOfSize:14];
    textField.layer.borderWidth = 1;
    _textContent = textField;
    [self.view addSubview:_textContent];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"BoardCast" style:UIBarButtonItemStyleDone target:self action:@selector(startBoardCast)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(didClickPost)];
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

- (void)startBoardCast {
    [self setUpServiceAndCharacteristic];
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:SERVICE_UUID]]}];
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
    
    switch (peripheral.state) {
        case CBManagerStateUnknown:
            NSLog(@"state unknown");
            _stateLabel.text = @"state unknow";
            break;
        case CBManagerStateUnsupported:
            NSLog(@"state unsupported");
            _stateLabel.text = @"state unsupported";
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"state unauthorzied");
            _stateLabel.text = @"state unauthorzied";
            break;
        case CBManagerStateResetting:
            NSLog(@"state resetting");
            _stateLabel.text = @"state resetting";
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"state poweroff");
            _stateLabel.text = @"state power off";
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"state power on");
            _stateLabel.text = @"state power on";
            break;
        default:
            break;
    }
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

@end
