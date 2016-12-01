//
//  RequestTokenDao.m
//  Depo
//
//  Created by Mahir on 9/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RequestTokenDao.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "AppUtil.h"
#import "CacheUtil.h"
#import "BaseDao.h"
#import "CurioSDK.h"
#import "SharedUtil.h"
#import "MPush.h"

@implementation RequestTokenDao

@synthesize delegate;
@synthesize successMethod;
@synthesize failMethod;

- (void) requestTokenForMsisdn:(NSString *) msisdnVal andPassword:(NSString *) passVal shouldRememberMe:(BOOL) rememberMeFlag {
    [self requestTokenForMsisdn:msisdnVal andPassword:passVal shouldRememberMe:rememberMeFlag withCaptchaId:nil withCaptchaValue:nil];
}

- (void) requestTokenForMsisdn:(NSString *) msisdnVal andPassword:(NSString *) passVal shouldRememberMe:(BOOL) rememberMeFlag withCaptchaId:(NSString *) captchaId withCaptchaValue:(NSString *) captchaValue {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:TOKEN_URL, rememberMeFlag ? @"on" : @"off"]];
    IGLog(@"[POST] Calling requestTokenForMsisdn:andPassword:shouldRememberMe:");
	
    NSDictionary *deviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[UIDevice currentDevice] identifierForVendor].UUIDString, @"uuid",
                                [[UIDevice currentDevice] name], @"name",
                                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"IPAD" : @"IPHONE"), @"deviceType",
//                                ([AppUtil readFirstVisitOverFlag] ? @"false" : @"true"), @"newDevice",
                                nil];
//    NSLog(@"Device Info: %@", deviceInfo);

    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                            msisdnVal, @"username",
                            passVal, @"password",
                            deviceInfo, @"deviceInfo",
                          	nil];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:info];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSLog(@"Token Req: %@", jsonStr);
    
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:[postData mutableCopy]];
    [request setDelegate:self];
    
    [request setRequestMethod:@"POST"];
    request.timeOutSeconds = 30;
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    if(APPDELEGATE.session.authToken) {
        [request addRequestHeader:@"X-Auth-Token" value:APPDELEGATE.session.authToken];
    }
    if(captchaId != nil && captchaValue != nil) {
        [request addRequestHeader:@"X-Captcha-Id" value:captchaId];
        [request addRequestHeader:@"X-Captcha-Answer" value:captchaValue];
    }
    [request startAsynchronous];
}

- (void) requestTokenByRememberMe {
    NSURL *url = [NSURL URLWithString:REMEMBER_ME_URL];
    IGLog(@"[POST] Calling requestTokenByRememberMe");
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[UIDevice currentDevice] identifierForVendor].UUIDString, @"uuid",
                                [[UIDevice currentDevice] name], @"name",
                                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"IPAD" : @"IPHONE"), @"deviceType",
//                                ([AppUtil readFirstVisitOverFlag] ? @"false" : @"true"), @"newDevice",
                                nil];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:info];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSLog(@"Token Req: %@", jsonStr);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"X-Remember-Me-Token" value:[CacheUtil readRememberMeToken]];
    [request setPostBody:[postData mutableCopy]];
    [request setDelegate:self];
    
    [request setRequestMethod:@"POST"];
    request.timeOutSeconds = 30;
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    if(APPDELEGATE.session.authToken) {
        [request addRequestHeader:@"X-Auth-Token" value:APPDELEGATE.session.authToken];
    }
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"RESULT: %@", responseStr);

        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *dict = [jsonParser objectWithString:responseStr];
        if(dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
            NSNumber *errorCode = [dict objectForKey:@"errorCode"];
            if(errorCode != nil && ![errorCode isKindOfClass:[NSNull class]]) {
                if([errorCode intValue] == 4002) {
                    IGLog(@"RequestTokenDao request failed with captcha error");
                    SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:CAPTCHA_ERROR_MESSAGE]);
                    return;
                }
            }
        }

        NSDictionary *headerParams = [request responseHeaders];
        NSString *authToken = [headerParams objectForKey:@"X-Auth-Token"];
        NSString *rememberMeToken = [headerParams objectForKey:@"X-Remember-Me-Token"];
        NSNumber *newUserFlag = [headerParams objectForKey:@"X-New-User"];
        NSNumber *migrationUserFlag = [headerParams objectForKey:@"X-Migration-User"];
        NSString *accountWarning = [headerParams objectForKey:@"X-Account-Warning"];
        
//        NSLog(@"Auth Token Response Headers: %@", headerParams);
        NSLog(@"TOKEN: %@", authToken);

        if(newUserFlag != nil && ![newUserFlag isKindOfClass:[NSNull class]]) {
            APPDELEGATE.session.newUserFlag = [newUserFlag boolValue];
        } else {
            APPDELEGATE.session.newUserFlag = NO;
        }
        if(migrationUserFlag != nil && ![migrationUserFlag isKindOfClass:[NSNull class]]) {
            APPDELEGATE.session.migrationUserFlag = [migrationUserFlag boolValue];
        } else {
            APPDELEGATE.session.migrationUserFlag = NO;
        }
        if(accountWarning != nil && ![accountWarning isKindOfClass:[NSNull class]]) {
            if([accountWarning isEqualToString:@"EMPTY_MSISDN"]) {
                APPDELEGATE.session.msisdnEmpty = YES;
            } else {
                APPDELEGATE.session.msisdnEmpty = NO;
            }
            if([accountWarning isEqualToString:@"EMPTY_EMAIL"]) {
                APPDELEGATE.session.emailEmpty = YES;
            } else {
                APPDELEGATE.session.emailEmpty = NO;
            }
            if([accountWarning isEqualToString:@"EMAIL_NOT_VERIFIED"]) {
                APPDELEGATE.session.emailNotVerified = YES;
            } else {
                APPDELEGATE.session.emailNotVerified = NO;
            }
        } else {
            APPDELEGATE.session.msisdnEmpty = NO;
            APPDELEGATE.session.emailEmpty = NO;
            APPDELEGATE.session.emailNotVerified = NO;
        }
        
        if(rememberMeToken != nil && ![rememberMeToken isKindOfClass:[NSNull class]]) {
            [CacheUtil writeRememberMeToken:rememberMeToken];
            [SharedUtil writeSharedRememberMeToken:rememberMeToken];
        }

        if(authToken != nil && ![authToken isKindOfClass:[NSNull class]]) {
            APPDELEGATE.session.authToken = authToken;
            [SharedUtil writeSharedToken:authToken];
            
            [[CurioSDK shared] sendEvent:@"LoginSuccess" eventValue:@"true"];
            [MPush hitTag:@"LoginSuccess" withValue:@"true"];

            IGLog(@"RequestTokenDao request finished successfully");
            [MPush hitTag:@"logged_in" withValue:@"1"];
            [MPush hitEvent:@"logged_in"];
            SuppressPerformSelectorLeakWarning([delegate performSelector:successMethod]);
        } else {
            IGLog(@"RequestTokenDao request failed with token error");
            SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:TOKEN_ERROR_MESSAGE]);
        }
	} else {
        NSString *log = [NSString stringWithFormat:@"RequestTokenDao request finished with error:%@", [error localizedDescription]];
        IGLog(log);
        SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:GENERAL_ERROR_MESSAGE]);
	}
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSString *responseStr = [request responseString];
    NSLog(@"Result: %@", responseStr);
    
    NSString *log = [NSString stringWithFormat:@"RequestTokenDao request failed with response:%@ and status code: %d", responseStr, [request responseStatusCode]];
    IGLog(log);
    
    SBJSON *jsonParser = [SBJSON new];
    NSDictionary *dict = [jsonParser objectWithString:responseStr];
    if(dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
        NSNumber *errorCode = [dict objectForKey:@"errorCode"];
        if(errorCode != nil && ![errorCode isKindOfClass:[NSNull class]]) {
            if([errorCode intValue] == 4002) {
                SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:CAPTCHA_ERROR_MESSAGE]);
                return;
            } else if([errorCode intValue] == 60) {
                SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:EMAIL_NOT_VERIFIED_ERROR_MESSAGE]);
                return;
            } else if([errorCode intValue] == 10) {
                SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:LDAP_LOCKED_ERROR_MESSAGE]);
                return;
            }
            else if([errorCode intValue] == 4101) {
                SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:SIGNUP_REQUIRED_ERROR_MESSAGE]);
                return;
            }
        }
    }
    if([request responseStatusCode] == 401) {
        //TODO 401 kontrolü için 3 satır eklendi. Test et!
//        [APPDELEGATE.session cleanoutAfterLogout];
//        [CacheUtil resetRememberMeToken];
//        [[UploadQueue sharedInstance] cancelAllUploads];
        
        SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:GENERAL_ERROR_MESSAGE]);
    } else if([request responseStatusCode] == 403) {
        SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:FORBIDDEN_ERROR_MESSAGE]);
    } else {
        if([request.error code] == ASIConnectionFailureErrorType){
            SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:NSLocalizedString(@"NoConnErrorMessage", @"")]);
        } else {
            SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:GENERAL_ERROR_MESSAGE]);
        }
    }
}

@end
