//
//  FirstUploadFlagDao.m
//  Depo
//
//  Created by Mahir Tarlan on 18/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "FirstUploadFlagDao.h"

@implementation FirstUploadFlagDao

- (void) requestSendFirstUploadFlag {
    NSURL *url = [NSURL URLWithString:FIRST_UPLOAD_FLAG_URL];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"First Upload Response: %@", responseStr);

        [self shouldReturnSuccess];
        return;
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
