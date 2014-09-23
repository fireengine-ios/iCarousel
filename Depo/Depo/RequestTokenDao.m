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

@implementation RequestTokenDao

- (void) requestTokenForMsisdn:(NSString *) msisdnVal andPassword:(NSString *) passVal {
	NSURL *url = [NSURL URLWithString:TOKEN_URL];
	
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          msisdnVal, @"username",
                          passVal, @"password",
                          nil];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:info];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Token Req: %@", jsonStr);
    
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:[postData mutableCopy]];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	if (!error) {
        NSDictionary *headerParams = [request responseHeaders];
        NSString *authToken = [headerParams objectForKey:@"X-Auth-Token"];
        if(authToken != nil && ![authToken isKindOfClass:[NSNull class]]) {
            APPDELEGATE.session.authToken = authToken;
            [self shouldReturnSuccess];
        } else {
            [self shouldReturnFailWithMessage:TOKEN_ERROR_MESSAGE];
        }
	} else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
	}
    
}

@end
