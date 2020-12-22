//
//  CNContactUnified.m
//  ContactSyncExample
//
//  Created by Furkan Bahceci on 8/7/20.
//  Copyright © 2020 Valven. All rights reserved.
//

#import "CNContactUnified.h"

@implementation CNContactUnified

- (instancetype)initWithCNContact:(CNContact *)cnContact local:(BOOL)local {
    self = [super init];
    if (self) {
        _cnContact = cnContact;
        _isDefault = local;
    }
    return self;
}
@end
