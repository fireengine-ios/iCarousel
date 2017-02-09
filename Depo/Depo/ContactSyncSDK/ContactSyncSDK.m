//
//  ContactSyncSDK.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "ContactSyncSDK.h"
#import "ContactUtil.h"
#import "SyncConstants.h"

@interface SyncHelper : NSObject


/*
 * Backup Values
 */
@property (strong) NSMutableSet *deletedLocalContactRemoteIds;
@property (strong) NSMutableSet *remoteUpdatedContactRemoteIds;
@property (strong) NSMutableDictionary *dirtyRemoteContacts;    // ObjectID(LocalID), Contact


/*
 * Restore Values
 */
@property (strong) NSMutableDictionary *modifiedContactIds;     // localid, remoteid
@property (strong) NSMutableDictionary *deletedContactIds;      // localid, remoteid
@property (strong) NSMutableDictionary *createdLocalContacts;   // ObjectID(LocalID), Contact

/*
 * Backup and Restore shared value.
 */
@property (strong) NSMutableSet *localContactIds;
@property (strong) NSString *deviceId;

@property SYNCMode mode;
@property (strong) SyncDBUtils *db;
@property long long lastSync;
@property BOOL startNewSync;

@property NSString *updateId;
@property NSInteger initialContactCount;


- (void)startSyncing:(SYNCMode)mode;
- (BOOL)isRunning;

@end

@interface ContactSyncSDK ()

@property SYNCMode mode;
+ (SYNC_INSTANCETYPE) shared;
+ (void)setLastSyncTime:(NSNumber*)time;

@end

@implementation SyncHelper

static bool syncing = false;

- (instancetype) init
{
    self = [super init];
    if (self){
        _db = [SyncDBUtils shared];
    }    
    return self;
}

- (void)startSyncing:(SYNCMode)mode
{
    if (syncing){
        return;
    }
    syncing = true;
    
    [[SyncStatus shared] reset];
    [[SyncLogger shared] startLogging:
     [NSString stringWithFormat:@"%@-%@",[SyncSettings shared].token,[@(mode) stringValue]]];
    
    [[ContactUtil shared] reset];
    self.initialContactCount = -1;
    self.updateId = nil;
    
    self.remoteUpdatedContactRemoteIds = [NSMutableSet new];
    self.localContactIds = [NSMutableSet new];
    self.mode = mode;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.updateId = [defaults objectForKey:SYNC_KEY_CHECK_UPDATE];
    
    /*
     * deviceID check. If it is not in the defaults then generate and save it into the deafults.
     */
    self.deviceId = [defaults objectForKey:SYNC_DEVICE_ID];
    if( SYNC_IS_NULL(_deviceId) ){
        _deviceId = [NSMutableString stringWithString:[[NSUUID UUID] UUIDString] ];
        [defaults setObject:_deviceId forKey:SYNC_DEVICE_ID];
        [defaults synchronize];
    }
    SYNC_Log(@"UUID [Device ID]:%@", _deviceId);
    
    if (!SYNC_IS_NULL(self.updateId)){
        _startNewSync = YES;
        if(_mode == SYNCRestore)
            [self checkProgressStatusForRestore];
        else
            [self checkProgressStatusForBackup];
        return;
    }
    
    /*
     * MSISDN value should be defined here. checkStatus request msisdn value.
     */
    [SyncAdapter checkStatus:@"x" callback:^(id response, BOOL isSuccess) {
        SYNC_Log(@"Msisdn: %@", [[SyncSettings shared] msisdn]);
        
        self.lastSync = [[ContactSyncSDK lastSyncTime] longLongValue];
        
        if(_mode == SYNCRestore)
            [self fetchLocalContactsForRestore];
        else
            [self getUpdatedContactsFromServerForBackup];
    }];

}

- (BOOL)isRunning
{
    return syncing;
}

- (void)fetchLocalContactsForBackup
{
    self.dirtyRemoteContacts = [NSMutableDictionary new];
    self.deletedLocalContactRemoteIds = [NSMutableSet new];
    
    SYNC_Log(@"Before BACKUP");
    [[ContactUtil shared] printContacts];
    
    NSMutableArray *contacts = [[ContactUtil shared] fetchContacts];
    self.initialContactCount = [contacts count];
    if (!SYNC_IS_NULL(contacts) && [contacts count]>0){
        for (Contact *contact in contacts){
            if (!SYNC_IS_NULL(contact) && ![_localContactIds containsObject:[contact objectId]]){
                // localContactIds is used to find removed contacts from phone using "NOT IN" in local database.
                [_localContactIds addObject:[contact objectId]];
                SyncRecord *rec =[_db isRecorded:contact];  // Is the record in the local database? If record is exist then add add remoteId into the contact.
                    if ( !SYNC_IS_NULL(rec) ){  // Is the record in the local database?
                        if( [_remoteUpdatedContactRemoteIds containsObject:contact.remoteId]
                           || _lastSync == 0
                           || [[ContactSyncSDK lastSyncTime] longLongValue] == 0)
                        {   // Is the contact in the _remoteUpdatedContactRemoteIds list or server ( "_lastSync" ) or phone ( "[[ContactSyncSDK lastSyncTime] longLongValue] " ) timestamp value is equal to zero. If it is then delete. _lastSync stores the timestamp value of the remoteUpdatedContact result's.
                            if (!SYNC_IS_NULL(contact.remoteId)) {
                                [_remoteUpdatedContactRemoteIds removeObject:contact.remoteId];
                                SYNC_Log(@"Contact remoteID is removed from remoteUpdatedContactRemoteIds:%@", contact.remoteId);
                            }
                            [[ContactUtil shared] fetchNumbers:contact];
                            [[ContactUtil shared] fetchEmails:contact];
                            [_dirtyRemoteContacts setObject:contact forKey:[contact objectId]];
                            SYNC_Log(@"Dirty Contact (1): %@ RemoteId:%@ LocalId:%@ localUpdate:%@ remoteUpdate:%@", [contact displayName], [contact remoteId], [contact objectId], [contact localUpdateDate], [contact remoteUpdateDate]);

                        }
                        else{
                            if ([contact.localUpdateDate longLongValue] > [rec.localUpdateDate longLongValue]){
                                /*
                                 * Fetch devices to calculate md5 hash. Not only localupdate time but also check hash value to understand change
                                 */
                                [[ContactUtil shared] fetchNumbers:contact];
                                [[ContactUtil shared] fetchEmails:contact];
                                NSString *checksum = [contact toMD5];
                                if (![checksum isEqualToString:rec.checksum]){
                                    [_dirtyRemoteContacts setObject:contact forKey:[contact objectId]];
                                    SYNC_Log(@"Dirty Contact (2): %@ RemoteId:%@ LocalId:%@ contact.localUpdate:%@ rec.localUpdate:%@", [contact displayName], [contact remoteId], [contact objectId], [contact localUpdateDate], [rec localUpdateDate]);
                                
                                } else {
                                    /*
                                     * Update timestamp to prevent contact for being a dirty contact.
                                     */
                                    rec.localUpdateDate = contact.localUpdateDate;
                                    [_db save:rec status:UPDATED_CONTACT];
                                }
                            }
                        }
                    }
                    else{   // Contact is not in the local database.
                        if (!SYNC_IS_NULL(contact.remoteId)) {
                            [_remoteUpdatedContactRemoteIds removeObject:contact.remoteId];
                            SYNC_Log(@"Contact remoteID is removed from remoteUpdatedContactRemoteIds:%@", contact.remoteId);
                        }
                        [[ContactUtil shared] fetchNumbers:contact];
                        [[ContactUtil shared] fetchEmails:contact];
                        if (contact.hasName || contact.hasPhoneNumber){
                            [_dirtyRemoteContacts setObject:contact forKey:[contact objectId]];
                            SYNC_Log(@"Dirty Contact (3): %@ RemoteId:%@ LocalId:%@ localUpdate:%@ remoteUpdate:%@", [contact displayName], [contact remoteId], [contact objectId], [contact localUpdateDate], [contact remoteUpdateDate]);
                        } else { //ignore contact if it has neither name nor phone number
                            SYNC_Log(@"Ignore Contact : %@ RemoteId:%@ LocalId:%@ localUpdate:%@ remoteUpdate:%@", [contact displayName], [contact remoteId], [contact objectId], [contact localUpdateDate], [contact remoteUpdateDate]);
                            [_localContactIds removeObject:[contact objectId]];
                        }
                    }
            }
        }
    }
    _deletedLocalContactRemoteIds = [NSMutableSet setWithSet:_remoteUpdatedContactRemoteIds];
    [self findDeletedRecordsForBackup];
}

- (void)fetchLocalContactsForRestore
{
    self.modifiedContactIds = [NSMutableDictionary new];
    self.deletedContactIds = [NSMutableDictionary new];
    self.createdLocalContacts = [NSMutableDictionary new];
    
        SYNC_Log(@"Before RESTORE");
        [[ContactUtil shared] printContacts];
        [[SyncDBUtils shared] printRecords];
        

        NSMutableArray *contacts = [[ContactUtil shared] fetchContacts];
        self.initialContactCount = [contacts count];
        if (!SYNC_IS_NULL(contacts) && [contacts count]>0){
            for (Contact *contact in contacts){
                
                if (!SYNC_IS_NULL(contact) && ![_localContactIds containsObject:[contact objectId]]){
                    [_localContactIds addObject:[contact objectId]];    // localContactIds is used to find removed contacts from phone using "NOT IN" in local database.
                    SyncRecord *rec =[_db isRecorded:contact]; // Is the record in the local database? If record is exist then add add remoteId into the contact.
                    if ( SYNC_IS_NULL(rec) ){   // Is the record in the local database?
                        SYNC_Log(@"Record not exists : %@",[contact objectId]);
                        /*
                         * Contact is not in the local database.
                         */
                        [[ContactUtil shared] fetchNumbers:contact];
                        [[ContactUtil shared] fetchEmails:contact];
                        if (contact.hasName || contact.hasPhoneNumber){
                            [_createdLocalContacts setObject:contact forKey:contact.objectId];
                        } else { //ignore contact if it has neither name nor phone number
                            SYNC_Log(@"Ignore contact : %@",[contact objectId]);
                            [_localContactIds removeObject:[contact objectId]];
                        }
                        
                    }
                    else{
                        /*
                         * Contact is in the local database.
                         */
                        
                        if ([contact.localUpdateDate longLongValue] > [rec.localUpdateDate longLongValue]){
                            /*
                             * Fetch devices to calculate md5 hash. Not only localupdate time but also check hash value to understand change
                             */
                            [[ContactUtil shared] fetchNumbers:contact];
                            [[ContactUtil shared] fetchEmails:contact];
                            NSString *checksum = [contact toMD5];
                            if ( ![checksum isEqualToString:rec.checksum]){
                                SYNC_Log(@"modifiedContactIds : %@ %@ => %@ %@ %@ %@",rec.remoteId,rec.localId,contact.localUpdateDate,rec.localUpdateDate, checksum, rec.checksum);
                                [_modifiedContactIds setObject:rec.remoteId forKey:rec.localId];
                            } else {
                                /*
                                 * Update timestamp to prevent contact for being a dirty contact.
                                 */
                                rec.localUpdateDate = contact.localUpdateDate;
                                [_db save:rec status:UPDATED_CONTACT];
                            }

                        }
                    }
                    
                }
            }
        }
        [self findDeletedRecordsRestore];

}

/*
 * According to timestamp and deviceId get the updated remote contact ids from server and
 * store them in _remoteUpdatedContactIds which is a NSMutableSet.
 */
- (void)getUpdatedContactsFromServerForBackup
{
        [SyncAdapter getUpdatedContacts:[ContactSyncSDK lastSyncTime] deviceId:_deviceId callback:^(id response, BOOL success) {
            if (success){
                NSDictionary *data = response[SYNC_JSON_PARAM_DATA];
                NSArray *updatedList = data[SYNC_JSON_PARAM_UPDATED];
                NSNumber *lastSyncTime = data[SYNC_JSON_PARAP_SERVER_TIMESTAMP];
                [self setLastSync:lastSyncTime.longLongValue];
                for (NSArray *updatedRemoteID in updatedList){
                    if(![_remoteUpdatedContactRemoteIds containsObject:updatedRemoteID]){
                        [_remoteUpdatedContactRemoteIds addObject:updatedRemoteID];
                    }
                }
                [self fetchLocalContactsForBackup];
            } else {
                [self endOfSyncCycle:response==nil?SYNC_RESULT_ERROR_REMOTE_SERVER:SYNC_RESULT_ERROR_NETWORK];
            }
        }];
}


- (void)findDeletedRecordsForBackup
{
    /*
     * Delete rows from SQL which were deleted in remote
     */
    NSString *idList = [[_localContactIds allObjects] componentsJoinedByString:@","];
    NSArray *records = [_db fetch:[NSString stringWithFormat:@"%@ NOT IN (%@)", COLUMN_LOCAL_ID, idList]];
    for (SyncRecord *record in records){
        [_deletedLocalContactRemoteIds addObject:record.remoteId];
    }
    
    for(NSNumber *objectID in _dirtyRemoteContacts){
        Contact *contact = [_dirtyRemoteContacts objectForKey:objectID];
        if( [_deletedLocalContactRemoteIds containsObject:contact.remoteId] ){  // It will return Yes or No
            [_dirtyRemoteContacts removeObjectForKey:contact.objectId];
        }
    }
    [self submitDirtyRecordsForBackup];
}


- (void)findDeletedRecordsRestore
{
    /*
     * Delete rows from SQL which were deleted in remote
     */
    NSString *idList = [[_localContactIds allObjects] componentsJoinedByString:@","];
    NSArray *records = [_db fetch:[NSString stringWithFormat:@"%@ NOT IN (%@)", COLUMN_LOCAL_ID, idList]];
    for (SyncRecord *record in records){
        [_deletedContactIds setObject:record.remoteId forKey:record.localId];
    }
    [self submitDirtyRecordsForRestore];

}

- (void)submitDirtyRecordsForRestore
{
    NSArray *deletedContactIDs = [_deletedContactIds allValues];    // remoteIDs
    SYNC_Log(@"Deleted Contacts: %@", deletedContactIDs);

    NSArray *updatedContactIDs = [_modifiedContactIds allValues];   // remoteIDs
    SYNC_Log(@"Updated Contacts: %@", updatedContactIDs);
    
    NSArray *newContacts = [_createdLocalContacts allValues];       // Contact
    /*
     * Debugging
     */
    NSMutableArray *array = [NSMutableArray new];
    for (Contact *c in newContacts){
        [array addObject:[c toJSON:false]];
    }
    SYNC_Log(@"New Contacts: %@", array);
    
    NSArray *modifiedContactIDs = [deletedContactIDs arrayByAddingObjectsFromArray:updatedContactIDs];
    
    [SyncAdapter restoreContactsWithTimestamp:[[ContactSyncSDK lastSyncTime] longLongValue] deviceId:_deviceId modifiedContactIDs:modifiedContactIDs newContacts:newContacts callback:^(id response, BOOL isSuccess) {
        if (isSuccess){
            NSMutableArray *storeDeleted = [NSMutableArray new];
            for(NSString *objectID in [_deletedContactIds allKeys]){
                [storeDeleted addObject:objectID];
            }
            
            NSMutableArray *storeUpdated = [NSMutableArray new];
            for(NSString *objectID in [_modifiedContactIds allKeys]){
                [storeUpdated addObject:objectID];
            }
            

            NSString *data = response[SYNC_JSON_PARAM_DATA];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if(!SYNC_IS_NULL(data) || ![data isEqualToString:@""])
                [defaults setObject:data forKey:SYNC_KEY_CHECK_UPDATE];
            if(!SYNC_IS_NULL(storeDeleted) || [storeDeleted count] != 0)
                [defaults setObject:storeDeleted forKey:SYNC_KEY_CONTACT_STORE_DELETED];
            if(!SYNC_IS_NULL(storeUpdated) || [storeUpdated count] != 0)
                [defaults setObject:storeUpdated forKey:SYNC_KEY_CONTACT_STORE_UPDATED];
            [defaults synchronize];
            [self checkProgressStatusForRestore];
        } else {
            syncing = false;
            [self endOfSyncCycle:response==nil?SYNC_RESULT_ERROR_REMOTE_SERVER:SYNC_RESULT_ERROR_NETWORK];
        }
    }];
}

- (void)submitDirtyRecordsForBackup
{
    NSArray *dirtyContacts = [_dirtyRemoteContacts allValues];
    NSMutableArray *array = [NSMutableArray new];
    for (Contact *c in dirtyContacts){
        [array addObject:[c toJSON:false]];
    }
    SYNC_Log(@"Dirty Contacts: %@", array);
    
    NSArray *deletedContacts = [_deletedLocalContactRemoteIds allObjects];
    SYNC_Log(@"Deleted Contacts: %@", deletedContacts);
    
    [SyncAdapter backupContactsWithDeviceId:_deviceId dirtyContacts:dirtyContacts deletedContacts:deletedContacts callback:^(id response, BOOL isSuccess) {
        if (isSuccess){
            NSMutableArray *storeDirty = [NSMutableArray new];
            for (Contact *c in dirtyContacts){
                [storeDirty addObject:c.objectId];
            }
            NSMutableArray *storeDeleted = [NSMutableArray new];
            for (NSNumber *c in deletedContacts){
                [storeDeleted addObject:c];
            }
            
            NSString *data = response[SYNC_JSON_PARAM_DATA];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if(!SYNC_IS_NULL(data) || ![data isEqualToString:@""] )
                [defaults setObject:data forKey:SYNC_KEY_CHECK_UPDATE];
            if(!SYNC_IS_NULL(storeDirty) || [storeDirty count] != 0)
                [defaults setObject:storeDirty forKey:SYNC_KEY_CONTACT_STORE_DIRTY];
            if(!SYNC_IS_NULL(storeDeleted) || [storeDeleted count] != 0)
                [defaults setObject:storeDeleted forKey:SYNC_KEY_CONTACT_STORE_DELETED];
            [defaults synchronize];
            [self checkProgressStatusForBackup];
        } else {
            syncing = false;
            [self endOfSyncCycle:response==nil?SYNC_RESULT_ERROR_REMOTE_SERVER:SYNC_RESULT_ERROR_NETWORK];
        }
    }];
}

- (NSMutableDictionary *)restoreRecordsFromUserDefaultsForRestore
{
    if (self.initialContactCount<0){
        self.initialContactCount = [[ContactUtil shared] getContactCount];
    }
    NSMutableArray *storeModifiedIDs = [NSMutableArray new];
        
    NSArray *updatedContactsIDs = [_modifiedContactIds allKeys];
    if (SYNC_IS_NULL(updatedContactsIDs) || [updatedContactsIDs count] == 0 ){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        updatedContactsIDs = [defaults objectForKey:SYNC_KEY_CONTACT_STORE_UPDATED];
        if( SYNC_IS_NULL(updatedContactsIDs) ){
            updatedContactsIDs = [NSMutableArray new];
        }
    }
    [storeModifiedIDs addObjectsFromArray:updatedContactsIDs];
    
    NSArray *deletedContactsIDs = [_deletedContactIds allKeys];
    if (SYNC_IS_NULL(deletedContactsIDs) || [deletedContactsIDs count] == 0){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *storeDeleted = [defaults objectForKey:SYNC_KEY_CONTACT_STORE_DELETED];
        if( !SYNC_IS_NULL(storeDeleted) ){
            [storeModifiedIDs addObjectsFromArray:storeDeleted];
        }
    }
    else{
        [storeModifiedIDs addObjectsFromArray:deletedContactsIDs];
    }
    
    NSMutableArray *toBeDeleted = [NSMutableArray new];
    NSMutableDictionary *contacts = [NSMutableDictionary new];
    for(NSNumber *objectId in storeModifiedIDs){
        Contact *c = [[ContactUtil shared] findContactById:objectId];
        if(SYNC_IS_NULL(c)){
            [toBeDeleted addObject:objectId];
        }
        
        NSArray *records = [_db fetch:[NSString stringWithFormat:@"%@=%@",COLUMN_LOCAL_ID,objectId]];
        if (!SYNC_ARRAY_IS_NULL_OR_EMPTY(records)){
            SyncRecord *record = records[0];
            if(!SYNC_IS_NULL(c)){
                c.remoteId = record.remoteId;
                [contacts setObject:c forKey:record.remoteId];
            }
            else{
                [contacts setObject:[NSNull null] forKey:record.remoteId];
            }

        }
    }
    [_db deleteRecords:toBeDeleted];
    return contacts;
}

- (NSArray*)restoreRecordsFromUserDefaultsForBackup:(NSString *)restore
{
    if (self.initialContactCount<0){
        self.initialContactCount = [[ContactUtil shared] getContactCount];
    }
    
    if([restore isEqualToString:SYNC_KEY_CONTACT_STORE_DIRTY]){
        /*
         * Return stored dirty contacts
         */
        if (SYNC_IS_NULL(_dirtyRemoteContacts) || [_dirtyRemoteContacts count] == 0 ){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSArray *storeDirty = [defaults objectForKey:SYNC_KEY_CONTACT_STORE_DIRTY];
            if (SYNC_IS_NULL(storeDirty)){
                return [NSArray new];
            }
            else {
                NSMutableArray *array = [NSMutableArray new];
                for(NSNumber *objectId in storeDirty){
                    Contact *c = [[ContactUtil shared] findContactById:objectId];
                    if(SYNC_IS_NULL(c)){
                        c = [Contact new];
                        c.objectId = objectId;
                    }

                    [array addObject:c];
                }
                return [array copy];
            }
        }
        else{
            return [_dirtyRemoteContacts allValues];
        }
    }
    else if([restore isEqualToString:SYNC_KEY_CONTACT_STORE_DELETED]){
        /*
         * Return stored deleted contacts
         */
        if (SYNC_IS_NULL(_deletedLocalContactRemoteIds) || [_deletedLocalContactRemoteIds count] == 0){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSArray *storeDeleted = [defaults objectForKey:SYNC_KEY_CONTACT_STORE_DELETED];
            if( SYNC_IS_NULL(storeDeleted) ){
                return [NSArray new];
            }
            else {
                return [storeDeleted copy];
            }
        }
        else{
            return [[_deletedLocalContactRemoteIds allObjects] copy];
        }
    }
    return nil;
}

-(void)checkProgressStatusForBackup{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.updateId = [defaults objectForKey:SYNC_KEY_CHECK_UPDATE];
    
    [SyncAdapter checkStatus:self.updateId callback:^(id response, BOOL isSuccess) {
        if (isSuccess && !SYNC_IS_NULL(response)){
            NSDictionary *data = response[SYNC_JSON_PARAM_DATA];
            if (SYNC_IS_NULL(data)){
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_DIRTY];
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_DELETED];
                [defaults removeObjectForKey:SYNC_KEY_CHECK_UPDATE];
                [defaults synchronize];
                
                [self endOfSyncCycle:SYNC_RESULT_ERROR_NETWORK];
                return;
            }
            NSString *status = data[@"status"];
            if ([@"COMPLETED" isEqualToString:status]){
                NSArray *contactsDirty = [self restoreRecordsFromUserDefaultsForBackup:SYNC_KEY_CONTACT_STORE_DIRTY];
                NSArray *contactsDeleted = [self restoreRecordsFromUserDefaultsForBackup:SYNC_KEY_CONTACT_STORE_DELETED];
                
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_DIRTY];
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_DELETED];
                [defaults removeObjectForKey:SYNC_KEY_CHECK_UPDATE];
                [defaults synchronize];
                
                NSNumber *timestamp = data[@"timestamp"];
                NSString *resultString = data[@"result"];
                NSData *data = [resultString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                SYNC_Log(@"Results:%@", result);
                
                NSArray *remoteIDs = result[@"result"];
                if (SYNC_IS_NULL(remoteIDs)){
                    [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER];
                    SYNC_Log(@"There is an error in API.");
                    return;
                }
                
                NSDictionary *stats = result[@"stats"];
                SYNC_Log(@"Remote IDs:%@ ", remoteIDs);
                
                if ([contactsDeleted count]>0){
                    [_db deleteRecordsWithIDs:contactsDeleted where:COLUMN_REMOTE_ID];
                }
                
                /*
                 * If Program only stores the SYNC_KEY_CHECK_UPDATE value and not SYNC_KEY_CONTACT_STORE_DIRTY and SYNC_KEY_CONTACT_STORE_DELETED then it will crash because of
                 * Contact *c = contactsDirty[i]; line. So check the count of the remoteIds and count of the contactsDirty if they are not equal then error.
                 */
                if ([remoteIDs count] != [contactsDirty count]){
                    [self endOfSyncCycle:SYNC_RESULT_ERROR_INTERNAL];
                    SYNC_Log(@"There is an internal error. The program will try again.");
                    return;
                }
                
                NSDate *now = [NSDate date];
                
                NSUInteger remoteIdsCount = 0;
                if(!SYNC_IS_NULL(remoteIDs))
                    remoteIdsCount = [remoteIDs count];
                
                for (int i=0;i<remoteIdsCount;i++){      // Update Remote IDs.
                    NSNumber *item = remoteIDs[i];
                    if (!SYNC_NUMBER_IS_NULL_OR_ZERO(item)){
                        Contact *c = contactsDirty[i];
                        c.remoteId = item;
                        
                        [_db deleteRecord:c.objectId];

                        SyncRecord *record = [SyncRecord new];
                        record.localId = c.objectId;
                        record.remoteId = c.remoteId;
                        record.localUpdateDate = SYNC_DATE_AS_NUMBER(now);
                        record.remoteUpdateDate = timestamp;

                        NSString *checksum = [c toMD5];
                        record.checksum = checksum;
                        SYNC_Log(@"Backup MD5 %@ %@", [c toStringValue], checksum);
                        SYNC_Log(@"Save record : %@ %@ %@ %@",record.localId, record.remoteId, record.localUpdateDate, record.remoteUpdateDate);

                        [_db save:record];
                    }
                }
                
                NSNumber *created = stats[@"created"];
                NSNumber *deleted = stats[@"deleted"];
                NSNumber *updated = stats[@"updated"];
                
                [[SyncStatus shared] addEmpty:created state:SYNC_INFO_NEW_CONTACT_ON_SERVER];
                [[SyncStatus shared] addEmpty:deleted state:SYNC_INFO_DELETED_ON_SERVER];
                [[SyncStatus shared] addEmpty:updated state:SYNC_INFO_UPDATED_ON_SERVER];

                if (!SYNC_NUMBER_IS_NULL_OR_ZERO(timestamp)){
                    [ContactSyncSDK setLastSyncTime:timestamp]; // Store client last sync time
                }
                
                SYNC_Log(@"After processing BACKUP");
                [[ContactUtil shared] printContacts];
                
                [self endOfSyncCycle:SYNC_RESULT_SUCCESS];
            } else if ([@"ERROR" isEqualToString:data[@"status"]]) {
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_DELETED];
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_UPDATED];
                [defaults removeObjectForKey:SYNC_KEY_CHECK_UPDATE];
                [defaults synchronize];
                
                if (SYNC_IS_NULL(data[@"result"])){
                    [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER];
                } else {
                    NSString *resultString = data[@"result"];
                    NSData *data = [resultString dataUsingEncoding:NSUTF8StringEncoding];
                    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                    [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER messages:result];
                }
            } else {
                [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkProgressStatusForBackup) userInfo:nil repeats:NO];
            }
        } else {
            [self endOfSyncCycle:response==nil?SYNC_RESULT_ERROR_REMOTE_SERVER:SYNC_RESULT_ERROR_NETWORK];
        }
    }];
    
}

- (void)checkProgressStatusForRestore
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.updateId = [defaults objectForKey:SYNC_KEY_CHECK_UPDATE];
    
    [SyncAdapter checkStatus:self.updateId callback:^(id response, BOOL isSuccess) {
        if (isSuccess && !SYNC_IS_NULL(response)){
            NSDictionary *data = response[SYNC_JSON_PARAM_DATA];
            if (SYNC_IS_NULL(data)){
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_DELETED];
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_UPDATED];
                [defaults removeObjectForKey:SYNC_KEY_CHECK_UPDATE];
                [defaults synchronize];
                
                [self endOfSyncCycle:SYNC_RESULT_ERROR_NETWORK];
                return;
            }
            NSString *status = data[@"status"];
            if ([@"COMPLETED" isEqualToString:status]){
                SYNC_Log(@"Before processing RESTORE");
                [[ContactUtil shared] printContacts];
                
                // Our modified list which contains deleted and updated contacts. The dictionary keys are RemoteIDs and values are contacts.
                NSDictionary *modifiedContacts = [self restoreRecordsFromUserDefaultsForRestore];   // remoteID, Contact
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_DELETED];
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_UPDATED];
                [defaults removeObjectForKey:SYNC_KEY_CHECK_UPDATE];
                [defaults synchronize];
                
                NSNumber *timestamp = data[@"timestamp"];
                NSString *resultString = data[@"result"];
                NSData *dataResultOut = [resultString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *resultOut = [NSJSONSerialization JSONObjectWithData:dataResultOut options:0 error:nil];
                SYNC_Log(@"Results:%@", resultOut);
                
                NSArray *allRecords = [_db fetch];
                //fetch records from database and cache them
                NSMutableDictionary *recordSet = [NSMutableDictionary new]; // remoteID, dbRecord
                if (!SYNC_ARRAY_IS_NULL_OR_EMPTY(allRecords)){
                    for (SyncRecord *rec in allRecords){
                        if (!SYNC_IS_NULL(rec.remoteId))
                            SYNC_SET_DICT_IF_NOT_NIL(recordSet, rec, rec.remoteId);
                    }
                }
                
                NSMutableArray *newRecords = [NSMutableArray new];
                NSDate *now;
                for (NSDictionary *item in resultOut[@"result"]){
                    Contact *remoteContact = [[Contact alloc] initWithDictionary:item];
                    SYNCContactStatus contactStatus;
                    
                    //Find remote updated contact object in local device.
                    Contact *localContact;
                    
                    SyncRecord *rec = [recordSet objectForKey:remoteContact.remoteId];
                    
                    if( !SYNC_IS_NULL([modifiedContacts objectForKey:remoteContact.remoteId]) ){
                        contactStatus = UPDATED_CONTACT;
                        localContact = [modifiedContacts objectForKey:remoteContact.remoteId];
                        [[ContactUtil shared] fetchEmails:localContact];
                        [[ContactUtil shared] fetchNumbers:localContact];
                    }
                    else if ( !SYNC_IS_NULL(rec) ){
                        contactStatus = UPDATED_CONTACT;
                        localContact = [[ContactUtil shared] findContactById:rec.localId];
                        [[ContactUtil shared] fetchEmails:localContact];
                        [[ContactUtil shared] fetchNumbers:localContact];
                    }
                    else{
                        contactStatus = NEW_CONTACT;
                        localContact = [Contact new];
                    }

                    

                    if (!SYNC_IS_NULL(localContact)){
                        if (!SYNC_ARRAY_IS_NULL_OR_EMPTY(localContact.devices)){
                            NSMutableArray *toBeDeleted = [NSMutableArray new];
                            for (int i=0;i<[localContact.devices count];){
                                ContactDevice *device = localContact.devices[i];
                                if (![remoteContact.devices containsObject:device]){
                                    SYNC_Log(@"Device %@ %@ not found in remote", device.value, [device deviceTypeLabel]);
                                    [toBeDeleted addObject:device];
                                    [localContact.devices removeObject:device];
                                } else {
                                    i++;
                                }
                            }
                            // delete devices that are not in remote
                            [[ContactUtil shared] deleteContact:localContact.objectId devices:toBeDeleted];
                        }
                        else{
                            localContact.devices = [NSMutableArray new];
                        }
                        
                        [localContact copyContact:remoteContact];
                        [[ContactUtil shared] save:localContact];
                        now = [NSDate date];    // Keep the current time to save it local database.
                        SYNC_Log(@" : First:%@ Last:%@ RemoteID:%@", localContact.firstName, localContact.lastName, remoteContact.remoteId);
                        
                        
                        /*
                         * Save contact information into the local database too.
                         */
                        SyncRecord *record = [SyncRecord new];
                        //record.localId = localContact.objectId; // There is no localId for that contact. The localId will be created at the end of the loop.
                        record.remoteId = remoteContact.remoteId;
                        record.localUpdateDate = SYNC_DATE_AS_NUMBER(now);
                        record.remoteUpdateDate = timestamp;
                        NSString *checksum = [localContact toMD5];
                        record.checksum = checksum;
                        SYNC_Log(@"MD5 %@ %@", [localContact toStringValue], checksum);
                        [newRecords addObject:record];  // At the end of the loop the newRecords objectIds' will be added and they will save into the local database
                        
                        // SYNC_SET_DICT_IF_NOT_NIL(recordSet, record, record.remoteId);
                        
                        if(contactStatus == NEW_CONTACT)
                            [[SyncStatus shared] addContact:remoteContact state:SYNC_INFO_NEW_CONTACT_ON_DEVICE];
                        else
                            [[SyncStatus shared] addContact:remoteContact state:SYNC_INFO_UPDATED_ON_DEVICE];
                    }

                    if (!SYNC_IS_NULL(remoteContact.objectId)&&!SYNC_IS_NULL(_dirtyRemoteContacts[remoteContact.objectId])) {
                        [_modifiedContactIds removeObjectForKey:remoteContact.objectId];
                    }
  
                    if (!SYNC_IS_NULL(remoteContact.objectId)) {
                        [_localContactIds addObject:remoteContact.objectId];
                    }
                    
                }
                
                /*
                 * At the end of the adding contacts into the phone, the result should be apply.
                 */
                SYNC_Log(@"Contacts will be save");
                NSMutableArray *objectIds = [[ContactUtil shared] applyContacts];
                if (!SYNC_IS_NULL(objectIds)){
                    SYNC_Log(@"Contacts have been saved successfully.");
                } else {
                    SYNC_Log(@"En error occurred while saving contacts!");
                }
                
                /*
                 * objectIDs' are defined. Now add it into the record and save into the database
                 * newRecords array and objectIds array has same order for contact information.
                 */
                NSUInteger recordCounter = [newRecords count];
                now = [NSDate date];
                for (NSUInteger i=0; i<recordCounter; i++){
                    SyncRecord *record = newRecords[i];
                    NSString *objectId = objectIds[i];
                    record.localId = [NSNumber numberWithLongLong:[objectId longLongValue]];
                    record.localUpdateDate = SYNC_DATE_AS_NUMBER(now);
                    
                    SyncRecord *rec = [recordSet objectForKey:record.remoteId];
                    SYNCContactStatus contactStatus;
                    if( !SYNC_IS_NULL([modifiedContacts objectForKey:record.remoteId]) ){
                        contactStatus = UPDATED_CONTACT;
                    }
                    else if ( !SYNC_IS_NULL(rec) ){
                        contactStatus = UPDATED_CONTACT;
                    }
                    else{
                        contactStatus = NEW_CONTACT;
                    }
                    
                    bool success = [_db save:record status:contactStatus];
                    if (success){    // Add record to the database. If it will return success then add record to recordSet cache.
                        SYNC_SET_DICT_IF_NOT_NIL(recordSet, record, record.remoteId);
                    }
                }
                
                now = [NSDate date];
                for (NSDictionary *item in resultOut[@"newDuplicateContacts"]){
                    SYNCContactStatus contactStatus = NEW_CONTACT;
                    Contact *remoteContact = [[Contact alloc] initWithDictionary:item];
                    SyncRecord *record = [SyncRecord new];
                    record.localId = remoteContact.objectId;
                    record.remoteId = remoteContact.remoteId;
                    record.localUpdateDate = SYNC_DATE_AS_NUMBER(now);
                    record.remoteUpdateDate = timestamp;
                    NSString *checksum = [remoteContact toMD5];
                    record.checksum = checksum;
                    SYNC_Log(@"MD5 2 %@ %@", [remoteContact toStringValue], checksum);
                    SyncRecord *rec = [recordSet objectForKey:remoteContact.remoteId];
                    if( !SYNC_IS_NULL([modifiedContacts objectForKey:remoteContact.remoteId]) ){
                        contactStatus = UPDATED_CONTACT;
                    }
                    else if ( !SYNC_IS_NULL(rec) ){
                        contactStatus = UPDATED_CONTACT;
                    }
                    [_db save:record status:contactStatus];
                }
                
                NSArray *deletedList = resultOut[@"deleted"];
                [_db deleteRecordsWithIDs:deletedList where:COLUMN_REMOTE_ID];
               
                if (!SYNC_NUMBER_IS_NULL_OR_ZERO(timestamp)){
                    [ContactSyncSDK setLastSyncTime:timestamp]; // Store Client last Sync time.
                }

                SYNC_Log(@"After processing RESTORE");
                [[ContactUtil shared] printContacts];
                [[SyncDBUtils shared] printRecords];
    
                [self endOfSyncCycle:SYNC_RESULT_SUCCESS];
            } else if ([@"ERROR" isEqualToString:data[@"status"]]) {
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_DELETED];
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_UPDATED];
                [defaults removeObjectForKey:SYNC_KEY_CHECK_UPDATE];
                [defaults synchronize];
                
                if (SYNC_IS_NULL(data[@"result"])){
                    [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER];
                } else {
                    NSString *resultString = data[@"result"];
                    NSData *data = [resultString dataUsingEncoding:NSUTF8StringEncoding];
                    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                    [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER messages:result];
                }
            } else {
                [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkProgressStatusForRestore) userInfo:nil repeats:NO];
            }
        } else {
            [self endOfSyncCycle:response==nil?SYNC_RESULT_ERROR_REMOTE_SERVER:SYNC_RESULT_ERROR_NETWORK];
        }
    }];
}

- (void)endOfSyncCycle:(SYNCResultType)result
{
    [self endOfSyncCycle:result messages:nil];
}

- (void)endOfSyncCycle:(SYNCResultType)result messages:(id)messages
{
    syncing = false;
    [SyncStatus shared].status = result;
    

    NSInteger finalCount = [[ContactUtil shared] getContactCount];
    [SyncAdapter sendStats:self.updateId start:self.initialContactCount
                                        result:finalCount
                                        created:[[SyncStatus shared].createdContactsReceived count]
                                        updated:[[SyncStatus shared].updatedContactsReceived count]
                                        deleted:[[SyncStatus shared].deletedContactsOnDevice count]];
    
    [[SyncLogger shared] stopLogging];
    
    void (^callback)(id) = [SyncSettings shared].callback;
    if (callback){
        callback(messages);
    }
    
    if (_startNewSync){
        _startNewSync = NO;
        [self startSyncing:_mode];
    }
}

@end

@implementation ContactSyncSDK

+ (void)doSync:(SYNCMode)mode
{
    SYNC_Log(@"%@",[[SyncSettings shared] endpointUrl]);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ContactUtil shared] checkAddressbookAccess:^(BOOL hasAccess) {
            if (hasAccess){
                ContactSyncSDK *sdk = [ContactSyncSDK shared];
                sdk.mode=mode;
                SyncHelper *helper = [SyncHelper new];
                [helper startSyncing:mode];
            } else {
                SYNC_Log(@"Sorry, user did not grant access to address book");
                [[SyncHelper new] endOfSyncCycle:SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK];
            }
        }];
    });
}

+ (BOOL)isRunning
{
    return [[SyncHelper new] isRunning];
}

+ (void)hasContactForBackup:(void (^)(SYNCResultType))callback
{
    [[ContactUtil shared] checkAddressbookAccess:^(BOOL hasAccess) {
        if (hasAccess){
            NSMutableArray *contacts = [[ContactUtil shared] fetchContacts];
            if (!SYNC_IS_NULL(contacts) && [contacts count]>0){
                for (Contact *contact in contacts){
                    if (!SYNC_IS_NULL(contact)){
                        if (contact.hasName){
                            if (callback!=nil)
                                callback(SYNC_RESULT_SUCCESS);
                            return;
                        }
                        [[ContactUtil shared] fetchNumbers:contact];
                        if (contact.hasPhoneNumber){
                            if (callback!=nil)
                                callback(SYNC_RESULT_SUCCESS);
                            return;
                        }
                    }
                }
            }
            if (callback!=nil)
                callback(SYNC_RESULT_FAIL);
            return;
        } else {
            if (callback!=nil)
                callback(SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK);
            return;
        }
    }];
}


+ (NSNumber*)lastSyncTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *time = [defaults objectForKey:SYNC_GET_KEY(SYNC_KEY_LAST_SYNC_TIME)];
    if (SYNC_IS_NULL(time)){
        return [NSNumber numberWithInt:0];
    } else {
        return time;
    }
    
}

+ (SYNC_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        instance = [self new];
    });
    
    return instance;
}

+ (void)setLastSyncTime:(NSNumber*)time
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:time forKey:SYNC_GET_KEY(SYNC_KEY_LAST_SYNC_TIME)];
    [defaults synchronize];
}

@end
