//
//  Characteristic.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/5.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "CharacteristicTabeViewCell.h"

// Helpers
#import <CoreBluetooth/CoreBluetooth.h>

@interface CharacteristicTabeViewCell()

@property (nonatomic, strong) UILabel *UUIDLabel;
@property (nonatomic, strong) UIView *notifyView;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *propertyLabel;

@end

@implementation CharacteristicTabeViewCell

- (UIView *)notifyView {
    if (!_notifyView) {
        _notifyView = [[UIView alloc] initWithFrame:CGRectZero];
        _notifyView.layer.cornerRadius = 5;
        _notifyView.layer.borderWidth = 1;
        _notifyView.layer.borderColor = [UIColor tintColor].CGColor;
        _notifyView.backgroundColor = [UIColor whiteColor];
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectZero];
        text.textAlignment = NSTextAlignmentCenter;
        text.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        text.textColor = [UIColor tintColor];
        text.text = NSLocalizedString(@"CharacteristicTableViewCell.notifyView.text", "");
        [_notifyView addSubview:text];
        
        [text mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(@0);
        }];
    }
    return _notifyView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.customContentView.backgroundColor = [UIColor whiteColor];
        self.customContentView.layer.borderWidth = .5f;
        self.customContentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.customContentView.layer.cornerRadius = 10;
        self.customContentView.layer.shadowOffset = CGSizeMake(0, 1);
        self.customContentView.layer.shadowRadius = 1;
        self.customContentView.layer.shadowOpacity = 0.4f;
        
        _UUIDLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _UUIDLabel.textAlignment = NSTextAlignmentCenter;
        _UUIDLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        _UUIDLabel.text = NSLocalizedString(@"CharacteristicTableViewCell.UUID", "");
        
        _propertyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _propertyLabel.textColor = [UIColor brownColor];
        _propertyLabel.text = NSLocalizedString(@"CharacteristicTableViewCell.property", "");
        _propertyLabel.numberOfLines = 0;
        _propertyLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _propertyLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.textColor = [UIColor lightGrayColor];
        _valueLabel.text = NSLocalizedString(@"CharacteristicTableViewCell.value", "");
        
        [self.customContentView addSubview:self.UUIDLabel];
        [self.customContentView addSubview:self.notifyView];
        [self.customContentView addSubview:self.propertyLabel];
        [self.customContentView addSubview:self.valueLabel];
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

+(CGFloat)rowHeight {
    return 60;
}

- (void)setCharacteristic:(CBCharacteristic *)characteristic {
    _characteristic = characteristic;
    NSString *uuidText = NSLocalizedString(@"CharacteristicTableViewCell.UUID", "");
    self.UUIDLabel.text = [uuidText stringByAppendingFormat:@" %@", characteristic.UUID.UUIDString];
    NSString *propertyText = NSLocalizedString(@"CharacteristicTableViewCell.property", "");
    NSString *properties = [self propertiesString:characteristic.properties];
    self.propertyLabel.text = [propertyText stringByAppendingFormat:@" %@", properties];
    NSString *valueText = NSLocalizedString(@"CharacteristicTableViewCell.value", "");
    NSString *valueString = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    self.valueLabel.text = [valueText stringByAppendingFormat:@" %@", valueString];
    self.notifyView.hidden = !characteristic.isNotifying;
}

- (NSString *)propertiesString:(CBCharacteristicProperties)properties {
    NSString *result = @"";
    if (properties & CBCharacteristicPropertyRead) {
        [result stringByAppendingFormat:@"%@", NSLocalizedString(@"Characteristic.propperty.read", "")];
    }
    if (properties & CBCharacteristicPropertyWrite) {
        [result stringByAppendingFormat:@", %@", NSLocalizedString(@"Characteristic.propperty.write", "")];
    }
    if (properties & CBCharacteristicPropertyNotify) {
        [result stringByAppendingFormat:@", %@", NSLocalizedString(@"Characteristic.propperty.notify", "")];
    }
    if (properties & CBCharacteristicPropertyIndicate) {
        [result stringByAppendingFormat:@", %@", NSLocalizedString(@"Characteristic.propperty.indicate", "")];
    }
    if (properties & CBCharacteristicPropertyBroadcast) {
        [result stringByAppendingFormat:@", %@", NSLocalizedString(@"Characteristic.propperty.boardcast", "")];
    }
    if (properties & CBCharacteristicPropertyExtendedProperties) {
        [result stringByAppendingFormat:@", %@", NSLocalizedString(@"Characteristic.propperty.extendedProperties", "")];
    }
    if (properties & CBCharacteristicPropertyWriteWithoutResponse) {
        [result stringByAppendingFormat:@", %@", NSLocalizedString(@"Characteristic.propperty.writeWithoutResponse", "")];
    }
    if (properties & CBCharacteristicPropertyNotifyEncryptionRequired) {
        [result stringByAppendingFormat:@", %@", NSLocalizedString(@"Characteristic.propperty.notifyEncryptionRequired", "")];
    }
    if (properties & CBCharacteristicPropertyAuthenticatedSignedWrites) {
        [result stringByAppendingFormat:@", %@", NSLocalizedString(@"Characteristic.propperty.authendicatedSignedWrite", "")];
    }
    if (properties & CBCharacteristicPropertyIndicateEncryptionRequired) {
        [result stringByAppendingFormat:@", %@", NSLocalizedString(@"Characteristic.propperty.indicateEncryptionRequired", "")];
    }
    return result;
}

- (void)setUnFold:(BOOL)unFold {
    if (unFold) {
        // 展开状态布局
        [self.customContentView addSubview:self.propertyLabel];
        [self.customContentView addSubview:self.valueLabel];
        [self.customContentView addSubview:self.notifyView];
        
        [self.valueLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.top.mas_equalTo(self.UUIDLabel.mas_bottom).mas_offset(10);
        }];
        
        [self.propertyLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.valueLabel.mas_right).mas_offset(10);
            make.top.mas_equalTo(self.UUIDLabel.mas_bottom).mas_offset(10);
        }];
        
        [self.notifyView mas_updateConstraints:^(MASConstraintMaker *make) {
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
        [self.valueLabel removeFromSuperview];
        [self.propertyLabel removeFromSuperview];
        [self.notifyView removeFromSuperview];
    }
}

@end
