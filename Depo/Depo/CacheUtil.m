//
//  CacheUtil.m
//  Depo
//
//  Created by Mahir on 9/23/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "CacheUtil.h"
#import "AppConstants.h"

@implementation CacheUtil

+ (NSString *) readRememberMeToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:REMEMBER_ME_TOKEN_KEY];
}

+ (void) writeRememberMeToken:(NSString *)newToken {
    [[NSUserDefaults standardUserDefaults] setObject:newToken forKey:REMEMBER_ME_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) resetRememberMeToken {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:REMEMBER_ME_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) showConfirmDeletePageFlag {
    return [[NSUserDefaults standardUserDefaults] boolForKey:CONFIRM_DELETE_HIDDEN_KEY];
}

+ (void) setConfirmDeletePageFlag {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CONFIRM_DELETE_HIDDEN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) cacheSearchHistoryItem:(SearchHistory *) historyItem {
    NSArray *result = [CacheUtil readSearchHistoryItems];
    NSMutableArray *mResult = [[NSMutableArray alloc]initWithArray:result];
    SearchHistory *sh;
    for (int i = 0; i < mResult.count; i++) {
        sh = [mResult objectAtIndex:i];
        if ([sh.searchText isEqualToString:historyItem.searchText])
            [mResult removeObjectAtIndex:i];
    }
    [mResult addObject:historyItem];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:mResult] forKey:SEARCH_HISTORY_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *) readSearchHistoryItems {
    NSArray *result = [[NSArray alloc] init];
    NSData *arrData = [[NSUserDefaults standardUserDefaults] objectForKey:SEARCH_HISTORY_KEY];
    if (arrData != nil) {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:arrData];
    }
    return result;
}

+ (void) clearSearchHistoryItems {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:nil] forKey:SEARCH_HISTORY_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) writeCachedProfileImage: (UIImage *) image {
    [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:SETTINGS_PROFILE_IMAGE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (UIImage *) readCachedProfileImage {
    //return [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PROFILE_IMAGE];
    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PROFILE_IMAGE];
    UIImage* image = [UIImage imageWithData:imageData];
    return image;
}

+ (void) resetCachedProfileImage {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:SETTINGS_PROFILE_IMAGE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) writeCachedProfileName: (NSString *) name {
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:SETTINGS_PROFILE_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) readCachedProfileName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PROFILE_NAME];
}

+ (void) writeCachedPhoneNumber: (NSString *) phoneNumber {
    [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:SETTINGS_PROFILE_PHONENUMBER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) readCachedPhoneNumber {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PROFILE_PHONENUMBER];
}

+ (void) writeCachedSettingCurrentPackageName: (NSString *) setting {
    [[NSUserDefaults standardUserDefaults] setObject:setting forKey:SETTINGS_STORAGE_CURRENTPACKAGE_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) readCachedSettingCurrentPackageName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_STORAGE_CURRENTPACKAGE_NAME];
}

+ (void) writeCachedSettingCurrentPackageRenewalDate: (NSString *) setting {
    [[NSUserDefaults standardUserDefaults] setObject:setting forKey:SETTINGS_STORAGE_CURRENTPACKAGE_RENEWALDATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) readCachedSettingCurrentPackageRenewalDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_STORAGE_CURRENTPACKAGE_RENEWALDATE];
}

+ (void) writeCachedSettingSyncingConnectionType: (NSInteger) setting {
    [[NSUserDefaults standardUserDefaults] setInteger:setting forKey:SETTINGS_UPLOAD_SYNCINGCONNECTION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger) readCachedSettingSyncingConnectionType {
    return [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_UPLOAD_SYNCINGCONNECTION];
}

+ (void) writeCachedSettingDataRoaming: (BOOL) setting {
    [[NSUserDefaults standardUserDefaults] setBool:setting forKey:SETTINGS_UPLOAD_DATAROAMING];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) readCachedSettingDataRaming {
    return [[NSUserDefaults standardUserDefaults] boolForKey:SETTINGS_UPLOAD_DATAROAMING];
}

+ (void) writeCachedSettingSyncPhotosVideos: (NSInteger) setting {
    [[NSUserDefaults standardUserDefaults] setInteger:setting forKey:SETTINGS_UPLOAD_PHOTOSVIDEOS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger) readCachedSettingSyncPhotosVideos {
    return [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_UPLOAD_PHOTOSVIDEOS];
}

+ (void) writeCachedSettingSyncMusic: (NSInteger) setting {
    [[NSUserDefaults standardUserDefaults] setInteger:setting forKey:SETTINGS_UPLOAD_MUSIC];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger) readCachedSettingSyncMusic {
    return [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_UPLOAD_MUSIC];
}

+ (void) writeCachedSettingSyncDocuments: (NSInteger) setting {
    [[NSUserDefaults standardUserDefaults] setInteger:setting forKey:SETTINGS_UPLOAD_DOCUMENTS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger) readCachedSettingSyncDocuments {
    return [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_UPLOAD_DOCUMENTS];
}

+ (void) writeCachedSettingSyncContacts: (NSInteger) setting {
    [[NSUserDefaults standardUserDefaults] setInteger:setting forKey:SETTINGS_UPLOAD_CONTACTS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger) readCachedSettingSyncContacts {
    return [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_UPLOAD_CONTACTS];
}

+ (void) writeCachedSettingNotification: (NSInteger) setting {
    [[NSUserDefaults standardUserDefaults] setInteger:setting forKey:SETTINGS_NOTIFICATIONS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger) readCachedSettingNotification {
    return [[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_NOTIFICATIONS];
}

+ (void) writeCachedMsisdnForPostMigration:(NSString *) msisdn {
    [[NSUserDefaults standardUserDefaults] setValue:msisdn forKey:MSISDN_STORE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) writeCachedPassForPostMigration:(NSString *) pass {
    [[NSUserDefaults standardUserDefaults] setValue:pass forKey:PASS_STORE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) writeCachedRememberMeForPostMigration:(BOOL) flag {
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:REMEMBER_ME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) readCachedMsisdnForPostMigration {
    return [[NSUserDefaults standardUserDefaults] valueForKey:MSISDN_STORE_KEY];
}

+ (NSString *) readCachedPassForPostMigration {
    return [[NSUserDefaults standardUserDefaults] valueForKey:PASS_STORE_KEY];
}

+ (BOOL) readCachedRememberMeForPostMigration {
    return [[NSUserDefaults standardUserDefaults] boolForKey:REMEMBER_ME_KEY];
}

@end
