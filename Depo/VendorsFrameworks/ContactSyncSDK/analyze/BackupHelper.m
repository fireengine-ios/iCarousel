//
//  BackupHelper.m
//  ContactSyncExample
//
//  Created by Furkan Bahceci on 14.01.2020.
//  Copyright © 2020 Valven. All rights reserved.
//

#import "BackupHelper.h"

@implementation BackupHelper

- (SYNCMode *)getMode {
    return SYNCBackup;
}

- (NSArray *)startAnalyze:(NSArray *)contactList {
    SYNC_Log(@"startAnalyze");
    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_ANALYZE progress: 0];
    NSDictionary* nameMap = [self mergeContacts:contactList];
    
    NSArray* result = [self deviceAnalyze:nameMap firstCheck:true];
    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_ANALYZE progress: 100];
    return result;
}

@end
