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
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceInfo options:0 error:nil];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    if(APPDELEGATE.session.authToken) {
        [request addValue:APPDELEGATE.session.authToken forHTTPHeaderField:@"X-Auth-Token"];
    }
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            
            NSDictionary *headerParams = [(NSHTTPURLResponse *)response allHeaderFields];
            NSHTTPURLResponse *res = (NSHTTPURLResponse *) response;
            if (!([res statusCode] > 199 && [res statusCode] < 300)) {
                [self requestFailed:response];
                return ;
            }
            NSString *authToken = [headerParams objectForKey:@"X-Auth-Token"];
            NSString *rememberMeToken = [headerParams objectForKey:@"X-Remember-Me-Token"];
            NSNumber *newUserFlag = [headerParams objectForKey:@"X-New-User"];
            NSNumber *migrationUserFlag = [headerParams objectForKey:@"X-Migration-User"];
            NSString *accountWarning = [headerParams objectForKey:@"X-Account-Warning"];
            
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
                
                [CacheUtil writeCachedMsisdnForPostMigration:nil];
                [CacheUtil writeCachedPassForPostMigration:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    SuppressPerformSelectorLeakWarning([delegate performSelector:successMethod]);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:TOKEN_ERROR_MESSAGE]);
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }

    }];
    [task resume];
}

- (void)requestFailed:(NSURLResponse *) urlresponse {
    NSHTTPURLResponse *response = (NSHTTPURLResponse *) urlresponse;
    if([response statusCode] == 401) {
        SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:GENERAL_ERROR_MESSAGE]);
    } else if([response statusCode] == 403) {
        SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:FORBIDDEN_ERROR_MESSAGE]);
    } else {
        if([response statusCode] == NSURLErrorNotConnectedToInternet){
            SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:NSLocalizedString(@"NoConnErrorMessage", @"")]);
        } else {
            SuppressPerformSelectorLeakWarning([delegate performSelector:failMethod withObject:GENERAL_ERROR_MESSAGE]);
        }
    }
}

@end
