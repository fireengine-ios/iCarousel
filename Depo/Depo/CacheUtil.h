//
//  CacheUtil.h
//  Depo
//
//  Created by Mahir on 9/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchHistory.h"

@interface CacheUtil : NSObject

+ (NSString *) readRememberMeToken;
+ (void) writeRememberMeToken:(NSString *) newToken;
+ (void) resetRememberMeToken;
+ (BOOL) showConfirmDeletePageFlag;
+ (void) setConfirmDeletePageFlag;
+ (void) cacheSearchHistoryItem:(SearchHistory *) historyItem;
+ (NSArray *) readSearchHistoryItems;
+ (void) clearSearchHistoryItems;

+ (void) writeCachedProfileImage: (UIImage *) image;
+ (UIImage *) readCachedProfileImage;
+ (void) resetCachedProfileImage;
+ (void) writeCachedProfileName: (NSString *) name;
+ (NSString *) readCachedProfileName;
+ (void) writeCachedPhoneNumber: (NSString *) phoneNumber;
+ (UIImage *) readCachedPhoneNumber;
+ (void) writeCachedSettingCurrentPackageName: (NSString *) setting;
+ (NSString *) readCachedSettingCurrentPackageName;
+ (void) writeCachedSettingCurrentPackageRenewalDate: (NSString *) setting;
+ (NSString *) readCachedSettingCurrentPackageRenewalDate;
+ (void) writeCachedSettingSyncingConnectionType: (NSInteger) setting;
+ (NSInteger) readCachedSettingSyncingConnectionType;
+ (void) writeCachedSettingDataRoaming: (BOOL) setting;
+ (BOOL) readCachedSettingDataRaming;
+ (void) writeCachedSettingSyncPhotosVideos: (NSInteger) setting;
+ (NSInteger) readCachedSettingSyncPhotosVideos;
+ (void) writeCachedSettingSyncMusic: (NSInteger) setting;
+ (NSInteger) readCachedSettingSyncMusic;
+ (void) writeCachedSettingSyncDocuments: (NSInteger) setting;
+ (NSInteger) readCachedSettingSyncDocuments;
+ (void) writeCachedSettingSyncContacts: (NSInteger) setting;
+ (NSInteger) readCachedSettingSyncContacts;
+ (void) writeCachedSettingNotification: (NSInteger) setting;
+ (NSInteger) readCachedSettingNotification;

@end
