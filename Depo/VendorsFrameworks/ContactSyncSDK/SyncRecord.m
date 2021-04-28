//
//  SyncRecord.m
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#import "SyncRecord.h"


@implementation SyncRecord

- (NSDictionary *) asDict {
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    SYNC_SET_DICT_IF_NOT_NIL(dict, _localId, @"localId");
    SYNC_SET_DICT_IF_NOT_NIL(dict, _remoteId, @"remoteId");
    SYNC_SET_DICT_IF_NOT_NIL(dict, _remoteUpdateDate, @"remoteUpdateDate");
    SYNC_SET_DICT_IF_NOT_NIL(dict, _localUpdateDate, @"localUpdateDate");
    return dict;
}

@end
