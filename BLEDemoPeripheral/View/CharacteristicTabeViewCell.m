//
//  Characteristic.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/5.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "CharacteristicTabeViewCell.h"

// Model
#import "DPCharacteristic.h"
#import "ViewModel.h"

// Helpers
#import "CBCharacteristic+StringExtensions.h"

@interface CharacteristicTabeViewCell()

@property (nonatomic, strong) UILabel *UUIDLabel;
@property (nonatomic, strong) UIView *notifyView;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *propertyLabel;
@property (nonatomic, strong) UIButton *foldButton;

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
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.centerY.mas_equalTo(0);
        }];
    }
    return _notifyView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
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
        _foldButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_foldButton addTarget:self action:@selector(foldButtonDidTappedAction) forControlEvents:UIControlEventTouchUpInside];
        [_foldButton setImage:[UIImage imageNamed:@"up_arrow"] forState:UIControlStateNormal];
        [_foldButton setImage:[UIImage imageNamed:@"down_arrow"] forState:UIControlStateSelected];
        _foldButton.contentMode = UIViewContentModeScaleAspectFit;
        [self.customContentView addSubview:self.foldButton];
        [self.customContentView addSubview:self.UUIDLabel];
    }
    return self;
}

- (void)updateConstraints {
    
    [self.UUIDLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.centerX.mas_equalTo(0);
    }];
    
    [self.foldButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.top.mas_equalTo(5);
        make.width.mas_equalTo(32);
        make.height.mas_equalTo(32);
    }];
    
    [super updateConstraints];
}

+(CGFloat)rowHeight {
    return 60;
}

- (void)foldButtonDidTappedAction {
    self.characteristic.viewModel.unfold = !self.isUnFold;
    ! self.foldButtonDidTappedHandler ?: self.foldButtonDidTappedHandler(!self.foldButton.isSelected);
}

- (void)setCharacteristic:(DPCharacteristic *)characteristic {
    _characteristic = characteristic;
    NSString *uuidText = NSLocalizedString(@"CharacteristicTableViewCell.UUID", "");
    self.UUIDLabel.text = [uuidText stringByAppendingFormat:@" %@", characteristic.uuid];
    NSString *propertyText = NSLocalizedString(@"CharacteristicTableViewCell.property", "");
    NSString *properties = [CBCharacteristic propertiesString:self.characteristic.properties];
    self.propertyLabel.text = [propertyText stringByAppendingFormat:@" %@", properties];
    
    NSString *valueText = NSLocalizedString(@"CharacteristicTableViewCell.value", "");
    NSString *valueString = characteristic.value;
    if (!characteristic.value) {
        valueString = @"nil";
    }
    self.valueLabel.text = [valueText stringByAppendingFormat:@" %@", valueString];
    
    self.notifyView.hidden = !self.characteristic.isReadOnly;
}

- (void)setUnFold:(BOOL)unFold {
    _unFold = unFold;
    if (_unFold) {
        // 展开状态布局
        [self.customContentView addSubview:self.propertyLabel];
        [self.customContentView addSubview:self.valueLabel];
        [self.customContentView addSubview:self.notifyView];
        
        [self.valueLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.UUIDLabel.mas_bottom).mas_offset(5);
            make.left.mas_equalTo(self.foldButton.mas_right).offset(10);
        }];
        
        [self.propertyLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(0).mas_offset(- 10);
        }];
        
        [self.notifyView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10);
            make.centerY.mas_equalTo(0);
            make.width.mas_greaterThanOrEqualTo(80);
            make.height.mas_equalTo(30);
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
    self.foldButton.selected = _unFold;
}

@end
