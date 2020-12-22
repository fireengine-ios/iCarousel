//
//  BackupStats.m
//  ContactSyncExample
//
//  Created by Mehmet Serdar Bicer on 29.10.2018.
//  Copyright © 2018 Valven. All rights reserved.
//

#import "BackupStats.h"

@implementation BackupStats

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self){
        _key = [dict objectForKey:@"key"];
        _mode = [@"BACKUP" isEqualToString:[dict objectForKey:@"operation"]] ? SYNCBackup : SYNCRestore;
        _createdOnServer = SYNC_IS_NULL([dict objectForKey:@"createdOnServer"]) ? 0: [[dict objectForKey:@"createdOnServer"] integerValue];
        _updatedOnServer = SYNC_IS_NULL([dict objectForKey:@"updatedOnServer"]) ? 0: [[dict objectForKey:@"updatedOnServer"] integerValue];
        _deletedOnServer = SYNC_IS_NULL([dict objectForKey:@"deletedOnServer"]) ? 0: [[dict objectForKey:@"deletedOnServer"] integerValue];
        _onServerAtStart = SYNC_IS_NULL([dict objectForKey:@"onServerAtStart"]) ? 0: [[dict objectForKey:@"onServerAtStart"] integerValue];
        _onServerAtEnd = SYNC_IS_NULL([dict objectForKey:@"onServerAtEnd"]) ? 0: [[dict objectForKey:@"onServerAtEnd"] integerValue];
        _mergedOnServer = SYNC_IS_NULL([dict objectForKey:@"mergedOnServer"]) ? 0 :[[dict objectForKey:@"mergedOnServer"] integerValue];
    }
    return self;
}

@end
