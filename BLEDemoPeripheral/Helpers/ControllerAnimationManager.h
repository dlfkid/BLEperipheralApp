//
//  ControllerAnimationManager.h
//  newBLEcentralDemo
//
//  Created by LeonDeng on 2019/1/19.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

@class SubViewController;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ControllerAnimationManager : NSObject

@property (nonatomic, strong, nullable) UIViewController *baseViewController;
@property (nonatomic, strong, nullable) UIViewController *showingViewController;

+ (ControllerAnimationManager *)sharedManager;

+ (void)popUp:(UIViewController *)popingViewController
     WithViewSize:(CGSize)size
inViewConrtroller:(UIViewController *)controller;

- (void)hideViewController;

@end

NS_ASSUME_NONNULL_END
