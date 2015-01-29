//
//  BaseDao.h
//  Depo
//
//  Created by Mahir Tarlan
//  Copyright (c) 2014 iGones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "SBJSON.h"
#import "AppConstants.h"
#import "MetaFile.h"
#import "Activity.h"
#import "Subscription.h"
#import "Offer.h"
#import "Device.h"

//TODO
//#define BASE_URL @"https://adepo.turkcell.com.tr/api"
#define BASE_URL @"https://tcloudstb.turkcell.com.tr/api"

#define TOKEN_URL BASE_URL@"/auth/token?rememberMe=%@"

//TODO
//#define RADIUS_URL @"http://adepo.turkcell.com.tr/api/auth/gsm/login?rememberMe=on"
#define RADIUS_URL @"http://tcloudstb.turkcell.com.tr/api/auth/gsm/login?rememberMe=on"

#define REMEMBER_ME_URL BASE_URL@"/auth/rememberMe"

#define USER_BASE_URL BASE_URL@"/container/baseUrl"

#define USAGE_INFO_URL BASE_URL@"/account/usageInfo"

#define ACCOUNT_INFO_URL BASE_URL@"/account/info"

#define RECENT_ACTIVITIES_URL BASE_URL@"/filesystem/activityFeed?&sortBy=%@&sortOrder=%@&page=%d&size=%d"

#define FILE_LISTING_MAIN_URL BASE_URL@"/filesystem?parentFolderUuid=%@&sortBy=%@&sortOrder=%@&page=%d&size=%d"

#define FOLDER_LISTING_MAIN_URL BASE_URL@"/filesystem?parentFolderUuid=%@&sortBy=%@&sortOrder=%@&page=%d&size=%d&folderOnly=true"

#define ELASTIC_LISTING_MAIN_URL BASE_URL@"/search/byField?fieldName=%@&fieldValue=%@&sortBy=%@&sortOrder=%@&page=%d&size=%d"

#define AUTH_TOKEN_URL BASE_URL@"/auth/token"

#define DELETE_FILE_URL BASE_URL@"/filesystem/delete"

#define FAVORITE_URL BASE_URL@"/filesystem/metadata"

#define SHARE_LINK_URL BASE_URL@"/share/public"

#define ADVANCED_SEARCH_URL BASE_URL@"/search/advancedSearch?name=%@&sortBy=%@&sortOrder=%@&page=%d&size=%d"

#define ADVANCED_SEARCH_URL_WITH_CATEGORY BASE_URL@"/search/advancedSearch?name=%@&sortBy=%@&sortOrder=%@&page=%d&size=%d&category=%@"

#define RENAME_URL BASE_URL@"/filesystem/rename/%@"

#define MOVE_URL BASE_URL@"/filesystem/move?targetFolderUuid=%@"

#define ADD_FOLDER_URL BASE_URL@"/filesystem/createFolder?parentFolderUuid=%@"

#define UPLOAD_NOTIFY_URL BASE_URL@"/notification/onFileUpload?parentFolderUuid=%@&fileName=%@"

#define ALBUM_LIST_URL BASE_URL@"/album?contentType=album/photo&page=%d&size=%d&sortBy=label&sortOrder=ASC"

#define ALBUM_DETAIL_URL BASE_URL@"/album/%@?page=%d&size=%d&sortBy=createdDate&sortOrder=DESC&"

#define ADD_ALBUM_URL BASE_URL@"/album"

#define DELETE_ALBUM_URL BASE_URL@"/album"

#define RENAME_ALBUM_URL BASE_URL@"/album/rename/%@?newLabel=%@"

#define ALBUM_ADD_PHOTOS_URL BASE_URL@"/album/addFiles/%@"

#define ALBUM_REMOVE_PHOTOS_URL BASE_URL@"/album/removeFiles/%@"

#define GET_CURRENT_SUBSCRIPTION_URL BASE_URL@"/account/currentSubscription"

#define GET_SUBSCRIPTION_OFFERS_URL BASE_URL@"/account/offers"

#define REQUEST_ACTIVATE_OFFER_URL BASE_URL@"/account/activateOffer"

#define REQUEST_CANCEL_SUBSCRIPTION_URL BASE_URL@"/account/cancelSubscription"

#define GET_CONNECTED_DEVICES BASE_URL@"/devices"

#define APN_URL @"http://pushserver.turkcell.com.tr/PushServer/rest/registerdevice/"

#define SHORTEN_URL @"https://www.googleapis.com/urlshortener/v1/url"

#define turkcellAuthAppId @"39532"
#define turkcellAuthSecretKey @"9adc2130-7d20-11e3-baa7-0800200c9a66"

#define turkcellServiceLogin @"https://sdk.turkcell.com.tr/BigLdapProxy/SDK/AuthAPI/serviceLogin.json"
#define turkcellServiceLoginWithGsm @"https://sdk.turkcell.com.tr/BigLdapProxy/SDK/AuthAPI/serviceLoginWithGSM.json"
#define turkcellRequestAuth @"https://sdk.turkcell.com.tr/BigLdapProxy/SDK/AuthAPI/requestAuthToken.json"
#define turkcellCaptchaReq @"https://sdk.turkcell.com.tr/BigLdapProxy/SDK/AuthAPI/captcha.json"
#define turkcellChangePass @"https://sdk.turkcell.com.tr/BigLdapProxy/SDK/AuthAPI/changePassword.json"

#define TOKEN_ERROR_MESSAGE @"Kullanıcı girişi esnasında hata oluştu. Lütfen tekrar deneyiniz."

#define GENERAL_ERROR_MESSAGE @"Genel bir hata oluştu. Lütfen tekrar deneyiniz."

#define NO_CONN_ERROR_MESSAGE @"Lütfen internet bağlantınızı kontrol ediniz."

#define FORBIDDEN_ERROR_MESSAGE @"Bu işlem için yetkiniz bulunmamaktadır."

#define OSP_USER @"proxyuser"

#define OSP_PASS @"proxyuser2013"

@interface BaseDao : NSObject {
	id delegate;
	SEL successMethod;
	SEL failMethod;
}

@property (nonatomic, strong) id delegate;
@property (nonatomic) SEL successMethod;
@property (nonatomic) SEL failMethod;

- (NSString *) hasFinishedSuccessfully:(NSDictionary *) mainDict;
- (void) sendPostRequest:(ASIFormDataRequest *) request;
- (void) sendGetRequest:(ASIFormDataRequest *) request;
- (void) sendPutRequest:(ASIFormDataRequest *) request;
- (void) sendDeleteRequest:(ASIFormDataRequest *) request;
- (BOOL) boolByNumber:(NSNumber *) numberObj;
- (int) intByNumber:(NSNumber *) numberObj;
- (float) floatByNumber:(NSNumber *) numberObj;
- (long) longByNumber:(NSNumber *) numberObj;
- (NSString *) strByRawVal:(NSString *) rawStr;
- (NSDate *) dateByRawVal:(NSString *) rawStr;
- (NSString *) enrichFileFolderName:(NSString *) fileFolderName;
- (ContentType) contentTypeByRawValue:(MetaFile *) metaFile;
- (void) shouldReturnSuccess;
- (void) shouldReturnSuccessWithObject:(id) obj;
- (void) shouldReturnFailWithMessage:(NSString *) errorMessage;
- (void) shouldReturnFailWithParam:(id) param;
- (MetaFile *) parseFile:(NSDictionary *) dict;
- (Activity *) parseActivity:(NSDictionary *) dict;
- (SortType) resetSortType:(SortType) sortType;
- (Subscription *) parseSubscription:(NSDictionary *) dict;
- (Offer *) parseOffer:(NSDictionary *) dict;
- (Device *) parseDevice:(NSDictionary *) dict;

@end
