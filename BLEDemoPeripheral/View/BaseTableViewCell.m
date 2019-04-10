//
//  BaseTableViewCell.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/5.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface BaseTableViewCell()

@end

@implementation BaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _customContentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.customContentView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.customContentView.backgroundColor = [UIColor whiteColor];
        self.customContentView.layer.borderWidth = .5f;
        self.customContentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.customContentView.layer.cornerRadius = 10;
        self.customContentView.layer.shadowOffset = CGSizeMake(0, 1);
        self.customContentView.layer.shadowRadius = 1;
        self.customContentView.layer.shadowOpacity = 0.4f;
        // self.customContentView.layer.shouldRasterize = YES;
        
        _baseTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _baseSubtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.customContentView addSubview:self.baseTitleLabel];
        [self.customContentView addSubview:self.baseSubtitleLabel];
    }
    return self;
}

- (void)updateConstraints {
    [self.customContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
        make.edges.mas_equalTo(0).insets(padding);
    }];
    
    [self.baseTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(10);
        make.right.mas_equalTo(-10);
    }];
    
    [self.baseSubtitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.baseTitleLabel.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
    }];
    
    [super updateConstraints];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

+ (CGFloat)rowHeight {
    return 70;
}

+ (CGFloat)rowUnfoldHeight {
    return 110;
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
