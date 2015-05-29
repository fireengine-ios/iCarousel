//
//  LogoutDao.m
//  Depo
//
//  Created by Mahir on 31/01/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "LogoutDao.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "CacheUtil.h"

@implementation LogoutDao

- (void) requestLogout {
    NSURL *url = [NSURL URLWithString:LOGOUT_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    if([CacheUtil readRememberMeToken] != nil) {
        [request addRequestHeader:@"X-Remember-Me-Token" value:[CacheUtil readRememberMeToken]];
    }
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"Logout response: %@", responseStr);
    }
}

@end
