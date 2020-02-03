//
//  SyncConstants.h
//  ContactSyncExample
//
//  Copyright (c) 2015 Valven. All rights reserved.
//

#ifndef ContactSyncExample_SyncConstants_h
#define ContactSyncExample_SyncConstants_h

#import "SyncLogger.h"

#ifndef SYNC_INSTANCETYPE
#if __has_feature(objc_instancetype)
#define SYNC_INSTANCETYPE instancetype
#else
#define SYNC_INSTANCETYPE id
#endif
#endif

#ifndef ANALYZE_INSTANCETYPE
#if __has_feature(objc_instancetype)
#define ANALYZE_INSTANCETYPE instancetype
#else
#define ANALYZE_INSTANCETYPE id
#endif
#endif

#define SYNC_VERSION @"4.0.3-030220"
#define SYNC_USER_AGENT @"iOS ContactSync SDK"

#define SYNC_HEADER_AUTH_TOKEN @"X-Auth-Token"
#define SYNC_HEADER_CLIENT_VERSION @"X-Client-Version"
#define SYNC_HEADER_MSISDN @"X-Msisdn"

#define SYNC_DEVICE_ID @"DeviceId_210120"

#define SYNC_KEY_LAST_SYNC_TIME @"ContactSyncLastTime_210120"
#define SYNC_KEY_LAST_PERIODIC_SYNC_TIME @"ContactPeriodicSyncLastTime_v4"
#define SYNC_KEY_AUTOMATED @"ContactSyncAutomated"
#define SYNC_KEY_CHECK_UPDATE @"ContactSyncUpdateKey"

#define SYNC_KEY_PROGRESS_RESTORE @"ProgressRestore"

#define SYNC_KEY_CURRENT_STEP @"CurrentStep"
#define SYNC_KEY_CURRENT_CONTACT_COUNT @"CurrentContactCount"

#define SYNC_KEY_DELAY @"ContactSyncDelay"

#define SYNC_KEY_PERIODIC_OPTION @"PeriodicBackupOption"
#define SYNC_KEY_PERIODIC_TOKEN @"PeriodicBackupToken"
#define SYNC_KEY_PERIODIC_URL @"PeriodicBackupUrl"

#define SYNC_KEY_DEPO_URL @"DepoUrl"

#define SYNC_DEFAULT_INTERVAL 30
#define SYNC_DEFAULT_DELAY 0
#define SYNC_RESTORE_THRESHOLD 2000

#define SYNC_NUM_OF_BACKUP_STEPS 4
#define SYNC_NUM_OF_RESTORE_STEPS 3
#define ANALYZE_NUM_OF_STEPS 3

#define SYNC_IS_NULL(obj) (obj==nil || [obj isKindOfClass:[NSNull class]])
#define SYNC_STRING_IS_NULL_OR_EMPTY(obj) (obj==nil || [obj isKindOfClass:[NSNull class]] || [obj isEqualToString:@""] || [obj isEqual:[NSNull null]])
#define SYNC_NUMBER_IS_NULL_OR_ZERO(obj) (obj==nil || [obj isKindOfClass:[NSNull class]] || [obj integerValue]==0)
#define SYNC_SET_DICT_IF_NOT_NIL(dict,val,key) if (val != nil && ![val isKindOfClass:[NSNull class]] && !([val isEqual:[NSNull null]])) [dict setObject:val forKey:key];
#define SYNC_APPEND_STRING_IF_NOT_NIL(buff, val) if (val != nil && ![val isKindOfClass:[NSNull class]] && ![val isEqualToString:@""] && !([val isEqual:[NSNull null]])) [buff appendString:val];
#define SYNC_ARRAY_IS_NULL_OR_EMPTY(obj) (obj==nil || [obj isKindOfClass:[NSNull class]] || [obj count]==0)

#define SYNC_CALCULATE_PROGRESS(step,stepSize,progress) (step < 0)?0:((step * (100.0 / stepSize)) + ([progress doubleValue] / stepSize))

#define SYNC_AS_STRING(val) [NSString stringWithFormat:@"%@",val]
#define SYNC_INT_AS_STRING(val) [NSString stringWithFormat:@"%i",val]
#define SYNC_LLD_AS_STRING(val) [NSString stringWithFormat:@"%lld",val]
#define SYNC_DATE_AS_NUMBER(val) ((val==nil || ![val isKindOfClass:[NSDate class]])?[NSNumber numberWithInt:0]:[NSNumber numberWithLongLong:[val timeIntervalSince1970]*1000])

#define SYNC_GET_KEY(val) [NSString stringWithFormat:@"%@_%@",val,[SyncSettings shared].msisdn]
#define SYNC_GET_KEY_PLAIN(val) [NSString stringWithFormat:@"%@",val]

#define SYNC_Log_Enabled ([SyncSettings shared].debug)
#define SYNC_Log(fmt, ...)  if (SYNC_Log_Enabled) { NSLog((@"ContactSyncSDK-%@: %s [Line %d] " fmt), SYNC_VERSION, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); \
NSString *logFormat = [NSString stringWithFormat:@"ContactSyncSDK-%@: %s [Line %d] %@", SYNC_VERSION,__PRETTY_FUNCTION__,__LINE__,fmt]; [[SyncLogger shared] log:[NSString stringWithFormat:logFormat, ##__VA_ARGS__]];}

#define SYNC_JSON_PARAM_DATA @"data"
#define SYNC_JSON_PARAM_ID @"id"
#define SYNC_JSON_PARAM_ITEMS @"items"
#define SYNC_JSON_PARAM_UPDATED @"updated"
#define SYNC_JSON_PARAM_CURRENT_PAGE @"currentPage"
#define SYNC_JSON_PARAM_TOTAL_COUNT @"totalCount"
#define SYNC_JSON_PARAM_PAGE_COUNT @"numOfPages"
#define SYNC_JSON_PARAP_SERVER_TIMESTAMP @"serverTimestamp"


#endif
