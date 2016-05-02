//
//  DeleteDao.m
//  Depo
//
//  Created by Mahir on 10/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "DeleteDao.h"

@implementation DeleteDao

- (void) requestDeleteFiles:(NSArray *) uuidList {
	NSURL *url = [NSURL URLWithString:DELETE_FILE_URL];
	
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:uuidList];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSLog(@"Delete Payload: %@", jsonStr);
    
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:[postData mutableCopy]];
    [request setDelegate:self];
    request.tag = REQ_TAG_FOR_PHOTO;
    
    [self sendDeleteRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	
	if (!error) {
		NSString *responseEnc = [request responseString];
		
//        NSLog(@"Delete Response: %@", responseEnc);
        
        [self shouldReturnSuccess];
	} else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
	}
    
}

@end
