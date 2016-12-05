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
+ (BOOL) isMetaFileAlbumPhoto:(MetaFile *)file;
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

+ (void) writeFirstUploadFlag;
+ (BOOL) readFirstUploadFlag;

+ (BOOL) isAlreadyRated;
+ (void) setAlreadyRated;

+ (NSString *) operatorName;
+ (NSString *) readCurrentMobileNetworkCode;

+ (void) writeFeatureFlag;
+ (BOOL) readFeatureFlag;

+ (void) writeLifeboxTeaserFlag;
+ (BOOL) readLifeboxTeaserFlag;

+ (void) writeLocInfoPopupShownFlag;
+ (BOOL) readLocInfoPopupShownFlag;

+ (void) writePeriodicLocInfoPopupIdleFlag;
+ (void) resetPeriodicLocInfoPopupIdleFlag;
+ (BOOL) readPeriodicLocInfoPopupIdleFlag;

+ (void) writeLastLocInfoPopupShownTime;
+ (NSDate *) readLastLocInfoPopupShownTime;

+ (void) increaseVideofyTutorialCount;
+ (int) readVideofyTutorialCount;

+ (void) increaseLoginCount;
+ (int) readLoginCount;
@end
