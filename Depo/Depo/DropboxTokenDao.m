//
//  DropboxTokenDao.m
//  Depo
//
//  Created by Mahir Tarlan on 22/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "DropboxTokenDao.h"

@implementation DropboxTokenDao

- (void) requestToken {
    NSString *urlStr = @"https://www.dropbox.com/1/oauth2/authorize?response_type=code&client_id=mydrrngzkvnljgs&state=users_get_current_account12312311";
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setRequestMethod:@"GET"];
    request.timeOutSeconds = 30;
//    [request addRequestHeader:@"Accept" value:@"application/json"];
//    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSLog(@"Response headers: %@", [request responseHeaders]);
        NSString *responseStr = [request responseString];
        NSLog(@"Dropbox Token Response: %@", responseStr);
        
        [self shouldReturnSuccess];
        return;
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
