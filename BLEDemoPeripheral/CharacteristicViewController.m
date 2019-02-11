//
//  CharacteristicViewController.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/11.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "CharacteristicViewController.h"

// Helpers
#import <CoreBluetooth/CBCharacteristic.h>

@interface CharacteristicViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CBCharacteristicProperties *currentProperties;
@property (nonatomic, assign) CBAttributePermissions *currentPermissions;

@end

@implementation CharacteristicViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kdefaultTableViewCellReuseIdentifier forIndexPath:indexPath];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kdefaultTableViewHeaderReuseIdentifier];
    return view;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
