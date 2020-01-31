//
//  SyncStatus.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "SyncStatus.h"

@implementation SyncInfo

- (instancetype)initWithContact:(Contact*)contact andState:(SYNCInfoStateType)state
{
    self = [super init];
    if (self){
        _localId = contact.objectId;
        _remoteId = contact.remoteId;
        _name = [contact generateDisplayName];
        _state = state;
    }
    return self;
}

- (instancetype)initWithRecord:(SyncRecord*)record andState:(SYNCInfoStateType)state
{
    self = [super init];
    if (self){
        _localId = record.localId;
        _remoteId = record.remoteId;
        _state = state;
    }
    return self;
}

- (instancetype)initWithEmpty:(SYNCInfoStateType)state
{
    self = [super init];
    if (self){
        _state = state;
    }
    return self;
}


@end

@implementation SyncStatus

+ (void)handleNSError:(NSError*)error
{
    SyncStatus *obj = [SyncStatus shared];
    if (!SYNC_IS_NULL(error)){
        if (!SYNC_IS_NULL(error.domain)){
            if ([NSURLErrorDomain isEqualToString:error.domain]){
                obj.status = SYNC_RESULT_ERROR_NETWORK;
            } else {
                obj.status = SYNC_RESULT_ERROR_INTERNAL;
            }
        }
        
        obj.lastError = error;
    }
}

- (void)addContact:(Contact*)contact state:(SYNCInfoStateType)state
{
    SyncInfo *info = [[SyncInfo alloc] initWithContact:contact andState:state];
    [self addItem:info];
}
- (void)addRecord:(SyncRecord*)record state:(SYNCInfoStateType)state
{
    SyncInfo *info = [[SyncInfo alloc] initWithRecord:record andState:state];
    [self addItem:info];
}
-(void)addEmpty:(NSNumber *)count state:(SYNCInfoStateType)state{
    for(int i=0; i<[count integerValue]; i++){
        SyncInfo *info = [[SyncInfo alloc] initWithEmpty:state];
        [self addItem:info];
    }
}
- (void)addItem:(SyncInfo*)object
{
    switch (object.state) {
        case SYNC_INFO_DELETED_ON_DEVICE:
           [_deletedContactsOnDevice addObject:object];
            break;
        case SYNC_INFO_DELETED_ON_SERVER:
            [_deletedContactsOnServer addObject:object];
            break;
        case SYNC_INFO_NEW_CONTACT_ON_DEVICE:
            [_createdContactsReceived addObject:object];
            break;
        case SYNC_INFO_NEW_CONTACT_ON_SERVER:
            [_createdContactsSent addObject:object];
            break;
        case SYNC_INFO_UPDATED_ON_DEVICE:
            [_updatedContactsReceived addObject:object];
            break;
        case SYNC_INFO_UPDATED_ON_SERVER:
            [_updatedContactsSent addObject:object];
            break;
    }
}

- (void)reset
{
    _createdContactsReceived = [NSMutableArray new];
    _updatedContactsReceived = [NSMutableArray new];
    _createdContactsSent = [NSMutableArray new];
    _updatedContactsSent = [NSMutableArray new];
    
    _deletedContactsOnDevice = [NSMutableArray new];
    _deletedContactsOnServer = [NSMutableArray new];
    
    _totalContactOnClient = 0;
    _totalContactOnServer = 0;
    
    _status = SYNC_RESULT_INITIAL;
    _lastError = nil;
    
    _step = SYNC_STEP_INITIAL;
    _progress = 0;
}

+ (SYNC_INSTANCETYPE) shared {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{
        SyncStatus *obj = [self new];
        instance = obj;
    });
    
    return instance;
}

- (NSString*) resultTypeToString:(SYNCResultType) type {
    NSString *result = nil;
    
    switch(type) {
        case SYNC_RESULT_SUCCESS:
            result = @"SUCCESS";
            break;
        case SYNC_RESULT_FAIL:
            result = @"RESULT_FAIL";
            break;
        case SYNC_RESULT_INITIAL:
            result = @"INITIAL";
            break;
        case SYNC_RESULT_ERROR_NETWORK:
            result = @"NETWORK_ERROR";
            break;
        case SYNC_RESULT_ERROR_INTERNAL:
            result = @"INTERNAL_ERROR";
            break;
        case SYNC_RESULT_ERROR_REMOTE_SERVER:
            result = @"SERVER_ERROR";
            break;
        case SYNC_RESULT_ERROR_PERMISSION_ADDRESS_BOOK:
            result = @"PERMISSION";
            break;
        case SYNC_RESULT_ERROR_DEPO:
            result = @"DEPO_ERROR";
            break;
        default:
            result = @"";
    }
    
    return result;
}

-(void)notifyProgress:(PartialInfo*)partialInfo step:(SYNCStep)step progress:(double)progress {
    if (partialInfo == nil) {
        return;
    }
    
    double result;
    if (progress > 100) {
        result = 100;
    } else if (progress < 0) {
        result = 0;
    } else {
        result = progress;
    }
    
    BOOL backup = [SyncSettings shared].mode == SYNCBackup;
    NSMutableDictionary *weight = [NSMutableDictionary new];
    if (backup) {
        [weight setObject:[[NSNumber alloc] initWithDouble:5.0] forKey:@(SYNC_STEP_INITIAL)];
        
        // %90
        [weight setObject:[[NSNumber alloc] initWithDouble:20.0] forKey:@(SYNC_STEP_READ_LOCAL_CONTACTS)];
        [weight setObject:[[NSNumber alloc] initWithDouble:25.0] forKey:@(SYNC_STEP_ANALYZE)];
        [weight setObject:[[NSNumber alloc] initWithDouble:50.0] forKey:@(SYNC_STEP_SERVER_IN_PROGRESS)];
        [weight setObject:[[NSNumber alloc] initWithDouble:5.0] forKey:@(SYNC_STEP_PROCESSING_RESPONSE)];
        
        [weight setObject:[[NSNumber alloc] initWithDouble:5.0] forKey:@(SYNC_STEP_UPLOAD_LOG)];
    } else {
        [weight setObject:[[NSNumber alloc] initWithDouble:5.0] forKey:@(SYNC_STEP_INITIAL)];
        
        // %90
        [weight setObject:[[NSNumber alloc] initWithDouble:35.0] forKey:@(SYNC_STEP_VCF)];
        [weight setObject:[[NSNumber alloc] initWithDouble:35.0] forKey:@(SYNC_STEP_ANALYZE)];
        [weight setObject:[[NSNumber alloc] initWithDouble:25.0] forKey:@(SYNC_STEP_SERVER_IN_PROGRESS)];
        [weight setObject:[[NSNumber alloc] initWithDouble:5.0] forKey:@(SYNC_STEP_PROCESSING_RESPONSE)];
        
        [weight setObject:[[NSNumber alloc] initWithDouble:5.0] forKey:@(SYNC_STEP_UPLOAD_LOG)];
    }
    
    switch (step) {
        case SYNC_STEP_INITIAL:
            result = result * ([[weight objectForKey:@(SYNC_STEP_INITIAL)] doubleValue] / 100.0);
            break;
        case SYNC_STEP_VCF:
        case SYNC_STEP_READ_LOCAL_CONTACTS:
        case SYNC_STEP_ANALYZE:
        case SYNC_STEP_SERVER_IN_PROGRESS:
        case SYNC_STEP_PROCESSING_RESPONSE:
            result = [self calculatePrevProgress:partialInfo step:step weight:weight backup:backup] +
            [self calculateProgress:partialInfo.totalStep currentStep:partialInfo.currentStep weight:[[weight objectForKey:@(step)] doubleValue] progress:progress backup:backup];
            break;
        case SYNC_STEP_UPLOAD_LOG:
            result = 95 + (result * ([[weight objectForKey:@(SYNC_STEP_UPLOAD_LOG)] doubleValue] / 100.0));
            break;
    }
    
    _step = step;
    
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
//    [formatter setMaximumFractionDigits:2];
//    [formatter setRoundingMode: NSNumberFormatterRoundHalfUp];
//    result = [[formatter stringFromNumber:[NSNumber numberWithFloat:result]] doubleValue];
    if ([_progress doubleValue] != 0 && [_progress doubleValue] > result) {
        SYNC_Log(@"Something went wrong. PROGRESS: %f - %f Step: %@", result, [_progress doubleValue], @(step));
    }
    _progress = [[NSNumber alloc] initWithDouble:result];
    
    SYNC_Log(@"PROGRESS: %f Step: %@", result, @(step));
    
    void (^callback)(void) = [SyncSettings shared].progressCallback;
    if (callback){
        callback();
    }
}

-(double)calculateProgress:(NSInteger)totalStep currentStep:(NSInteger)currentStep weight:(double)weight progress:(double)progress backup:(BOOL)backup {
    double onePartPercentage;
    if (backup) {
        if (totalStep == 1) {
            onePartPercentage = 90.0 / totalStep;
        } else if (totalStep == currentStep) {
            onePartPercentage = 90.0 / 2.0;
        } else {
            onePartPercentage = 90.0 / (((totalStep - 1) * 2.0) - 0);
        }
    } else {
        onePartPercentage = 90.0 / totalStep;
    }
    double thisStepTotalPercentage = (onePartPercentage * weight) / 100.0;
    double thisStepCurrentPercentage = (thisStepTotalPercentage * progress) / 100.0;
    return thisStepCurrentPercentage;
}

-(double)calculatePrevProgress:(PartialInfo*)partialInfo step:(SYNCStep)step weight:(NSDictionary*)weight backup:(BOOL)backup{
    double result = 0;
    NSArray *weigths = nil;
    if (backup) {
        if (step == SYNC_STEP_READ_LOCAL_CONTACTS) {
            weigths = @[@(SYNC_STEP_INITIAL)];
        } else if (step == SYNC_STEP_ANALYZE) {
            weigths = @[@(SYNC_STEP_INITIAL),
                        @(SYNC_STEP_READ_LOCAL_CONTACTS)];
        } else if (step == SYNC_STEP_SERVER_IN_PROGRESS) {
            weigths = @[@(SYNC_STEP_INITIAL),
                        @(SYNC_STEP_READ_LOCAL_CONTACTS),
                        @(SYNC_STEP_ANALYZE)];
        } else if (step == SYNC_STEP_PROCESSING_RESPONSE) {
            weigths = @[@(SYNC_STEP_INITIAL),
                        @(SYNC_STEP_READ_LOCAL_CONTACTS),
                        @(SYNC_STEP_ANALYZE),
                        @(SYNC_STEP_SERVER_IN_PROGRESS)];
        }
    } else {
        if (step == SYNC_STEP_VCF) {
            weigths = @[@(SYNC_STEP_INITIAL)];
        } else if (step == SYNC_STEP_SERVER_IN_PROGRESS) {
            weigths = @[@(SYNC_STEP_INITIAL),
                        @(SYNC_STEP_VCF)];
        } else if (step == SYNC_STEP_PROCESSING_RESPONSE) {
            weigths = @[@(SYNC_STEP_INITIAL),
                        @(SYNC_STEP_VCF),
                        @(SYNC_STEP_SERVER_IN_PROGRESS)];
        } else if (step == SYNC_STEP_ANALYZE) {
            weigths = @[@(SYNC_STEP_INITIAL),
                        @(SYNC_STEP_VCF),
                        @(SYNC_STEP_SERVER_IN_PROGRESS),
                        @(SYNC_STEP_PROCESSING_RESPONSE)];
        }
    }
    
    for (id s in weigths) {
        if ([s isEqual: @(SYNC_STEP_INITIAL)]) {
            result += [[weight objectForKey:s] doubleValue];
        } else {
            result += [self calculateProgress:partialInfo.totalStep currentStep:partialInfo.currentStep weight:[[weight objectForKey:s] doubleValue] progress:100.0 backup:backup];
        }
    }
    
    if (backup) {
        if (partialInfo.totalStep != 1) {
            result += (90 * ((partialInfo.currentStep - 1) * 100.0) / (((partialInfo.totalStep - 1) * 2))) / 100.0;
        }
    } else {
        result += (90 * ((partialInfo.currentStep - 1) * 100) / partialInfo.totalStep) / 100;
    }

    return result;
}

@end
