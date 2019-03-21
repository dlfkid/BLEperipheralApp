//
//  CBCharacteristic+StringExtensions.m
//  BLEDemoPeripheral
//
//  Created by LeonDeng on 2019/2/11.
//  Copyright © 2019 Ivan_deng. All rights reserved.
//

#import "CBCharacteristic+StringExtensions.h"

#import <UIExtensionKit/NSString+UIKitExtension.h>

@implementation CBCharacteristic (StringExtensions)

+ (NSString *)propertiesString:(CBCharacteristicProperties)properties {
    NSString *result = @"";
    if (properties & CBCharacteristicPropertyRead) {
        result = [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.read", "")];
    }
    if (properties & CBCharacteristicPropertyWrite) {
        result = [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.write", "")];
    }
    if (properties & CBCharacteristicPropertyNotify) {
        result = [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.notify", "")];
    }
    if (properties & CBCharacteristicPropertyIndicate) {
        result = [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.indicate", "")];
    }
    if (properties & CBCharacteristicPropertyBroadcast) {
        result = [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.boardcast", "")];
    }
    if (properties & CBCharacteristicPropertyExtendedProperties) {
        result = [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.extendedProperties", "")];
    }
    if (properties & CBCharacteristicPropertyWriteWithoutResponse) {
        result = [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.writeWithoutResponse", "")];
    }
    if (properties & CBCharacteristicPropertyNotifyEncryptionRequired) {
        result = [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.notifyEncryptionRequired", "")];
    }
    if (properties & CBCharacteristicPropertyAuthenticatedSignedWrites) {
        result = [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.authendicatedSignedWrite", "")];
    }
    if (properties & CBCharacteristicPropertyIndicateEncryptionRequired) {
        result = [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.propperty.indicateEncryptionRequired", "")];
    }
    return result;
}

+ (NSString *)permissionString:(CBAttributePermissions)permissions {
    NSString *result = @"";
    if (permissions & CBAttributePermissionsReadable) {
        result = [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.permission.readable", "")];
    }
    if (permissions & CBAttributePermissionsWriteable) {
        result = [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.permission.writeable", "")];
    }
    if (permissions & CBAttributePermissionsReadEncryptionRequired) {
        result = [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.permission.readEncryptionRequired", "")];
    }
    if (permissions & CBAttributePermissionsWriteEncryptionRequired) {
        result = [result stringByAppendingFormat:@"%@, ", NSLocalizedString(@"Characteristic.permission.writeEncryptionRequired", "")];
    }
    return result;
}

+ (NSString *)uuidValid:(NSString *)UUIDString {
    NSString *sample = [NSString hexStringWithString:UUIDString];
    return sample.length < 4 ? sample : [sample substringWithRange:NSMakeRange(0, 4)];
}

@end
