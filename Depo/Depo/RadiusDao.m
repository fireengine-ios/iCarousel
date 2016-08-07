//
//  RadiusDao.m
//  Depo
//
//  Created by Mahir on 27/01/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "RadiusDao.h"
#import "AppUtil.h"
#import "CacheUtil.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "BaseDao.h"
#import "CurioSDK.h"
#import "SharedUtil.h"
#import "MPush.h"

@implementation RadiusDao

@synthesize delegate;
@synthesize successMethod;
@synthesize failMethod;

- (void) requestRadiusLogin {
    NSURL *url = [NSURL URLWithString:RADIUS_URL];
    
    NSDictionary *deviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[UIDevice currentDevice] identifierForVendor].UUIDString, @"uuid",
                                [[UIDevice currentDevice] name], @"name",
                                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"IPAD" : @"IPHONE"), @"deviceType",
//                                ([AppUtil readFirstVisitOverFlag] ? @"false" : @"true"), @"newDevice",
                                nil];
    
    IGLog(@"[POST] RadiusDao requestRadiusLogin called");

    //    NSLog(@"Device Info: %@", deviceInfo);
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:deviceInfo];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSLog(@"Radius Login Req: %@", jsonStr);
    
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

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSDictionary *headerParams = [request responseHeaders];
        NSString *authToken = [headerParams objectForKey:@"X-Auth-Token"];
        NSString *rememberMeToken = [headerParams objectForKey:@"X-Remember-Me-Token"];
        NSNumber *newUserFlag = [headerParams objectForKey:@"X-New-User"];
        NSNumber *migrationUserFlag = [headerParams objectForKey:@"X-Migration-User"];
        NSString *accountWarning = [headerParams objectForKey:@"X-Account-Warning"];
        
        IGLog(@"RadiusDao requestFinished successfully");
        
//        NSLog(@"Radius Login Response Headers: %@", headerParams);
//        NSLog(@"Radius login response: %@", [request responseString]);
        
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
            [MPush hitTag:@"logged_in" withValue:@"1"];
            [MPush hitEvent:@"logged_in"];
            
            [CacheUtil writeCachedMsisdnForPostMigration:nil];
            [CacheUtil writeCachedPassForPostMigration:nil];
            
            SuppressPerformSelectorLeakWarning([delegate performSelector:successMethod]);
        } else {
            SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:TOKEN_ERROR_MESSAGE]);
        }
    } else {
        IGLog(@"RadiusDao requestFinished requestFinished with general error");
        SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:GENERAL_ERROR_MESSAGE]);
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if([request responseStatusCode] == 401) {
        IGLog(@"RadiusDao requestFinished request failed with 401");
        SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:GENERAL_ERROR_MESSAGE]);
    } else if([request responseStatusCode] == 403) {
        IGLog(@"RadiusDao requestFinished request failed with 403");
        SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:FORBIDDEN_ERROR_MESSAGE]);
    } else {
        IGLog(@"RadiusDao requestFinished request failed");
        if([request.error code] == ASIConnectionFailureErrorType){
            SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:NSLocalizedString(@"NoConnErrorMessage", @"")]);
        } else {
            SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:GENERAL_ERROR_MESSAGE]);
        }
    }
}

@end
