//
//  SideMenuViewController.m
//  BLEDemoPeripheral
//
//  Created by Ivan_deng on 2019/3/11.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "SideMenuViewController.h"

// Controller
#import <PKRevealController/PKRevealController.h>
#import "MainViewController.h"

// Models
#import "ViewModel.h"

@interface SideMenuViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <ViewModel *> *optionModels;

@end

@implementation SideMenuViewController

#pragma mark - LifeCycle

+ (instancetype)sharedMenuController {
    static SideMenuViewController *sharedMenueInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMenueInstance = [[self alloc] init];
    });
    return sharedMenueInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        ViewModel * (^generateOptionModelHandler)(NSString *title, dispatch_block_t block) = ^(NSString *title, dispatch_block_t block) {
            ViewModel *model = [[ViewModel alloc] init];
            model.title = title;
            model.didSelectedHandler = block;
            return model;
        };
        
        _optionModels = @[generateOptionModelHandler(NSLocalizedString(@"SideMenuViewController.option.peripheral", ""), ^(void){ [self performSelector:@selector(showBLEPeripheralViewController) withObject:nil afterDelay:0]; }),
                          generateOptionModelHandler(NSLocalizedString(@"SideMenuViewController.option.central", ""), ^(void){ [self performSelector:@selector(showBLECentralViewController) withObject:nil afterDelay:0]; }),
                          generateOptionModelHandler(NSLocalizedString(@"SideMenuViewController.option.about", ""), ^(void){ [self performSelector:@selector(showAboutViewController) withObject:nil afterDelay:0]; })
                           ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"SideMenuViewController.title", "");
    [self setupContent];
}

- (void)setupContent {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kdefaultTableViewCellReuseIdentifier];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(DSStatusBarMargin + 44);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}



#pragma mark - Actions

+ (void)showAboutViewController {
    NSLog(@"Showing about viewController");
}

+ (void)showBLEPeripheralViewController {
    NSLog(@"Showing Peripheral viewController");
}

+ (void)showBLECentralViewController {
    NSLog(@"Show Central viewController");
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.optionModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kdefaultTableViewCellReuseIdentifier forIndexPath:indexPath];
    ViewModel *model = self.optionModels[indexPath.row];
    cell.textLabel.text = model.title;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor tintColor];
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ViewModel *model = self.optionModels[indexPath.row];
    model.didSelectedHandler();
}


@end
