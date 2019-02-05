//
//  BaseTableViewCell.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/5.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseTableViewCell : UITableViewCell

+ (CGFloat)rowHeight;

+ (NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
