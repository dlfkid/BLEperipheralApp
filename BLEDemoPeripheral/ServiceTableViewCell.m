//
//  ServiceTableViewCell.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/7.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "ServiceTableViewCell.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ServiceTableViewCell()

@property (nonatomic, strong) UILabel *UUIDLabel;
@property (nonatomic, strong) UIView *primaryIndiCatorView;
@property (nonatomic, strong) UILabel *includedServiceCountLabel;
@property (nonatomic, strong) UILabel *characteristicCountLabel;

@end

@implementation ServiceTableViewCell

- (UIView *)primaryIndiCatorView {
    if (!_primaryIndiCatorView) {
        _primaryIndiCatorView = [[UIView alloc] initWithFrame:CGRectZero];
        _primaryIndiCatorView.layer.cornerRadius = 5;
        _primaryIndiCatorView.layer.borderWidth = 1;
        _primaryIndiCatorView.layer.borderColor = [UIColor tintColor].CGColor;
        _primaryIndiCatorView.backgroundColor = [UIColor whiteColor];
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectZero];
        text.textAlignment = NSTextAlignmentCenter;
        text.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        text.textColor = [UIColor tintColor];
        text.text = NSLocalizedString(@"ServiceTableViewCell.primaryIndicator.text", "");
        [_primaryIndiCatorView addSubview:text];
        
        [text mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(@0);
        }];
    }
    return _primaryIndiCatorView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.customContentView.backgroundColor = [UIColor whiteColor];
        self.customContentView.layer.borderWidth = .5f;
        self.customContentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.customContentView.layer.cornerRadius = 10;
        self.customContentView.layer.shadowOffset = CGSizeMake(0, 1);
        self.customContentView.layer.shadowRadius = 1;
        self.customContentView.layer.shadowOpacity = 0.4f;
        
        _UUIDLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _UUIDLabel.text = NSLocalizedString(@"ServiceTableViewCell.UUIDLabel.text", @"");
        _includedServiceCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _includedServiceCountLabel.text = NSLocalizedString(@"ServiceTableViewCell.includedServicesLabel.text", @"");
        _characteristicCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _characteristicCountLabel.text = NSLocalizedString(@"ServiceTableViewCell.characteristicLabel.text", @"");
        [self.customContentView addSubview:self.UUIDLabel];
    }
    return self;
}

- (void)updateConstraints {
    
    [self.customContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
        make.edges.mas_equalTo(0).insets(padding);
    }];
    
    [self.UUIDLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.centerX.mas_equalTo(0);
    }];
    
    [super updateConstraints];
}

#pragma mark - Actions

- (void)setService:(CBService *)service {
    _service = service;
    self.UUIDLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"ServiceTableViewCell.UUIDLabel.text", @""), service.UUID.UUIDString];
    self.includedServiceCountLabel.text = [NSString stringWithFormat:@"%@ %lu", NSLocalizedString(@"ServiceTableViewCell.includedServicesLabel.text", @""), service.includedServices.count];
    self.characteristicCountLabel.text = [NSString stringWithFormat:@"%@ %lu", NSLocalizedString(@"ServiceTableViewCell.characteristicLabel.text", @""), service.characteristics.count];
    self.primaryIndiCatorView.hidden = !service.isPrimary;
}

- (void)setUnFold:(BOOL)unFold {
    if (unFold) {
        // 展开状态布局
        [self.customContentView addSubview:self.includedServiceCountLabel];
        [self.customContentView addSubview:self.characteristicCountLabel];
        [self.customContentView addSubview:self.primaryIndiCatorView];
        
        [self.includedServiceCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.top.mas_equalTo(self.UUIDLabel.mas_bottom).mas_offset(10);
        }];
        
        [self.characteristicCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.includedServiceCountLabel.mas_right).mas_offset(10);
            make.top.mas_equalTo(self.UUIDLabel.mas_bottom).mas_offset(10);
        }];
        
        [self.primaryIndiCatorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10);
            make.centerY.mas_equalTo(0);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(35);
        }];
        
        [self.customContentView layoutIfNeeded];
    } else {
        // 折叠状态布局
        [self.UUIDLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.centerX.mas_equalTo(0);
        }];
        [self.includedServiceCountLabel removeFromSuperview];
        [self.characteristicCountLabel removeFromSuperview];
        [self.primaryIndiCatorView removeFromSuperview];
    }
}

@end