//
//  BaseViewController.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/1.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "BaseViewController.h"


@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNavigationBar];
}


- (void)setNavigationBar {
    // 1、设置视图背景颜色
    // self.view.backgroundColor = [UIColor tintColor];
    // 2、设置导航栏标题属性：设置标题颜色
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    // 3、设置导航栏前景色：设置item指示色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    // 4、设置导航栏半透明
    self.navigationController.navigationBar.translucent = true;
    // 5、设置导航栏背景图片
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor tintColor]]
                                                  forBarMetrics: UIBarMetricsDefault];
    // 6、设置导航栏阴影图片
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

@end
