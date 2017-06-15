//
//  AuthSDKTokenDao.m
//  Depo
//
//  Created by Mahir on 09/11/15.
//  Copyright © 2015 com.igones. All rights reserved.
//

#import "AuthSDKTokenDao.h"
#import "AppDelegate.h"
#import "CacheUtil.h"
#import "SharedUtil.h"
#import "CurioSDK.h"

@implementation AuthSDKTokenDao

- (void) requestAuthSDKToken:(NSString *) token withRememberMeFlag:(BOOL) rememberMeFlag {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:AUTH_SDK_TOKEN_URL, rememberMeFlag ? @"on" : @"off"]];
    
    NSDictionary *deviceInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[UIDevice currentDevice] identifierForVendor].UUIDString, @"uuid",
                                [[UIDevice currentDevice] name], @"name",
                                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"IPAD" : @"IPHONE"), @"deviceType",
                                nil];
    
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          token, @"sdkToken",
                          deviceInfo, @"deviceInfo",
                          nil];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:info];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
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
    NSLog(@"At SDK TOKEN requestFinished");
    NSError *error = [request error];
    if (!error) {
        NSDictionary *headerParams = [request responseHeaders];
        NSString *authToken = [headerParams objectForKey:@"X-Auth-Token"];
        NSString *rememberMeToken = [headerParams objectForKey:@"X-Remember-Me-Token"];
        NSNumber *newUserFlag = [headerParams objectForKey:@"X-New-User"];
        NSNumber *migrationUserFlag = [headerParams objectForKey:@"X-Migration-User"];
        
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
            [SharedUtil writeSharedRememberMeToken:rememberMeToken];
        }
        
        if(authToken != nil && ![authToken isKindOfClass:[NSNull class]]) {
            APPDELEGATE.session.authToken = authToken;
            [SharedUtil writeSharedToken:authToken];
            
            [[CurioSDK shared] sendEvent:@"LoginSuccess" eventValue:@"true"];
            
            SuppressPerformSelectorLeakWarning([delegate performSelector:successMethod]);
        } else {
            SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:TOKEN_ERROR_MESSAGE]);
        }
    } else {
        SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:GENERAL_ERROR_MESSAGE]);
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"At SDK TOKEN requestFailed");
    if([request responseStatusCode] == 401) {
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
