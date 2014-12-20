//
//  AddAlbumDao.m
//  Depo
//
//  Created by Mahir on 10/15/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AddAlbumDao.h"

@implementation AddAlbumDao

- (void) requestAddAlbumWithName:(NSString *) name {
	NSURL *url = [NSURL URLWithString:ADD_ALBUM_URL];
	
    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:name, @"label", @"application/photo", @"contentType", nil];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:payload];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Add Album Payload: %@", jsonStr);
    
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:[postData mutableCopy]];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	if (!error) {
		NSString *responseEnc = [request responseString];
		
        NSLog(@"Add Album Response: %@", responseEnc);
        
        [self shouldReturnSuccess];
	} else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
	}
    
}

@end
