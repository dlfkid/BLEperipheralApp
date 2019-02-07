//
//  BaseTableViewCell.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/5.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _customContentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.customContentView];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

+ (CGFloat)rowHeight {
    return 50;
}

+ (CGFloat)rowUnfoldHeight {
    return 90;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
