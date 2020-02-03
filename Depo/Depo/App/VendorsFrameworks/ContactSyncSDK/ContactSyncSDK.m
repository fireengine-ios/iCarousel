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
#import "PartialInfo.h"
#import "BackupStats.h"

@interface SyncHelper : NSObject


/*
 * Backup Values
 */
@property (strong) NSMutableSet *deletedLocalContactRemoteIds;
@property (strong) NSMutableSet *remoteUpdatedContactRemoteIds;
@property (strong) NSMutableDictionary *dirtyRemoteContacts;    // ObjectID(LocalID), Contact
@property (strong) NSMutableArray *allContacts;


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
@property PartialInfo *partialInfo;

@property (nonatomic, copy) void (^backupCallback)();

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
@property BOOL CANCELLED;

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
    self.CANCELLED = false;

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
    if (callback){
        dispatch_async( dispatch_get_main_queue(), ^{
            callback(willMerge, willDelete);
            
        });
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
    if (self.CANCELLED){
        return;
    }
    self.nameMap = [NSMutableDictionary new];
    self.nameDuplicateMap = [NSMutableDictionary new];

    [self notifyProgress:ANALYZE_STEP_FIND_DUPLICATES progress:@(0)];

    NSMutableArray *contacts = [[ContactUtil shared] fetchLocalContacts];
    self.initialContactCount = [contacts count];

    if (!SYNC_IS_NULL(contacts) && [contacts count]>0){
        SYNC_Log(@"Count: %ld", (long)[contacts count]);
        NSInteger counter = 0;
        for (Contact *contact in contacts){
            if (self.CANCELLED){
                return;
            }
            counter++;
            if (counter % 100 == 0){
                [self notifyProgress:@(counter*100/self.initialContactCount)];
            }
            NSString *nameForCompare = contact.nameForCompare;
            if (!SYNC_IS_NULL(contact) && !SYNC_STRING_IS_NULL_OR_EMPTY(nameForCompare)){
                SYNC_Log(@"Contact: %@", [contact.objectId stringValue]);
                if (!SYNC_IS_NULL([self.nameMap objectForKey:nameForCompare])){
                    SYNC_Log(@"Duplicate contact: %@ is found for contact :%@.", [contact.objectId stringValue], [self.nameMap objectForKey:nameForCompare].objectId)
                    if (!SYNC_ARRAY_IS_NULL_OR_EMPTY([self.nameDuplicateMap objectForKey:nameForCompare])){
                        [[self.nameDuplicateMap objectForKey:nameForCompare] addObject:contact];
                    }
                    else{
                        NSMutableArray<Contact*>*duplicateList = [NSMutableArray new];
                        [duplicateList addObject:[self.nameMap objectForKey:nameForCompare]];
                        [duplicateList addObject:contact];
                        [self.nameDuplicateMap setObject:duplicateList forKey:nameForCompare];
                    }
                }
                else{
                    [self.nameMap setObject:contact forKey:nameForCompare];
                }
            }
            else{
                SYNC_Log(@"Contact: %@ is null.", [contact.objectId stringValue]);
            }
        }
    }
    [self analyzeDuplicateContacts];
}

- (void)analyzeDuplicateContacts{
    if (self.CANCELLED){
        return;
    }
    [self notifyProgress:ANALYZE_STEP_PROCESS_DUPLICATES progress:@(0)];

    self.mergeMap = [NSMutableDictionary new];
    self.willMerge = [NSMutableArray new];
    self.willDelete = [NSMutableArray new];

    self.initialDuplicateCount = [self.nameDuplicateMap count];

    if (self.initialDuplicateCount > 0){
        SYNC_Log(@"Name duplicates count: %ld", (long)self.initialDuplicateCount);
        NSInteger counter = 0;
        for (NSMutableArray <Contact*>*contacts in [self.nameDuplicateMap allValues]){
            if (self.CANCELLED){
                return;
            }
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
                [willMergeMap setObject:@([[self.mergeMap objectForKey:contact] count]) forKey:contact.nameForCompare];
            }
            NSMutableArray<NSString*> *willDeleteList = [NSMutableArray new];
            for (Contact *contact in self.willDelete) {
                [willDeleteList addObject:contact.nameForCompare];
            }
            [self onNotify:willMergeMap delete:willDeleteList];
        }
    }
}

- (void)clearDuplicateContacts{
    if (self.CANCELLED){
        return;
    }
    [self notifyProgress:ANALYZE_STEP_CLEAR_DUPLICATES progress:@(0)];
    NSInteger initialDuplicateCount = [self.mergeMap count];

    if (initialDuplicateCount > 0) {
        SYNC_Log(@"Will Merge Duplicates Count : %ld" ,(long)initialDuplicateCount);
        NSInteger counter = 0;
        for (Contact *contact in [self.mergeMap allKeys]) {
            if (self.CANCELLED){
                return;
            }
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
    if (self.CANCELLED){
        return;
    }
    //Analyze is completed
    [[SyncHelper shared] setSyncing:NO];
    [AnalyzeStatus shared].status = result;
    if ([SyncSettings shared].analyzeCompleteCallback != nil) {
        [self onComplete];
    }
    NSInteger finalCount = [[ContactUtil shared] getContactCount];
    SYNC_Log(@"Final Contact count => %ld", (long)finalCount);

    // consuming too much time. we need a better solution
//    NSMutableArray *localContacts = [[ContactUtil shared] fetchLocalContacts];
//    NSInteger finalLocalCount = [localContacts count];
//    SYNC_Log(@"Final Local Contact count => %ld", (long)finalLocalCount);
    
    NSString *errorCode = nil;
    for (id item in messages)
    {
        errorCode = item[@"code"];
    }
    
    if (result != CANCELLED){
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp];
        NSString *key = [[NSString alloc] initWithFormat:@"%@-%@", intervalString, self.deviceId];
        [SyncAdapter sendStats:key start:self.initialContactCount
                        result:finalCount
                       created:0
                       updated:[self.mergeMap count]
                       deleted:[self.willDelete count]
                        status: (result == SUCCESS ? 1 : 0)
                     errorCode: errorCode
                      errorMsg: (result == SUCCESS ? nil : [[AnalyzeStatus shared] resultTypeToString:result])
                     operation: @"ANALYZE"
                      callback:nil];
    }else{
        self.CANCELLED = true;
        SYNC_Log(@"Analyze cancelled")
    }
    
    _willDelete = nil;
    
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
    
    self.mode = mode;
    [SyncSettings shared].mode = mode;
    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_INITIAL progress: 0];
    
    [[ContactUtil shared] reset];
    self.initialContactCount = -1;
    
    self.remoteUpdatedContactRemoteIds = [NSMutableSet new];
    self.localContactIds = [NSMutableSet new];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    SYNC_Log(@"Device Info:%@", [NSString stringWithCString:systemInfo.machine
                                                  encoding:NSUTF8StringEncoding]);
    
    self.initialContactCount = [[ContactUtil shared] getContactCount];

    _partialInfo = [[PartialInfo alloc] initWithCount:self.initialContactCount mode:_mode];
    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_INITIAL progress: 50];
    SYNC_Log(@"%@", [_partialInfo print]);
    
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
    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_INITIAL progress: 60];
    
    if (_mode == SYNCBackup){
        [self resolveMsisdn];
        return;
    } else {
        if ([SyncSettings shared].environment != SYNCDevelopmentEnvironment) {
            [DepoAdapter getUploadURL:^(id response, BOOL isSuccess) {
                if (isSuccess) {
                    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_INITIAL progress: 65];
                    SYNC_Log(@"Depo URL %@", response);
                    if (response == nil) {
                        [self endOfSyncCycleError:SYNC_RESULT_ERROR_DEPO response: nil];
                        return;
                    }
                    
                    NSString *value = response[@"value"];
                    if (SYNC_STRING_IS_NULL_OR_EMPTY(value)) {
                        [self endOfSyncCycleError:SYNC_RESULT_ERROR_DEPO response: nil];
                        return;
                    }
                    
                    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_INITIAL progress: 100];
                    [self uploadVCF:value];
                } else {
                    SYNC_Log(@"Error while getting upload url %@", response);
                    [self endOfSyncCycleError:SYNC_RESULT_ERROR_DEPO response: response];
                }
            }];
        } else {
            [self resolveMsisdn];
        }
        return;
    }
}

// SHARED
- (void)resolveMsisdn {
    /*
     * MSISDN value should be defined here. checkStatus request msisdn value.
     */
    SYNC_Log(@"Resolve MSISDN");
    [SyncAdapter checkStatus:@"x" callback:^(id response, BOOL isSuccess) {
        if (isSuccess){
            SYNC_Log(@"MSISDN resolved");
            
            self.lastSync = [[ContactSyncSDK lastSyncTime] longLongValue];
            
            if (_mode == SYNCBackup) {
                [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_INITIAL progress: 100];
                [self startPartialBackup];
            } else {
                [self fetchLocalContactsForRestore];
            }
        }else{
            [self endOfSyncCycleError:SYNC_RESULT_ERROR_REMOTE_SERVER response: response];
        }
    }];
}

// ######## BACKUP FUNCTIONS ########

-(void) startPartialBackup{
    [self setBackupCallbackHandler];
    [self fetchLocalContactsForBackup];
}

-(void) setBackupCallbackHandler {
    [SyncHelper shared].backupCallback = ^void() {
        [self.partialInfo stepUp];
        [self fetchLocalContactsForBackup];
    };
}

- (void)fetchLocalContactsForBackup
{
    SYNC_Log(@"fetchLocalContactsForBackup");
    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_READ_LOCAL_CONTACTS progress: 0];
    NSMutableArray *contacts = [[ContactUtil shared] fetchContacts:_partialInfo.bulkCount offset:_partialInfo.calculateOffset];
    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_READ_LOCAL_CONTACTS progress: 10];
    
    self.allContacts = [NSMutableArray new];
    if (!SYNC_IS_NULL(contacts) && [contacts count]>0){
        SYNC_Log(@"Contacts count: %zd", [contacts count]);
        [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_READ_LOCAL_CONTACTS progress: 15];
        
        int counter = 0;
        for (Contact *contact in contacts){
            counter++;
            if ([Utils notify:counter size:[contacts count]]) {
                [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_READ_LOCAL_CONTACTS progress: 85 * (counter * 100 / [contacts count]) / 100];
            }
            if (!SYNC_IS_NULL(contact)) {
                if (SYNC_STRING_IS_NULL_OR_EMPTY(contact.generateDisplayName)) {
                    SYNC_Log(@"Contact display name is empty %@", [contact objectId]);
                    continue;
                } else if ([contact.generateDisplayName length] > 1000) {
                    SYNC_Log(@"Contact display name is not valid %@", [contact objectId]);
                    continue;
                }
                SYNC_Log(@"Contact : %@", [contact objectId]);
                if (![_localContactIds containsObject:[contact objectId]]) {
                    [_localContactIds addObject:[contact objectId]];
                    
                    [[ContactUtil shared] fetchNumbers:contact];
                    [[ContactUtil shared] fetchEmails:contact];
                    [[ContactUtil shared] fetchAddresses:contact];
                    [_allContacts addObject:contact];
                }
            } else {
                SYNC_Log(@"Contact is null");
            }
        }
    }
    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_READ_LOCAL_CONTACTS progress: 100];
    [self submitDirtyRecordsForBackup];
}

- (void)submitDirtyRecordsForBackup
{
    SYNC_Log(@"submitDirtyRecordsForBackup");
    
    NSArray *it = [_allContacts copy];
    SYNC_Log(@"allContacts : %@", @(_allContacts.count));
    
    BackupHelper *backupHelper = [BackupHelper new];
    backupHelper.partialInfo = [self partialInfo];
    NSArray *contacts = [backupHelper startAnalyze:it];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.updateId = [defaults objectForKey:SYNC_KEY_CHECK_UPDATE];
    SYNC_Log(@"Progress Key : %@ %@",self.updateId,self.partialInfo)
    
    if (!self.partialInfo.isFirstStep && !self.partialInfo.isLastStep && [contacts count]==0){
        SYNC_Log(@"Ignore this step %zd", self.partialInfo.currentStep);
        if (self.backupCallback!=nil){
            self.backupCallback();
        }
        return;
    }
    
    [SyncAdapter partialBackup:self.updateId deviceId:_deviceId dirtyContacts:contacts deletedContacts:nil duplicates:nil step:@(self.partialInfo.currentStep) totalStep:@(self.partialInfo.totalStep) callback:^(id response, BOOL isSuccess) {
        if (isSuccess){
            SYNC_Log(@"partialBackup");
            NSString *data = response[SYNC_JSON_PARAM_DATA];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if(!SYNC_IS_NULL(data) || ![data isEqualToString:@""] )
                [defaults setObject:data forKey:SYNC_KEY_CHECK_UPDATE];
            self.updateId = data;
            
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

-(void)checkProgressStatusForBackup{
    SYNC_Log(@"checkProgressStatusForBackup");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [SyncAdapter checkStatus:self.updateId callback:^(id response, BOOL isSuccess) {
        if (isSuccess && !SYNC_IS_NULL(response)){
            NSDictionary *data = response[SYNC_JSON_PARAM_DATA];
            if (SYNC_IS_NULL(data)){
                if ([self.partialInfo isLastStep]){
                    [defaults removeObjectForKey:SYNC_KEY_CHECK_UPDATE];
                    [defaults synchronize];
                }
                
                SYNC_Log(@"%@", @"Possible network error");
                [self endOfSyncCycle:SYNC_RESULT_ERROR_NETWORK];
                return;
            }
            NSString *status = data[@"status"];
            if ([@"COMPLETED" isEqualToString:status] || [@"BULK_COMPLETED" isEqualToString:status]){
                [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_SERVER_IN_PROGRESS progress: 100];
                
                [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_PROCESSING_RESPONSE progress: 0];
                if (_partialInfo.isLastStep){
                    [defaults removeObjectForKey:SYNC_KEY_CHECK_UPDATE];
                    [defaults synchronize];
                }
                
                NSNumber *timestamp = data[@"timestamp"];
                NSString *resultString = data[@"result"];
                NSNumber *totalCount = data[@"totalCount"];
                [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_PROCESSING_RESPONSE progress: 20];
                
                NSData *data = [resultString dataUsingEncoding:NSUTF8StringEncoding];\
                NSDictionary *res = nil;
                if (!SYNC_IS_NULL(data)) {
                    res = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                }
                
                [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_PROCESSING_RESPONSE progress: 40];
                if (!SYNC_IS_NULL(res)) {
                    NSDictionary *stats = res[@"stats"];
                    NSNumber *created = stats[@"created"];
                    NSNumber *deleted = stats[@"deleted"];
                    NSNumber *updated = stats[@"updated"];

                    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_PROCESSING_RESPONSE progress: 60];
                    
                    [[SyncStatus shared] addEmpty:created state:SYNC_INFO_NEW_CONTACT_ON_SERVER];
                    [[SyncStatus shared] addEmpty:deleted state:SYNC_INFO_DELETED_ON_SERVER];
                    [[SyncStatus shared] addEmpty:updated state:SYNC_INFO_UPDATED_ON_SERVER];

                    [SyncStatus shared].totalContactOnServer = totalCount;
                    [SyncStatus shared].totalContactOnClient = [NSNumber numberWithInteger:0];

                    if (!SYNC_NUMBER_IS_NULL_OR_ZERO(timestamp)){
                        [ContactSyncSDK setLastSyncTime:timestamp]; // Store client last sync time
                    }
                    SYNC_Log(@"%@", @"SUCCESS");

                    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_PROCESSING_RESPONSE progress: 100];
                    
                    [self endOfSyncCycle:SYNC_RESULT_SUCCESS];
                } else {
                    [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER];
                }
            } else if ([@"ERROR" isEqualToString:data[@"status"]]) {
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
                    SYNC_Log(@"Server progress: %f", [data[@"progress"] doubleValue]);
                    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_SERVER_IN_PROGRESS progress: [data[@"progress"] doubleValue]];
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

// ######## RESTORE FUNCTIONS ########

- (void)fetchLocalContactsForRestore
{
    SYNC_Log(@"fetchLocalContactsForRestore");
    self.initialContactCount = [[ContactUtil shared] getContactCount];
    [self submitDirtyRecordsForRestore];
}

- (void)submitDirtyRecordsForRestore
{
    SYNC_Log(@"submitDirtyRecordsForRestore");
    [SyncAdapter restoreContactsWithTimestamp:0 deviceId:_deviceId callback:^(id response, BOOL isSuccess) {
        if (isSuccess){
            NSString *data = response[SYNC_JSON_PARAM_DATA];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if(!SYNC_STRING_IS_NULL_OR_EMPTY(data))
                [defaults setObject:data forKey:SYNC_KEY_CHECK_UPDATE];

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

- (void)checkProgressStatusForRestore
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.updateId = [defaults objectForKey:SYNC_KEY_CHECK_UPDATE];
    
    [SyncAdapter checkStatus:self.updateId callback:^(id response, BOOL isSuccess) {
        if (isSuccess && !SYNC_IS_NULL(response)){
            NSDictionary *data = response[SYNC_JSON_PARAM_DATA];
            if (SYNC_IS_NULL(data)){
                [defaults removeObjectForKey:SYNC_KEY_CHECK_UPDATE];
                [defaults synchronize];
                
                SYNC_Log(@"%@", @"DATA is null");
                [self endOfSyncCycle:SYNC_RESULT_ERROR_NETWORK];
                return;
            }
            NSString *status = data[@"status"];
            if ([@"COMPLETED" isEqualToString:status]){
                [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_SERVER_IN_PROGRESS progress: 100];
                
                [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_PROCESSING_RESPONSE progress: 0];
                
                [defaults removeObjectForKey:SYNC_KEY_CHECK_UPDATE];
                [defaults synchronize];
                
                NSNumber *timestamp = data[@"timestamp"];
                NSString *resultString = data[@"result"];
                if (resultString != nil) {
                    SYNC_Log(@"Parse contacts");
                    NSData *dataResultOut = [resultString dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *resultOut = [NSJSONSerialization JSONObjectWithData:dataResultOut options:0 error:nil];
                    
                    NSMutableDictionary *resultContacts = [NSMutableDictionary new];
                    for (NSDictionary *item in resultOut[@"result"]){
                        Contact *c = [[Contact alloc] initWithDictionary:item];
                        if (!SYNC_IS_NULL(c)) {
                            NSMutableArray *cs = [resultContacts objectForKey:c.nameForCompare];
                            if (cs != nil) {
                                [cs addObject:c];
                            } else {
                                cs = [NSMutableArray new];
                                [cs addObject:c];
                                [resultContacts setObject:cs forKey:c.nameForCompare];
                            }
                        }
                    }
                    
                    SYNC_Log(@"Result contacts %zd", [resultContacts count]);
                    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_PROCESSING_RESPONSE progress: 100];
                    
                    RestoreHelper *ra = [RestoreHelper new];
                    ra.partialInfo = [self partialInfo];
                    [ra startAnalyze:resultContacts];
                    
                    if (!SYNC_NUMBER_IS_NULL_OR_ZERO(timestamp)){
                        [ContactSyncSDK setLastSyncTime:timestamp];
                    }
                    
                    [SyncStatus shared].totalContactOnServer = [NSNumber numberWithInteger:0];
                    [SyncStatus shared].totalContactOnClient = [NSNumber numberWithInteger:[[ContactUtil shared] getContactCount]];
                    
                    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_ANALYZE progress: 100];
                    
                    [[ContactUtil shared] reset];

                    SYNC_Log(@"%@", @"SUCCESS");
                    [self endOfSyncCycle:SYNC_RESULT_SUCCESS];
                } else {
                    SYNC_Log(@"%@", @"REMOTE_SERVER_ERROR");
                    [self endOfSyncCycle:SYNC_RESULT_ERROR_REMOTE_SERVER];
                }
            } else if ([@"ERROR" isEqualToString:data[@"status"]]) {
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
                    SYNC_Log(@"Server progress: %f", [data[@"progress"] doubleValue]);
                    [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_SERVER_IN_PROGRESS progress: [data[@"progress"] doubleValue]];
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
    if (result == SYNC_RESULT_ERROR_NETWORK || result == SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK || result == SYNC_RESULT_ERROR_REMOTE_SERVER || result == SYNC_RESULT_ERROR_DEPO){
        syncing = false;
        
        if (result == SYNC_RESULT_ERROR_DEPO) {
            [SyncStatus shared].status = result;
            [self callStats:messages];
            return;
        }
    } else {
        if (!self.partialInfo || [self.partialInfo isLastStep]){
            syncing = false;
            [self.partialInfo erase];
        }
    }
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = self.updateId == nil ? [defaults objectForKey:SYNC_KEY_CHECK_UPDATE]: self.updateId;
    [SyncAdapter sendStats:key start:self.initialContactCount
                                result:finalCount
                                created:[[SyncStatus shared].createdContactsReceived count]
                                updated:[[SyncStatus shared].updatedContactsReceived count]
                                deleted:[[SyncStatus shared].deletedContactsOnDevice count]
                                status: (result == SYNC_RESULT_SUCCESS ? 1 : 0)
                                errorCode: errorCode
          errorMsg:(result == SYNC_RESULT_SUCCESS ? nil : [[SyncStatus shared] resultTypeToString:result]) callback:^(id response, BOOL success) {
              if (success){
                  BackupStats *stats = [[BackupStats alloc] initWithDictionary:response[@"data"]];
                  [SyncStatus shared].deletedOnServer = stats.deletedOnServer;
                  [SyncStatus shared].createdOnServer = stats.createdOnServer;
                  [SyncStatus shared].updatedOnServer = stats.updatedOnServer;
                  [SyncStatus shared].mergedOnServer = stats.mergedOnServer;
                  
                  if ([self.partialInfo isLastStep]){
                      [self callStats:messages];
                  }
              } else {
                  [self callStats:messages];
              }
    }];
    
    if (self.startNewSync){
        self.startNewSync = NO;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self startSyncing:_mode];
        });
    } else {
        if ([self.partialInfo isLastStep] || !syncing){
            [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_UPLOAD_LOG progress: 0];
            [[SyncLogger shared] stopLogging];
            [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_UPLOAD_LOG progress: 100];
        } else {
            if (self.backupCallback){
                self.backupCallback();
            }
        }
    }
    
    
}

- (void)callStats:(id)messages
{
    if (!syncing){
        void (^callback)(id) = [SyncSettings shared].callback;
        if (callback){
            dispatch_async( dispatch_get_main_queue(), ^{
                callback(messages);
                
            });
        }
    }
}

-(void)uploadVCF:(NSString*)depoURL{
    NSString *vcf = [[ContactUtil shared] getCards:[self partialInfo]];
    
    [DepoAdapter uploadVCF:[self deviceId] url:depoURL source:vcf callback:^(id response, BOOL isSuccess) {
        if (isSuccess) {
            [[SyncStatus shared] notifyProgress:[self partialInfo] step:SYNC_STEP_VCF progress: 100];
            SYNC_Log(@"File uploaded");
            
            [self resolveMsisdn];
        } else {
            SYNC_Log(@"Error while uploading vcf %@", response);
            [self endOfSyncCycleError:SYNC_RESULT_ERROR_DEPO response: response];
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

                SyncHelper *helper = [SyncHelper shared];
                [helper startSyncing:mode];
            } else {
                SYNC_Log(@"%@", @"Sorry, user did not grant access to address book");
                [[SyncHelper shared] endOfSyncCycle:SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK];
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
                SyncHelper *helper = [SyncHelper shared];
                [helper startSyncing:SYNCBackup];
            } else if (result == SYNC_RESULT_FAIL){
                SYNC_Log(@"%@", @"Sorry, sync result is unsuccessful. Periodic backup has failed.");
                [[SyncHelper shared] endOfSyncCycle:SYNC_RESULT_FAIL];
            } else {
                SYNC_Log(@"%@", @"Sorry, user did not grant access to address book. Periodic backup has failed.");
                [[SyncHelper shared] endOfSyncCycle:SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK];
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
    return [[SyncHelper shared] isRunning];
}

+ (void)cancelAnalyze
{
    [[AnalyzeStatus shared] reset];
    [[AnalyzeHelper shared] endOfAnalyzeCycle:CANCELLED];
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
            if ([[ContactUtil shared] getContactCount]>0){
                if (callback!=nil){
                    dispatch_async( dispatch_get_main_queue(), ^{
                        callback(SYNC_RESULT_SUCCESS);
                    });
                }
                return;
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
