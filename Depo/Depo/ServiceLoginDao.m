//
//  ServiceLoginDao.m
//  Acdm_1
//
//  Created by mahir tarlan on 12/30/13.
//  Copyright (c) 2013 igones. All rights reserved.
//

#import "ServiceLoginDao.h"
#import "AuthResponse.h"

@implementation ServiceLoginDao

- (id)init {
	if (self = [super init]) {
	}
	return self;
}

- (void) requestServiceLogin:(NSString *) gsmVal withPass:(NSString *) passVal shouldRememberMe:(BOOL) rememberMe {
	NSURL *url = [NSURL URLWithString:turkcellServiceLogin];
	
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          turkcellAuthAppId, @"appId",
                          gsmVal, @"username",
                          passVal, @"password",
                          rememberMe ? @"yes" : @"no", @"rememberMe",
                          @"", @"captchaToken",
                          nil];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:info];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request setPostBody:postData];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	
	if (!error) {
		NSString *responseEnc = [request responseString];
//        NSLog(@"REQUEST AUTH RESP:%@", responseEnc);
		
		SBJSON *jsonParser = [SBJSON new];
		NSDictionary *mainDict = [jsonParser objectWithString:responseEnc];

        NSNumber *code = [mainDict objectForKey:@"code"];
        NSString *message = [mainDict objectForKey:@"message"];
        NSNumber *rememberMe = [mainDict objectForKey:@"rememberMe"];
        NSNumber *showCaptcha = [mainDict objectForKey:@"showCaptcha"];
        NSString *token = [mainDict objectForKey:@"authToken"];
        
        AuthResponse *result = [[AuthResponse alloc] init];
        result.code = [code intValue];
        result.message = message;
        if(rememberMe != nil) {
            result.rememberMe = [rememberMe boolValue];
        }
        if(showCaptcha != nil) {
            result.showCaptcha = [showCaptcha boolValue];
        }
        if(token != nil) {
            result.authToken = token;
        }
		
        [delegate performSelector:successMethod withObject:result];
		
	} else {
        [delegate performSelector:failMethod withObject:GENERAL_ERROR_MESSAGE];
	}
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	[delegate performSelector:failMethod withObject:GENERAL_ERROR_MESSAGE];
}

@end
