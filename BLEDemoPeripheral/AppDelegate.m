//
//  AppDelegate.m
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2017/8/7.
//  Copyright © 2017年 Ivan_deng. All rights reserved.
//

#import "AppDelegate.h"

// Controllers
#import <PKRevealController/PKRevealController.h>
#import "MainViewController.h"
#import "SideMenuViewController.h"

// Helpers
#import <UIExtensionKit/UIColor+UIExtensionKit.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <iOSDeviceScreenAdapter/DeviceScreenAdaptor.h>
#import "DataBaseManager.h"
#import <SVProgressHUD/SVProgressHUD.h>



@interface AppDelegate () <PKRevealing>

@property (nonatomic, strong, readwrite) PKRevealController *revealController;

@end

@implementation AppDelegate

#warning TODO: Finish peripheral VC and make characteristic writeable;
#warning TODO: When centralManager switch off was detected, empty all peripheral cells;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 初始化数据库
    [[DataBaseManager sharedDataBaseManager] dataBaseInitialization];
    
    // 设置开发者屏幕型号
    [[DeviceScreenAdaptor sharedAdaptor] setDeveloperScreenType:DeviceScreenType5_5];
    
    // 设置Tost显示时间
    [SVProgressHUD setMaximumDismissTimeInterval:3];
    
    // 设置侧滑菜单和主菜单
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    MainViewController *main = [[MainViewController alloc]init];
    UINavigationController *frontViewController = [[UINavigationController alloc]initWithRootViewController:main];
    
    SideMenuViewController *left = [SideMenuViewController sharedMenuController];
    UINavigationController *leftViewController = [[UINavigationController alloc] initWithRootViewController:left];
    
    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontViewController leftViewController:leftViewController];
    
    self.revealController.delegate = self;
    self.revealController.animationDuration = 0.25;
    [self.revealController setMinimumWidth:[SideMenuViewController sideMenuWidth] maximumWidth:[SideMenuViewController sideMenuWidth] forViewController:leftViewController];
    
    self.window.rootViewController = self.revealController;
    [self.window makeKeyAndVisible];
    // 设置主色调
    [UIColor setTintColor:[UIColor colorWithR:57.f G:98.f B:153.f]];
    // 激活智能键盘
    [IQKeyboardManager sharedManager].enable = YES;
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - PKRevealingDelegate

- (void)revealController:(PKRevealController *)revealController didChangeToState:(PKRevealControllerState)state {
    // NSLog(@"%@ (%d)", NSStringFromSelector(_cmd), (int)state);
}

- (void)revealController:(PKRevealController *)revealController willChangeToState:(PKRevealControllerState)next {
//    PKRevealControllerState current = revealController.state;
//    NSLog(@"%@ (%d -> %d)", NSStringFromSelector(_cmd), (int)current, (int)next);
}

@end
