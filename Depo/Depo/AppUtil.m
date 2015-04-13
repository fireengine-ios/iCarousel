//
//  AppUtil.m
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AppUtil.h"
#import "MetaMenu.h"

@implementation AppUtil

+ (NSArray *) readMenuItemsForLoggedIn {
    MetaMenu *profileMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeProfile];
    profileMenu.title = @"Mahir Tarlan";
    profileMenu.iconName = @"";
    profileMenu.selectedIconName = @"";
    
    MetaMenu *searchMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeSearch];
    searchMenu.title = NSLocalizedString(@"MenuSearch", @"");
    searchMenu.iconName = @"";
    searchMenu.selectedIconName = @"";
    
    MetaMenu *homeMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeHome];
    homeMenu.title = NSLocalizedString(@"MenuHome", @"");
    homeMenu.iconName = @"home_icon.png";
    homeMenu.selectedIconName = @"yellow_home_icon.png";
    
    MetaMenu *favMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeFav];
    favMenu.title = NSLocalizedString(@"MenuFav", @"");
    favMenu.iconName = @"fav_icon.png";
    favMenu.selectedIconName = @"yellow_fav_icon.png";
    
    MetaMenu *fileMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeFiles];
    fileMenu.title = NSLocalizedString(@"MenuFiles", @"");
    fileMenu.iconName = @"file_icon.png";
    fileMenu.selectedIconName = @"yellow_file_icon.png";
    
    MetaMenu *photoMenu = [[MetaMenu alloc] initWithMenuType:MenuTypePhoto];
    photoMenu.title = NSLocalizedString(@"MenuPhoto", @"");
    photoMenu.iconName = @"photos_icon.png";
    photoMenu.selectedIconName = @"yellow_photos_icon.png";
    
    MetaMenu *musicMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeMusic];
    musicMenu.title = NSLocalizedString(@"MenuMusic", @"");
    musicMenu.iconName = @"music_icon.png";
    musicMenu.selectedIconName = @"yellow_music_icon.png";
    
    MetaMenu *docMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeDoc];
    docMenu.title = NSLocalizedString(@"MenuDoc", @"");
    docMenu.iconName = @"documents_icon.png";
    docMenu.selectedIconName = @"yellow_documents_icon.png";

    MetaMenu *contactMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeContactSync];
    contactMenu.title = NSLocalizedString(@"MenuContactSync", @"");
    contactMenu.iconName = @"contact_sync_icon.png";
    contactMenu.selectedIconName = @"yellow_contact_sync_icon.png";

    MetaMenu *logoutMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeLogout];
    logoutMenu.title = NSLocalizedString(@"MenuLogout", @"");
    logoutMenu.iconName = @"logout_icon.png";
    logoutMenu.selectedIconName = @"yellow_logout_icon.png";

    return @[profileMenu, searchMenu, homeMenu, favMenu, fileMenu, photoMenu, musicMenu, docMenu, /* contacts commented out // contactMenu ,*/ logoutMenu];
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
        default:
            break;
    }
    return iconName;
}

+ (NSString *) buttonImgNameByAddType:(AddType) addType {
    NSString *iconName = @"blue_add_photo_icon.png";
    switch (addType) {
        case AddTypeMusic:
            iconName = @"blue_add_music_icon.png";
            break;
        case AddTypeFolder:
        case AddTypeAlbum:
            iconName = @"blue_add_new_folder_icon.png";
            break;
        case AddTypePhoto:
            iconName = @"blue_add_photo_icon.png";
            break;
        case AddTypeCamera:
            iconName = @"blue_add_camera_shot_icon.png";
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
        case AddTypeCamera:
            title = NSLocalizedString(@"AddTypeCameraTitle", @"");
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
            iconName = @"nav_favourite_icon.png";//@"yellow_fav_icon.png";
            break;
        case MoreMenuTypeDelete:
        case MoreMenuTypeAlbumDelete:
            iconName = @"nav_delete_icon.png";
            break;
        case MoreMenuTypeDownloadImage:
            iconName = @"nav_download_icon.png";
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
        case MoreMenuTypeAlbumShare:
            title = NSLocalizedString(@"MoreMenuShareTitleAlbum", @"");
            break;
        case MoreMenuTypeAlbumDelete:
            title = NSLocalizedString(@"MoreMenuDeleteTitleAlbum", @"");
            break;
        case MoreMenuTypeDownloadImage:
            title = NSLocalizedString(@"MoreMenuDownloadImageTitle", @"");
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

+ (AddType) strToAddType:(NSString *) str {
    if([str isEqualToString:@"AddTypeAlbum"]) {
        return AddTypeAlbum;
    } else if([str isEqualToString:@"AddTypeMusic"]) {
            return AddTypeMusic;
    } else if([str isEqualToString:@"AddTypePhoto"]) {
        return AddTypePhoto;
    } else if([str isEqualToString:@"AddTypeCamera"]) {
        return AddTypeCamera;
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

+ (NSString *) serverSortNameByEnum:(SortType) type {
    switch (type) {
        case SortTypeAlphaAsc:
        case SortTypeAlphaDesc:
            return @"name";
        case SortTypeDateDesc:
        case SortTypeDateAsc:
            return @"createdDate";
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

@end