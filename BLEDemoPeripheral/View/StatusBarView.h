//
//  StatusBarView.h
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/3/24.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, StatusBarPosition) {
    StatusBarPositionTop,
    StatusBarPositionBottom,
};

@interface StatusBarView : UIView

- (instancetype)initWithPosition:(StatusBarPosition)position Frame:(CGRect)frame;

- (void)reframe;

- (void)showWithMessage:(NSString *)message;

- (void)hide;

- (void)showWithMessage:(NSString *)message ForSeconds:(NSTimeInterval)seconds;

@end

NS_ASSUME_NONNULL_END
