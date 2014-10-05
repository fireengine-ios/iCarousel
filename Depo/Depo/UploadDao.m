//
//  UploadDao.m
//  Depo
//
//  Created by Mahir on 10/1/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "UploadDao.h"
#import "AppDelegate.h"
#import "AppSession.h"

@implementation UploadDao

- (void) requestUploadForFile:(ALAsset *) asset {
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    NSString *fileName = [rep filename];

    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", APPDELEGATE.session.baseUrl, fileName];
	NSURL *url = [NSURL URLWithString:urlStr];
    NSLog(@"UPLOAD URL: %@", urlStr);

    Byte *buffer = (Byte*)malloc(rep.size);
    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
    NSData *sourceData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
	
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"X-Object-Meta-Favourite" value:@"false"];
    [request addRequestHeader:@"x-meta-strategy" value:@"1"];
    [request setDelegate:self];
    [request setPostBody:[sourceData mutableCopy]];
    
    [self sendPutRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	if (!error) {
		NSString *responseEnc = [request responseString];
		
        NSLog(@"UPLOAD File Response: %@", responseEnc);
        
        [self shouldReturnSuccess];
	} else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
	}
    
}

@end
