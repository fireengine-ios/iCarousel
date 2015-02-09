//
//  SyncConstants.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#ifndef ContactSyncExample_SyncConstants_h
#define ContactSyncExample_SyncConstants_h

#ifndef SYNC_INSTANCETYPE
#if __has_feature(objc_instancetype)
#define SYNC_INSTANCETYPE instancetype
#else
#define SYNC_INSTANCETYPE id
#endif
#endif

#define SYNC_VERSION @"0.4"
#define SYNC_USER_AGENT @"iOS ContactSync SDK"

#define SYNC_HEADER_AUTH_TOKEN @"X-Auth-Token"
#define SYNC_HEADER_CLIENT_VERSION @"X-Client-Version"
#define SYNC_HEADER_MSISDN @"X-Msisdn"

#define SYNC_KEY_LAST_SYNC_TIME @"ContactSyncLastTime"
#define SYNC_KEY_AUTOMATED @"ContactSyncAutomated"

#define SYNC_DEFAULT_INTERVAL 30

#define SYNC_IS_NULL(obj) (obj==nil || [obj isKindOfClass:[NSNull class]])
#define SYNC_STRING_IS_NULL_OR_EMPTY(obj) (obj==nil || [obj isKindOfClass:[NSNull class]] || [obj isEqualToString:@""])
#define SYNC_NUMBER_IS_NULL_OR_ZERO(obj) (obj==nil || [obj isKindOfClass:[NSNull class]] || [obj integerValue]==0)
#define SYNC_SET_DICT_IF_NOT_NIL(dict,val,key) if (val != nil) [dict setObject:val forKey:key];
#define SYNC_ARRAY_IS_NULL_OR_EMPTY(obj) (obj==nil || [obj isKindOfClass:[NSNull class]] || [obj count]==0)

#define SYNC_AS_STRING(val) [NSString stringWithFormat:@"%@",val]
#define SYNC_INT_AS_STRING(val) [NSString stringWithFormat:@"%i",val]
#define SYNC_LLD_AS_STRING(val) [NSString stringWithFormat:@"%lld",val]
#define SYNC_DATE_AS_NUMBER(val) ((val==nil || ![val isKindOfClass:[NSDate class]])?[NSNumber numberWithInt:0]:[NSNumber numberWithLongLong:[val timeIntervalSince1970]*1000])

#define SYNC_Log_Enabled ([SyncSettings shared].debug)
#define SYNC_Log(fmt, ...)  if (SYNC_Log_Enabled) { NSLog((@"ContactSyncSDK: %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }

#define SYNC_JSON_PARAM_DATA @"data"
#define SYNC_JSON_PARAM_ITEMS @"items"
#define SYNC_JSON_PARAM_CURRENT_PAGE @"currentPage"
#define SYNC_JSON_PARAM_TOTAL_COUNT @"totalCount"
#define SYNC_JSON_PARAM_PAGE_COUNT @"numOfPages"

#endif
