//
//  BaseTableViewCell.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/5.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

+ (CGFloat)rowHeight {
    return 50;
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
