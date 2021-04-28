//
//  AnalyzeStatus.m
//  ContactSyncExample
//
//  Created by Batuhan Yıldız on 02/10/2017.
//  Copyright © 2017 Valven. All rights reserved.
//

#import "AnalyzeStatus.h"

@implementation AnalyzeInfo

- (instancetype)initWithContact:(Contact*)contact andState:(AnalyzeStateType)state
{
    self = [super init];
    if (self){
        _localId = contact.objectIdentifier;
        _name = [contact generateDisplayName];
        _state = state;
    }
    return self;
}

- (instancetype)initWithEmpty:(AnalyzeStateType)state
{
    self = [super init];
    if (self){
        _state = state;
    }
    return self;
}

@end

@implementation AnalyzeStatus

+ (void)handleNSError:(NSError*)error
{
    AnalyzeStatus *obj = [AnalyzeStatus shared];
    if (!SYNC_IS_NULL(error)){
        if (!SYNC_IS_NULL(error.domain)){
            obj.status = INTERNAL_ERROR;
        }
        obj.lastError = error;
    }
}

+ (SYNC_INSTANCETYPE) shared {

    static dispatch_once_t once;
    static id instance;

    dispatch_once(&once, ^{
        AnalyzeStatus *obj = [self new];
        instance = obj;
    });

    return instance;
}

- (void)addContact:(Contact*)contact state:(AnalyzeStateType)state
{
    AnalyzeInfo *info = [[AnalyzeInfo alloc] initWithContact:contact andState:state];
    [self addItem:info];
}

-(void)addEmpty:(NSNumber *)count state:(AnalyzeStateType)state{
    for(int i=0; i<[count integerValue]; i++){
        AnalyzeInfo *info = [[AnalyzeInfo alloc] initWithEmpty:state];
        [self addItem:info];
    }
}
- (void)addItem:(AnalyzeInfo*)object
{
    switch (object.state) {
        case MERGE_CONTACTS:
            [_mergeContacts addObject:object];
            break;
        case DELETE_CONTACTS:
            [_deleteContacts addObject:object];
            break;
    }
}

- (void)reset
{
    _mergeContacts = [NSMutableArray new];
    _deleteContacts = [NSMutableArray new];

    _status = INITIAL;
    _lastError = nil;

    _analyzeStep = ANALYZE_STEP_INITAL;
    _progress = 0;
}


- (NSString*) resultTypeToString:(AnalyzeResultType) type {
    NSString *result = nil;
    
    switch(type) {
        case INITIAL:
            result = @"INITIAL";
            break;
        case ANALYZE:
            result = @"ANALYZE";
            break;
        case CANCELLED:
            result = @"CANCELLED";
            break;
        case SUCCESS:
            result = @"SUCCESS";
            break;
        case INTERNAL_ERROR:
            result = @"INTERNAL_ERROR";
            break;
        case ANALYZE_RESULT_ERROR_PERMISSION_ADDRESS_BOOK:
            result = @"ANALYZE_RESULT_ERROR_PERMISSION_ADDRESS_BOOK";
            break;
        case ANALYZE_RESULT_ERROR_NETWORK:
            result = @"ANALYZE_RESULT_ERROR_NETWORK";
            break;
        default:
            result = @"";
    }
    
    return result;
}

@end
