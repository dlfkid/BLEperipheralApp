//
//  PeripheralTableViewCell.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/3/12.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "PeripheralTableViewCell.h"

// Models
#import <CoreBluetooth/CBPeripheral.h>

@interface PeripheralTableViewCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitileLabel;
@property (nonatomic, strong) UILabel *stateLabel;

@end

@implementation PeripheralTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.peripheral addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.customContentView.backgroundColor = [UIColor whiteColor];
        self.customContentView.layer.borderWidth = .5f;
        self.customContentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.customContentView.layer.cornerRadius = 10;
        self.customContentView.layer.shadowOffset = CGSizeMake(0, 1);
        self.customContentView.layer.shadowRadius = 1;
        self.customContentView.layer.shadowOpacity = 0.4f;
        
        _titleLabel = [[UILabel alloc] initWithFrame: CGRectZero];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.customContentView addSubview:self.titleLabel];
        
        _subTitileLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subTitileLabel.numberOfLines = 0;
        _subTitileLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _subTitileLabel.textColor = [UIColor tintColor];
        _subTitileLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        [self.customContentView addSubview:self.subTitileLabel];
        
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        [self.customContentView addSubview:self.stateLabel];
    }
    return self;
}

- (void)updateConstraints {
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(DSAdaptedValue(10));
    }];
    
    [self.subTitileLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(10);
    }];
    
    [self.stateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(0);
    }];
    
    
    [super updateConstraints];
}

- (void)setPeripheral:(CBPeripheral *)peripheral {
    _peripheral = peripheral;
    self.titleLabel.text = peripheral.name;
    self.subTitileLabel.text = peripheral.identifier.UUIDString;
    self.stateLabel.text = [PeripheralTableViewCell peripheralStateString:peripheral.state];
    if (peripheral.state == CBPeripheralStateConnected) {
        self.stateLabel.textColor = [UIColor greenColor];
    } else if (peripheral.state == CBPeripheralStateDisconnected) {
        self.stateLabel.textColor = [UIColor redColor];
    } else {
        self.stateLabel.textColor = [UIColor lightGrayColor];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        switch (self.peripheral.state) {
                
            default:
                break;
        }
    }
}

+ (CGFloat)rowHeight {
    return 60;
}

+ (NSString *)peripheralStateString:(CBPeripheralState)state {
    switch (state) {
        case CBPeripheralStateConnected:
            return NSLocalizedString(@"CBPeripheralState.connected", "");
            
        case CBPeripheralStateConnecting:
            return NSLocalizedString(@"CBPeripheralState.connecting", "");
        
        case CBPeripheralStateDisconnected:
            return NSLocalizedString(@"CBPeripheralState.disconnected", "");
        
        case CBPeripheralStateDisconnecting:
            return NSLocalizedString(@"CBPeripheralState.disconnecting", "");
    }
}


@end
