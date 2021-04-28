//
//  BackupStats.h
//  ContactSyncExample
//
//  Created by Mehmet Serdar Bicer on 29.10.2018.
//  Copyright © 2018 Valven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncSettings.h"

@interface BackupStats : NSObject

@property NSString *key;
@property SYNCMode mode;


@property NSInteger createdOnServer;
@property NSInteger updatedOnServer;
@property NSInteger deletedOnServer;
@property NSInteger onServerAtStart;
@property NSInteger onServerAtEnd;
@property NSInteger mergedOnServer;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
