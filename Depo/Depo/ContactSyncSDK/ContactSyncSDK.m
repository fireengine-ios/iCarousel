//
//  ContactSyncSDK.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "ContactSyncSDK.h"
#import "ContactUtil.h"

@interface SyncHelper : NSObject

@property (strong) NSMutableDictionary *dirtyContacts;
@property (strong) NSMutableSet *localContactIds;
@property (strong) NSMutableSet *remoteContactIds;
@property (strong) NSMutableSet *dirtyRemoteContactIds;
@property (strong) NSMutableArray *remoteContacts;
@property (strong) NSMutableArray *localContacts;
@property (strong) NSMutableDictionary *localContactIdCache;
@property (strong) NSMutableDictionary *preCheckCache;
@property SYNCMode mode;

@property (strong) SyncDBUtils *db;

@property long long lastSync;

@property BOOL startNewSync;

- (void)startSyncing:(SYNCMode)mode;
- (BOOL)isRunning;

@end

@interface ContactSyncSDK ()

@property (strong) NSTimer *timer;
@property (strong) NSTimer *firstTimer;
@property BOOL periodic;
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
    
    self.lastSync = [[ContactSyncSDK lastSyncTime] longLongValue];
    self.remoteContactIds = [NSMutableSet new];
    self.localContactIds = [NSMutableSet new];
    self.remoteContacts = [NSMutableArray new];
    self.mode = mode;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [defaults objectForKey:SYNC_KEY_CHECK_UPDATE];
    if (!SYNC_IS_NULL(key)){
        _startNewSync = YES;
        [self checkUpdateStatus];
        
        return;
    }
    
    [self fetchRemoteContacts];
}

- (BOOL)isRunning
{
    return syncing;
}

- (void)fetchLocalContacts
{
    self.dirtyContacts = [NSMutableDictionary new];
    self.localContacts = [NSMutableArray new];
    self.localContactIdCache = [NSMutableDictionary new];
    self.preCheckCache = [NSMutableDictionary new];
    self.dirtyRemoteContactIds = [NSMutableSet new];
    
    NSMutableArray *contacts = [[ContactUtil shared] fetchContacts];
    if (!SYNC_IS_NULL(contacts) && [contacts count]>0){
        for (Contact *contact in contacts){
            if (!SYNC_IS_NULL(contact) && ![_localContactIds containsObject:[contact objectId]]){
                [_localContactIds addObject:[contact objectId]];
                if ([_db isDirty:contact]){
                    if (_mode==SYNCRestore) {
                        //In restore mode, only interest with local dirty contacts ids
                        if (!SYNC_IS_NULL(contact.remoteId)) {
                            [self.dirtyRemoteContactIds addObject:contact.remoteId];
                        }
                    }else{
                        // we can have its details, otherwise not interested
                        [[ContactUtil shared] fetchNumbers:contact];
                        [[ContactUtil shared] fetchEmails:contact];
                        
                        [_dirtyContacts setObject:contact forKey:[contact objectId]];
                    }
                }
                [self addLocalContactCache:contact];
            }
        }
        
        if (_mode==SYNCRestore) {
            //In Restore mode, find deleted contact from address book and delete records about them in db. Delete contact completely
            NSString *idList = [[_localContactIds allObjects] componentsJoinedByString:@","];
            NSArray *records = [_db fetch:[NSString stringWithFormat:@"%@ NOT IN (%@)", COLUMN_LOCAL_ID, idList]];
            NSMutableArray *deletedLocalsContact=[[NSMutableArray alloc]init];
            for (SyncRecord *rec in records) {
                [deletedLocalsContact addObject:rec.localId];
            }
            [_db deleteRecords:deletedLocalsContact];
        }
    }
    
}
- (void)fetchRemoteContacts
{
    [SyncAdapter getContacts:^(id response, BOOL success) {
        if (success){
            NSDictionary *data = response[SYNC_JSON_PARAM_DATA];
            NSArray *items = data[SYNC_JSON_PARAM_ITEMS];
            [self fetchLocalContacts];

            for (NSDictionary *item in items){
                Contact *contact = [[Contact alloc] initWithDictionary:item];
                if (![_remoteContactIds containsObject:[contact remoteId]]){
                    [_remoteContactIds addObject:[contact remoteId]];
                    if ([contact.remoteUpdateDate longLongValue] > _lastSync
                        || ![_db hasRemoteId:contact.remoteId]
                        || (_mode==SYNCRestore && [_dirtyRemoteContactIds containsObject:contact.remoteId])){
                        // we are only interested with updated contacts
                        [_remoteContacts addObject:contact];
                    }
                }
            }

            [_remoteContacts sortUsingComparator:^NSComparisonResult(Contact *obj1, Contact *obj2) {

                if ([[obj1 displayName] isEqualToString:[obj2 displayName]]) {
                    if (obj1.devices.count > obj2.devices.count ) {
                        return (NSComparisonResult) NSOrderedAscending;
                    }
                    if (obj1.devices.count < obj2.devices.count ) {
                        return (NSComparisonResult)NSOrderedDescending;
                    }
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            // we got all records
            [self allRecordsAreFetched];
        } else {
            [self endOfSyncCycle:response==nil?SYNC_RESULT_ERROR_REMOTE_SERVER:SYNC_RESULT_ERROR_NETWORK];
        }
    }];
}


- (void)allRecordsAreFetched
{
    NSArray *records = [_db fetch];
    NSMutableSet *existingRemote = [[NSMutableSet alloc] initWithCapacity:records.count];
    for (SyncRecord *rec in records){
        [existingRemote addObject:rec.remoteId];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (Contact *remoteContact in _remoteContacts){
            [self checkContactExists:remoteContact cache:existingRemote];
        }
        
        if (_mode == SYNCBackup){
            //No local deletion on Restore mode
            [self findDeletedRecords];
        }else{
            //Don't need to submit dirtycontact on restore mode
            [_dirtyContacts removeAllObjects];
        }
        [self submitDirtyRecords];
    });
    
}
- (Contact*)findContactWithRecord:(NSNumber*)localId{
    Contact* contact = nil;
    if (!SYNC_IS_NULL(localId)){
        contact = [self.localContactIdCache objectForKey:localId];
    }
    return contact;
}
- (void)addLocalContactCache:(Contact*)contact
{
    NSString *key = [contact displayName];
    NSMutableArray *preCheckArray = [_preCheckCache objectForKey:key];
    if (SYNC_IS_NULL(preCheckArray)){
        preCheckArray = [NSMutableArray new];
    }
    [preCheckArray addObject:contact];
    [_preCheckCache setObject:preCheckArray forKey:key];
    
    [_localContacts addObject:contact];
    SYNC_SET_DICT_IF_NOT_NIL(_localContactIdCache, contact, contact.objectId);
}
- (void)checkContactExists:(Contact*)remoteContact cache:(NSMutableSet*)existing
{
    SyncRecord *record = nil;
    if (![existing containsObject:remoteContact.remoteId]){
        // remote contact is not in local db
        SYNC_Log(@"remote contact is not in local db : %@",[remoteContact displayName]);
        
        //check for duplicates
        Contact *duplicate = nil;
        
        NSMutableArray *contacts = [_preCheckCache objectForKey:[remoteContact displayName]];
        if (!SYNC_IS_NULL(contacts)){
            duplicate = [self findDuplicate:remoteContact cache:contacts];
        }
        if (duplicate==nil){
            if (_mode==SYNCBackup) {
                //No adtion contact on backup mode.
                return;
            }
            // this is a new record, clear IDs
            remoteContact.recordRef = nil;
            remoteContact.objectId = nil;
            
            [[ContactUtil shared] save:remoteContact];
            [self addLocalContactCache:remoteContact];
            [[SyncStatus shared] addContact:remoteContact state:SYNC_INFO_NEW_CONTACT_ON_DEVICE];
        } else {
            return;
        }
        
        record = [SyncRecord new];
        record.localId = remoteContact.objectId;
        record.remoteId = remoteContact.remoteId;
        record.localUpdateDate = SYNC_DATE_AS_NUMBER([NSDate date]);
    } else {
        NSArray *records = [_db fetch:[NSString stringWithFormat:@"%@=%@",COLUMN_REMOTE_ID,remoteContact.remoteId]];
        if (records.count>0) {
            record = records[0];
        }
        
        remoteContact.objectId = record.localId;
        
        //Find remote updated contact object in local device.
        Contact *localContact = [self findContactWithRecord:remoteContact.objectId];
        if (!SYNC_IS_NULL(localContact)){
            [[ContactUtil shared] fetchEmails:localContact];
            [[ContactUtil shared] fetchNumbers:localContact];
        }
        
        if (_mode == SYNCBackup && !SYNC_IS_NULL(localContact)) {
            //In backup mode,revert changes to server
            [_dirtyContacts setObject:localContact forKey:[localContact objectId]];
            return ;
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
            [localContact copyContact:remoteContact];
            [[ContactUtil shared] save:localContact];
            [self addLocalContactCache:remoteContact];
            [[SyncStatus shared] addContact:remoteContact state:SYNC_INFO_UPDATED_ON_DEVICE];
        }
        if (!SYNC_IS_NULL(remoteContact.objectId)&&!SYNC_IS_NULL(_dirtyContacts[remoteContact.objectId])) {
            [_dirtyContacts removeObjectForKey:remoteContact.objectId];
        }
        NSNumber* updateDate=nil;
        if (!SYNC_IS_NULL(remoteContact.objectId)) {
            updateDate = [[ContactUtil shared] localUpdateDate:remoteContact.objectId];
        }
        
        if (SYNC_IS_NULL(updateDate)){
            updateDate = SYNC_DATE_AS_NUMBER([NSDate date]);
        }
        record.localUpdateDate = updateDate;
    }
    if (!SYNC_IS_NULL(remoteContact.objectId)) {
         [_localContactIds addObject:remoteContact.objectId];
    }

    record.remoteUpdateDate = remoteContact.remoteUpdateDate;
    [_db save:record];
}

- (void)findDeletedRecords
{
    //delete rows which were deleted in remote
    NSString *idList = [[_remoteContactIds allObjects] componentsJoinedByString:@","];
    NSArray *records = [_db fetch:[NSString stringWithFormat:@"%@ NOT IN (%@)", COLUMN_REMOTE_ID, idList]];
    NSMutableArray *toBeDeleted = [NSMutableArray new];
    for (SyncRecord *record in records){
        [_dirtyContacts removeObjectForKey:record.localId];
        Contact *dirty =[self findContactWithRecord:record.localId];
        if ([_localContactIds containsObject:record.localId]) {
            //If a contact deleted on server in backup mode, we should send the contact to server again
            dirty.remoteId=nil;
            dirty.remoteUpdateDate=nil;
            [_dirtyContacts setObject:dirty forKey:dirty.objectId];
        }else{
            [_dirtyContacts removeObjectForKey:dirty.objectId];
        }
        SYNC_Log(@"Deleting row : %@", record.localId);
        [toBeDeleted addObject:record.localId];
    }
    if ([toBeDeleted count]>0){
        [_db deleteRecords:toBeDeleted];
    }
    //find locally deleted rows and delete on server
    idList = [[_localContactIds allObjects] componentsJoinedByString:@","];
    records = [_db fetch:[NSString stringWithFormat:@"%@ NOT IN (%@)", COLUMN_LOCAL_ID, idList]];
    toBeDeleted = [NSMutableArray new];
    for (SyncRecord *record in records){
        [SyncAdapter deleteContact:record.remoteId callback:nil];
        [toBeDeleted addObject:record.localId];
        
        [[SyncStatus shared] addRecord:record state:SYNC_INFO_DELETED_ON_SERVER];
    }
    if ([toBeDeleted count]>0){
        [_db deleteRecords:toBeDeleted];
    }
}

- (void)submitDirtyRecords
{
    if ([_dirtyContacts count]==0){
        [SyncAdapter getServerTime:^(id response, BOOL isSuccess) {
            if (isSuccess && !SYNC_IS_NULL(response)){
                NSNumber *time = response[SYNC_JSON_PARAM_DATA];
                if (!SYNC_NUMBER_IS_NULL_OR_ZERO(time)){
                    [ContactSyncSDK setLastSyncTime:time];
                }
                [self endOfSyncCycle:SYNC_RESULT_SUCCESS];
            } else {
                [self endOfSyncCycle:(SYNC_IS_NULL(response)?SYNC_RESULT_ERROR_NETWORK:SYNC_RESULT_ERROR_REMOTE_SERVER)];
            }
        }];

    } else {
        NSArray *contacts =[_dirtyContacts allValues];
        [SyncAdapter updateContacts:contacts callback:^(id response, BOOL isSuccess) {
            if (isSuccess){
                NSMutableArray *store = [NSMutableArray new];
                for (Contact *c in contacts){
                    [store addObject:c.objectId];
                }
                
                NSString *data = response[SYNC_JSON_PARAM_DATA];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:data forKey:SYNC_KEY_CHECK_UPDATE];
                [defaults setObject:store forKey:SYNC_KEY_CONTACT_STORE];
                [defaults synchronize];
                
                [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkUpdateStatus) userInfo:nil repeats:NO];
            } else {
                syncing = false;
                [self endOfSyncCycle:response==nil?SYNC_RESULT_ERROR_REMOTE_SERVER:SYNC_RESULT_ERROR_NETWORK];
            }
        }];
        
    }
}

- (Contact*)findDuplicate:(Contact*)contact cache:(NSMutableArray*)contacts
{
    NSUInteger size = [contacts count];
    Contact *duplicate = nil;
    for ( int i = 0; i < size; i++ )
    {
        Contact *c = [contacts objectAtIndex:i];
        if ([[c displayName] isEqualToString:[contact displayName]]){
            //pre check passed, continue further investigation
            [[ContactUtil shared] fetchNumbers:c];
            [[ContactUtil shared] fetchEmails:c];
            if ([c isEqual:contact]){
                contact.objectId = c.objectId;
                contact.localUpdateDate = duplicate.localUpdateDate;
                SyncRecord *record = [SyncRecord new];
                record.remoteId = contact.remoteId;
                record.localId = contact.objectId;
                record.localUpdateDate = SYNC_DATE_AS_NUMBER([NSDate date]);
                
                if (_mode==SYNCBackup && ![c isDeviceSizeEqual:contact]) {
                    c.remoteId = contact.remoteId;
                    [_dirtyContacts setObject:c forKey:c.objectId];
                }else{
                    if (_dirtyContacts[c.objectId]) {
                        [_dirtyContacts removeObjectForKey:c.objectId];
                    }
                }
                
                [_localContactIds addObject:contact.objectId];
                
                record.remoteUpdateDate = contact.remoteUpdateDate;
                [_db save:record];
                duplicate = c;
            }
        }
    }
    return duplicate;
}

- (NSArray*)restoreRecords
{
    if (SYNC_IS_NULL(_dirtyContacts) || [_dirtyContacts count] == 0){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *store = [defaults objectForKey:SYNC_KEY_CONTACT_STORE];
        if (SYNC_IS_NULL(store)){
            return [NSArray new];
        } else {
            NSMutableArray *array = [NSMutableArray new];
            for (NSNumber *objectId in store){
                Contact *c = [[ContactUtil shared] findContactById:objectId];
                NSArray *records = [_db fetch:[NSString stringWithFormat:@"%@=%@",COLUMN_LOCAL_ID,c.objectId]];
                if (!SYNC_ARRAY_IS_NULL_OR_EMPTY(records)){
                    SyncRecord *record = records[0];
                    c.remoteId = record.remoteId;
                }
                [array addObject:c];
            }
            return [array copy];
        }
    } else {
        return [_dirtyContacts allValues];
    }
}

- (void)checkUpdateStatus
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [defaults objectForKey:SYNC_KEY_CHECK_UPDATE];
    
    [SyncAdapter checkStatus:key callback:^(id response, BOOL isSuccess) {
        if (isSuccess && !SYNC_IS_NULL(response)){
            NSDictionary *data = response[SYNC_JSON_PARAM_DATA];
            if (SYNC_IS_NULL(data[@"status"])){
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE];
                [defaults removeObjectForKey:SYNC_KEY_CHECK_UPDATE];
                [defaults synchronize];
                
                [self endOfSyncCycle:SYNC_RESULT_ERROR_NETWORK];
                return;
            }
            NSString *status = data[@"status"];
            if ([@"COMPLETED" isEqualToString:status]){
                NSArray *contacts = [self restoreRecords];
                
                [defaults removeObjectForKey:SYNC_KEY_CONTACT_STORE];
                [defaults removeObjectForKey:SYNC_KEY_CHECK_UPDATE];
                [defaults synchronize];
                
                NSNumber *timestamp = data[@"timestamp"];
                NSArray *result = data[@"result"];
                NSDate *now = [NSDate date];
                
                for (int i=0;i<[result count];i++){
                    NSNumber *item = result[i];
                    if (!SYNC_NUMBER_IS_NULL_OR_ZERO(item)){
                        Contact *c = contacts[i];
                        SYNCInfoStateType state;
                        if (SYNC_IS_NULL(c.remoteId)){
                            state = SYNC_INFO_NEW_CONTACT_ON_SERVER;
                        } else {
                            state = SYNC_INFO_UPDATED_ON_SERVER;
                        }
                        c.remoteId = item;
                        
                        [[SyncStatus shared] addContact:c state:state];
                        
                        SyncRecord *record = [SyncRecord new];
                        record.localId = c.objectId;
                        record.remoteId = c.remoteId;
                        record.localUpdateDate = SYNC_DATE_AS_NUMBER(now);
                        record.remoteUpdateDate = timestamp;
                        
                        [_db save:record];
                    }
                }
                if (!SYNC_NUMBER_IS_NULL_OR_ZERO(timestamp)){
                    [ContactSyncSDK setLastSyncTime:timestamp];
                }
                
                [self endOfSyncCycle:SYNC_RESULT_SUCCESS];
            } else {
                [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(checkUpdateStatus) userInfo:nil repeats:NO];
            }
        } else {
            [self endOfSyncCycle:response==nil?SYNC_RESULT_ERROR_REMOTE_SERVER:SYNC_RESULT_ERROR_NETWORK];
        }
    }];
}

- (void)endOfSyncCycle:(SYNCResultType)result
{
    syncing = false;
    [SyncStatus shared].status = result;
    
    void (^callback)(void) = [SyncSettings shared].callback;
    if (callback){
        callback();
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
                if ([SyncSettings shared].periodicSync){
                    
                    if([SyncSettings shared].delayInterval == SYNC_DEFAULT_DELAY){
                        [sdk setupTimer];
                        [sdk fireSynch];
                    }else{
                        [sdk firstFire];
                    }
                }else{
                    [sdk fireSynch];
                }
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

+ (void)runInBackground
{
    [[ContactSyncSDK shared] fireSynch];
}
- (void)firstFire{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval delay = [SyncSettings shared].delayInterval;
        _firstTimer=[NSTimer scheduledTimerWithTimeInterval:delay*60 target:self selector:@selector(fireSynch) userInfo:nil repeats:NO];
    });
}
- (void)setupTimer
{
    //do nothing if already has a timer
    if (self.timer && [self.timer isValid]){
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger interval = [SyncSettings shared].syncInterval;
        NSInteger delay =[SyncSettings shared].delayInterval;
        NSLog(@"Timer is running");
        self.timer = [NSTimer scheduledTimerWithTimeInterval:(interval+delay)*60 target:self selector:@selector(fireSynch) userInfo:nil repeats:YES];

    });
    
}

- (void)fireSynch
{
    if (_firstTimer && [self.firstTimer isValid]) {
        [self setupTimer];
        [self.firstTimer invalidate];
        self.firstTimer =nil;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ContactUtil shared] checkAddressbookAccess:^(BOOL hasAccess) {
            SyncHelper *helper = [SyncHelper new];
            if (hasAccess){
                [helper startSyncing:_mode];
            } else {
                SYNC_Log(@"Sorry, user did not grant access to address book");
                [helper endOfSyncCycle:SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK];
            }
        }];
    });
}

+ (BOOL) automated{
    BOOL automated = [SyncSettings shared].periodicSync;
    return automated;
}

+ (void)sleep
{
    ContactSyncSDK *sdk = [ContactSyncSDK shared];
    if ((sdk.firstTimer && [sdk.firstTimer isValid])) {
        [sdk.firstTimer invalidate];
        sdk.firstTimer =nil;
    }
    if ((sdk.timer && [sdk.timer isValid])){
        [sdk.timer invalidate];
        sdk.timer = nil;
    }
}

+ (void)awake
{
    if ([ContactSyncSDK automated]){
        [[ContactSyncSDK shared] setupTimer];
    }
}

+ (void)cancel
{
    [ContactSyncSDK sleep];
    
    [SyncSettings shared].periodicSync = NO;
}

+ (NSNumber*)lastSyncTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *time = [defaults objectForKey:SYNC_KEY_LAST_SYNC_TIME];
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
    [defaults setObject:time forKey:SYNC_KEY_LAST_SYNC_TIME];
    [defaults synchronize];
}

@end
