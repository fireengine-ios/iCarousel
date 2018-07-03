//
//  ContactSyncSDK.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "ContactSyncSDK.h"
#import "ContactUtil.h"
#import "SyncConstants.h"
#import <sys/utsname.h>

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
@property SYNCType type;

@property NSString *updateId;
@property NSInteger initialContactCount;

+ (SYNC_INSTANCETYPE) shared;


- (void)startSyncing:(SYNCMode)mode;
- (BOOL)isRunning;
- (void)setSyncing:(BOOL)run;

@end

@interface AnalyzeHelper : NSObject

@property (strong) NSMutableDictionary<NSString*, Contact*> *nameMap;    // Name(LocalName), Contact
@property (strong) NSMutableDictionary<NSString*, NSMutableArray<Contact*>*> *nameDuplicateMap;    // Name(LocalName), Duplicate Contact List
@property (strong) NSMutableDictionary<Contact*, NSMutableSet<ContactDevice*>*> *mergeMap;    // Contact, Contact Device Set
@property (strong) NSMutableArray<Contact*> *willMerge;
@property (strong) NSMutableArray<Contact*> *willDelete;

/*
 * Backup and Restore shared value.
 */
@property (strong) NSMutableSet *localContactIds;
@property (strong) NSString *deviceId;

@property (strong) SyncDBUtils *db;

@property NSString *updateId;
@property NSInteger initialContactCount;
@property NSInteger initialDuplicateCount;

+ (SYNC_INSTANCETYPE) shared;

- (void)startAnalyzing;
- (BOOL)isRunning;
- (void)reset;

@end

@interface ContactSyncSDK ()

@property SYNCMode mode;
@property SYNCType type;
+ (SYNC_INSTANCETYPE) shared;
+ (void)setLastSyncTime:(NSNumber*)time;
+ (void)setLastPeriodicSyncTime:(NSDate*)time;

@end

@implementation AnalyzeHelper

+ (SYNC_INSTANCETYPE) shared {

    static dispatch_once_t once;

    static id instance;

    dispatch_once(&once, ^{
        AnalyzeHelper *obj = [self new];
        instance = obj;
    });

    return instance;
}

- (instancetype) init
{
    self = [super init];
    if (self){
        _db = [SyncDBUtils shared];
    }
    return self;
}

- (void)reset{
    self.nameMap = [NSMutableDictionary new];
    self.nameDuplicateMap = [NSMutableDictionary new];
    self.mergeMap = [NSMutableDictionary new];
    self.willDelete = [NSMutableArray new];
    self.willMerge = [NSMutableArray new];
}

-(void)startAnalyzing
{
    if ([self isRunning]){
        return;
    }
    [[SyncHelper shared] setSyncing:YES];
    [[AnalyzeHelper shared] reset];

    [[SyncStatus shared] reset];
    [[SyncLogger shared] startLogging:
     [NSString stringWithFormat:@"%@-%@",[SyncSettings shared].token,@"ANALYZE"]];

    [self notifyProgress:@0];

    [[ContactUtil shared] reset];
    self.initialContactCount = -1;
    self.initialDuplicateCount = -1;
    self.updateId = nil;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
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

    struct utsname systemInfo;
    uname(&systemInfo);

    SYNC_Log(@"Device Info:%@", [NSString stringWithCString:systemInfo.machine
                                                   encoding:NSUTF8StringEncoding]);

    /*
     * MSISDN value should be defined here. checkStatus request msisdn value.
     */
    [SyncAdapter checkStatus:@"x" callback:^(id response, BOOL isSuccess) {
        if (isSuccess){
            SYNC_Log(@"Msisdn: %@", [[SyncSettings shared] msisdn]);
            [self findNameDuplicateContacts];
        } else {
            [self endOfAnalyzeCycleError:ANALYZE_RESULT_ERROR_NETWORK response:response];
        }
    }];
}

- (BOOL)isRunning
{
    return [[SyncHelper shared] isRunning];
}

- (void)notifyProgress:(NSNumber*)progress
{
    AnalyzeStatus *status = [AnalyzeStatus shared];
    status.progress = [self calculateProgress:progress];

    void (^callback)(void) = [SyncSettings shared].analyzeProgressCallback;
    if (callback){
        callback();
    }
}

- (void)notifyProgress:(AnalyzeStep)step progress:(NSNumber*)progress
{
    [AnalyzeStatus shared].analyzeStep = step;
    [self notifyProgress:progress];
}

- (NSNumber*)calculateProgress:(NSNumber*)progress
{
    AnalyzeStatus *status = [AnalyzeStatus shared];
    double step = (double)status.analyzeStep - 1;
    NSUInteger progressValue = SYNC_CALCULATE_PROGRESS(step,ANALYZE_NUM_OF_STEPS,progress);
    return @(progressValue);
}

- (void)onNotify:(NSMutableDictionary<NSString*, NSNumber*>*)willMerge delete:(NSMutableArray<NSString*>*)willDelete
{
    void (^callback)(NSMutableDictionary<NSString*, NSNumber*>*, NSMutableArray<NSString*>*) = [SyncSettings shared].analyzeNotifyCallback;
    if (callback) {
        callback(willMerge, willDelete);
    }
}

- (void)onComplete
{
    void (^callback)(void) = [SyncSettings shared].analyzeCompleteCallback;
    if (callback) {
        callback();
    }
}

- (void)findNameDuplicateContacts{
    self.nameMap = [NSMutableDictionary new];
    self.nameDuplicateMap = [NSMutableDictionary new];

    [self notifyProgress:ANALYZE_STEP_FIND_DUPLICATES progress:@(0)];

    NSMutableArray *contacts = [[ContactUtil shared] fetchLocalContacts];
    self.initialContactCount = [contacts count];

    if (!SYNC_IS_NULL(contacts) && [contacts count]>0){
        SYNC_Log(@"Count: %ld", (long)[contacts count]);
        NSInteger counter = 0;
        for (Contact *contact in contacts){
            counter++;
            if (counter % 100 == 0){
                [self notifyProgress:@(counter*100/self.initialContactCount)];
            }
            NSString *displayName = contact.generateDisplayName;
            if (!SYNC_IS_NULL(contact) && !SYNC_STRING_IS_NULL_OR_EMPTY(displayName)){
                SYNC_Log(@"Contact: %@", [contact.objectId stringValue]);
                if (!SYNC_IS_NULL([self.nameMap objectForKey:displayName])){
                    SYNC_Log(@"Duplicate contact: %@ is found for contact :%@.", [contact.objectId stringValue], [self.nameMap objectForKey:displayName].objectId)
                    if (!SYNC_ARRAY_IS_NULL_OR_EMPTY([self.nameDuplicateMap objectForKey:displayName])){
                        [[self.nameDuplicateMap objectForKey:displayName] addObject:contact];
                    }
                    else{
                        NSMutableArray<Contact*>*duplicateList = [NSMutableArray new];
                        [duplicateList addObject:[self.nameMap objectForKey:displayName]];
                        [duplicateList addObject:contact];
                        [self.nameDuplicateMap setObject:duplicateList forKey:displayName];
                    }
                }
                else{
                    [self.nameMap setObject:contact forKey:displayName];
                }
            }
            else{
                SYNC_Log(@"Contact: %@ is null.", [contact.objectId stringValue]);
            }
        }
        [self analyzeDuplicateContacts];
    }
}

- (void)analyzeDuplicateContacts{
    [self notifyProgress:ANALYZE_STEP_PROCESS_DUPLICATES progress:@(0)];

    self.mergeMap = [NSMutableDictionary new];
    self.willMerge = [NSMutableArray new];
    self.willDelete = [NSMutableArray new];

    self.initialDuplicateCount = [self.nameDuplicateMap count];

    if (self.initialDuplicateCount > 0){
        SYNC_Log(@"Name duplicates count: %ld", (long)self.initialDuplicateCount);
        NSInteger counter = 0;
        for (NSMutableArray <Contact*>*contacts in [self.nameDuplicateMap allValues]){
            counter++;
            [self notifyProgress: @(counter*100/self.initialDuplicateCount)];
            if ([contacts count] < 2){
                continue;
            }
            Contact *masterContact = contacts[0];
            NSInteger masterContactDeviceCount = 0;
            for (Contact *contact in contacts) {
                [[ContactUtil shared] fetchEmails:contact];
                [[ContactUtil shared] fetchNumbers:contact];
                if ([contact.devices count] > masterContactDeviceCount) {
                    masterContact = contact;
                    masterContactDeviceCount = [contact.devices count];
                }
            }

            NSMutableSet<ContactDevice*> *masterDeviceSet = [NSMutableSet new];
            for (ContactDevice *device in masterContact.devices) {
                [masterDeviceSet addObject:device];
            }
            for (Contact *contact in contacts){
                if (masterContact.objectId == contact.objectId) {
                    continue;
                }
                NSMutableSet<ContactDevice*> *deviceDiff = [self collectDifferentDevice:contact withDevices:masterDeviceSet];
                if ([deviceDiff count] > 0) {
                    SYNC_Log(@"Will merge master: %@ and new: %@", masterContact.objectId, contact.objectId);
                    if ([self.mergeMap objectForKey:masterContact]) {
                        [[self.mergeMap objectForKey:masterContact] unionSet:deviceDiff];
                    } else {
                        [self.mergeMap setObject:deviceDiff forKey:masterContact];
                    }
                    [self.willMerge addObject:contact];
                    [masterDeviceSet unionSet:deviceDiff];
                } else {
                    SYNC_Log(@"Will delete: %@", contact.objectId);
                    [self.willDelete addObject:contact];
                }
            }
        }
    }
    if (![SyncSettings shared].dryRun) {
        [self clearDuplicateContacts];
    } else {
        if ([SyncSettings shared].analyzeNotifyCallback != nil) {
            NSMutableDictionary<NSString*, NSNumber*> *willMergeMap = [NSMutableDictionary new];
            for (Contact *contact in [self.mergeMap allKeys]){
                [willMergeMap setObject:@([[self.mergeMap objectForKey:contact] count]) forKey:contact.generateDisplayName];
            }
            NSMutableArray<NSString*> *willDeleteList = [NSMutableArray new];
            for (Contact *contact in self.willDelete) {
                [willDeleteList addObject:contact.generateDisplayName];
            }
            [self onNotify:willMergeMap delete:willDeleteList];
        }
    }
}

- (void)clearDuplicateContacts{
    [self notifyProgress:ANALYZE_STEP_CLEAR_DUPLICATES progress:@(0)];
    NSInteger initialDuplicateCount = [self.mergeMap count];

    if (initialDuplicateCount > 0) {
        SYNC_Log(@"Will Merge Duplicates Count : %ld" ,(long)initialDuplicateCount);
        NSInteger counter = 0;
        for (Contact *contact in [self.mergeMap allKeys]) {
            counter++;
            [self notifyProgress:@(counter*80/initialDuplicateCount)];
            [contact.devices addObjectsFromArray:[[self.mergeMap objectForKey:contact] allObjects]];
            [[ContactUtil shared] save:contact];
        }
    }
    [self.willDelete addObjectsFromArray:self.willMerge];
    [self notifyProgress:@(80)];
    SYNC_Log(@"Will Delete Duplicates Count : %ld", (long)[self.willDelete count]);
    [[ContactUtil shared] deleteContacts:self.willDelete];
    [self notifyProgress:@(100)];

    [self endOfAnalyzeCycle:SUCCESS];
}

- (NSMutableSet<ContactDevice*>*) collectDifferentDevice:(Contact*)checkContact withDevices:(NSMutableSet<ContactDevice*>*)devices
{
    NSMutableSet<ContactDevice*>* deviceDiff = [NSMutableSet new];
    for (ContactDevice *device in checkContact.devices) {
        if (![devices containsObject:device]) {
            [deviceDiff addObject:device];
        }
    }
    return deviceDiff;
}

- (void)endOfAnalyzeCycleError:(AnalyzeResultType)result response:(id) response
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    if (response[@"error"] != nil){
        [array addObject:response[@"error"]];
    }
    [self endOfAnalyzeCycle:result messages:array];
}

- (void)endOfAnalyzeCycle:(AnalyzeResultType)result
{
    [self endOfAnalyzeCycle:result messages:nil];
}

- (void)endOfAnalyzeCycle:(AnalyzeResultType)result messages:(id)messages
{
    //Analyze is completed
    [[SyncHelper shared] setSyncing:NO];
    [AnalyzeStatus shared].status = result;
    if ([SyncSettings shared].analyzeCompleteCallback != nil) {
        [self onComplete];
    }
    NSInteger finalCount = [[ContactUtil shared] getContactCount];
    SYNC_Log(@"Final Contact count => %ld", (long)finalCount);

    [[SyncLogger shared] stopLogging];

}

@end

@implementation SyncHelper

static bool syncing = false;

+ (SYNC_INSTANCETYPE) shared {

    static dispatch_once_t once;

    static id instance;

    dispatch_once(&once, ^{
        SyncHelper *obj = [self new];
        instance = obj;
    });

    return instance;
}

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
     [NSString stringWithFormat:@"%@-%@",[SyncSettings shared].token,(mode==SYNCBackup)?@"BACKUP":@"RESTORE"]];
    
    [self notifyProgress:@0];
    
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
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    SYNC_Log(@"Device Info:%@", [NSString stringWithCString:systemInfo.machine
                                                  encoding:NSUTF8StringEncoding]);
    
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
        if (isSuccess){
            SYNC_Log(@"Msisdn: %@", [[SyncSettings shared] msisdn]);
            
            self.lastSync = [[ContactSyncSDK lastSyncTime] longLongValue];
            
            if(_mode == SYNCRestore){
                [self fetchLocalContactsForRestore];
            }
            else
                [self getUpdatedContactsFromServerForBackup];
        }else{
            [self endOfSyncCycleError:SYNC_RESULT_ERROR_REMOTE_SERVER response: response];
        }
    }];

}

- (BOOL)isRunning
{
    return syncing;
}

- (void)setSyncing:(BOOL)run
{
    syncing = run;
}

- (void)fetchLocalContactsForBackup
{
    self.dirtyRemoteContacts = [NSMutableDictionary new];
    self.deletedLocalContactRemoteIds = [NSMutableSet new];
    
    SYNC_Log(@"Before BACKUP");
    [[ContactUtil shared] printContacts];
    
    [self notifyProgress:SYNC_STEP_READ_LOCAL_CONTACTS progress:@(0)];
    
    NSMutableArray *contacts = [[ContactUtil shared] fetchContacts];
    self.initialContactCount = [contacts count];
    if (!SYNC_IS_NULL(contacts) && [contacts count]>0){
        int i = 0;
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
                            SYNC_Log(@"Dirty Contact (1): RemoteId:%@ LocalId:%@ localUpdate:%@ remoteUpdate:%@", [contact remoteId], [contact objectId], [contact localUpdateDate], [contact remoteUpdateDate]);

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
                                    SYNC_Log(@"Dirty Contact (2): RemoteId:%@ LocalId:%@ contact.localUpdate:%@ rec.localUpdate:%@", [contact remoteId], [contact objectId], [contact localUpdateDate], [rec localUpdateDate]);
                                
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
                            SYNC_Log(@"Dirty Contact (3): RemoteId:%@ LocalId:%@ localUpdate:%@ remoteUpdate:%@", [contact remoteId], [contact objectId], [contact localUpdateDate], [contact remoteUpdateDate]);
                        } else { //ignore contact if it has neither name nor phone number
                            SYNC_Log(@"Ignore Contact : RemoteId:%@ LocalId:%@ localUpdate:%@ remoteUpdate:%@", [contact remoteId], [contact objectId], [contact localUpdateDate], [contact remoteUpdateDate]);
                            [_localContactIds removeObject:[contact objectId]];
                        }
                    }
            }
            if (++i%100==0){
                double progress = ((double)i*100)/[contacts count];
                [self notifyProgress:@(progress)];
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
    
    [self notifyProgress:SYNC_STEP_READ_LOCAL_CONTACTS progress:@(0)];
    

    NSMutableArray *contacts = [[ContactUtil shared] fetchContacts];
    self.initialContactCount = [contacts count];
    if (!SYNC_IS_NULL(contacts) && [contacts count]>0){
        int i = 0;
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
                if (++i%100==0){
                    double progress = ((double)i*100)/[contacts count];
                    [self notifyProgress:@(progress)];
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
    [self notifyProgress:SYNC_STEP_CHECK_SERVER_STATUS progress:@0];
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
            [self notifyProgress:@100];
            [self fetchLocalContactsForBackup];
        } else {
            if (response==nil){
                SYNC_Log(@"We got NULL response");
                [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER];
            } else {
                SYNC_Log(@"Possible network error");
                [self endOfSyncCycle:SYNC_RESULT_ERROR_NETWORK];
            }
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
    
    for(NSNumber *objectID in [_dirtyRemoteContacts allKeys]){
        Contact *contact = [_dirtyRemoteContacts objectForKey:objectID];
        if( [_deletedLocalContactRemoteIds containsObject:contact.remoteId] ){  // It will return Yes or No
            [_dirtyRemoteContacts removeObjectForKey:contact.objectId];
        }
    }
    
    [self notifyProgress:@100];
    
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
    
    [self notifyProgress:@100];
    
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
    SYNC_Log(@"New Contacts: %ld", [array count]);
    
    NSArray *modifiedContactIDs = [deletedContactIDs arrayByAddingObjectsFromArray:updatedContactIDs];
    [self notifyProgress:SYNC_STEP_SERVER_IN_PROGRESS progress:@0];
    long long time = [[ContactSyncSDK lastSyncTime] longLongValue];
    if([[NSUserDefaults standardUserDefaults] objectForKey:SYNC_KEY_PROGRESS_RESTORE] != nil){
        SYNC_Log(@"An error occurred in the previous restore");
        time = 0;
    }
    [SyncAdapter restoreContactsWithTimestamp:time deviceId:_deviceId modifiedContactIDs:modifiedContactIDs newContacts:newContacts callback:^(id response, BOOL isSuccess) {
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
            if (response==nil){
                SYNC_Log(@"We got NULL response");
                [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER];
            } else {
                SYNC_Log(@"Possible network error");
                [self endOfSyncCycle:SYNC_RESULT_ERROR_NETWORK];
            }
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
    SYNC_Log(@"Dirty Contacts: %@", @(array.count));
    
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
            if (response==nil){
                SYNC_Log(@"We got NULL response");
                [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER];
            } else {
                SYNC_Log(@"Possible network error");
                [self endOfSyncCycle:SYNC_RESULT_ERROR_NETWORK];
            }
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"DELETED" forKey:SYNC_KEY_PROGRESS_RESTORE];
    
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
                
                SYNC_Log(@"%@", @"Possible network error");
                [self endOfSyncCycle:SYNC_RESULT_ERROR_NETWORK];
                return;
            }
            NSString *status = data[@"status"];
            if ([@"COMPLETED" isEqualToString:status]){
                [self notifyProgress:SYNC_STEP_SERVER_IN_PROGRESS progress:@100];
                
                NSArray *contactsDirty = [self restoreRecordsFromUserDefaultsForBackup:SYNC_KEY_CONTACT_STORE_DIRTY];
                NSArray *contactsDeleted = [self restoreRecordsFromUserDefaultsForBackup:SYNC_KEY_CONTACT_STORE_DELETED];
                
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_DIRTY];
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_DELETED];
                [defaults removeObjectForKey:SYNC_KEY_CHECK_UPDATE];
                [defaults synchronize];
                
                NSNumber *timestamp = data[@"timestamp"];
                NSString *resultString = data[@"result"];
                NSNumber *totalCount = data[@"totalCount"];
                
                NSData *data = [resultString dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                NSArray *remoteIDs = result[@"result"];
                if (SYNC_IS_NULL(remoteIDs)){
                    SYNC_Log(@"%@", @"There is an error in API.");
                    [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER];
                    
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
                    SYNC_Log(@"%@", @"There is an internal error. The program will try again.");
                    [self endOfSyncCycle:SYNC_RESULT_ERROR_INTERNAL];
                    return;
                }
                
                NSDate *now = [NSDate date];
                
                NSUInteger remoteIdsCount = 0;
                if(!SYNC_IS_NULL(remoteIDs))
                    remoteIdsCount = [remoteIDs count];
                
                [self notifyProgress:SYNC_STEP_PROCESSING_RESPONSE progress:@0];
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
                        SYNC_Log(@"Backup MD5 %@", checksum);
                        SYNC_Log(@"Save record : %@ %@ %@ %@",record.localId, record.remoteId, record.localUpdateDate, record.remoteUpdateDate);

                        [_db save:record];
                    }
                    
                    if (i%100==0){
                        double progress = ((double)i*100)/remoteIdsCount;
                        [self notifyProgress:@(progress)];
                    }
                }
                
                NSNumber *created = stats[@"created"];
                NSNumber *deleted = stats[@"deleted"];
                NSNumber *updated = stats[@"updated"];
                
                [[SyncStatus shared] addEmpty:created state:SYNC_INFO_NEW_CONTACT_ON_SERVER];
                [[SyncStatus shared] addEmpty:deleted state:SYNC_INFO_DELETED_ON_SERVER];
                [[SyncStatus shared] addEmpty:updated state:SYNC_INFO_UPDATED_ON_SERVER];

                [SyncStatus shared].totalContactOnClient = [NSNumber numberWithInteger:0];
                [SyncStatus shared].totalContactOnServer = totalCount;
                
                if (!SYNC_NUMBER_IS_NULL_OR_ZERO(timestamp)){
                    [ContactSyncSDK setLastSyncTime:timestamp]; // Store client last sync time
                }
                
                SYNC_Log(@"%@", @"After processing BACKUP");
                [[ContactUtil shared] printContacts];
                [[SyncDBUtils shared] printRecords];
                
                [self notifyProgress:@100];
                
                SYNC_Log(@"%@", @"SUCCESS");
                [self endOfSyncCycle:SYNC_RESULT_SUCCESS];
            } else if ([@"ERROR" isEqualToString:data[@"status"]]) {
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_DELETED];
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_UPDATED];
                [defaults removeObjectForKey:SYNC_KEY_CHECK_UPDATE];
                [defaults synchronize];
                
                SYNC_Log(@"%@", @"ERROR received");
                if (SYNC_IS_NULL(data[@"result"])){
                    [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER];
                } else {
                    NSString *resultString = data[@"result"];
                    NSData *data = [resultString dataUsingEncoding:NSUTF8StringEncoding];
                    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                    [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER messages:result];
                }
            } else {
                if (!SYNC_NUMBER_IS_NULL_OR_ZERO(data[@"progress"])){
                    [self notifyProgress:SYNC_STEP_SERVER_IN_PROGRESS progress:data[@"progress"]];
                }
                dispatch_async( dispatch_get_main_queue(), ^{
                    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkProgressStatusForBackup) userInfo:nil repeats:NO];
                });
            }
        } else {
            if (response==nil){
                SYNC_Log(@"%@", @"We got NULL response Possible network error");
                [self endOfSyncCycle:SYNC_RESULT_ERROR_NETWORK];
            } else {
                [self endOfSyncCycleError:SYNC_RESULT_ERROR_REMOTE_SERVER response:response];
            }
            
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
                
                SYNC_Log(@"%@", @"DATA is null");
                [self endOfSyncCycle:SYNC_RESULT_ERROR_NETWORK];
                return;
            }
            NSString *status = data[@"status"];
            if ([@"COMPLETED" isEqualToString:status]){
                [self notifyProgress:SYNC_STEP_SERVER_IN_PROGRESS progress:@100];
                
                SYNC_Log(@"%@", @"Before processing RESTORE");
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
                
                [self notifyProgress:SYNC_STEP_PROCESSING_RESPONSE progress:@0];
                
                NSArray *allRecords = [_db fetch];
                //fetch records from database and cache them
                NSMutableDictionary *recordSet = [NSMutableDictionary new]; // remoteID, dbRecord
                if (!SYNC_ARRAY_IS_NULL_OR_EMPTY(allRecords)){
                    for (SyncRecord *rec in allRecords){
                        if (!SYNC_IS_NULL(rec.remoteId))
                            SYNC_SET_DICT_IF_NOT_NIL(recordSet, rec, rec.remoteId);
                    }
                }
                
                [self notifyProgress:@5];
                
                NSMutableArray *newRecords = [NSMutableArray new];
                NSDate *now;
                NSDate *recordDate;
                NSMutableArray *objectIds = [NSMutableArray new];
                NSInteger thresholdCounter = 0;
                NSInteger restoreRound = 0; //Large amount of contacts are restored in multiple rounds
                NSInteger indexCounter = 0;
                NSInteger resultSize = resultOut[@"result"] != nil ? [resultOut[@"result"] count] : 0;

                for (NSDictionary *item in resultOut[@"result"]){
                    indexCounter++;
                    thresholdCounter++;
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
                                    SYNC_Log(@"Device %@ not found in remote", [device deviceTypeLabel]);
                                    [toBeDeleted addObject:device];
                                    [localContact.devices removeObject:device];
                                } else {
                                    i++;
                                }
                            }
                            // delete devices that are not in remote
                            [[ContactUtil shared] deleteContactDevices:localContact.objectId devices:toBeDeleted];
                        }
                        else{
                            localContact.devices = [NSMutableArray new];
                        }

                        [localContact copyContact:remoteContact];
                        [[ContactUtil shared] save:localContact];
                        now = [NSDate date];    // Keep the current time to save it local database.
                        SYNC_Log(@"RemoteID:%@", remoteContact.remoteId);

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
                        SYNC_Log(@"MD5 %@", checksum);
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
                    if (thresholdCounter >= SYNC_RESTORE_THRESHOLD || indexCounter == [resultOut[@"result"] count]) {
                        SYNC_Log(@"%ld Contacts will be saved. Round:%ld.", thresholdCounter, (restoreRound+1));
                        objectIds = [[ContactUtil shared] applyContacts:restoreRound];

                        SYNC_Log(@"Contacts saved to phone contacts: %ld index: %ld", (restoreRound+1), indexCounter);
                        
                        if(recordDate == nil){
                            recordDate = [NSDate date];
                        }
                        
                        NSInteger size = [objectIds count];
                        NSInteger firstIndex = (size - SYNC_RESTORE_THRESHOLD)<= 0 ? 0 : ([objectIds count] - SYNC_RESTORE_THRESHOLD);
                        NSInteger lastIndex =  firstIndex + SYNC_RESTORE_THRESHOLD > resultSize ? resultSize: (firstIndex + SYNC_RESTORE_THRESHOLD);
                        if (lastIndex > size + 1){
                            SYNC_Log(@"Check error logs. Probably addressbook cannot save lastIndex: %ld, size: %ld firstIndex: %ld resultSize: %ld", lastIndex, size, firstIndex, resultSize)
                            [self endOfSyncCycle:SYNC_RESULT_ERROR_INTERNAL];
                            return;
                        }
                        for (NSUInteger i=firstIndex; i<lastIndex; i++){
                            SyncRecord *record = newRecords[i];
                            NSString *objectId = objectIds[i];
                            record.localId = [NSNumber numberWithLongLong:[objectId longLongValue]];
                            record.localUpdateDate = SYNC_DATE_AS_NUMBER(recordDate);
                            
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
                        
                        restoreRound++;
                        thresholdCounter = 0;
                        
                        SYNC_Log(@"Contacts saved to local db. round: %ld, index: %ld, total: %ld", (restoreRound+1), indexCounter, [objectIds count]);
                    }
                    if (indexCounter%100==0){
                        double progress = ((double)indexCounter*80)/resultSize;
                        [self notifyProgress:@(5+progress)];
                    }
                }

                SYNC_Log(@"Total saved contacts count is %ld.", [objectIds count]);

                NSUInteger recordCounter = [newRecords count];
                
                now = [NSDate date];
                int i = 0;
                recordCounter = [resultOut[@"newDuplicateContacts"] count];
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
                    SYNC_Log(@"MD5 2 %@", checksum);
                    SyncRecord *rec = [recordSet objectForKey:remoteContact.remoteId];
                    if( !SYNC_IS_NULL([modifiedContacts objectForKey:remoteContact.remoteId]) ){
                        contactStatus = UPDATED_CONTACT;
                    }
                    else if ( !SYNC_IS_NULL(rec) ){
                        contactStatus = UPDATED_CONTACT;
                    }
                    [_db save:record status:contactStatus];
                    
                    if (++i%100==0){
                        double progress = ((double)i*10)/recordCounter;
                        [self notifyProgress:@(90+progress)];
                    }
                }
                
                NSArray *deletedList = resultOut[@"deleted"];
                [_db deleteRecordsWithIDs:deletedList where:COLUMN_REMOTE_ID];
               
                if (!SYNC_NUMBER_IS_NULL_OR_ZERO(timestamp)){
                    [ContactSyncSDK setLastSyncTime:timestamp]; // Store Client last Sync time.
                }

                SYNC_Log(@"%@", @"After processing RESTORE");
                [[ContactUtil shared] printContacts];
                [[SyncDBUtils shared] printRecords];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults removeObjectForKey:SYNC_KEY_PROGRESS_RESTORE];
                
                [self notifyProgress:@100];
                
                [SyncStatus shared].totalContactOnServer = [NSNumber numberWithInteger:0];
                [SyncStatus shared].totalContactOnClient = [NSNumber numberWithInteger:[[ContactUtil shared] getContactCount]];
                
                [[ContactUtil shared] reset];

                SYNC_Log(@"%@", @"SUCCESS");
                [self endOfSyncCycle:SYNC_RESULT_SUCCESS];
            } else if ([@"ERROR" isEqualToString:data[@"status"]]) {
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_DELETED];
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE_UPDATED];
                [defaults removeObjectForKey:SYNC_KEY_CHECK_UPDATE];
                [defaults synchronize];
                
                SYNC_Log(@"%@", @"An ERROR is received on check status for restore.");
                if (SYNC_IS_NULL(data[@"result"])){
                    [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER];
                } else {
                    NSString *resultString = data[@"result"];
                    NSData *data = [resultString dataUsingEncoding:NSUTF8StringEncoding];
                    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                    [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER messages:result];
                }
            } else {
                if (!SYNC_NUMBER_IS_NULL_OR_ZERO(data[@"progress"])){
                    [self notifyProgress:SYNC_STEP_SERVER_IN_PROGRESS progress:data[@"progress"]];
                }
                dispatch_async( dispatch_get_main_queue(), ^{
                    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkProgressStatusForRestore) userInfo:nil repeats:NO];
                });
            }
        } else {
            if (response==nil){
                SYNC_Log(@"%@", @"We got NULL response");
                [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER];
            } else {
                SYNC_Log(@"%@", @"Possible network error");
                [self endOfSyncCycle:SYNC_RESULT_ERROR_NETWORK];
            }
        }
    }];
}
- (void)endOfSyncCycleError:(SYNCResultType)result response:(id) response
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    if (response[@"error"] != nil){
        [array addObject:response[@"error"]];
    }
    [self endOfSyncCycle:result messages:array];
}

- (void)endOfSyncCycle:(SYNCResultType)result
{
    [self endOfSyncCycle:result messages:nil];
}

- (void)endOfSyncCycle:(SYNCResultType)result messages:(id)messages
{
    syncing = false;
    [SyncStatus shared].status = result;

    if ([ContactSyncSDK shared].type == SYNCPeriod){
        if (result == SYNC_RESULT_SUCCESS){
            //Periodic Backup is successful set last periodic sync time
            [ContactSyncSDK setLastPeriodicSyncTime:[NSDate date]];
        }
    }

    NSInteger finalCount = [[ContactUtil shared] getContactCount];
    
    NSString *errorCode = nil;
    for (id item in messages)
    {
        errorCode = item[@"code"];
    }
    
    [SyncAdapter sendStats:self.updateId start:self.initialContactCount
                                        result:finalCount
                                        created:[[SyncStatus shared].createdContactsReceived count]
                                        updated:[[SyncStatus shared].updatedContactsReceived count]
                                        deleted:[[SyncStatus shared].deletedContactsOnDevice count]
                                        status: (result == SYNC_RESULT_SUCCESS ? 1 : 0)
                                        errorCode: errorCode
                                        errorMsg:(result == SYNC_RESULT_SUCCESS ? nil : [[SyncStatus shared] resultTypeToString:result])];

    SyncStatus *status = [SyncStatus shared];
    NSString *resultInfo = [NSString stringWithFormat:@"%@.\n"
     "Last Sync Time: %@\n"
     "Update: %ld from device, %ld from server\n"
     "Create: %ld from device, %ld from server\n"
     "Delete: %ld on device, %ld on server\n"
     "Contacts On Server: %@\n"
     "Contacts On Client: %@",
     [[SyncStatus shared] resultTypeToString:result],
     [NSDate dateWithTimeIntervalSince1970:[[ContactSyncSDK lastSyncTime] longLongValue]/1000]
     ,(unsigned long)status.updatedContactsSent.count,(unsigned long)status.updatedContactsReceived.count
     ,(unsigned long)status.createdContactsSent.count, (unsigned long)status.createdContactsReceived.count
     ,(unsigned long)status.deletedContactsOnDevice.count,(unsigned long)status.deletedContactsOnServer.count
     ,status.totalContactOnServer,status.totalContactOnClient];

    SYNC_Log(@"Result is: %@", resultInfo);
    
    [[SyncLogger shared] stopLogging];
    
    void (^callback)(id) = [SyncSettings shared].callback;
    if (callback){
        dispatch_async( dispatch_get_main_queue(), ^{
            callback(messages);
            
            if (_startNewSync){
                _startNewSync = NO;
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self startSyncing:_mode];
                });
            }
        });
    }
    
    
}

- (void)notifyProgress:(NSNumber*)progress
{
    SyncStatus *status = [SyncStatus shared];
    status.progress = [self calculateProgress:progress];

    void (^callback)(void) = [SyncSettings shared].progressCallback;
    if (callback){
        callback();
    }
}

- (void)notifyProgress:(SYNCStep)step progress:(NSNumber*)progress
{
    [SyncStatus shared].step = step;
    [self notifyProgress:progress];
}

- (NSNumber*)calculateProgress:(NSNumber*)progress
{
    SyncStatus *status = [SyncStatus shared];
    ContactSyncSDK *sdk = [ContactSyncSDK shared];
    NSInteger stepSize = 0;
    NSInteger progressStep = 0;
    if (sdk.mode == SYNCBackup){
        stepSize = SYNC_NUM_OF_BACKUP_STEPS;
        progressStep = status.step - 1;
    }
    else {
        stepSize = SYNC_NUM_OF_RESTORE_STEPS;
        progressStep = status.step - 2;
    }

    NSUInteger progressValue = SYNC_CALCULATE_PROGRESS(progressStep,stepSize,progress);
    return @(progressValue);
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
                sdk.type = SYNCRequested;
                //Set info for periodic backup
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[SyncSettings shared].token forKey:SYNC_KEY_PERIODIC_TOKEN];
                [defaults setObject:[SyncSettings shared].url forKey:SYNC_KEY_PERIODIC_URL];
                [defaults synchronize];

                SyncHelper *helper = [SyncHelper new];
                [helper startSyncing:mode];
            } else {
                SYNC_Log(@"%@", @"Sorry, user did not grant access to address book");
                [[SyncHelper new] endOfSyncCycle:SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK];
            }
        }];
    });
}

+ (void)doAnalyze:(BOOL)dryRun
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ContactUtil shared] checkAddressbookAccess:^(BOOL hasAccess) {
            if (hasAccess){
                [SyncSettings shared].dryRun = dryRun;
                AnalyzeHelper *helper = [AnalyzeHelper shared];
                [helper startAnalyzing];
            } else {
                SYNC_Log(@"%@", @"Sorry, user did not grant access to address book");
                [[AnalyzeHelper new] endOfAnalyzeCycle:ANALYZE_RESULT_ERROR_PERMISSION_ADDRESS_BOOK];
            }
        }];
    });
}

+ (void)doPeriodicSync
{
    //Check if any backup or restore operation is active
    if ([ContactSyncSDK isRunning]){
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastPeriodic = [ContactSyncSDK lastPeriodicSyncTime];

    //If periodic option is not selected, do not proceed
    if (SYNC_IS_NULL([defaults objectForKey:SYNC_KEY_PERIODIC_OPTION]) || (SYNCPeriodic)[[defaults objectForKey:SYNC_KEY_PERIODIC_OPTION] integerValue] == SYNCNone) {
        return;
    }
    SYNCPeriodic period = (SYNCPeriodic)[[defaults objectForKey:SYNC_KEY_PERIODIC_OPTION] integerValue];
    //Check if it is time for a periodic backup
    if (![self isValidPeriodicBackup:period lastTime:lastPeriodic]){
        return;
    }

    //If token and url is not saved, do not proceed
    if (SYNC_STRING_IS_NULL_OR_EMPTY([defaults objectForKey:SYNC_KEY_PERIODIC_TOKEN]) || SYNC_STRING_IS_NULL_OR_EMPTY([defaults objectForKey:SYNC_KEY_PERIODIC_URL])){
        return;
    }

    SYNC_Log(@"Periodic selection is: %@. Last periodic backup time is: %@", [[SyncSettings shared] periodToString:period], SYNC_IS_NULL(lastPeriodic) ? @"None" : lastPeriodic);

    SYNC_Log(@"%@",[[SyncSettings shared] endpointUrl]);

    [SyncSettings shared].token = [defaults objectForKey:SYNC_KEY_PERIODIC_TOKEN];
    [SyncSettings shared].url = [defaults objectForKey:SYNC_KEY_PERIODIC_URL];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //Period checks
        [ContactSyncSDK hasContactForBackup:^(SYNCResultType result) {
            if (result == SYNC_RESULT_SUCCESS){
                ContactSyncSDK *sdk = [ContactSyncSDK shared];
                sdk.mode = SYNCBackup;
                sdk.type = SYNCPeriod;

                SYNC_Log(@"%@", @"Periodic backup has started on the background.");
                SyncHelper *helper = [SyncHelper new];
                [helper startSyncing:SYNCBackup];
            } else if (result == SYNC_RESULT_FAIL){
                SYNC_Log(@"%@", @"Sorry, sync result is unsuccessful. Periodic backup has failed.");
                [[SyncHelper new] endOfSyncCycle:SYNC_RESULT_FAIL];
            } else {
                SYNC_Log(@"%@", @"Sorry, user did not grant access to address book. Periodic backup has failed.");
                [[SyncHelper new] endOfSyncCycle:SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK];
            }
        }];
    });
}

+ (BOOL)isValidPeriodicBackup:(SYNCPeriodic)period lastTime:(NSDate*)lastPeriodicBackup
{
    if (SYNC_IS_NULL(lastPeriodicBackup) && period != SYNCNone) {
        return YES;
    } else {
        //Date difference between last periodic backup to this moment in second
        NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:lastPeriodicBackup];
        //86400:seconds in a day
        int numberOfDays = secondsBetween / 86400;
        if (period == SYNCDaily && numberOfDays > 0){
            return YES;
        } else if (period == SYNCEvery7 && numberOfDays > 6){
            return YES;
        } else if (period == SYNCEvery30 && numberOfDays > 29){
            return YES;
        } else {
            return NO;
        }
    }
}

+ (BOOL)isRunning
{
    return [[SyncHelper new] isRunning];
}

+ (void)cancelAnalyze
{
    [[AnalyzeHelper shared] endOfAnalyzeCycle:CANCELLED];
    [[AnalyzeStatus shared] reset];
}

+ (void)continueAnalyze
{
    [AnalyzeStatus shared].status = ANALYZE;
    [[AnalyzeHelper shared] clearDuplicateContacts];
}

+ (void)getBackupStatus:(void (^)(id))callback
{
    [SyncAdapter getLastBackup:^(id response, BOOL success) {
        dispatch_async( dispatch_get_main_queue(), ^{
            if (success){
                if (SYNC_IS_NULL(response)){
                    callback(nil);
                } else {
                    callback(response[@"data"]);
                }
            } else {
                callback(nil);
            }
        });
    }];
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
                            if (callback!=nil){
                                dispatch_async( dispatch_get_main_queue(), ^{
                                    callback(SYNC_RESULT_SUCCESS);
                                });
                            }
                            return;
                        }
                        [[ContactUtil shared] fetchNumbers:contact];
                        if (contact.hasPhoneNumber){
                            if (callback!=nil){
                                dispatch_async( dispatch_get_main_queue(), ^{
                                    callback(SYNC_RESULT_SUCCESS);
                                });
                            }
                            return;
                        }
                    }
                }
            }
            if (callback!=nil){
                dispatch_async( dispatch_get_main_queue(), ^{
                    callback(SYNC_RESULT_FAIL);
                });
            }
            return;
        } else {
            if (callback!=nil){
                dispatch_async( dispatch_get_main_queue(), ^{
                    callback(SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK);
                });
            }
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

+ (NSDate*)lastPeriodicSyncTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *time = [defaults objectForKey:SYNC_GET_KEY_PLAIN(SYNC_KEY_LAST_PERIODIC_SYNC_TIME)];
    if (SYNC_IS_NULL(time)){
        return nil;
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

+ (void)setLastPeriodicSyncTime:(NSDate*)time
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:time forKey:SYNC_GET_KEY_PLAIN(SYNC_KEY_LAST_PERIODIC_SYNC_TIME)];
    [defaults synchronize];
}

@end
