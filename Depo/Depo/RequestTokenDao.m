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

@implementation RequestTokenDao

@synthesize delegate;
@synthesize successMethod;
@synthesize failMethod;

- (void) requestTokenForMsisdn:(NSString *) msisdnVal andPassword:(NSString *) passVal shouldRememberMe:(BOOL) rememberMeFlag {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:TOKEN_URL, rememberMeFlag ? @"on" : @"off"]];
	
    NSDictionary *deviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[UIDevice currentDevice] identifierForVendor].UUIDString, @"uuid",
                                [[UIDevice currentDevice] name], @"name",
                                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"IPAD" : @"IPHONE"), @"deviceType",
//                                ([AppUtil readFirstVisitOverFlag] ? @"false" : @"true"), @"newDevice",
                                nil];

    NSLog(@"Device Info: %@", deviceInfo);

    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                            msisdnVal, @"username",
                            passVal, @"password",
                            deviceInfo, @"deviceInfo",
                          	nil];
    
    [CacheUtil writeCachedMsisdnForPostMigration:msisdnVal];
    [CacheUtil writeCachedPassForPostMigration:passVal];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:info];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Token Req: %@", jsonStr);
    
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
    [request startAsynchronous];
}

- (void) requestTokenByRememberMe {
    NSURL *url = [NSURL URLWithString:REMEMBER_ME_URL];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[UIDevice currentDevice] identifierForVendor].UUIDString, @"uuid",
                                [[UIDevice currentDevice] name], @"name",
                                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"IPAD" : @"IPHONE"), @"deviceType",
//                                ([AppUtil readFirstVisitOverFlag] ? @"false" : @"true"), @"newDevice",
                                nil];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:info];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Token Req: %@", jsonStr);
    
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
        NSDictionary *headerParams = [request responseHeaders];
        NSString *authToken = [headerParams objectForKey:@"X-Auth-Token"];
        NSString *rememberMeToken = [headerParams objectForKey:@"X-Remember-Me-Token"];
        NSNumber *newUserFlag = [headerParams objectForKey:@"X-New-User"];
        NSNumber *migrationUserFlag = [headerParams objectForKey:@"X-Migration-User"];
        
        NSLog(@"Auth Token Response Headers: %@", headerParams);
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

        if(rememberMeToken != nil && ![rememberMeToken isKindOfClass:[NSNull class]]) {
            [CacheUtil writeRememberMeToken:rememberMeToken];
        }

        if(authToken != nil && ![authToken isKindOfClass:[NSNull class]]) {
            APPDELEGATE.session.authToken = authToken;
            SuppressPerformSelectorLeakWarning([delegate performSelector:successMethod]);
        } else {
            SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:TOKEN_ERROR_MESSAGE]);
        }
	} else {
        SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:GENERAL_ERROR_MESSAGE]);
	}
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if([request responseStatusCode] == 401) {
        SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:GENERAL_ERROR_MESSAGE]);
    } else if([request responseStatusCode] == 403) {
        SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:FORBIDDEN_ERROR_MESSAGE]);
    } else {
        if([request.error code] == ASIConnectionFailureErrorType){
            SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:NO_CONN_ERROR_MESSAGE]);
        } else {
            SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:GENERAL_ERROR_MESSAGE]);
        }
    }
}

@end
