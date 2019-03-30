//
//  CentralServiceTableViewCell.m
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/3/30.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "CentralServiceTableViewCell.h"

// Views
#import "BaseTableViewCell.h"
#import "CentralCharacteristicTableViewCell.h"

// Models
#import <CoreBluetooth/CBService.h>
#import <CoreBluetooth/CBCharacteristic.h>

@interface CentralServiceTableViewCell()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong, readonly) NSArray <CBCharacteristic *> *characters;
@property (nonatomic, strong, readonly) NSArray <CBService *> *includedServices;

@end

@implementation CentralServiceTableViewCell

- (NSArray<CBCharacteristic *> *)characters {
    return _service.characteristics;
}

- (NSArray<CBService *> *)includedServices {
    return _service.includedServices;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView registerClass:[BaseTableViewCell class] forCellReuseIdentifier:kdefaultTableViewCellReuseIdentifier];
        [_tableView registerClass:[CentralCharacteristicTableViewCell class] forCellReuseIdentifier:[CentralCharacteristicTableViewCell reuseIdentifier]];
        [_tableView registerClass:[CentralServiceTableViewCell class] forCellReuseIdentifier:[CentralServiceTableViewCell reuseIdentifier]];
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kdefaultTableViewHeaderReuseIdentifier];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [self.customContentView addSubview:self.tableView];
        
    }
    return self;
}

- (void)updateConstraints {
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(10);
    }];
    
    [super updateConstraints];
}

#pragma mark - Action

#pragma mark - TableViewDelegate



#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3; // 第1组展示UUID，是否主要服务;第2组展示所有特征;第3组展示所有子服务;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
        
        case 1:
            return self.characters.count;
        
        case 2:
            return self.includedServices.count;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1: {
            CentralCharacteristicTableViewCell *characterCell = [tableView dequeueReusableCellWithIdentifier:[CentralCharacteristicTableViewCell reuseIdentifier] forIndexPath:indexPath];
            return characterCell;
        }
            break;
         
        case 2: {
            CentralServiceTableViewCell *serviceCell = [tableView dequeueReusableCellWithIdentifier:[CentralServiceTableViewCell reuseIdentifier] forIndexPath:indexPath];
            return serviceCell;
        }
            break;
            
        default: {
            BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kdefaultTableViewCellReuseIdentifier forIndexPath:indexPath];
            return cell;
        }
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kdefaultTableViewHeaderReuseIdentifier];
    return header;
}

@end

