//
//  SyncUtil.m
//  Depo
//
//  Created by Mahir on 25.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "SyncUtil.h"
#import "AppConstants.h"

@implementation SyncUtil

+ (NSDate *) readLastSyncDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:LAST_SYNC_DATE];
}

+ (void) writeLastSyncDate:(NSDate *) syncDate {
    [[NSUserDefaults standardUserDefaults] setObject:syncDate forKey:LAST_SYNC_DATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) updateLastSyncDate {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LAST_SYNC_DATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) cacheSyncReference:(SyncReference *) ref {
    NSArray *result = [SyncUtil readSyncReferences];
    BOOL shouldAdd = YES;
    for(SyncReference *row in result) {
        if([row.uuid isEqualToString:ref.uuid]) {
            shouldAdd = NO;
            break;
        }
    }
    if(shouldAdd) {
        NSArray *updatedArray = [result arrayByAddingObject:ref];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:updatedArray] forKey:SYNC_REF_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSArray *) readSyncReferences {
    NSArray *result = [[NSArray alloc] init];
    NSData *arrData = [[NSUserDefaults standardUserDefaults] objectForKey:SYNC_REF_KEY];
    if (arrData != nil) {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:arrData];
    }
    return result;
}

@end
