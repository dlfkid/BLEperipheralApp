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
#import "CBCharacteristic+StringExtensions.h"

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
        _uuidLabel.text = NSLocalizedString(@"CharacteristicTableViewCell.UUID", "");
        [self.customContentView addSubview:self.uuidLabel];
        
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLabel.textColor = [UIColor tintColor];
        _valueLabel.text = NSLocalizedString(@"CharacteristicTableViewCell.value", "");
        [self.customContentView addSubview:self.valueLabel];
        
        _propertiesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _propertiesLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        _propertiesLabel.textColor = [UIColor brownColor];
        _propertiesLabel.text = NSLocalizedString(@"CharacteristicTableViewCell.property", "");
        [self.customContentView addSubview:self.propertiesLabel];
        
    }
    return self;
}

- (void)updateConstraints {
    
    [self.uuidLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(10);
        make.right.mas_equalTo(-10);
    }];
    
    [self.propertiesLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-10);
        make.left.mas_equalTo(10);
    }];
    
    [self.valueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(0);
    }];
    
    [super updateConstraints];
}


- (void)setCharacter:(CBCharacteristic *)character {
    _character = character;
    
    NSString *properties = [CBCharacteristic propertiesString:character.properties];
    self.propertiesLabel.text = [properties stringByAppendingFormat:@" %@", properties];
}

+ (CGFloat)rowHeight {
    return 90;
}

@end
