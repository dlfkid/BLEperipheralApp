//
//  StatusBarView.m
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/3/24.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "StatusBarView.h"

#import <Masonry/Masonry.h>
#import <pop/POP.h>
#import <UIExtensionKit/UIColor+UIExtensionKit.h>

@interface StatusBarView()

@property (nonatomic, assign) StatusBarPosition position;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation StatusBarView

- (instancetype)initWithPosition:(StatusBarPosition)position Frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithR:0 G:0 B:0 Alpha:0.7];
        _position = position;
        _messageLabel = [[UILabel alloc] initWithFrame:frame];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        _messageLabel.numberOfLines = 0;
        [self addSubview:self.messageLabel];
    }
    return self;
}

- (void)updateConstraints {
    
    [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [super updateConstraints];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 30);
}

- (void)showWithMessage:(NSString *)message {
    if (!self.superview) {
        return;
    }
    self.hidden = NO;
    self.messageLabel.text = message;
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    if (self.position == StatusBarPositionTop) {
        animation.toValue = @(self.intrinsicContentSize.height / 2);
    } else if (self.position == StatusBarPositionBottom) {
        CGFloat superViewHeight = self.superview.frame.size.height;
        animation.toValue = @(superViewHeight - self.intrinsicContentSize.height / 2);
    }
    
    [self.layer pop_addAnimation:animation forKey:@"showUp"];
}

- (void)hide {
    if (!self.superview) {
        return;
    }
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    if (self.position == StatusBarPositionTop) {
        animation.toValue = @(- self.intrinsicContentSize.height / 2);
    } else if (self.position == StatusBarPositionBottom) {
        CGFloat superViewHeight = self.superview.frame.size.height;
        animation.toValue = @(superViewHeight + self.intrinsicContentSize.height / 2);
    }
    [animation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        self.hidden = YES;
    }];
    [self.layer pop_addAnimation:animation forKey:@"hide"];
}

- (void)showWithMessage:(NSString *)message ForSeconds:(NSTimeInterval)seconds {
    [self showWithMessage:message];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self hide];
    });
}

- (void)reframe {
    if (!self.superview) {
        return;
    }
    CGFloat superViewOriginX = self.superview.frame.origin.x;
    CGFloat superViewOriginY = self.superview.frame.origin.y;
    CGFloat superViewSizeWidth = self.superview.frame.size.width;
    CGFloat superViewSizeHeight = self.superview.frame.size.height;
    if (self.position == StatusBarPositionTop) {
        self.frame = CGRectMake(superViewOriginX, superViewOriginY - self.intrinsicContentSize.height, superViewSizeWidth, self.intrinsicContentSize.height);
    } else if (self.position == StatusBarPositionBottom) {
        self.frame = CGRectMake(superViewOriginX, superViewOriginY + superViewSizeHeight, superViewSizeWidth, self.intrinsicContentSize.height);
    }
}

@end
