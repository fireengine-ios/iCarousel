//
//  RequestBaseUrlDao.m
//  Depo
//
//  Created by Mahir on 9/22/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "RequestBaseUrlDao.h"

@implementation RequestBaseUrlDao

- (void) requestBaseUrl {
	NSURL *url = [NSURL URLWithString:USER_BASE_URL];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	
	if (!error) {
		NSString *responseEnc = [request responseString];
		
        NSLog(@"User Base Url Response: %@", responseEnc);
        
		SBJSON *jsonParser = [SBJSON new];
		NSDictionary *mainDict = [jsonParser objectWithString:responseEnc];
        
        [self shouldReturnSuccess];
		
	} else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
	}
    
}

@end
