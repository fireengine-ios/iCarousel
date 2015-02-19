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
@property (strong) NSMutableArray *remoteContacts;
@property (strong) NSMutableArray *localContacts;

@property (strong) SyncDBUtils *db;

@property long long lastSync;

- (void) startSyncing;

@end

@interface ContactSyncSDK ()

@property (strong) NSTimer *timer;
@property BOOL periodic;

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

- (void) startSyncing
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
    
    [self fetchRemoteContacts];
}

- (void)fetchRemoteContacts
{
    [SyncAdapter getContacts:^(id response, BOOL success) {
        if (success){
            NSDictionary *data = response[SYNC_JSON_PARAM_DATA];
            NSArray *items = data[SYNC_JSON_PARAM_ITEMS];
            
            for (NSDictionary *item in items){
                Contact *contact = [[Contact alloc] initWithDictionary:item];
                if (![_remoteContactIds containsObject:[contact remoteId]]){
                    [_remoteContactIds addObject:[contact remoteId]];
                    if ([contact.remoteUpdateDate longLongValue] > _lastSync
                        || ![_db hasRemoteId:contact.remoteId] ){
                        // we are only interested with updated contacts
                        [_remoteContacts addObject:contact];
                    }
                }
            }
            
            // we got all records
            [self fetchLocalContacts];
        } else {
            [self endOfSyncCycle:response==nil?SYNC_RESULT_ERROR_REMOTE_SERVER:SYNC_RESULT_ERROR_NETWORK];
        }
    }];
}

- (void)fetchLocalContacts
{
    self.dirtyContacts = [NSMutableDictionary new];
    self.localContacts = [NSMutableArray new];
    NSMutableArray *contacts = [[ContactUtil shared] fetchContacts];
    if (!SYNC_IS_NULL(contacts) && [contacts count]>0){
        for (Contact *contact in contacts){
            if (!SYNC_IS_NULL(contact) && ![_localContactIds containsObject:[contact objectId]]){
                [_localContactIds addObject:[contact objectId]];
                if ([_db isDirty:contact]){
                    // we can have its details, otherwise not interested
                    [[ContactUtil shared] fetchNumbers:contact];
                    [[ContactUtil shared] fetchEmails:contact];
                    
                    [_dirtyContacts setObject:contact forKey:[contact objectId]];
                }
                [_localContacts addObject:contact];
            }
        }
    }
    [self allRecordsAreFetched];
}

- (void)allRecordsAreFetched
{
    NSArray *records = [_db fetch];
    NSMutableSet *existingRemote = [[NSMutableSet alloc] initWithCapacity:records.count];
    for (SyncRecord *rec in records){
        [existingRemote addObject:rec.remoteId];
    }
    
    for (Contact *remoteContact in _remoteContacts){
        [self checkContactExists:remoteContact cache:existingRemote];
    }
    
    [self findDeletedRecords];
    [self submitDirtyRecords];
    
}

- (void)checkContactExists:(Contact*)remoteContact cache:(NSMutableSet*)existing
{
    SyncRecord *record = nil;
    if (![existing containsObject:remoteContact.remoteId]){
        // remote contact is not in local db
        SYNC_Log(@"remote contact is not in local db : %@",[remoteContact displayName]);
        
        //check for duplicates
        Contact *duplicate = [[ContactUtil shared] findDuplicate:remoteContact cache:_localContacts];
        if (duplicate==nil){
            // this is a new record, clear IDs
            remoteContact.recordRef = nil;
            remoteContact.objectId = nil;
            
            [[ContactUtil shared] save:remoteContact];
            
            [[SyncStatus shared] addContact:remoteContact state:SYNC_INFO_NEW_CONTACT_ON_DEVICE];
        } else {
            remoteContact.objectId = duplicate.objectId;
            remoteContact.localUpdateDate = duplicate.localUpdateDate;
            [_dirtyContacts removeObjectForKey:remoteContact.objectId];
        }
        
        record = [SyncRecord new];
        record.localId = remoteContact.objectId;
        record.remoteId = remoteContact.remoteId;
        record.localUpdateDate = SYNC_DATE_AS_NUMBER([NSDate date]);
    } else {
        NSArray *records = [_db fetch:[NSString stringWithFormat:@"%@=%@",COLUMN_REMOTE_ID,remoteContact.remoteId]];
        record = records[0];
        
        remoteContact.objectId = record.localId;
        
        Contact *localContact = _dirtyContacts[record.localId];
        if (SYNC_IS_NULL(localContact)){
            localContact = [[ContactUtil shared] findContactById:record.localId];
            if (!SYNC_IS_NULL(localContact)){
                [[ContactUtil shared] fetchNumbers:localContact];
                [[ContactUtil shared] fetchEmails:localContact];
            }
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
            [[SyncStatus shared] addContact:remoteContact state:SYNC_INFO_UPDATED_ON_DEVICE];
        }
        [_dirtyContacts removeObjectForKey:remoteContact.objectId];
        
        NSNumber* updateDate = [[ContactUtil shared] localUpdateDate:remoteContact.objectId];
        if (SYNC_IS_NULL(updateDate)){
            updateDate = SYNC_DATE_AS_NUMBER([NSDate date]);
        }
        record.localUpdateDate = updateDate;
    }
    
    [_localContactIds addObject:remoteContact.objectId];
    
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
        SYNC_Log(@"Deleting row : %@", record.localId);
        if ([[ContactUtil shared] deleteContact:record.localId]){
            [toBeDeleted addObject:record.localId];
            
            [[SyncStatus shared] addRecord:record state:SYNC_INFO_DELETED_ON_DEVICE];
        }
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
        [self endOfSyncCycle:SYNC_RESULT_SUCCESS];
    } else {
        NSArray *contacts =[_dirtyContacts allValues];
        [SyncAdapter updateContacts:contacts callback:^(id response, BOOL isSuccess) {
            if (isSuccess){
                NSNumber *timestamp = response[SYNC_JSON_PARAM_DATA][@"timestamp"];
                NSArray *data = response[SYNC_JSON_PARAM_DATA][@"result"];
                NSDate *now = [NSDate date];
                for (int i=0;i<[data count];i++){
                    NSNumber *item = data[i];
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
                
                [self endOfSyncCycle:SYNC_RESULT_SUCCESS];
            } else {
                syncing = false;
                [self endOfSyncCycle:response==nil?SYNC_RESULT_ERROR_REMOTE_SERVER:SYNC_RESULT_ERROR_NETWORK];
            }
        }];
        
    }
}

- (void)endOfSyncCycle:(SYNCResultType)result
{
    [SyncAdapter getServerTime:^(id response, BOOL isSuccess) {
        syncing = false;
        void (^callback)(void) = [SyncSettings shared].callback;
        if (isSuccess && !SYNC_IS_NULL(response)){
            NSNumber *time = response[SYNC_JSON_PARAM_DATA];
            if (!SYNC_NUMBER_IS_NULL_OR_ZERO(time)){
                [ContactSyncSDK setLastSyncTime:time];
            }
            [SyncStatus shared].status = result;
            
            if (callback){
                callback();
            }
        } else {
            [SyncStatus shared].status = SYNC_IS_NULL(response)?SYNC_RESULT_ERROR_NETWORK:SYNC_RESULT_ERROR_REMOTE_SERVER;
            if (callback){
                callback();
            }
        }
    }];
}

@end

@implementation ContactSyncSDK

+ (void)doSync
{
    SYNC_Log(@"%@",[[SyncSettings shared] endpointUrl]);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ContactUtil shared] checkAddressbookAccess:^(BOOL hasAccess) {
            if (hasAccess){
                ContactSyncSDK *sdk = [ContactSyncSDK shared];
                if ([SyncSettings shared].periodicSync){
                    [sdk setupTimer];
                }
                [sdk fireSynch];
            } else {
                SYNC_Log(@"Sorry, user did not grant access to address book");
                [[SyncHelper new] endOfSyncCycle:SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK];
            }
        }];
    });
}

+ (void)runInBackground
{
    [[ContactSyncSDK shared] fireSynch];
}

- (void)setupTimer
{
    //do nothing if already has a timer
    if (self.timer && [self.timer isValid]){
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval interval = [SyncSettings shared].syncInterval*60;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(fireSynch) userInfo:nil repeats:YES];
    });
    
}

- (void)fireSynch
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ContactUtil shared] checkAddressbookAccess:^(BOOL hasAccess) {
            SyncHelper *helper = [SyncHelper new];
            if (hasAccess){
                [helper startSyncing];
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
    if (sdk.timer && [sdk.timer isValid]){
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
