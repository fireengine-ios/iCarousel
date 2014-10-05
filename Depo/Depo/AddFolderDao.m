//
//  AddFolderDao.m
//  Depo
//
//  Created by Mahir on 9/30/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AddFolderDao.h"

@implementation AddFolderDao

- (void) requestAddFolderAtPath:(NSString *) path {
	NSURL *url = [NSURL URLWithString:ADD_FOLDER_URL];
	
    NSDictionary *metadata = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"X-Object-Meta-Favourite", nil];
    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:metadata, @"metadata", nil];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:payload];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Add Folder Payload: %@", jsonStr);
    NSLog(@"Add Folder Destination Path: %@", [self enrichFileFolderName:path]);
    
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Destination-Path" value:[self enrichFileFolderName:path]];
    [request setPostBody:[postData mutableCopy]];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	if (!error) {
		NSString *responseEnc = [request responseString];
		
        NSLog(@"Add Folder Response: %@", responseEnc);

        [self shouldReturnSuccess];
	} else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
	}
    
}

@end
