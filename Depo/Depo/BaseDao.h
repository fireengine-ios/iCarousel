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

#define BASE_URL @"https://tcloudstb.turkcell.com.tr/api"

#define TOKEN_URL BASE_URL@"/auth/token"

#define USER_BASE_URL BASE_URL@"/container/baseUrl"

#define FILE_LISTING_MAIN_URL BASE_URL@"/search/byField?fieldName=%@&fieldValue=%@&exactMatch=true&sortBy=%@&sortOrder=ASC&from=%d&size=%d"

#define IMG_LISTING_MAIN_URL BASE_URL@"/search/byField?fieldName=%@&fieldValue=%@&sortBy=%@&sortOrder=DESC&from=%d&size=%d"

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

@end
