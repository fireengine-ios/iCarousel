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
        _createdOnServer = [[dict objectForKey:@"createdOnServer"] integerValue];
        _updatedOnServer = [[dict objectForKey:@"updatedOnServer"] integerValue];
        _deletedOnServer = [[dict objectForKey:@"deletedOnServer"] integerValue];
        _onServerAtStart = [[dict objectForKey:@"onServerAtStart"] integerValue];
        _onServerAtEnd = [[dict objectForKey:@"onServerAtEnd"] integerValue];
        _mergedOnServer = SYNC_IS_NULL([dict objectForKey:@"mergedOnServer"]) ? 0 :[[dict objectForKey:@"mergedOnServer"] integerValue];
    }
    return self;
}

@end
