//
//  CentralCharacteristicTableViewCell.m
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/3/30.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "CentralCharacteristicTableViewCell.h"

// Models
#import <CoreBluetooth/CBCharacteristic.h>

// Helpers
#import <UIColor+UIExtensionKit.h>

@interface CentralCharacteristicTableViewCell()

@property (nonatomic, strong) UILabel *uuidLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *propertiesLabel;

@end

@implementation CentralCharacteristicTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _uuidLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _uuidLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        [self.customContentView addSubview:self.uuidLabel];
        
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLabel.textColor = [UIColor tintColor];
        [self.customContentView addSubview:self.valueLabel];
        
        _propertiesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _propertiesLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        _propertiesLabel.textColor = [UIColor brownColor];
        [self.customContentView addSubview:self.propertiesLabel];
        
    }
    return self;
}

- (void)updateConstraints {
    
    [super updateConstraints];
}


- (void)setCharacter:(CBCharacteristic *)character {
    _character = character;
}

@end
