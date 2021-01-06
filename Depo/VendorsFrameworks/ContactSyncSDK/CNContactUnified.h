//
//  CNContactUnified.h
//  ContactSyncExample
//
//  Created by Furkan Bahceci on 8/7/20.
//  Copyright © 2020 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>

NS_ASSUME_NONNULL_BEGIN

@interface CNContactUnified : NSObject

@property (strong) CNContact *cnContact;
@property BOOL isDefault;

- (instancetype)initWithCNContact:(CNContact *)cnContact local:(BOOL)local;

@end

NS_ASSUME_NONNULL_END
