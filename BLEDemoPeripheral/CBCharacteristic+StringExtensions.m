//
//  CBCharacteristic+StringExtensions.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/11.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "CBCharacteristic+StringExtensions.h"

@implementation CBCharacteristic (StringExtensions)

+ (NSString *)propertiesString:(CBCharacteristicProperties)properties {
    NSString *result = @"";
    if (properties & CBCharacteristicPropertyRead) {
        [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.read", "")];
    }
    if (properties & CBCharacteristicPropertyWrite) {
        [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.write", "")];
    }
    if (properties & CBCharacteristicPropertyNotify) {
        [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.notify", "")];
    }
    if (properties & CBCharacteristicPropertyIndicate) {
        [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.indicate", "")];
    }
    if (properties & CBCharacteristicPropertyBroadcast) {
        [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.boardcast", "")];
    }
    if (properties & CBCharacteristicPropertyExtendedProperties) {
        [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.extendedProperties", "")];
    }
    if (properties & CBCharacteristicPropertyWriteWithoutResponse) {
        [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.writeWithoutResponse", "")];
    }
    if (properties & CBCharacteristicPropertyNotifyEncryptionRequired) {
        [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.notifyEncryptionRequired", "")];
    }
    if (properties & CBCharacteristicPropertyAuthenticatedSignedWrites) {
        [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.authendicatedSignedWrite", "")];
    }
    if (properties & CBCharacteristicPropertyIndicateEncryptionRequired) {
        [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.indicateEncryptionRequired", "")];
    }
    return result;
}

+ (NSString *)permissionString:(CBAttributePermissions)permissions {
    NSString *result = @"";
    if (permissions & CBAttributePermissionsReadable) {
        [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.permission.readable", "")];
    }
    if (permissions & CBAttributePermissionsWriteable) {
        [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.permission.writeable", "")];
    }
    if (permissions & CBAttributePermissionsReadEncryptionRequired) {
        [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.permission.readEncryptionRequired", "")];
    }
    if (permissions & CBAttributePermissionsWriteEncryptionRequired) {
        [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.permission.writeEncryptionRequired", "")];
    }
    return result;
}

@end
