//
//  AppUtil.m
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AppUtil.h"
#import "MetaMenu.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "User.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "SyncUtil.h"
#import "CacheUtil.h"

@implementation AppUtil

+ (NSArray *) readMenuItemsForLoggedIn {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    MetaMenu *profileMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeProfile];
    profileMenu.title = @"";
    profileMenu.iconName = @"";
    profileMenu.selectedIconName = @"";
    [result addObject:profileMenu];
    
    MetaMenu *searchMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeSearch];
    searchMenu.title = NSLocalizedString(@"MenuSearch", @"");
    searchMenu.iconName = @"";
    searchMenu.selectedIconName = @"";
    [result addObject:searchMenu];
    
    MetaMenu *homeMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeHome];
    homeMenu.title = NSLocalizedString(@"MenuHome", @"");
    homeMenu.iconName = @"cloud_icon.png";
    homeMenu.selectedIconName = @"cloud_icon.png";
    [result addObject:homeMenu];
    
    MetaMenu *favMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeFav];
    favMenu.title = NSLocalizedString(@"MenuFav", @"");
    favMenu.iconName = @"fav_icon.png";
    favMenu.selectedIconName = @"yellow_fav_icon.png";
    [result addObject:favMenu];

    MetaMenu *dropboxMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeDropbox];
    dropboxMenu.title = NSLocalizedString(@"ExportFromDropbox", @"");
    dropboxMenu.iconName = @"icon_menu_dbtasi_w.png";
    dropboxMenu.selectedIconName = @"icon_menu_dbtasi_w.png";
    //[result addObject:dropboxMenu];

    MetaMenu *fileMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeFiles];
    fileMenu.title = NSLocalizedString(@"MenuFiles", @"");
    fileMenu.iconName = @"file_icon.png";
    fileMenu.selectedIconName = @"yellow_file_icon.png";
    [result addObject:fileMenu];
    
    MetaMenu *photoMenu = [[MetaMenu alloc] initWithMenuType:MenuTypePhoto];
    photoMenu.title = NSLocalizedString(@"MenuPhoto", @"");
    photoMenu.iconName = @"photos_icon.png";
    photoMenu.selectedIconName = @"yellow_photos_icon.png";
    [result addObject:photoMenu];
    
    MetaMenu *musicMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeMusic];
    musicMenu.title = NSLocalizedString(@"MenuMusic", @"");
    musicMenu.iconName = @"music_icon.png";
    musicMenu.selectedIconName = @"yellow_music_icon.png";
    [result addObject:musicMenu];
    
    MetaMenu *docMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeDoc];
    docMenu.title = NSLocalizedString(@"MenuDoc", @"");
    docMenu.iconName = @"documents_icon.png";
    docMenu.selectedIconName = @"yellow_documents_icon.png";
    [result addObject:docMenu];

    MetaMenu *promoMenu = [[MetaMenu alloc] initWithMenuType:MenuTypePromo];
    promoMenu.title = NSLocalizedString(@"MenuPromo", @"");
    promoMenu.iconName = @"documents_icon.png";
    promoMenu.selectedIconName = @"yellow_documents_icon.png";
//    [result addObject:promoMenu];

    MetaMenu *contactMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeContactSync];
    contactMenu.title = NSLocalizedString(@"MenuContactSync", @"");
    contactMenu.iconName = @"contact_sync_icon.png";
    contactMenu.selectedIconName = @"yellow_contact_sync_icon.png";
    [result addObject:contactMenu];
    
    if(APPDELEGATE.session.user.cropAndSharePresentFlag) {
        MetaMenu *cropAndShare = [[MetaMenu alloc] initWithMenuType:MenuTypeCropAndShare];
        cropAndShare.title = NSLocalizedString(@"CropAndShareTitle", @"");
        cropAndShare.iconName = @"cropy.png";
        cropAndShare.selectedIconName = @"yellow_cropy.png";
        [result addObject:cropAndShare];
    }

    if([APPDELEGATE.session.user.countryCode isEqualToString:@"90"]) {
        MetaMenu *cellographMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeCellograph];
        cellographMenu.title = NSLocalizedString(@"MenuCellograph", @"");
        cellographMenu.iconName = @"icon_m_baskial_w.png";
        cellographMenu.selectedIconName = @"icon_m_baskial.png";
        [result addObject:cellographMenu];
    }

    MetaMenu *helpMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeHelp];
    helpMenu.title = NSLocalizedString(@"MenuHelp", @"");
    helpMenu.iconName = @"icon_m_yardim_w.png";
    helpMenu.selectedIconName = @"icon_m_yardim.png";
    [result addObject:helpMenu];

    MetaMenu *reachUshMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeReachUs];
    reachUshMenu.title = NSLocalizedString(@"MenuReachUs", @"");
    reachUshMenu.iconName = @"icon_menu_bizeulasin_w.png";
    reachUshMenu.selectedIconName = @"icon_menu_bizeulasin.png";
    [result addObject:reachUshMenu];

    MetaMenu *logoutMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeLogout];
    logoutMenu.title = NSLocalizedString(@"MenuLogout", @"");
    logoutMenu.iconName = @"logout_icon.png";
    logoutMenu.selectedIconName = @"yellow_logout_icon.png";
    [result addObject:logoutMenu];
    
    return result;
    //    return @[profileMenu, searchMenu, homeMenu, favMenu, fileMenu, photoMenu, musicMenu, docMenu, /* contacts commented out // contactMenu ,*/ logoutMenu];
}

+ (NSString *) iconNameByContentType:(ContentType) contentType {
    NSString *iconName = @"document_icon.png";
    switch (contentType) {
        case ContentTypeMusic:
            iconName = @"green_music_icon.png";
            break;
        case ContentTypeFolder:
            iconName = @"folder_icon.png";
            break;
        case ContentTypeAlbumPhoto:
            iconName = @"album_photo_icon.png";
            break;
        default:
            break;
    }
    return iconName;
}

+ (NSString *) buttonImgNameByAddType:(AddType) addType {
    NSString *iconName = @"blue_add_photo_icon.png";
    switch (addType) {
        case AddTypeMusic:
        case AddTypeDepoMusicFav:
            iconName = @"blue_add_music_icon.png";
            break;
        case AddTypeFolder:
        case AddTypeAlbum:
            iconName = @"blue_add_new_folder_icon.png";
            break;
        case AddTypePhoto:
        case AddTypeDepoPhotoFav:
            iconName = @"blue_add_photo_icon.png";
            break;
        case AddTypeDepoPhoto:
            iconName = @"icon_yukle_depo.png";
            break;
        case AddTypeCamera:
            iconName = @"blue_add_camera_shot_icon.png";
            break;
        case AddTypeFile:
        case AddTypeDepoDocumentFav:
            iconName = @"blue_add_new_folder_icon.png";
            break;
        default:
            break;
    }
    return iconName;
}

+ (NSString *) buttonTitleByAddType:(AddType) addType {
    NSString *title = @"";
    switch (addType) {
        case AddTypeMusic:
            title = NSLocalizedString(@"AddTypeMusicTitle", @"");
            break;
        case AddTypeFolder:
            title = NSLocalizedString(@"AddTypeFolderTitle", @"");
            break;
        case AddTypeAlbum:
            title = NSLocalizedString(@"AddTypeAlbumTitle", @"");
            break;
        case AddTypePhoto:
            title = NSLocalizedString(@"AddTypePhotoTitle", @"");
            break;
        case AddTypeDepoPhoto:
            title = NSLocalizedString(@"AddTypeDepoPhotoTitle", @"");
            break;
        case AddTypeCamera:
            title = NSLocalizedString(@"AddTypeCameraTitle", @"");
            break;
        case AddTypeFile:
            title = NSLocalizedString(@"AddTypeFromDepoTitle", @"");
            break;
        case AddTypeDepoDocumentFav:
            title = NSLocalizedString(@"AddTypeDepoDocumentTitle", @"");
            break;
        case AddTypeDepoMusicFav:
            title = NSLocalizedString(@"AddTypeDepoMusicTitle", @"");
            break;
        case AddTypeDepoPhotoFav:
            title = NSLocalizedString(@"AddTypeDepoPhotoFavTitle", @"");
            break;
        default:
            break;
    }
    return title;
}

+ (NSString *) nakedFileFolderName:(NSString *) fileFolderName {
    if([fileFolderName hasSuffix:@"/"]) {
        fileFolderName = [fileFolderName substringToIndex:[fileFolderName length]-1];
    }
    NSArray *components = [fileFolderName componentsSeparatedByString:@"/"];
    if([components count] == 0) {
        return fileFolderName;
    } else {
        return [components objectAtIndex:[components count]-1];
    }
}

+ (NSString *) enrichFileFolderName:(NSString *) fileFolderName {
    if(![fileFolderName hasSuffix:@"/"]) {
        fileFolderName = [NSString stringWithFormat:@"%@/", fileFolderName];
    }
    if(![fileFolderName hasPrefix:@"/"]) {
        fileFolderName = [NSString stringWithFormat:@"/%@", fileFolderName];
    }
    return fileFolderName;
}

+ (NSString *) moreMenuRowImgNameByMoreMenuType:(MoreMenuType) menuType {
    NSString *iconName = @"nav_detail_icon.png";
    switch (menuType) {
        case MoreMenuTypeSort:
        case MoreMenuTypeSortWithList:
            iconName = @"nav_sort_icon.png";
            break;
        case MoreMenuTypeSelect:
            iconName = @"nav_select_icon.png";
            break;
        case MoreMenuTypeVideofy:
            iconName = @"icon_createstory.png";
            break;
        case MoreMenuTypeFileDetail:
        case MoreMenuTypeFolderDetail:
        case MoreMenuTypeAlbumDetail:
        case MoreMenuTypeVideoDetail:
        case MoreMenuTypeImageDetail:
            iconName = @"nav_detail_icon.png";
            break;
        case MoreMenuTypeShare:
        case MoreMenuTypeAlbumShare:
            iconName = @"nav_share_icon.png";
            break;
        case MoreMenuTypeFav:
            iconName = @"nav_favourite_icon.png";
            break;
        case MoreMenuTypeUnfav:
            iconName = @"yellow_fav_icon.png";//@"nav_favourite_active_icon.png";
            break;
        case MoreMenuTypeDelete:
        case MoreMenuTypeAlbumDelete:
        case MoreMenuTypeRemoveFromAlbum:
            iconName = @"nav_delete_icon.png";
            break;
        case MoreMenuTypeDownloadImage:
        case MoreMenutypeDownloadAlbum:
            iconName = @"nav_download_icon.png";
            break;
        case MoreMenuTypeSetCoverPhoto:
            iconName = @"icon_kapakresmi.png";
            break;
        default:
            break;
    }
    return iconName;
}

+ (NSString *) moreMenuRowTitleByMoreMenuType:(MoreMenuType) menuType withContentType:(ContentType) contentType {
    NSString *title = @"";
    switch (menuType) {
        case MoreMenuTypeSort:
        case MoreMenuTypeSortWithList:
            title = NSLocalizedString(@"MoreMenuSortTitle", @"");
            break;
        case MoreMenuTypeSelect:
            title = NSLocalizedString(@"MoreMenuSelectTitle", @"");
            break;
        case MoreMenuTypeVideofy:
            title = NSLocalizedString(@"MoreMenuVideofyTitle", @"");
            break;
        case MoreMenuTypeFolderDetail:
            title = NSLocalizedString(@"MoreMenuDetailFolderTitle", @"");
            break;
        case MoreMenuTypeAlbumDetail:
            title = NSLocalizedString(@"MoreMenuDetailAlbumTitle", @"");
            break;
        case MoreMenuTypeVideoDetail:
            title = NSLocalizedString(@"MoreMenuDetailFileTitleVideo", @"");
            break;
        case MoreMenuTypeImageDetail:
            title = NSLocalizedString(@"MoreMenuDetailFileTitleImg", @"");
            break;
        case MoreMenuTypeMusicDetail:
            title = NSLocalizedString(@"MoreMenuDetailFileTitleMusic", @"");
            break;
        case MoreMenuTypeFileDetail: {
            switch (contentType) {
                case ContentTypeDoc:
                    title = NSLocalizedString(@"MoreMenuDetailFileTitleDoc", @"");
                    break;
                case ContentTypePhoto:
                    title = NSLocalizedString(@"MoreMenuDetailFileTitleImg", @"");
                    break;
                case ContentTypeVideo:
                    title = NSLocalizedString(@"MoreMenuDetailFileTitleVideo", @"");
                    break;
                case ContentTypeMusic:
                    title = NSLocalizedString(@"MoreMenuDetailFileTitleMusic", @"");
                    break;
                    
                default:
                    title = NSLocalizedString(@"MoreMenuDetailFileTitle", @"");
                    break;
            }
            break;
        }
        case MoreMenuTypeShare: {
            switch (contentType) {
                case ContentTypeDoc:
                    title = NSLocalizedString(@"MoreMenuShareTitleDoc", @"");
                    break;
                case ContentTypePhoto:
                    title = NSLocalizedString(@"MoreMenuShareTitleImg", @"");
                    break;
                case ContentTypeVideo:
                    title = NSLocalizedString(@"MoreMenuShareTitleVideo", @"");
                    break;
                case ContentTypeMusic:
                    title = NSLocalizedString(@"MoreMenuShareTitleMusic", @"");
                    break;
                case ContentTypeFolder:
                    title = NSLocalizedString(@"MoreMenuShareTitle", @"");
                    break;
                default:
                    title = NSLocalizedString(@"MoreMenuShareTitleOther", @"");
                    break;
            }
            break;
        }
        case MoreMenuTypeFav: {
            switch (contentType) {
                case ContentTypeDoc:
                    title = NSLocalizedString(@"MoreMenuFavTitleDoc", @"");
                    break;
                case ContentTypePhoto:
                    title = NSLocalizedString(@"MoreMenuFavTitleImg", @"");
                    break;
                case ContentTypeVideo:
                    title = NSLocalizedString(@"MoreMenuFavTitleVideo", @"");
                    break;
                case ContentTypeMusic:
                    title = NSLocalizedString(@"MoreMenuFavTitleMusic", @"");
                    break;
                case ContentTypeFolder:
                    title = NSLocalizedString(@"MoreMenuFavTitle", @"");
                    break;
                default:
                    title = NSLocalizedString(@"MoreMenuFavTitleOther", @"");
                    break;
            }
            break;
        }
        case MoreMenuTypeUnfav: {
            switch (contentType) {
                case ContentTypeDoc:
                    title = NSLocalizedString(@"MoreMenuUnfavTitleDoc", @"");
                    break;
                case ContentTypePhoto:
                    title = NSLocalizedString(@"MoreMenuUnfavTitleImg", @"");
                    break;
                case ContentTypeVideo:
                    title = NSLocalizedString(@"MoreMenuUnfavTitleVideo", @"");
                    break;
                case ContentTypeMusic:
                    title = NSLocalizedString(@"MoreMenuUnfavTitleMusic", @"");
                    break;
                case ContentTypeFolder:
                    title = NSLocalizedString(@"MoreMenuUnfavTitle", @"");
                    break;
                default:
                    title = NSLocalizedString(@"MoreMenuUnfavTitleOther", @"");
                    break;
            }
            break;
        }
        case MoreMenuTypeDelete: {
            switch (contentType) {
                case ContentTypeDoc:
                    title = NSLocalizedString(@"MoreMenuDeleteTitleDoc", @"");
                    break;
                case ContentTypePhoto:
                    title = NSLocalizedString(@"MoreMenuDeleteTitleImg", @"");
                    break;
                case ContentTypeVideo:
                    title = NSLocalizedString(@"MoreMenuDeleteTitleVideo", @"");
                    break;
                case ContentTypeMusic:
                    title = NSLocalizedString(@"MoreMenuDeleteTitleMusic", @"");
                    break;
                case ContentTypeFolder:
                    title = NSLocalizedString(@"MoreMenuDeleteTitle", @"");
                    break;
                default:
                    title = NSLocalizedString(@"MoreMenuDeleteTitleOther", @"");
                    break;
            }
            break;
        }
        case MoreMenuTypeRemoveFromAlbum: {
            switch (contentType) {
                case ContentTypePhoto:
                    title = NSLocalizedString(@"MoreMenuRemoveTitleImg", @"");
                    break;
                case ContentTypeVideo:
                    title = NSLocalizedString(@"MoreMenuRemoveTitleVideo", @"");
                    break;
                default:
                    title = NSLocalizedString(@"MoreMenuRemoveTitleOther", @"");
                    break;
            }
            break;
        }
        case MoreMenuTypeAlbumShare:
            title = NSLocalizedString(@"MoreMenuShareTitleAlbum", @"");
            break;
        case MoreMenuTypeAlbumDelete:
            title = NSLocalizedString(@"MoreMenuDeleteTitleAlbum", @"");
            break;
        case MoreMenutypeDownloadAlbum:
            title = NSLocalizedString(@"MoreMenuDownloadTitleAlbum", @"");
            break;
        case MoreMenuTypeDownloadImage:
            title = NSLocalizedString(@"MoreMenuDownloadImageTitle", @"");
            break;
        case MoreMenuTypeSetCoverPhoto:
            title = NSLocalizedString(@"MoreMenuSetCoverPhotoTitle", @"");
            break;
        default:
            break;
    }
    return title;
}

+ (BOOL) isMetaFileImage:(MetaFile *) file {
    return ([file.rawContentType isEqualToString:CONTENT_TYPE_JPEG_VALUE] || [file.rawContentType isEqualToString:CONTENT_TYPE_JPG_VALUE] || [file.rawContentType isEqualToString:CONTENT_TYPE_PNG_VALUE]);
}

+ (BOOL) isMetaFileVideo:(MetaFile *) file {
    return ([file.rawContentType hasPrefix:@"video/"]);
}

+ (BOOL) isMetaFileMusic:(MetaFile *) file {
    //    return ([file.rawContentType isEqualToString:CONTENT_TYPE_AUDIO_MP3_VALUE] || [file.rawContentType isEqualToString:CONTENT_TYPE_AUDIO_MPEG_VALUE]);
    return ([file.rawContentType hasPrefix:@"audio/"]);
}

+ (BOOL) isMetaFileDoc:(MetaFile *) file {
    return ([file.rawContentType isEqualToString:CONTENT_TYPE_PDF_VALUE] || [file.rawContentType isEqualToString:CONTENT_TYPE_DOC_VALUE] || [file.rawContentType isEqualToString:CONTENT_TYPE_TXT_VALUE] || [file.rawContentType isEqualToString:CONTENT_TYPE_HTML_VALUE]);
}

+ (BOOL) isMetaFileAlbumPhoto:(MetaFile *)file {
    return ([file.rawContentType hasPrefix:@"album/photo"]);
}

+ (AddType) strToAddType:(NSString *) str {
    if([str isEqualToString:@"AddTypeAlbum"]) {
        return AddTypeAlbum;
    } else if([str isEqualToString:@"AddTypeMusic"]) {
        return AddTypeMusic;
    } else if([str isEqualToString:@"AddTypePhoto"]) {
        return AddTypePhoto;
    } else if([str isEqualToString:@"AddTypeCamera"]) {
        return AddTypeCamera;
    } else if([str isEqualToString:@"AddTypeFile"]) {
        return AddTypeFile;
    } else if([str isEqualToString:@"AddTypeDepoPhoto"]) {
        return AddTypeDepoPhoto;
    } else if([str isEqualToString:@"AddTypeDepoDocumentFav"]) {
        return AddTypeDepoDocumentFav;
    } else if([str isEqualToString:@"AddTypeDepoMusicFav"]) {
        return AddTypeDepoMusicFav;
    } else if([str isEqualToString:@"AddTypeDepoPhotoFav"]) {
        return AddTypeDepoPhotoFav;
    }
    return AddTypeFolder;
}

+ (NSString *) sortTypeTitleByEnum:(SortType) type {
    switch (type) {
        case SortTypeAlphaAsc:
            return NSLocalizedString(@"SortTypeAlphaAscTitle", @"");
        case SortTypeAlphaDesc:
            return NSLocalizedString(@"SortTypeAlphaDescTitle", @"");
        case SortTypeDateDesc:
            return NSLocalizedString(@"SortTypeDateDescTitle", @"");
        case SortTypeDateAsc:
            return NSLocalizedString(@"SortTypeDateAscTitle", @"");
        case SortTypeSizeAsc:
            return NSLocalizedString(@"SortTypeSizeAscTitle", @"");
        case SortTypeSizeDesc:
            return NSLocalizedString(@"SortTypeSizeDescTitle", @"");
        case SortTypeSongNameAsc:
            return NSLocalizedString(@"SortTypeSongNameAscTitle", @"");
        case SortTypeSongNameDesc:
            return NSLocalizedString(@"SortTypeSongNameDescTitle", @"");
        case SortTypeArtistAsc:
            return NSLocalizedString(@"SortTypeArtistAscTitle", @"");
        case SortTypeArtistDesc:
            return NSLocalizedString(@"SortTypeArtistDescTitle", @"");
        case SortTypeAlbumAsc:
            return NSLocalizedString(@"SortTypeAlbumAscTitle", @"");
        case SortTypeAlbumDesc:
            return NSLocalizedString(@"SortTypeAlbumDescTitle", @"");
        default:
            return @"";
    }
}

+ (NSString *) serverSortNameByEnum:(SortType) type forPhotosOnly:(BOOL) photosOnly {
    switch (type) {
        case SortTypeAlphaAsc:
        case SortTypeAlphaDesc:
            return @"name";
        case SortTypeDateDesc:
        case SortTypeDateAsc:
            return photosOnly ? @"metadata.Image-DateTime" : @"createdDate";
        case SortTypeSizeAsc:
        case SortTypeSizeDesc:
            return @"bytes";
        case SortTypeSongNameAsc:
        case SortTypeSongNameDesc:
            return @"name";
        case SortTypeArtistAsc:
        case SortTypeArtistDesc:
            return @"Artist";
        case SortTypeAlbumAsc:
        case SortTypeAlbumDesc:
            return @"Album";
        default:
            return @"";
    }
}

+ (NSString *) serverSortNameByEnum:(SortType) type {
    return [AppUtil serverSortNameByEnum:type forPhotosOnly:NO];
}

+ (BOOL) isAscByEnum:(SortType) type {
    return (type == SortTypeAlphaAsc || type == SortTypeSizeAsc || type == SortTypeDateAsc || type == SortTypeSongNameAsc || type == SortTypeArtistAsc || type == SortTypeAlbumAsc);
}

+ (NSString *) randomCamImgName {
    return [NSString stringWithFormat:@"fromCam%d.png", arc4random_uniform(999)];
}

+ (NSString *) iconNameByActivityType:(ActivityType) type {
    switch (type) {
        case ActivityTypeFolder:
            return @"circle_folder_icon.png";
        case ActivityTypeImage:
            return @"circle_photos_icon.png";
        case ActivityTypeTrash:
            return @"circle_delete_icon.png";
        case ActivityTypeContact:
            return @"circle_contact_icon.png";
        case ActivityTypeFav:
            return @"circle_fav_icon.png";
        case ActivityTypeMusic:
            return @"circle_music_icon.png";
        case ActivityTypeFile:
            return @"circle_doc_icon.png";
        default:
            return @"circle_welcome_icon.png";
    }
    return @"";
}

+ (NSString *) iconNameByUsageType:(UsageType) type {
    switch (type) {
        case UsageTypeImage:
            return @"usage_photos_icon.png";
        case UsageTypeMusic:
            return @"musics_icon.png";
        case UsageTypeOther:
            return @"docs_icon.png";
        case UsageTypeContact:
            return @"contacts_icon.png";
        case UsageTypeVideo:
            return @"video_main_icon.png";
    }
    return @"";
}

+ (BOOL) readFirstVisitOverFlag {
    return [[NSUserDefaults standardUserDefaults] boolForKey:FIRST_VISIT_OVER];
}

+ (void) writeFirstVisitOverFlag {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FIRST_VISIT_OVER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) readDueDateInReadableFormat:(NSDate *) date {
    if(date == nil)
        return @"";
    
    NSDate *today = [NSDate date];
    double diffInSec = [today timeIntervalSinceReferenceDate] - [date timeIntervalSinceReferenceDate];
    
    int days = floor(diffInSec/86400);
    int hours = floor((diffInSec - days*86400)/3600);
    int minutes = floor((diffInSec - days*86400 - hours*3600)/60);
    int secs = diffInSec - days*86400 - hours*3600 - minutes*60;
    
    if(days > 0) {
        return [NSString stringWithFormat:@"%d %@, %d %@", days, days > 1 ? NSLocalizedString(@"Days", @"") : NSLocalizedString(@"Day", @""), hours, hours > 1 ? NSLocalizedString(@"Hours", @"") : NSLocalizedString(@"Hour", @"")];
    } else if(hours > 0) {
        return [NSString stringWithFormat:@"%d %@, %d %@", hours, hours > 1 ? NSLocalizedString(@"Hours", @"") : NSLocalizedString(@"Hour", @""), minutes, minutes > 1 ? NSLocalizedString(@"Minutes", @"") : NSLocalizedString(@"Minute", @"")];
    } else if(minutes > 0) {
        return [NSString stringWithFormat:@"%d %@, %d %@", minutes, minutes > 1 ? NSLocalizedString(@"Minutes", @"") : NSLocalizedString(@"Minute", @""), secs, secs > 1 ? NSLocalizedString(@"Seconds", @"") : NSLocalizedString(@"Second", @"")];
    } else {
        return [NSString stringWithFormat:@"%d %@", secs, secs > 1 ? NSLocalizedString(@"Seconds", @"") : NSLocalizedString(@"Second", @"")];
    }
}

+ (NSString *) userUniqueValueByBaseUrl:(NSString *) baseUrl {
    NSArray *baseUrlComponents = [baseUrl componentsSeparatedByString:@"/"];
    if([baseUrlComponents count] > 0) {
        for(NSString *component in baseUrlComponents) {
            if([component hasPrefix:@"AUTH_"]) {
                return component;
            }
        }
    }
    return @"";
    
}

+ (NSString *) readDocumentsPathForFileName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}

+ (void) sendLocalNotificationForDate:(NSDate *) dateToSend withMessage:(NSString *) msg {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = dateToSend;
    localNotification.alertBody = msg;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.userInfo = @{@"action":@"photos_videos"};
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

+ (BOOL) checkIsUpdate {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *oldVersion = [[NSUserDefaults standardUserDefaults] objectForKey:SYSTEM_VERSION_KEY];
    if (oldVersion) {
        if ([version isEqualToString:oldVersion]) {
            return NO;
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:version forKey:SYSTEM_VERSION_KEY];
            return YES;
        }
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:version forKey:SYSTEM_VERSION_KEY];
        return NO;
    }
}

+ (BOOL) shouldShowNewFeatures {
    BOOL newFeaturesFlag = NO;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:NEW_FEATURES_FLAG_KEY]) {
        newFeaturesFlag = [[NSUserDefaults standardUserDefaults] boolForKey:NEW_FEATURES_FLAG_KEY];
        return newFeaturesFlag;
    }
    else {
        newFeaturesFlag = YES;
        [[NSUserDefaults standardUserDefaults] setBool:newFeaturesFlag forKey:NEW_FEATURES_FLAG_KEY];
        return newFeaturesFlag;
    }
}

+ (BOOL) checkAndSetFlags:(NSString *) flagKey {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:flagKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:flagKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:flagKey];
        return YES;
    }
}

+ (NSDictionary *) readWaitingIAPValidationForFutureTry {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"WAITING_IAP_VALIDATION_INFO_KEY"];
    if(!dict)
        dict = [[NSDictionary alloc] init];
    return dict;
}

+ (void) writeWaitingIAPValidationForFutureTryForProductId:(NSString *) productId andReceiptId:(NSString *) receiptId {
    NSDictionary *currentDict = [AppUtil readWaitingIAPValidationForFutureTry];
    if([currentDict objectForKey:productId] == nil) {
        NSMutableDictionary *finalDict = [currentDict mutableCopy];
        [finalDict setObject:receiptId forKey:productId];
        
        [[NSUserDefaults standardUserDefaults] setObject:finalDict forKey:@"WAITING_IAP_VALIDATION_INFO_KEY"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void) cleanWaitingIAPValidationForFutureTryWithProductId:(NSString *) productId {
    NSDictionary *currentDict = [AppUtil readWaitingIAPValidationForFutureTry];
    if([currentDict objectForKey:productId] != nil) {
        NSMutableDictionary *finalDict = [currentDict mutableCopy];
        [finalDict removeObjectForKey:productId];
        
        [[NSUserDefaults standardUserDefaults] setObject:finalDict forKey:@"WAITING_IAP_VALIDATION_INFO_KEY"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (BOOL) isValidEmail:(NSString *)checkString {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (NSString *)getPackageDisplayName: (NSString *) roleName {
    NSString *name = @"";
    if ([roleName isEqualToString:@"demo"]) {
        name = NSLocalizedString(@"Welcome", @"");
    } else if ([roleName isEqualToString:@"standard"]) {
        name = @"Mini Paket";
    } else if ([roleName isEqualToString:@"premium"]) {
        name = @"Standart Paket";
    } else if ([roleName isEqualToString:@"ultimate"]) {
        name = @"Mega Paket";
    }
    return name;
}

+ (NSString *)getPackageNameForSms: (NSString *)roleName {
    NSString *name = @"";
    if ([roleName isEqualToString:@"standart"] || [roleName isEqualToString:@"standard"]) {
        name = @"LIFEBOX 50GB";
    } else if ([roleName isEqualToString:@"premium"]) {
        name = @"LIFEBOX 500GB";
    } else if ([roleName isEqualToString:@"ultimate"]) {
        name = @"LIFEBOX 25TB";
    }
    return name;
}

+ (void) writeDoNotShowAgainFlagForKey:(NSString *) key {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) readDoNotShowAgainFlagForKey:(NSString *) key {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+ (BOOL) isAlreadyRated {
    return [[NSUserDefaults standardUserDefaults] boolForKey:APP_RATE_FLAG_KEY];
}

+ (void) setAlreadyRated {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:APP_RATE_FLAG_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) writeFirstUploadFlag {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FIRST_UPLOAD_FLAG_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) readFirstUploadFlag {
    return [[NSUserDefaults standardUserDefaults] boolForKey:FIRST_UPLOAD_FLAG_KEY];
}

+ (NSString *) operatorName {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    if([carrier.mobileCountryCode isEqualToString:@"286"]) {
        if([carrier.mobileNetworkCode isEqualToString:@"01"]) {
            return @"TURKCELL";
        } else if([carrier.mobileNetworkCode isEqualToString:@"02"]) {
            return @"VODAFONE";
        } else if([carrier.mobileNetworkCode isEqualToString:@"03"]) {
            return @"AVEA";
        }
    }
    return [NSString stringWithFormat:@"%@-%@", carrier.mobileCountryCode, carrier.mobileNetworkCode];
}

+ (NSString *) readCurrentMobileNetworkCode {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    NSString *mnc = [carrier mobileNetworkCode];
    return mnc;
}

+ (void) writeFeatureFlag {
    NSString *keyVal = [NSString stringWithFormat:@"FEATURE_PAGE_SHOWN_FLAG_%@", APPDELEGATE.session.user.username];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:keyVal];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) readFeatureFlag {
    NSString *keyVal = [NSString stringWithFormat:@"FEATURE_PAGE_SHOWN_FLAG_%@", APPDELEGATE.session.user.username];
    return [[NSUserDefaults standardUserDefaults] boolForKey:keyVal];
}

//+ (void) writeLifeboxTeaserFlag {
//    NSString *keyVal = [NSString stringWithFormat:@"LIFEBOX_TEASER_PAGE_SHOWN_FLAG_%@", APPDELEGATE.session.user.username];
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:keyVal];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//+ (BOOL) readLifeboxTeaserFlag {
//    NSString *keyVal = [NSString stringWithFormat:@"LIFEBOX_TEASER_PAGE_SHOWN_FLAG_%@", APPDELEGATE.session.user.username];
//    return [[NSUserDefaults standardUserDefaults] boolForKey:keyVal];
//}

//+ (void) writeLocInfoPopupShownFlag {
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"LOC_INFO_POPUP_SHOWN_%@", [SyncUtil readBaseUrlConstant]]];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//+ (BOOL) readLocInfoPopupShownFlag {
//    return [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"LOC_INFO_POPUP_SHOWN_%@", [SyncUtil readBaseUrlConstant]]];
//}
//

+ (void) writeLocInfoPopupShownFlag {
    NSString* key = [NSString stringWithFormat:@"LOC_INFO_POPUP_SHOWN_%@", [SyncUtil readBaseUrlConstantForLocPopup]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) readLocInfoPopupShownFlag {
    NSString* key = [NSString stringWithFormat:@"LOC_INFO_POPUP_SHOWN_%@", [SyncUtil readBaseUrlConstantForLocPopup]];
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+ (void) writePeriodicLocInfoPopupIdleFlag {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"PERIODIC_LOC_INFO_POPUP_IDLE_%@", [SyncUtil readBaseUrlConstant]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) resetPeriodicLocInfoPopupIdleFlag {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"PERIODIC_LOC_INFO_POPUP_IDLE_%@", [SyncUtil readBaseUrlConstant]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL) readPeriodicLocInfoPopupIdleFlag {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"PERIODIC_LOC_INFO_POPUP_IDLE_%@", [SyncUtil readBaseUrlConstant]]];
}

+ (void) writeLastLocInfoPopupShownTime {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"LAST_LOC_INFO_POPUP_SHOWN_TIME_%@", [SyncUtil readBaseUrlConstant]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDate *) readLastLocInfoPopupShownTime {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"LAST_LOC_INFO_POPUP_SHOWN_TIME_%@", [SyncUtil readBaseUrlConstant]]];
}

+ (void) increaseVideofyTutorialCount {
    NSInteger result = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:TUTORIAL_VIDEOFY_COUNT_KEY, APPDELEGATE.session.user.phoneNumber]];
    result ++;
    [[NSUserDefaults standardUserDefaults] setInteger:result forKey:[NSString stringWithFormat:TUTORIAL_VIDEOFY_COUNT_KEY, APPDELEGATE.session.user.phoneNumber]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (int) readVideofyTutorialCount {
    NSInteger result = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:TUTORIAL_VIDEOFY_COUNT_KEY, APPDELEGATE.session.user.phoneNumber]];
    return (int)result;
}

+ (NSString*) loginCountKey {
    return [NSString stringWithFormat:DEPO_LOGIN_COUNT_KEY, APPDELEGATE.session.user.phoneNumber];
}

+ (void) increaseLoginCount {
    NSInteger result = [AppUtil readLoginCount];
    result ++;
    NSString* key =  [self loginCountKey];
    [[NSUserDefaults standardUserDefaults] setInteger:result forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    if (result == 2) {
//        [AppUtil writeLastLocInfoPopupShownTime];
//    }
}

+ (int) readLoginCount {
    NSString* key =  [self loginCountKey];
    NSInteger result = [[NSUserDefaults standardUserDefaults] integerForKey:key];
    return (int)result;
    
}

+ (void) writeAppFirstLaunchFlag {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:APP_FIRST_LAUNCH_FLAG];
}

+ (BOOL) readAppFirstLaunchFlag {
    return [[NSUserDefaults standardUserDefaults] boolForKey:APP_FIRST_LAUNCH_FLAG];
}

@end
