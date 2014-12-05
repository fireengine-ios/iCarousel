//
//  ValidateAuthTokenDao.m
//  Depo
//
//  Created by Mahir on 4.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "ValidateAuthTokenDao.h"

@implementation ValidateAuthTokenDao

- (void) requestAuthToken:(NSString *) token {
    NSURL *url = [NSURL URLWithString:AUTH_TOKEN_URL];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"X-Auth-Token" value:token];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseEnc = [request responseString];
        NSLog(@"Auth Token Response: %@", responseEnc);
        
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *mainDict = [jsonParser objectWithString:responseEnc];
        
        [self shouldReturnSuccess];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
