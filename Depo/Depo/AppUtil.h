//
//  AppUtil.h
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstants.h"
#import "MetaFile.h"

@interface AppUtil : NSObject

+ (NSArray *) readMenuItemsForLoggedIn;
+ (NSString *) iconNameByContentType:(ContentType) contentType;
+ (NSString *) nakedFileFolderName:(NSString *) fileFolderName;
+ (NSString *) enrichFileFolderName:(NSString *) fileFolderName;
+ (NSString *) buttonImgNameByAddType:(AddType) addType;
+ (NSString *) buttonTitleByAddType:(AddType) addType;
+ (NSString *) moreMenuRowImgNameByMoreMenuType:(MoreMenuType) menuType;
+ (NSString *) moreMenuRowTitleByMoreMenuType:(MoreMenuType) menuType withContentType:(ContentType) contentType;
+ (BOOL) isMetaFileImage:(MetaFile *) file;
+ (BOOL) isMetaFileVideo:(MetaFile *) file;
+ (BOOL) isMetaFileMusic:(MetaFile *) file;
+ (BOOL) isMetaFileDoc:(MetaFile *) file;
+ (AddType) strToAddType:(NSString *) str;
+ (NSString *) sortTypeTitleByEnum:(SortType) type;
+ (NSString *) serverSortNameByEnum:(SortType) type forPhotosOnly:(BOOL) photosOnly;
+ (NSString *) serverSortNameByEnum:(SortType) type;
+ (BOOL) isAscByEnum:(SortType) type;
+ (NSString *) randomCamImgName;
+ (NSString *) iconNameByActivityType:(ActivityType) type;
+ (NSString *) iconNameByUsageType:(UsageType) type;
+ (BOOL) readFirstVisitOverFlag;
+ (void) writeFirstVisitOverFlag;
+ (NSString *) readDueDateInReadableFormat:(NSDate *) date;
+ (NSString *) userUniqueValueByBaseUrl:(NSString *) baseUrl;
+ (NSString *) readDocumentsPathForFileName:(NSString *)name;
+ (void) sendLocalNotificationForDate:(NSDate *) dateToSend withMessage:(NSString *) msg;
+ (BOOL) shouldShowNewFeatures;
+ (BOOL) checkIsUpdate;
+ (BOOL) checkAndSetFlags:(NSString *) flagKey;

+ (NSDictionary *) readWaitingIAPValidationForFutureTry;
+ (void) writeWaitingIAPValidationForFutureTryForProductId:(NSString *) productId andReceiptId:(NSString *) receiptId;
+ (void) cleanWaitingIAPValidationForFutureTryWithProductId:(NSString *) productId;

+ (NSString *)getPackageDisplayName: (NSString *) roleName;
+ (NSString *)getPackageNameForSms: (NSString *)roleName;

+ (void) writeDoNotShowAgainFlagForKey:(NSString *) key;
+ (BOOL) readDoNotShowAgainFlagForKey:(NSString *) key;

+ (BOOL) isAlreadyRated;
+ (void) setAlreadyRated;

@end
