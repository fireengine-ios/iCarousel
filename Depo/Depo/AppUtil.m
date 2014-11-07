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
    
    MetaMenu *logoutMenu = [[MetaMenu alloc] initWithMenuType:MenuTypeLogout];
    logoutMenu.title = NSLocalizedString(@"MenuLogout", @"");
    logoutMenu.iconName = @"logout_icon.png";
    logoutMenu.selectedIconName = @"yellow_logout_icon.png";

    return @[profileMenu, searchMenu, homeMenu, favMenu, fileMenu, photoMenu, musicMenu, docMenu, logoutMenu];
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
            iconName = @"nav_sort_icon.png";
            break;
        case MoreMenuTypeSelect:
            iconName = @"nav_select_icon.png";
            break;
        case MoreMenuTypeFileDetail:
        case MoreMenuTypeFolderDetail:
            iconName = @"nav_detail_icon.png";
            break;
        case MoreMenuTypeShare:
            iconName = @"nav_share_icon.png";
            break;
        case MoreMenuTypeFav:
            iconName = @"nav_favourite_icon.png";
            break;
        case MoreMenuTypeUnfav:
            iconName = @"nav_favourite_icon.png";//@"yellow_fav_icon.png";
            break;
        case MoreMenuTypeDelete:
            iconName = @"nav_delete_icon.png";
            break;
        default:
            break;
    }
    return iconName;
}

+ (NSString *) moreMenuRowTitleByMoreMenuType:(MoreMenuType) menuType {
    NSString *title = @"";
    switch (menuType) {
        case MoreMenuTypeSort:
            title = NSLocalizedString(@"MoreMenuSortTitle", @"");
            break;
        case MoreMenuTypeSelect:
            title = NSLocalizedString(@"MoreMenuSelectTitle", @"");
            break;
        case MoreMenuTypeFolderDetail:
            title = NSLocalizedString(@"MoreMenuDetailFolderTitle", @"");
            break;
        case MoreMenuTypeFileDetail:
            title = NSLocalizedString(@"MoreMenuDetailFileTitle", @"");
            break;
        case MoreMenuTypeShare:
            title = NSLocalizedString(@"MoreMenuShareTitle", @"");
            break;
        case MoreMenuTypeFav:
            title = NSLocalizedString(@"MoreMenuFavTitle", @"");
            break;
        case MoreMenuTypeUnfav:
            title = NSLocalizedString(@"MoreMenuUnfavTitle", @"");
            break;
        case MoreMenuTypeDelete:
            title = NSLocalizedString(@"MoreMenuDeleteTitle", @"");
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
    return ([file.rawContentType isEqualToString:CONTENT_TYPE_QUICKTIME_VALUE] || [file.rawContentType isEqualToString:CONTENT_TYPE_MP4_VALUE]);
}

+ (BOOL) isMetaFileMusic:(MetaFile *) file {
    return ([file.rawContentType isEqualToString:CONTENT_TYPE_AUDIO_MP3_VALUE] || [file.rawContentType isEqualToString:CONTENT_TYPE_AUDIO_MPEG_VALUE]);
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
            return @"size";
        default:
            return @"";
    }
}

+ (BOOL) isAscByEnum:(SortType) type {
    return (type == SortTypeAlphaAsc || type == SortTypeSizeAsc || type == SortTypeDateAsc);
}

+ (NSString *) randomCamImgName {
    return [NSString stringWithFormat:@"fromCam%d.png", arc4random_uniform(999)];
}

@end
