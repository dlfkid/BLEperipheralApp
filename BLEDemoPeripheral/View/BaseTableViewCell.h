//
//  BaseTableViewCell.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/5.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import <UIColor+UIExtensionKit.h>
#import <iOSDeviceScreenAdapter/DeviceScreenAdaptor.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *customContentView;
@property (nonatomic, strong) UILabel *baseTitleLabel;
@property (nonatomic, strong) UILabel *baseSubtitleLabel;

+ (CGFloat)rowHeight;

+ (CGFloat)rowUnfoldHeight;

+ (NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
