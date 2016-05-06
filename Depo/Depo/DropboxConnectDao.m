//
//  DropboxConnectDao.m
//  Depo
//
//  Created by Mahir Tarlan on 19/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "DropboxConnectDao.h"

@implementation DropboxConnectDao

- (void) requestConnectDropboxWithToken:(NSString *) tokenVal {
    NSString *connectUrlStr = [NSString stringWithFormat:DROPBOX_CONNECT_URL, tokenVal];
    NSURL *url = [NSURL URLWithString:connectUrlStr];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    request.tag = REQ_TAG_FOR_DROPBOX;
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"Dropbox Connect Response: %@", responseStr);
        
        [self shouldReturnSuccess];
        return;
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
