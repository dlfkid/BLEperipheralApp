//
//  ServiceTableViewCell.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/7.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "ServiceTableViewCell.h"

// Models
#import "ViewModel.h"
#import "DPService.h"

@interface ServiceTableViewCell()

@property (nonatomic, strong) UILabel *UUIDLabel;
@property (nonatomic, strong) UIView *primaryIndiCatorView;
@property (nonatomic, strong) UILabel *includedServiceCountLabel;
@property (nonatomic, strong) UILabel *characteristicCountLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIButton *foldButton;

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
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.centerY.mas_equalTo(0);
        }];
    }
    return _primaryIndiCatorView;
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
        
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descriptionLabel.textAlignment = NSTextAlignmentCenter;
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _descriptionLabel.textColor = [UIColor darkGrayColor];
        
        _UUIDLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _UUIDLabel.text = NSLocalizedString(@"ServiceTableViewCell.UUIDLabel.text", @"");
        _includedServiceCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _includedServiceCountLabel.text = NSLocalizedString(@"ServiceTableViewCell.includedServicesLabel.text", @"");
        _characteristicCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _characteristicCountLabel.text = NSLocalizedString(@"ServiceTableViewCell.characteristicLabel.text", @"");
        [self.customContentView addSubview:self.UUIDLabel];
        
        _unfold = NO;
        
        _foldButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_foldButton addTarget:self action:@selector(foldButtonDidTappedAction) forControlEvents:UIControlEventTouchUpInside];
        [_foldButton setImage:[UIImage imageNamed:@"up_arrow"] forState:UIControlStateNormal];
        [_foldButton setImage:[UIImage imageNamed:@"down_arrow"] forState:UIControlStateSelected];
        _foldButton.contentMode = UIViewContentModeScaleAspectFit;
        [self.customContentView addSubview:self.foldButton];
    }
    return self;
}

- (void)updateConstraints {
    
    [self.customContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
        make.edges.mas_equalTo(0).insets(padding);
    }];
    
    [self.foldButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.top.mas_equalTo(5);
        make.width.mas_equalTo([DeviceScreenAdaptor adaptedValue:32]);
        make.height.mas_equalTo([DeviceScreenAdaptor adaptedValue:32]);
    }];
    
    [self.UUIDLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.centerX.mas_equalTo(0);
    }];
    
    [super updateConstraints];
}

#pragma mark - Actions

- (void)foldButtonDidTappedAction {
    self.service.viewModel.unfold = !self.isUnfold;
    ! self.foldButtonDidTappedHandler ?: self.foldButtonDidTappedHandler(self.isUnfold);
}

- (void)setService:(DPService *)service {
    _service = service;
    self.UUIDLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"ServiceTableViewCell.UUIDLabel.text", @""), service.uuid];
    self.includedServiceCountLabel.text = [NSString stringWithFormat:@"%@ %tu", NSLocalizedString(@"ServiceTableViewCell.includedServicesLabel.text", @""), service.includedService.count];
    self.characteristicCountLabel.text = [NSString stringWithFormat:@"%@ %tu", NSLocalizedString(@"ServiceTableViewCell.characteristicLabel.text", @""), service.characters.count];
    self.primaryIndiCatorView.hidden = !service.isPrimary;
    self.descriptionLabel.text = service.descriptionText;
}

- (void)setUnfold:(BOOL)unfold {
    _unfold = unfold;
    if (_unfold) {
        // 展开状态布局
        [self.customContentView addSubview:self.includedServiceCountLabel];
        [self.customContentView addSubview:self.characteristicCountLabel];
        [self.customContentView addSubview:self.primaryIndiCatorView];
        [self.customContentView addSubview:self.descriptionLabel];
        
        [self.includedServiceCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.bottom.mas_equalTo(0).mas_offset(- 10);
        }];
        
        [self.primaryIndiCatorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-[DeviceScreenAdaptor adaptedValue:10]);
            make.centerY.mas_equalTo(0);
            make.width.mas_greaterThanOrEqualTo([DeviceScreenAdaptor adaptedValue:80]);
            make.height.mas_equalTo([DeviceScreenAdaptor adaptedValue:30]);
        }];
        
        [self.characteristicCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.includedServiceCountLabel.mas_right);
            make.bottom.mas_equalTo(self.includedServiceCountLabel.mas_top).mas_offset(-10);
        }];
        
        [self.descriptionLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.characteristicCountLabel.mas_right).mas_offset(5);
            make.right.mas_equalTo(self.primaryIndiCatorView.mas_left).offset(-5);
            make.top.mas_equalTo(self.UUIDLabel.mas_bottom).offset(10);
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
        [self.descriptionLabel removeFromSuperview];
    }
    self.foldButton.selected = _unfold;
}

+(CGFloat)rowHeight {
    return 60;
}

@end
