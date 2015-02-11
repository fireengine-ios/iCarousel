//
//  BaseDao.m
//  Depo
//
//  Created by Mahir Tarlan
//  Copyright (c) 2014 iGones. All rights reserved.
//

#import "BaseDao.h"
#import "AppDelegate.h"
#import "AppUtil.h"

@implementation BaseDao

@synthesize delegate, successMethod, failMethod;

- (NSString *) hasFinishedSuccessfully:(NSDictionary *) mainDict {
    if(mainDict == nil) {
        return GENERAL_ERROR_MESSAGE;
    } else {
        NSDictionary *resultDict = [mainDict objectForKey:@"result"];
        if(resultDict == nil) {
            return GENERAL_ERROR_MESSAGE;
        } else {
            NSNumber *isSuccess = [resultDict objectForKey:@"success"];
            NSString *message = [resultDict objectForKey:@"errorDescription"];
            if(!isSuccess) {
                if(message != nil) {
                    return message;
                } else {
                    return GENERAL_ERROR_MESSAGE;
                }
            }
        }
    }
    return nil;
}

- (void) sendPostRequest:(ASIFormDataRequest *) request {
    [request setRequestMethod:@"POST"];
    request.timeOutSeconds = 30;
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    if(APPDELEGATE.session.authToken) {
        [request addRequestHeader:@"X-Auth-Token" value:APPDELEGATE.session.authToken];
    }
    [request startAsynchronous];
}

- (void) sendGetRequest:(ASIFormDataRequest *) request {
    [request setRequestMethod:@"GET"];
    request.timeOutSeconds = 30;
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    if(APPDELEGATE.session.authToken) {
        [request addRequestHeader:@"X-Auth-Token" value:APPDELEGATE.session.authToken];
    }
    [request startAsynchronous];
}

- (void) sendPutRequest:(ASIFormDataRequest *) request {
    [request setRequestMethod:@"PUT"];
    request.timeOutSeconds = 90;
    if(APPDELEGATE.session.authToken) {
        [request addRequestHeader:@"X-Auth-Token" value:APPDELEGATE.session.authToken];
    }
    [request startAsynchronous];
}

- (void) sendDeleteRequest:(ASIFormDataRequest *) request {
    request.timeOutSeconds = 90;
    if(APPDELEGATE.session.authToken) {
        [request addRequestHeader:@"X-Auth-Token" value:APPDELEGATE.session.authToken];
    }
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request buildPostBody];
    [request setRequestMethod:@"DELETE"];
    [request startAsynchronous];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if([request responseStatusCode] == 401) {
        //TODO token tekrar alınacak
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    } else if([request responseStatusCode] == 403) {
        [self shouldReturnFailWithMessage:FORBIDDEN_ERROR_MESSAGE];
    } else {
        if([request.error code] == ASIConnectionFailureErrorType){
            [self shouldReturnFailWithMessage:NO_CONN_ERROR_MESSAGE];
        } else {
            [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
        }
    }
}

- (BOOL) boolByNumber:(NSNumber *) numberObj {
    if(numberObj != nil && ![numberObj isKindOfClass:[NSNull class]]) {
        return  [numberObj boolValue];
    }
    return NO;
}

- (int) intByNumber:(NSNumber *) numberObj {
    if(numberObj != nil && ![numberObj isKindOfClass:[NSNull class]]) {
        return  [numberObj intValue];
    }
    return 0;
}

- (float) floatByNumber:(NSNumber *) numberObj {
    if(numberObj != nil && ![numberObj isKindOfClass:[NSNull class]]) {
        return  [numberObj floatValue];
    }
    return 0;
}

- (long) longByNumber:(NSNumber *) numberObj {
    if(numberObj != nil && ![numberObj isKindOfClass:[NSNull class]]) {
        return  [numberObj longValue];
    }
    return 0;
}

- (NSString *) strByRawVal:(NSString *) rawStr {
    if(rawStr == nil || [rawStr isKindOfClass:[NSNull class]])
        return nil;
    return rawStr;
}

- (NSDate *) dateByRawVal:(NSString *) rawStr {
    if(rawStr == nil || [rawStr isKindOfClass:[NSNull class]])
        return nil;
    
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
//    return [df dateFromString:rawStr];
    return [NSDate dateWithTimeIntervalSince1970:([rawStr longLongValue] / 1000.0)];
}

- (NSString *) enrichFileFolderName:(NSString *) fileFolderName {
    if(![fileFolderName hasSuffix:@"/"]) {
        return [NSString stringWithFormat:@"%@/", fileFolderName];
    }
    return fileFolderName;
}

- (ContentType) contentTypeByRawValue:(MetaFile *) metaFile {
    if(metaFile.folder) {
        return ContentTypeFolder;
    }
    if([metaFile.rawContentType isEqualToString:CONTENT_TYPE_JPEG_VALUE] || [metaFile.rawContentType isEqualToString:CONTENT_TYPE_JPG_VALUE] || [metaFile.rawContentType isEqualToString:CONTENT_TYPE_PNG_VALUE]) {
        return ContentTypePhoto;
    } else if([metaFile.rawContentType isEqualToString:CONTENT_TYPE_AUDIO_MP3_VALUE] || [metaFile.rawContentType isEqualToString:CONTENT_TYPE_AUDIO_MPEG_VALUE]) {
            return ContentTypeMusic;
    } else if([metaFile.rawContentType hasPrefix:@"video/"]) {
        return ContentTypeVideo;
    } else if([metaFile.rawContentType isEqualToString:CONTENT_TYPE_PDF_VALUE] || [metaFile.rawContentType isEqualToString:CONTENT_TYPE_DOC_VALUE] || [metaFile.rawContentType isEqualToString:CONTENT_TYPE_TXT_VALUE] || [metaFile.rawContentType isEqualToString:CONTENT_TYPE_HTML_VALUE]) {
        return ContentTypeDoc;
    }
    return ContentTypeOther;
}

- (void) shouldReturnSuccess {
    SuppressPerformSelectorLeakWarning([delegate performSelector:successMethod]);
}

- (void) shouldReturnSuccessWithObject:(id) obj {
    SuppressPerformSelectorLeakWarning([delegate performSelector:successMethod withObject:obj]);
}

- (void) shouldReturnFailWithMessage:(NSString *) errorMessage {
    SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:errorMessage]);
}

- (void) shouldReturnFailWithParam:(id) param {
    SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:param]);
}

- (MetaFile *) parseFile:(NSDictionary *) dict {
    NSString *uuid = [dict objectForKey:@"uuid"];
    NSString *hash = [dict objectForKey:@"hash"];
    NSString *subdir = [dict objectForKey:@"subdir"];
    NSString *parent = [dict objectForKey:@"parent"];
    NSString *name = [dict objectForKey:@"name"];
    NSNumber *bytes = [dict objectForKey:@"bytes"];
    NSNumber *folder = [dict objectForKey:@"folder"];
    NSNumber *hidden = [dict objectForKey:@"hidden"];
    NSNumber *childCount = [dict objectForKey:@"childCount"];
    NSString *path = [dict objectForKey:@"path"];
    NSString *tempDownloadURL = [dict objectForKey:@"tempDownloadURL"];
    NSString *last_modified = [dict objectForKey:@"lastModifiedDate"];
    NSString *content_type = [dict objectForKey:@"content_type"];
    
    MetaFile *file = [[MetaFile alloc] init];
    file.uuid = [self strByRawVal:uuid];
    file.hash = [self strByRawVal:hash];
    file.subDir = [self strByRawVal:subdir];
    file.parent = [self strByRawVal:parent];
    file.name = [self strByRawVal:name];
    file.bytes = [self longByNumber:bytes];
    file.folder = [self boolByNumber:folder];
    file.hidden = [self boolByNumber:hidden];
    file.path = [self strByRawVal:path];
    file.tempDownloadUrl = [self strByRawVal:tempDownloadURL];
    file.lastModified = [self dateByRawVal:last_modified];
    file.rawContentType = [self strByRawVal:content_type];
    file.contentType = [self contentTypeByRawValue:file];
    file.visibleName = [AppUtil nakedFileFolderName:file.name];
    file.contentLengthDisplay = @"02:04";
    file.itemCount = [self intByNumber:childCount];
    
    NSDictionary *detailDict = [dict objectForKey:@"metadata"];
    if(detailDict != nil && ![detailDict isKindOfClass:[NSNull class]]) {
        NSNumber *favFlag = [detailDict objectForKey:@"X-Object-Meta-Favourite"];
        NSString *thumbLarge = [detailDict objectForKey:@"X-Object-Meta-Thumbnail-Large"];
        NSString *thumbMedium = [detailDict objectForKey:@"X-Object-Meta-Thumbnail-Medium"];
        NSString *thumbSmall = [detailDict objectForKey:@"X-Object-Meta-Thumbnail-Small"];
        NSString *metaHash = [detailDict objectForKey:@"X-Object-Meta-Ios-Metadata-Hash"];
        NSNumber *imgHeight = [detailDict objectForKey:@"X-Object-Meta-Image-Height"];
        NSNumber *imgWidth = [detailDict objectForKey:@"X-Object-Meta-Image-Width"];
        NSString *genre = [detailDict objectForKey:@"Genre"];
        NSString *artist = [detailDict objectForKey:@"Artist"];
        NSString *album = [detailDict objectForKey:@"Album"];
        NSString *songTitle = [detailDict objectForKey:@"Title"];
        NSNumber *duration = [detailDict objectForKey:@"Duration"];

        FileDetail *detail = [[FileDetail alloc] init];
        detail.favoriteFlag = [self boolByNumber:favFlag];
        detail.thumbLargeUrl = thumbLarge;
        detail.thumbMediumUrl = thumbMedium;
        detail.thumbSmallUrl = thumbSmall;
        detail.width = [self intByNumber:imgWidth];
        detail.height = [self intByNumber:imgHeight];
        detail.genre = [self strByRawVal:genre];
        detail.artist = [self strByRawVal:artist];
        detail.album = [self strByRawVal:album];
        detail.songTitle = [self strByRawVal:songTitle];
        detail.duration = [self floatByNumber:duration];
        
        file.detail = detail;
        file.metaHash = [self strByRawVal:metaHash];
    }
    return file;
}

- (Activity *) parseActivity:(NSDictionary *) dict {
    NSNumber *activityId = [dict objectForKey:@"id"];
    NSString *createdDate = [dict objectForKey:@"createdDate"];
    NSString *rawActivityType = [dict objectForKey:@"activityType"];
    NSString *rawFileType = [dict objectForKey:@"fileType"];
    NSString *fileUuid = [dict objectForKey:@"fileUUID"];
    NSString *name = [dict objectForKey:@"name"];

    Activity *result = [[Activity alloc] init];
    result.activityId = [self longByNumber:activityId];
    result.date = [self dateByRawVal:createdDate];
    result.rawActivityType = [self strByRawVal:rawActivityType];
    result.rawFileType = [self strByRawVal:rawFileType];
    result.fileUuid = [self strByRawVal:fileUuid];
    result.name = [self strByRawVal:name];
    
    NSDictionary *fileInfo = [dict objectForKey:@"fileInfo"];
    if(fileInfo != nil && ![fileInfo isKindOfClass:[NSNull class]]) {
        NSMutableArray *files = [[NSMutableArray alloc] init];
        [files addObject:[self parseFile:fileInfo]];
        result.actionItemList = files;
    }
    
    if([result.rawActivityType isEqualToString:@"FAVOURITE"]) {
        result.activityType = ActivityTypeFav;
    } else if([result.rawActivityType isEqualToString:@"DELETED"]) {
        result.activityType = ActivityTypeTrash;
    } else {
        if([result.rawFileType isEqualToString:@"IMAGE"]) {
            result.activityType = ActivityTypeImage;
        } else if([result.rawFileType isEqualToString:@"OTHER"]) {
            if([result.actionItemList count] > 0) {
                MetaFile *file = [result.actionItemList objectAtIndex:0];
                if(file.folder) {
                    result.activityType = ActivityTypeFolder;
                } else {
                    result.activityType = ActivityTypeFile;
                }
            }
        } else if([result.rawFileType isEqualToString:@"AUDIO"]) {
            result.activityType = ActivityTypeMusic;
        } else if([result.rawFileType isEqualToString:@"CONTACT"]) {
            result.activityType = ActivityTypeContact;
        } else {
            result.activityType = ActivityTypeFile;
        }
    }
    
    return result;
}

- (SortType) resetSortType:(SortType) sortType {
    if(sortType == SortTypeSongNameAsc || sortType == SortTypeSongNameDesc || sortType == SortTypeArtistAsc || sortType == SortTypeArtistDesc || sortType == SortTypeAlbumAsc || sortType == SortTypeAlbumDesc) {
        APPDELEGATE.session.sortType = SortTypeAlphaAsc;
        return APPDELEGATE.session.sortType;
    }
    return sortType;
}

- (Subscription *) parseSubscription:(NSDictionary *) dict {
    Subscription *subscription = [[Subscription alloc] init];
    
    NSString *createdDate = [dict objectForKey:@"createdDate"];
    NSString *lastModifiedDate = [dict objectForKey:@"lastModifiedDate"];
    NSString *createdBy = [dict objectForKey:@"createdBy"];
    NSString *lastModifiedBy = [dict objectForKey:@"lastModifiedBy"];
    NSNumber *isCurrentSubscription = [dict objectForKey:@"isCurrentSubscription"];
    NSString *status = [dict objectForKey:@"status"];
    
    subscription.createdDate = [self strByRawVal:createdDate];
    subscription.lastModifiedDate = [self strByRawVal:lastModifiedDate];
    subscription.createdBy = [self strByRawVal:createdBy];
    subscription.lastModifiedBy = [self strByRawVal:lastModifiedBy];
    subscription.isCurrentSubscription = [self boolByNumber:isCurrentSubscription];
    subscription.status = [self strByRawVal:status];
    
    NSDictionary *detailDict = [dict objectForKey:@"subscriptionPlan"];
    if(detailDict != nil && ![detailDict isKindOfClass:[NSNull class]]) {
        NSString *name = [detailDict objectForKey:@"name"];
        NSString *displayName = [detailDict objectForKey:@"displayName"];
        NSString *description = [detailDict objectForKey:@"description"];
        NSNumber *price = [detailDict objectForKey:@"price"];
        NSNumber *isDefault = [detailDict objectForKey:@"isDefault"];
        NSString *role = [detailDict objectForKey:@"role"];
        NSString *slcmOfferId = [detailDict objectForKey:@"slcmOfferId"];
        NSString *cometOfferId = [detailDict objectForKey:@"cometOfferId"];
        NSNumber *quota = [detailDict objectForKey:@"quota"];
        
        subscription.plan = [[SubscriptionPlan alloc] init];
        subscription.plan.name = [self strByRawVal:name];
        subscription.plan.displayName = [self strByRawVal:displayName];
        subscription.plan.accountDescription = [self strByRawVal:description];
        subscription.plan.price = [self floatByNumber:price];
        subscription.plan.isDefault = [self boolByNumber:isDefault];
        subscription.plan.role = [self strByRawVal:role];
        subscription.plan.slcmOfferId = [self strByRawVal:slcmOfferId];
        subscription.plan.cometOfferId = [self strByRawVal:cometOfferId];
        subscription.plan.quota = [self floatByNumber:quota];
    }
    
    return subscription;
}

- (Offer *) parseOffer:(NSDictionary *) dict {
    Offer *offer = [[Offer alloc] init];
    
    if(dict != nil && ![dict isKindOfClass:[NSNull class]]) {
        NSString *offerId = [dict objectForKey:@"aeOfferId"];
        NSString *name = [dict objectForKey:@"aeOfferName"];
        NSString *campaignChannel = [dict objectForKey:@"campaignChannel"];
        NSString *campaignCode = [dict objectForKey:@"campaignCode"];
        NSString *campaignId = [dict objectForKey:@"campaignId"];
        NSString *campaignUserCode = [dict objectForKey:@"campaignUserCode"];
        NSString *cometParameters = [dict objectForKey:@"cometParameters"];
        NSString *responseApi = [dict objectForKey:@"responseApi"];
        NSString *validationKey = [dict objectForKey:@"validationKey"];
        NSString *price = [dict objectForKey:@"price"];
        NSString *role = [dict objectForKey:@"role"];
        NSString *quota = [dict objectForKey:@"quota"];
        
        offer.offerId = [self strByRawVal:offerId];
        offer.name = [self strByRawVal:name];
        offer.campaignChannel = [self strByRawVal:campaignChannel];
        offer.campaignCode = [self strByRawVal:campaignCode];
        offer.campaignId = [self strByRawVal:campaignId];
        offer.campaignUserCode = [self strByRawVal:campaignUserCode];
        offer.cometParameters = [self strByRawVal:cometParameters];
        offer.responseApi = [self strByRawVal:responseApi];
        offer.validationKey = [self strByRawVal:validationKey];
        offer.price = [self strByRawVal:price];
        offer.role = [self strByRawVal:role];
        offer.quota = [self strByRawVal:quota];
    }
    
    return offer;
}

- (Device *) parseDevice:(NSDictionary *) dict {
    Device *device = [[Device alloc] init];
    
    if(dict != nil && ![dict isKindOfClass:[NSNull class]]) {
        NSString *name = [dict objectForKey:@"name"];
        NSString *deviceTypeText = [dict objectForKey:@"deviceType"];
        
        device.name = [self strByRawVal:name];
        
        if ([deviceTypeText isEqualToString:@"IPHONE"])
            device.type = DeviceTypeIphone;
        else if ([deviceTypeText isEqualToString:@"IPAD"])
            device.type = DeviceTypeIpad;
        else if ([deviceTypeText isEqualToString:@"MAC"])
            device.type = DeviceTypeMac;
        else if ([deviceTypeText isEqualToString:@"WINDOWS"])
            device.type = DeviceTypeWindows;
        else if ([deviceTypeText isEqualToString:@"ANDROID"])
            device.type = DeviceTypeAndroid;
        else
            device.type = DeviceTypeOther;
    }
    
    return device;
}

@end
