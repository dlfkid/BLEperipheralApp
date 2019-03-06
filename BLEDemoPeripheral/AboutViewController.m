//
//  AboutViewController.m
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/3/6.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "AboutViewController.h"

#import <iOSDeviceScreenAdapter/DeviceScreenAdaptor.h>

@interface AboutViewController ()

@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) UILabel *appNameLabel;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UILabel *buildLabel;
@property (nonatomic, strong) UILabel *autherLabel;

@end

@implementation AboutViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"AboutViewController.title", "");
    [self setupContent];
}

- (void)setupContent {
    _logoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.logoImageView];
    
    _appNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _appNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.appNameLabel];
    
    _versionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _versionLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.versionLabel];
    
    _buildLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _buildLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.buildLabel];
    
    _autherLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _autherLabel.textAlignment = NSTextAlignmentCenter;
    _autherLabel.textColor = [UIColor lightGrayColor];
    _autherLabel.numberOfLines = 0;
    _autherLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _autherLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    [self.view addSubview:self.autherLabel];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.size.mas_equalTo(DSAdaptedValue(100));
        make.centerY.mas_equalTo(- 50);
    }];
    
    [self.appNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.logoImageView.mas_bottom).mas_offset(10);
        make.centerX.mas_equalTo(0);
    }];
    
    [self.versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.appNameLabel.mas_bottom).mas_offset(10);
        make.right.mas_equalTo(self.view.mas_centerX).mas_offset(-10);
    }];
    
    [self.buildLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.appNameLabel.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.view.mas_centerX).mas_offset(10);
    }];
    
    [self.autherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(- 10).mas_offset(- DSBottomMargin);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Actions

@end
