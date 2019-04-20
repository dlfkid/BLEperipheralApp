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
#import "SwitchTableViewCell.h"

// Models
#import <CoreBluetooth/CBService.h>
#import <CoreBluetooth/CBCharacteristic.h>
#import <CoreBluetooth/CBUUID.h>

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

- (void)dealloc {
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView registerClass:[SwitchTableViewCell class] forCellReuseIdentifier:[SwitchTableViewCell reuseIdentifier]];
        [_tableView registerClass:[BaseTableViewCell class] forCellReuseIdentifier:kdefaultTableViewCellReuseIdentifier];
        [_tableView registerClass:[CentralCharacteristicTableViewCell class] forCellReuseIdentifier:[CentralCharacteristicTableViewCell reuseIdentifier]];
        [_tableView registerClass:[CentralServiceTableViewCell class] forCellReuseIdentifier:[CentralServiceTableViewCell reuseIdentifier]];
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kdefaultTableViewHeaderReuseIdentifier];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.customContentView addSubview:self.tableView];
        // 监听TableView的内容高度改变自身高度
        [self.tableView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
    }
    return self;
}

- (void)updateConstraints {
    self.tableView.mas_key = @"mas_key: TableViewEdges";
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.inset(10);
    }];
    
    [super updateConstraints];
}

#pragma mark - Action

- (void)setService:(CBService *)service {
    _service = service;
    [self.tableView reloadData];
}

#pragma mark - TableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [BaseTableViewCell rowHeight];
    } else if (indexPath.section == 1) {
        return [CentralCharacteristicTableViewCell rowHeight];
    } else {
        return [CentralServiceTableViewCell rowHeight];
    }
}

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
            characterCell.character = self.characters[indexPath.row];
            return characterCell;
        }
            break;
         
        case 2: {
            CentralServiceTableViewCell *serviceCell = [tableView dequeueReusableCellWithIdentifier:[CentralServiceTableViewCell reuseIdentifier] forIndexPath:indexPath];
            serviceCell.service = self.includedServices[indexPath.row];
            return serviceCell;
        }
            break;
            
        default: {
            if (indexPath.row == 0) {
                BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kdefaultTableViewCellReuseIdentifier forIndexPath:indexPath];
                cell.baseTitleLabel.text = NSLocalizedString(@"CoreBlueTableViewCell.UUID.alert.text", "");
                cell.baseSubtitleLabel.text = self.service.UUID.UUIDString;
                cell.baseSubtitleLabel.textColor = [UIColor lightGrayColor];
                cell.baseSubtitleLabel.numberOfLines = 0;
                cell.baseSubtitleLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
                return cell;
            } else {
                SwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[SwitchTableViewCell reuseIdentifier]];
                cell.title = NSLocalizedString(@"ServiceViewController.table.cell.primary", "");
                cell.switchControl.on = self.service.isPrimary;
                cell.switchControl.enabled = NO;
                return cell;
            }
        }
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kdefaultTableViewHeaderReuseIdentifier];
    if (section == 0) {
        header.textLabel.text = NSLocalizedString(@"CoreBlueTableViewCell.header.info", "");
    } else if (section == 1) {
        header.textLabel.text = NSLocalizedString(@"ServiceTableViewCell.characteristicLabel.text", "");
    } else {
        header.textLabel.text = NSLocalizedString(@"ServiceTableViewCell.includedServicesLabel.text", "");
    }
    return header;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    CGRect frame = self.tableView.frame;
    frame.size = self.tableView.contentSize;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_greaterThanOrEqualTo(frame.size.height);
    }];
    [self layoutIfNeeded];
}

@end

