//
//  RestoreHelper.h
//  ContactSyncExample
//
//  Created by Furkan Bahceci on 15.01.2020.
//  Copyright © 2020 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractHelper.h"
#import "SyncSettings.h"

NS_ASSUME_NONNULL_BEGIN

@interface RestoreHelper : AbstractHelper

- (void)startAnalyze:(NSDictionary*)remoteContacts;

@end

NS_ASSUME_NONNULL_END
