//  Created by mahir tarlan
//  Copyright (c) 2013 igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoggerUtil.h"

#define IGLog(x) [LoggerUtil logString:(x)]

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)

#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == 568.0f)

#define IS_BELOW_7 ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)

#define IS_BELOW_6 ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

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

#define CROPY_EMPTY_NOTIFICATION @"CROPY_EMPTY_NOTIFICATION"

#define MSISDN_CHANGED_NOTIFICATION @"MSISDN_CHANGED_NOTIFICATION"

#define PROFILE_IMG_UPLOADED_NOTIFICATION @"PROFILE_IMG_UPLOADED_NOTIFICATION"

#define VIDEOFY_MUSIC_PREVIEW_CHANGED_NOTIFICATION @"VIDEOFY_MUSIC_PREVIEW_CHANGED_NOTIFICATION"

#define VIDEOFY_DEPO_MUSIC_SELECTED_NOTIFICATION @"VIDEOFY_DEPO_MUSIC_SELECTED_NOTIFICATION"

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

#define FIRST_SYNC_DONE_FLAG_KEY @"FIRST_SYNC_DONE_FLAG_KEY_%@"

#define FIRST_SYNC_FINALIZED_FLAG_KEY @"FIRST_SYNC_FINALIZED_FLAG_KEY_%@"

#define BULK_AUTO_SYNC_IN_PROGRESS_FLAG_KEY @"BULK_AUTO_SYNC_IN_PROGRESS_FLAG_KEY"

#define UPLOAD_FILE_BADGE_COUNT_KEY @"UPLOAD_FILE_BADGE_COUNT_KEY"

#define AUTO_SYNC_INDEX_KEY @"AUTO_SYNC_INDEX_KEY_%@"

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

#define AUTO_SYNC_ASSET_COUNT 1000

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

#define PERSISTENT_BASE_URL_CONSTANT_KEY @"PERSISTENT_BASE_URL_CONSTANT_KEY"

#define PERSISTENT_BASE_URL_KEY @"PERSISTENT_BASE_URL_KEY"

#define LAST_LOC_UPDATE_TIME_KEY @"LAST_LOC_UPDATE_TIME_KEY"

#define QUOTA_413_LOCK_KEY @"QUOTA_413_LOCK_KEY"

#define QUOTA_413_LAST_CHECK_DATE_KEY @"QUOTA_413_LAST_CHECK_DATE_KEY"

#define GENERAL_TASK_TIMEOUT 1200.0f

#define POST_SIGNUP_ACTION_OTP @"CONTINUE_WITH_OTP_VERIFICATION"

#define POST_SIGNUP_ACTION_EMAIL @"CONTINUE_WITH_EMAIL_VERIFICATION"

#ifdef PLATFORM_STORE
#define GROUP_NAME_SUITE_NSUSERDEFAULTS @"group.com.turkcell.akillidepo"
#elif defined PLATFORM_ICT
#define GROUP_NAME_SUITE_NSUSERDEFAULTS @"group.com.turkcell.akillideponew.ent"
#else
#define GROUP_NAME_SUITE_NSUSERDEFAULTS @"group.com.igones.Depo"
#endif

#define EXTENSION_WORMHOLE_DIR @"WORMHOLE_DIR"

#define EXTENSION_WORMHOLE_TOTAL_COUNT_IDENTIFIER @"EXTENSION_WORMHOLE_TOTAL_COUNT_IDENTIFIER"

#define EXTENSION_WORMHOLE_FINISHED_COUNT_IDENTIFIER @"EXTENSION_WORMHOLE_FINISHED_COUNT_IDENTIFIER"

#define SPECIAL_LOCAL_ALBUM_NAMES @[@"Instagram", @"Picasa", @"Whatsapp", @"Facebook", @"Twitter", @"Snapchat", @"BIP", @"Bip"]

//TODO test->prod
//#define CONTACT_SYNC_SERVER_URL @"https://adepo.turkcell.com.tr/ttyapi/"
#define CONTACT_SYNC_SERVER_URL @"https://tcloudstb.turkcell.com.tr/ttyapi/"

//#define UPDATER_SDK_URL @"http://www.igones.com/adepo/ios_igones.json"
#define UPDATER_SDK_URL @"https://adepo.turkcell.com.tr/download/update_ios.json"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#define DIALOGUE_P1_FLAG @"P1Flag"
#define DIALOGUE_P2_FLAG @"P2Flag"
#define DIALOGUE_P3_FLAG @"P3Flag"
#define DIALOGUE_P4_FLAG @"P4Flag"
#define DIALOGUE_P5_FLAG @"P5Flag"
#define DIALOGUE_P6_FLAG @"P6Flag"
#define DIALOGUE_P7_FLAG @"P7Flag"
#define DIALOGUE_P8_FLAG @"P8Flag"

#define SYSTEM_VERSION_KEY @"VERSION_NUMBER"
#define NEW_FEATURES_FLAG_KEY @"NEW_FEATURES_FLAG"

#define STANDART_PAKET_KEY @"standard";
#define DEMO_PAKET_KEY @"demo";
#define PREMIUM_PAKET_KEY @"premium";
#define ULTIMATE_PAKET_KEY @"ultimate";
#define TURKCELL_PHONE_PAKET_KEY @"turkcellphone";
#define TURKCELL_PLATINIUM_PAKET_KEY @"platiniumpaket";

#define IAP_MINI_PACKAGE_ID @"mini_1_month";

#define IAP_STANDARD_PACKAGE_ID @"standard_1_month";

#define REQ_TAG_FOR_PACKAGE 111

#define REQ_TAG_FOR_GROUPED_PHOTOS 222

#define REQ_TAG_FOR_ALBUM 333

#define REQ_TAG_FOR_PHOTO 444

#define REQ_TAG_FOR_DROPBOX 555

#define APP_RATE_FLAG_KEY @"DEPO_APP_RATE_FLAG_KEY"

#define TUTORIAL_MENU_KEY @"ADEPO_TUTORIAL_MENU_KEY"

#define TUTORIAL_DETAIL_KEY @"ADEPO_TUTORIAL_DETAIL_KEY"

#define FIRST_UPLOAD_FLAG_KEY @"DEPO_FIRST_UPLOAD_FLAG_KEY"

#define DROPBOX_LINK_SUCCESS_KEY @"DEPO_DROPBOX_LINK_SUCCESS_KEY"

#define EMPTY_EMAIL_CONFIRM_KEY @"EMPTY_EMAIL_CONFIRM_KEY"

//#define REACH_US_MAIL_ADDRESS @"burcu.atalan@turkcell.com.tr"
#define REACH_US_MAIL_ADDRESS @"DESTEK-AKILLIDEPO@turkcell.com.tr"

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
    MenuTypePromo,
    MenuTypeDropbox,
    MenuTypeContactSync,
    MenuTypeLogin,
    MenuTypeCropAndShare,
    MenuTypeCellograph,
    MenuTypeReachUs,
    MenuTypeHelp,
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
    AddTypeFile,
    AddTypeDepoPhoto,
    AddTypeDepoPhotoFav,
    AddTypeDepoMusicFav,
    AddTypeDepoDocumentFav,
    AddTypeOther
} AddType;

typedef enum {
    MoreMenuTypeSort = 0,
    MoreMenuTypeSortWithList,
    MoreMenuTypeSelect,
    MoreMenuTypeVideofy,
    MoreMenuTypeFileDetail,
    MoreMenuTypeFolderDetail,
    MoreMenuTypeAlbumDetail,
    MoreMenuTypeMusicDetail,
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
    NotificationActionPackages,
    NotificationActionPhotos,
    NotificationActionWeb
} NotificationAction;

typedef enum {
    ContactSyncTypeBackup = 1,
    ContactSyncTypeRestore
} ContactSyncType;

typedef enum {
    AccountTypeTurkcell,
    AccountTypeOther
} AccountType;

typedef enum {
    OfferTypeTurkcell,
    OfferTypeApple
} OfferType;

typedef enum {
    UploadStarterPagePhotos = 1,
    UploadStarterPageList,
    UploadStarterPageAuto
} UploadStarterPage;

typedef enum {
    PackageInfo1GB = 1,
    PackageInfo5GB,
    PackageInfo500GB,
    PackageInfoMini,
    PackageInfoStandart,
    PackageInfoMegaPaket
} PackageInfo;

typedef enum {
    MsisdnUpdateTypeSignup,
    MsisdnUpdateTypeEmpty,
    MsisdnUpdateTypeSettings
} MsisdnUpdateType;

typedef enum {
    FeedBackTypeSuggestion,
    FeedBackTypeComplaint
} FeedBackType;

typedef enum {
    PhotoHeaderSegmentTypePhoto,
    PhotoHeaderSegmentTypeAlbum
} PhotoHeaderSegmentType;

typedef enum {
    DropboxExportStatusPending,
    DropboxExportStatusRunning,
    DropboxExportStatusFailed,
    DropboxExportStatusWaitingAction,
    DropboxExportStatusScheduled,
    DropboxExportStatusFinished,
    DropboxExportStatusCancelled
} DropboxExportStatus;

typedef enum {
    SocialExportStatusPending,
    SocialExportStatusRunning,
    SocialExportStatusFailed,
    SocialExportStatusWaitingAction,
    SocialExportStatusScheduled,
    SocialExportStatusFinished,
    SocialExportStatusCancelled
} SocialExportStatus;

typedef enum {
    ImageGroupLevelYear = 1,
    ImageGroupLevelMonth,
    ImageGroupLevelDay
} ImageGroupLevel;

typedef enum {
    ImageGroupTypeDepo = 1,
    ImageGroupTypeInProgress
} ImageGroupType;

@interface AppConstants : NSObject

@end
