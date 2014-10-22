//
//  UploadNotifyDao.m
//  Depo
//
//  Created by Mahir on 10/2/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "UploadNotifyDao.h"

@implementation UploadNotifyDao

- (void) requestNotifyUploadForFile:(NSString *) fileUuid atParentFolder:(NSString *) parentUuid {
    NSString *urlStr = [NSString stringWithFormat:UPLOAD_NOTIFY_URL, parentUuid, fileUuid];
	NSURL *url = [NSURL URLWithString:urlStr];

	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendGetRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	
	if (!error) {
		NSString *responseEnc = [request responseString];
		
        NSLog(@"Upload Notify Response: %@", responseEnc);
        
        [self shouldReturnSuccess];
	} else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
	}
}

@end
