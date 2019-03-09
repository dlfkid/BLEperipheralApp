//
//  Constants.h
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/8.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

static NSString * const kdefaultTableViewCellReuseIdentifier = @"com.GitHub.BLEDemoPeripheral.tableViewCell";
static NSString * const kdefaultTableViewHeaderReuseIdentifier = @"com.GitHub.BLEDemoPeripheral.tableViewHeader";

/** 获取APP名称 */
#define APP_NAME ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"])

/** 程序版本号 */
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

/** 获取APP build版本 */
#define APP_BUILD ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])

#endif /* Constants_h */
