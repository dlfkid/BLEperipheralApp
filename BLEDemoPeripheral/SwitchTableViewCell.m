//
//  SwitchTableViewCell.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/13.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "SwitchTableViewCell.h"

@interface SwitchTableViewCell()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation SwitchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:self.titleLabel];
        
        _switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_switchControl addTarget:self action:@selector(switchValueDidChangedAction) forControlEvents:UIControlEventValueChanged];
        _switchControl.onTintColor = [UIColor tintColor];
        [self.contentView addSubview:self.switchControl];
    }
    return self;
}

-(void)updateConstraints {
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(@0);
        make.left.mas_equalTo(20);
    }];
    
    [self.switchControl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
    }];
    
    [super updateConstraints];
}

#pragma mark - Actions

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)switchValueDidChangedAction {
    !self.switchValueDidChangedHandler ?: self.switchValueDidChangedHandler(self.switchControl.isOn);
}

@end
