//
//  AbstractHelper.h
//  ContactSyncExample
//
//  Created by Furkan Bahceci on 14.01.2020.
//  Copyright © 2020 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PartialInfo.h"
#import "SyncSettings.h"
#import "Contact.h"
#import "Utils.h"
#import "ContactDevice.h"
#import "ContactAddress.h"
#import "SyncStatus.h"
#import "ContactUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface AbstractHelper : NSObject

@property (strong) PartialInfo *partialInfo;

- (SYNCMode*)getMode;
- (NSMutableDictionary*)mergeContacts:(NSArray*)contactList;
- (NSArray*)deviceAnalyze:(NSDictionary*)nameMap firstCheck:(BOOL)firstCheck;
- (void)setDeviceAndAddress:(Contact*)contact;
- (void)mergeDetail:(Contact*)masterContact contact:(Contact*)contact;

@end

NS_ASSUME_NONNULL_END
