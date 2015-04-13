//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == 568.0f)

#define IS_BELOW_7 ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)

#define IS_BELOW_6 ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)

#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)

#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define turkcellAuthAppIdTest @"151"
#define turkcellAuthSecretKeyTest @"7dad024c-600e-468b-9bcd-5fb518399d15"

#define BASE_PAGE_URL @"https://m.turkcell.com.tr"

#define LOGGED_IN_NOT_NAME @"LOGGED_IN_NOT_NAME"

#define SILENT_LOGGED_IN_NOT_NAME @"SILENT_LOGGED_IN_NOT_NAME"

#define LOGGED_OUT_NOT_NAME @"LOGGED_OUT_NOT_NAME"

#define FORCE_HOMEPAGE_NOTIFICATION @"FORCE_HOMEPAGE_NOTIFICATION"

#define MENU_SCROLLING_NOTIFICATION @"MENU_SCROLLING_NOTIFICATION"

#define MENU_CLOSED_NOTIFICATION @"MENU_CLOSED_NOTIFICATION"

#define TEMP_IMG_UPLOAD_NOTIFICATION @"TEMP_IMG_UPLOAD_NOTIFICATION"

#define TEMP_IMG_UPLOAD_NOTIFICATION_UUID_PARAM @"TEMP_IMG_UPLOAD_NOTIFICATION_UUID_PARAM"

#define TEMP_IMG_UPLOAD_NOTIFICATION_URL_PARAM @"TEMP_IMG_UPLOAD_NOTIFICATION_URL_PARAM"

#define MUSIC_PAUSED_NOTIFICATION @"MUSIC_PAUSED_NOTIFICATION"

#define MUSIC_RESUMED_NOTIFICATION @"MUSIC_RESUMED_NOTIFICATION"

#define MUSIC_CHANGED_NOTIFICATION @"MUSIC_CHANGED_NOTIFICATION"

#define MUSIC_SHOULD_BE_REMOVED_NOTIFICATION @"MUSIC_SHOULD_BE_REMOVED_NOTIFICATION"

#define MUSIC_SHUFFLE_NOTIFICATION @"MUSIC_SHUFFLE_NOTIFICATION"

#define CHANGED_MUSIC_OBJ_KEY @"CHANGED_MUSIC_OBJ_KEY"

#define INDEX_AFTER_SHUFFLE_OBJ_KEY @"INDEX_AFTER_SHUFFLE_OBJ_KEY"

#define MSISDN_STORE_KEY @"MSISDN_STORE_KEY"

#define REMEMBER_ME_TOKEN_KEY @"REMEMBER_ME_TOKEN_KEY"

#define PASS_STORE_KEY @"PASS_STORE_KEY"

#define REMEMBER_ME_KEY @"REMEMBER_ME_KEY"

#define CONFIRM_DELETE_HIDDEN_KEY @"CONFIRM_DELETE_HIDDEN_KEY"

#define SYNCED_REMOTE_HASHES_KEY @"SYNCED_REMOTE_HASHES_KEY_%@"

#define SYNCED_REMOTE_FILES_SUMMARY_KEY @"SYNCED_REMOTE_FILES_SUMMARY_KEY_%@"

#define SYNCED_LOCAL_HASHES_KEY @"SYNCED_LOCAL_HASHES_KEY_%@"

#define FIRST_SYNC_DONE_FLAG_KEY @"FIRST_SYNC_DONE_FLAG_KEY"

#define FIRST_SYNC_FINALIZED_FLAG_KEY @"FIRST_SYNC_FINALIZED_FLAG_KEY"

#define BULK_AUTO_SYNC_IN_PROGRESS_FLAG_KEY @"BULK_AUTO_SYNC_IN_PROGRESS_FLAG_KEY"

#define UPLOAD_FILE_BADGE_COUNT_KEY @"UPLOAD_FILE_BADGE_COUNT_KEY"

#define AUTO_SYNC_INDEX_KEY @"AUTO_SYNC_INDEX_KEY"

#define ONGOING_TASKS_KEY @"ONGOING_TASKS_KEY"

#define CONTENT_TYPE_JPEG_VALUE @"image/jpeg"

#define CONTENT_TYPE_JPG_VALUE @"image/jpg"

#define CONTENT_TYPE_PNG_VALUE @"image/png"

#define CONTENT_TYPE_AUDIO_MP3_VALUE @"audio/mp3"

#define CONTENT_TYPE_AUDIO_MPEG_VALUE @"audio/mpeg"

#define CONTENT_TYPE_QUICKTIME_VALUE @"video/quicktime"

#define CONTENT_TYPE_MP4_VALUE @"video/mp4"

#define CONTENT_TYPE_PDF_VALUE @"application/pdf"

#define CONTENT_TYPE_DOC_VALUE @"application/doc"

#define CONTENT_TYPE_TXT_VALUE @"text/plain"

#define CONTENT_TYPE_HTML_VALUE @"text/html"

#define NO_OF_FILES_PER_PAGE 10

#define RECENT_ACTIVITY_COUNT 30

//TODO 100 ya da 1000 gibi bir rakam set edilebilir
#define AUTO_SYNC_ASSET_COUNT 100

#define SEARCH_HISTORY_KEY @"SEARCH_HISTORY_KEY"

#define FIRST_VISIT_OVER @"FIRST_VISIT_OVER"

#define LAST_SYNC_DATE @"LAST_SYNC_DATE"

#define LAST_CONTACT_SYNC_DATE @"LAST_CONTACT_SYNC_DATE"

#define LAST_CONTACT_SYNC_RESULT @"LAST_CONTACT_SYNC_RESULT"

#define SYNC_REF_KEY @"SYNC_REF_KEY"

#define SETTINGS_PROFILE_IMAGE @"SETTINGS_PROFILE_IMAGE"

#define SETTINGS_PROFILE_NAME @"SETTINGS_PROFILE_NAME"

#define SETTINGS_PROFILE_PHONENUMBER @"SETTINGS_PROFILE_PHONENUMBER"

#define SETTINGS_STORAGE_CURRENTPACKAGE_NAME @"SETTINGS_STORAGE_CURRENTPACKAGE_NAME"

#define SETTINGS_STORAGE_CURRENTPACKAGE_RENEWALDATE @"SETTINGS_STORAGE_CURRENTPACKAGE_RENEWALDATE"

#define SETTINGS_UPLOAD_SYNCINGCONNECTION @"SETTINGS_UPLOAD_SYNCINGCONNECTION"

#define SETTINGS_UPLOAD_DATAROAMING @"SETTINGS_UPLOAD_DATAROAMING"

#define SETTINGS_UPLOAD_PHOTOSVIDEOS @"SETTINGS_UPLOAD_PHOTOSVIDEOS"

#define SETTINGS_UPLOAD_MUSIC @"SETTINGS_UPLOAD_MUSIC"

#define SETTINGS_UPLOAD_DOCUMENTS @"SETTINGS_UPLOAD_DOCUMENTS"

#define SETTINGS_UPLOAD_CONTACTS @"SETTINGS_UPLOAD_CONTACTS"

#define SETTINGS_NOTIFICATIONS @"SETTINGS_NOTIFICATIONS"

#define PROFILE_IMAGE_WAS_LOADED_NOTIFICATION @"PROFILE_IMAGE_WAS_LOADED_NOTIFICATION"

#define AUTO_SYNC_QUEUE_CHANGED_NOTIFICATION @"AUTO_SYNC_QUEUE_CHANGED_NOTIFICATION"

#define LOGIN_REQ_NOTIFICATION @"LOGIN_REQ_NOTIFICATION"

#define AKILLI_DEPO_PROFILE_IMG_NAME @"akilli_depo_profile_img.jpg"

#define MAX_CONCURRENT_UPLOAD_TASKS 1

//TODO group id for shared nsuserdefaults - this will be revisited for Turkcell - igones: group.com.igones.Depo
#define GROUP_NAME_SUITE_NSUSERDEFAULTS @"group.com.turkcell.akillideponew.ent"

#define EXTENSION_WORMHOLE_DIR @"WORMHOLE_DIR"

#define EXTENSION_WORMHOLE_TOTAL_COUNT_IDENTIFIER @"EXTENSION_WORMHOLE_TOTAL_COUNT_IDENTIFIER"

#define EXTENSION_WORMHOLE_FINISHED_COUNT_IDENTIFIER @"EXTENSION_WORMHOLE_FINISHED_COUNT_IDENTIFIER"

//TODO
//#define CONTACT_SYNC_SERVER_URL @"https://tcloudstb.turkcell.com.tr/sync/ttyapi/"
#define CONTACT_SYNC_SERVER_URL @"https://adepo.turkcell.com.tr/ttyapi/"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

typedef enum {
	LoginTypeRadius = 0,
	LoginTypeWebSifre
} LoginType;

typedef enum {
	MenuTypeProfile = 0,
	MenuTypeSearch,
	MenuTypeHome,
	MenuTypeFav,
	MenuTypeFiles,
	MenuTypePhoto,
	MenuTypeMusic,
	MenuTypeDoc,
    MenuTypeContactSync,
	MenuTypeLogin,
	MenuTypeLogout
} MenuType;

typedef enum {
    ModalTypeError = 0,
    ModalTypeWarning,
    ModalTypeSuccess,
    ModalTypeApprove,
    ModalTypeInfo
} ModalType;

typedef enum {
	ContentTypeFolder = 0,
	ContentTypePhoto,
    ContentTypeVideo,
	ContentTypeMusic,
	ContentTypeDoc,
	ContentTypeOther
} ContentType;

typedef enum {
	AddTypeFolder = 0,
	AddTypeAlbum,
	AddTypePhoto,
	AddTypeMusic,
	AddTypeCamera,
	AddTypeOther
} AddType;

typedef enum {
	MoreMenuTypeSort = 0,
    MoreMenuTypeSortWithList,
	MoreMenuTypeSelect,
	MoreMenuTypeFileDetail,
    MoreMenuTypeFolderDetail,
    MoreMenuTypeAlbumDetail,
    MoreMenuTypeVideoDetail,
    MoreMenuTypeImageDetail,
	MoreMenuTypeShare,
    MoreMenuTypeAlbumShare,
	MoreMenuTypeFav,
    MoreMenuTypeUnfav,
    MoreMenuTypeDownloadImage,
    MoreMenuTypeDelete,
    MoreMenuTypeAlbumDelete
} MoreMenuType;

typedef enum {
    SortTypeAlphaAsc = 0,
    SortTypeAlphaDesc,
    SortTypeSongNameAsc,
    SortTypeSongNameDesc,
    SortTypeArtistAsc,
    SortTypeArtistDesc,
    SortTypeAlbumAsc,
    SortTypeAlbumDesc,
    SortTypeDateDesc,
    SortTypeDateAsc,
    SortTypeSizeDesc,
    SortTypeSizeAsc
} SortType;

typedef enum {
    ActivityTypeFolder = 0,
    ActivityTypeImage,
    ActivityTypeTrash,
    ActivityTypeFile,
    ActivityTypeMusic,
    ActivityTypeContact,
    ActivityTypeFav,
    ActivityTypeWelcome
} ActivityType;

typedef enum {
    UsageTypeImage = 0,
    UsageTypeMusic,
    UsageTypeOther,
    UsageTypeVideo,
    UsageTypeContact
} UsageType;

typedef enum {
    EnableOptionOff = 1,
    EnableOptionOn,
    EnableOptionAuto
} EnableOption;

typedef enum {
    ConnectionOptionWifi3G = 1,
    ConnectionOptionWifi
} ConnectionOption;

typedef enum {
    NotificationOptionAnytime = 1,
    NotificationOptionOnceADay,
    NotificationOptionOnceAWeek,
    NotificationOptionOnceAMonth,
    NotificationOptionNever
} NotificationOption;

typedef enum {
    SearchListTypeAllFiles = 0,
    SearchListTypePhotosAndVides,
    SearchListTypeMusics,
    SearchListTypeDocumnets
} SearchListType;

typedef enum {
    UploadTaskTypeAsset = 0,
    UploadTaskTypeData,
    UploadTaskTypeFile
} UploadTaskType;

typedef enum {
    DeleteTypeFooterMenu = 0,
    DeleteTypeMoreMenu,
    DeleteTypeSwipeMenu,
    DeleteTypePhotos,
    DeleteTypeAlbums
} DeleteType;

typedef enum {
    UploadErrorTypeQuota = 1,
    UploadErrorTypeLogin
} UploadErrorType;

typedef enum {
    NotificationActionMain = 1,
    NotificationActionSyncSettings,
    NotificationActionFloatingMenu,
    NotificationActionPackages
} NotificationAction;

typedef enum {
    ContactSyncTypeBackup = 1,
    ContactSyncTypeRestore
} ContactSyncType;

typedef enum {
    UploadStarterPagePhotos = 1,
    UploadStarterPageList,
    UploadStarterPageAuto
} UploadStarterPage;

@interface AppConstants : NSObject

@end
