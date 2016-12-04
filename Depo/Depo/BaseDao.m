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
#import "Reachability.h"
#import "CacheUtil.h"

@implementation BaseDao

@synthesize delegate;
@synthesize successMethod;
@synthesize failMethod;
@synthesize currentRequest;
@synthesize tokenAlreadyRevisitedFlag;
@synthesize taskCompletionHandler;
@synthesize hasError;

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

- (NSMutableURLRequest *) sendPostRequest:(NSMutableURLRequest *) request {
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    if (APPDELEGATE.session.authToken) {
        [request addValue:APPDELEGATE.session.authToken forHTTPHeaderField:@"X-Auth-Token"];
    }
    self.currentRequest = request;
    return request;
}

- (NSURLRequest *) sendGetRequest:(NSMutableURLRequest *) request {
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:30];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    if (APPDELEGATE.session.authToken) {
        [request addValue:APPDELEGATE.session.authToken forHTTPHeaderField:@"X-Auth-Token"];
    }
    self.currentRequest = request;
    return request;
}

- (NSURLRequest *) sendPutRequest:(NSMutableURLRequest *) request {
    [request setHTTPMethod:@"PUT"];
    [request setTimeoutInterval:90];
    if (APPDELEGATE.session.authToken) {
        [request addValue:APPDELEGATE.session.authToken forHTTPHeaderField:@"X-Auth-Token"];
    }
    self.currentRequest = request;
    return request;
}

- (NSURLRequest *) sendDeleteRequest:(NSMutableURLRequest *) request {
    [request setHTTPMethod:@"DELETE"];
    [request setTimeoutInterval:90];
    if (APPDELEGATE.session.authToken) {
        [request addValue:APPDELEGATE.session.authToken forHTTPHeaderField:@"X-Auth-Token"];
    }
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    self.currentRequest = request;
    return request;
}

- (void)requestFailed:(NSURLResponse *) response {
    NSHTTPURLResponse *request = (NSHTTPURLResponse *) response;
    NSString *errorInfoLog = [NSString stringWithFormat:@"BaseDao request failed with code: %d and response", (int)[request statusCode]];
    IGLog(errorInfoLog);
    NSLog(@"%@",errorInfoLog);
    if ([request statusCode] == 200 || [request statusCode] == 0) {
        return;
    }
    if([request statusCode] == 401) {
        IGLog(@"BaseDao request failed with 401");
        if(!self.tokenAlreadyRevisitedFlag) {
            IGLog(@"BaseDao request failed with 401 - tokenAlreadyRevisitedFlag is false, setting to true");
            self.tokenAlreadyRevisitedFlag = YES;
            [self triggerNewToken];
        } else {
            IGLog(@"BaseDao request failed with 401 - tokenAlreadyRevisitedFlag is true");
//            [self shouldReturnFailWithMessage:LOGIN_REQ_ERROR_MESSAGE];
//            NSLog(@"Login Required Triggered within requestFailed instead of fail method: %@", NSStringFromSelector(failMethod));
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_REQ_NOTIFICATION object:nil userInfo:nil];
        }
    } else if([request statusCode] == 403) {
        IGLog(@"BaseDao request failed with 403");
        [self shouldReturnFailWithMessage:FORBIDDEN_ERROR_MESSAGE];
    } else if([request statusCode] == 412) {
        IGLog(@"BaseDao request failed with 412");
        [self shouldReturnFailWithMessage:INVALID_CONTENT_ERROR_MESSAGE];
    } else {
        if([request statusCode] == NSURLErrorNotConnectedToInternet){
            NSString *errorMessageWithRequestUrl = [NSString stringWithFormat:@"BaseDao request failed - ASIConnectionFailureErrorType for %@", self.currentRequest.URL];
            IGLog(errorMessageWithRequestUrl);
            [self shouldReturnFailWithMessage:NSLocalizedString(@"NoConnErrorMessage", @"")];
        } else if([request statusCode] == NSURLErrorTimedOut){
            NSString *errorMessageWithRequestUrl = [NSString stringWithFormat:@"BaseDao request failed - NSURLErrorTimedOut for %@", self.currentRequest.URL];
            IGLog(errorMessageWithRequestUrl);
            [self shouldReturnFailWithMessage:NSLocalizedString(@"TimeoutMessage", @"")];
        } else {
            NSString *localizedErrStr = [NSHTTPURLResponse localizedStringForStatusCode:[request statusCode]];
            NSString *errorMessageWithRequestUrl = [NSString stringWithFormat:@"BaseDao request failed with code:%d and error: %@ - GENERAL_ERROR_MESSAGE for %@", (int)[request statusCode], localizedErrStr, self.currentRequest.URL];
            IGLog(errorMessageWithRequestUrl);
            
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
//    } else if([metaFile.rawContentType isEqualToString:CONTENT_TYPE_AUDIO_MP3_VALUE] || [metaFile.rawContentType isEqualToString:CONTENT_TYPE_AUDIO_MPEG_VALUE]) {
//            return ContentTypeMusic;
    } else if([metaFile.rawContentType hasPrefix:@"audio/"]) {
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

- (FileInfoGroup *) parseFileInfoGroup:(NSDictionary *) dict {
    NSString *rangeStart = [dict objectForKey:@"rangeStart"];
    NSString *rangeEnd = [dict objectForKey:@"rangeEnd"];
    NSString *locationInfo = [dict objectForKey:@"locationInfo"];
    NSString *yearStr = [dict objectForKey:@"year"];
    NSString *monthStr = [dict objectForKey:@"month"];
    NSString *dayStr = [dict objectForKey:@"day"];
    NSArray *fileInfo = [dict objectForKey:@"fileInfo"];

    FileInfoGroup *result = [[FileInfoGroup alloc] init];
    result.uniqueKey = [[NSUUID UUID] UUIDString];
    result.rangeStart = rangeStart;
    result.rangeEnd = rangeEnd;
    result.yearStr = yearStr;
    result.monthStr = monthStr;
    result.dayStr = dayStr;
    result.locationInfo = locationInfo;
    result.groupType = ImageGroupTypeDepo;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    result.rangeRefDate = [dateFormat dateFromString:rangeStart];
    
    NSMutableArray *fileList = [[NSMutableArray alloc] init];
    for(NSDictionary *file in fileInfo) {
        [fileList addObject:[self parseFile:file]];
    }
    result.fileInfo = fileList;
    return result;
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
    NSString *createdDate = [dict objectForKey:@"createdDate"];
    NSArray *albumUuids = [dict objectForKey:@"album"];
    
    MetaFile *file = [[MetaFile alloc] init];
    file.uuid = [self strByRawVal:uuid];
    file.fileHash = [self strByRawVal:hash];
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
    file.contentLengthDisplay = @"";
    file.itemCount = [self intByNumber:childCount];
    
    if(albumUuids != nil && [albumUuids isKindOfClass:[NSArray class]]) {
        file.addedAlbumUuids = albumUuids;
    }
    
    NSDictionary *detailDict = [dict objectForKey:@"metadata"];
    if(detailDict != nil && ![detailDict isKindOfClass:[NSNull class]]) {
        NSNumber *favFlag = [detailDict objectForKey:@"X-Object-Meta-Favourite"];
        NSString *thumbLarge = [detailDict objectForKey:@"Thumbnail-Large"];
        NSString *thumbMedium = [detailDict objectForKey:@"Thumbnail-Medium"];
        NSString *thumbSmall = [detailDict objectForKey:@"Thumbnail-Small"];
        NSString *videoPreview = [detailDict objectForKey:@"Video-Preview"];
        NSString *metaHash = [detailDict objectForKey:@"X-Object-Meta-Ios-Metadata-Hash"];
        NSNumber *imgHeight = [detailDict objectForKey:@"Image-Height"];
        NSNumber *imgWidth = [detailDict objectForKey:@"Image-Width"];
        NSString *fileDate = [detailDict objectForKey:@"Image-DateTime"];
        NSString *genre = [detailDict objectForKey:@"Genre"];
        NSString *artist = [detailDict objectForKey:@"Artist"];
        NSString *album = [detailDict objectForKey:@"Album"];
        NSString *songTitle = [detailDict objectForKey:@"Title"];
        NSNumber *duration = [detailDict objectForKey:@"Duration"];

        NSString *geoAdminLevel1 = [detailDict objectForKey:@"Geo-Admin-Level-1"];
        NSString *geoAdminLevel2 = [detailDict objectForKey:@"Geo-Admin-Level-2"];
        NSString *geoAdminLevel3 = [detailDict objectForKey:@"Geo-Admin-Level-3"];
        NSString *geoAdminLevel4 = [detailDict objectForKey:@"Geo-Admin-Level-4"];
        NSString *geoAdminLevel5 = [detailDict objectForKey:@"Geo-Admin-Level-5"];
        NSString *geoAdminLevel6 = [detailDict objectForKey:@"Geo-Admin-Level-6"];

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
        detail.fileDate = [self dateByRawVal:fileDate];
        detail.createdDate = [self dateByRawVal:createdDate];
        detail.imageDate = [self dateByRawVal:fileDate];

        detail.geoAdminLevel1 = [self strByRawVal:geoAdminLevel1];
        detail.geoAdminLevel2 = [self strByRawVal:geoAdminLevel2];
        detail.geoAdminLevel3 = [self strByRawVal:geoAdminLevel3];
        detail.geoAdminLevel4 = [self strByRawVal:geoAdminLevel4];
        detail.geoAdminLevel5 = [self strByRawVal:geoAdminLevel5];
        detail.geoAdminLevel6 = [self strByRawVal:geoAdminLevel6];

        file.videoPreviewUrl = [self strByRawVal:videoPreview];
        
        NSString *durationVal = @"";
        if(detail.duration) {
            int durationInSec = floor(detail.duration/1000);
            int durationInMin = floor(durationInSec/60);
            int remainingSec = durationInSec - durationInMin*60;
            durationVal = [NSString stringWithFormat:@"%d:%@%d", durationInMin, remainingSec <=9 ? @"0": @"", remainingSec];
        }
        file.contentLengthDisplay = durationVal;
        
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
    } else if ([result.rawActivityType isEqualToString:@"WELCOME"]) {
        result.activityType = ActivityTypeWelcome;
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
        } else if([result.rawFileType isEqualToString:@"DIRECTORY"]) {
            result.activityType = ActivityTypeFolder;
        } else {
            result.activityType = ActivityTypeFile;
        }
    }
    
    return result;
}

- (SortType) resetSortType:(SortType) sortType {
    if(sortType == SortTypeSongNameAsc || sortType == SortTypeSongNameDesc || sortType == SortTypeArtistAsc || sortType == SortTypeArtistDesc || sortType == SortTypeAlbumAsc || sortType == SortTypeAlbumDesc) {
        APPDELEGATE.session.sortType = SortTypeDateDesc;
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
    NSNumber *nextRenewalDate = [dict objectForKey:@"nextRenewalDate"];
    NSString *subscriptionEndDate = [dict objectForKey:@"subscriptionEndDate"];
    NSString *type = [dict objectForKey:@"type"];
    NSString *renewalStatus = [dict objectForKey:@"renewalStatus"];
    
    subscription.createdDate = [self strByRawVal:createdDate];
    subscription.lastModifiedDate = [self strByRawVal:lastModifiedDate];
    subscription.createdBy = [self strByRawVal:createdBy];
    subscription.lastModifiedBy = [self strByRawVal:lastModifiedBy];
    subscription.isCurrentSubscription = [self boolByNumber:isCurrentSubscription];
    subscription.status = [self strByRawVal:status];
    subscription.subscriptionEndDate = [self strByRawVal:subscriptionEndDate];
    subscription.type = [self strByRawVal:type];
    subscription.renewalStatus = [self strByRawVal:renewalStatus];
    if(nextRenewalDate != nil && ![nextRenewalDate isKindOfClass:[NSNull class]]) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd MMM yy"];
        subscription.nextRenewalDate = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:([nextRenewalDate doubleValue]/1000)]];
    }
    
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
        NSString *period = [detailDict objectForKey:@"period"];
        NSString *inAppPurchaseId = [detailDict objectForKey:@"inAppPurchaseId"];
        NSString *type = [detailDict objectForKey:@"type"];
        
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
        subscription.plan.period = [self strByRawVal:period];
        subscription.plan.inAppPurchaseId = [self strByRawVal:inAppPurchaseId];
        subscription.plan.type = [self strByRawVal:type];
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
        NSNumber *rawPrice = [dict objectForKey:@"price"];
        NSString *role = [dict objectForKey:@"role"];
        NSString *quotaString = [dict objectForKey:@"quota"];
        NSString *period = [dict objectForKey:@"period"];
        NSNumber *quota = [dict objectForKey:@"quota"];
        
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
        offer.rawPrice = [self floatByNumber:rawPrice];
        offer.role = [self strByRawVal:role];
        offer.quotaString = [self strByRawVal:quotaString];
        offer.quota = [self floatByNumber:quota];
        offer.period = [self strByRawVal:period];
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

- (void) triggerNewToken {
    IGLog(@"BaseDao at triggerNewToken");
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(networkStatus == kReachableViaWiFi || networkStatus == kReachableViaWWAN) {
        IGLog(@"BaseDao at triggerNewToken kReachableViaWiFi || kReachableViaWWAN");
        if([CacheUtil readRememberMeToken] != nil) {
            IGLog(@"BaseDao at triggerNewToken readRememberMeToken not null");
            tokenDao = [[RequestTokenDao alloc] init];
            tokenDao.delegate = self;
            tokenDao.successMethod = @selector(tokenRevisitedSuccessCallback);
            tokenDao.failMethod = @selector(tokenRevisitedFailCallback:);
            [tokenDao requestTokenByRememberMe];
        } else {
            if(networkStatus == kReachableViaWiFi) {
                IGLog(@"BaseDao at triggerNewToken readRememberMeToken null - kReachableViaWiFi");
                //            [self shouldReturnFailWithMessage:LOGIN_REQ_ERROR_MESSAGE];
//                NSLog(@"Login Required Triggered within triggerNewToken instead of fail method: %@", NSStringFromSelector(failMethod));
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_REQ_NOTIFICATION object:nil userInfo:nil];
            } else {
                IGLog(@"BaseDao at triggerNewToken readRememberMeToken null - not kReachableViaWiFi -  calling radiusDao");
                radiusDao = [[RadiusDao alloc] init];
                radiusDao.delegate = self;
                radiusDao.successMethod = @selector(tokenRevisitedSuccessCallback);
                radiusDao.failMethod = @selector(tokenRevisitedFailCallback:);
                [radiusDao requestRadiusLogin];
            }
        }
    }
}

- (void) tokenRevisitedSuccessCallback {
    if(APPDELEGATE.session.authToken) {
        NSMutableURLRequest *req = [self.currentTask.currentRequest mutableCopy];
        [req setValue:APPDELEGATE.session.authToken forHTTPHeaderField:@"X-Auth-Token"];
        self.currentTask = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:req completionHandler:self.taskCompletionHandler];
        //        NSURLSessionDataTask *newTask = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:req completionHandler:taskCompletionHandler];
        [self.currentTask resume];
    }
}

- (void) tokenRevisitedFailCallback:(NSString *) errorMessage {
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

- (void) cancelRequest {
    if(self.currentRequest) {
        [self setDelegate:nil];
        //[self cancel];
    }
}

- (taskComplition) createCompletionHandlerWithCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion{
    
    self.taskCompletionHandler = [completion copy];
    return completion;
}

- (BOOL) checkResponseHasError:(NSURLResponse *) response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if ([httpResponse statusCode] == 200) {
            return NO;
        }
        else {
            [self requestFailed:response];
        }
    }
    return YES;
}
@end
