//
//  CentralViewController.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/3/12.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "CentralViewController.h"

// Helpers
#import <PKRevealController/PKRevealController.h>

@interface CentralViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CentralViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"CentralViewController.title", "");
    UIButton *aboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *icon = [UIImage imageScaledFromImage:[UIImage imageNamed:@"edit"] Size:CGSizeMake(DSAdaptedValue(30), DSAdaptedValue(28))];
    [aboutButton setBackgroundImage:icon forState:UIControlStateNormal];
    [aboutButton addTarget:self action:@selector(menuButtonDidTappedAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aboutButton];
    [self setupContent];
}

- (void)setupContent {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

#pragma mark - Actions

- (void)menuButtonDidTappedAction {
    [self.revealController showViewController:self.revealController.leftViewController];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    }
    return cell;
}

#pragma mark - Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
