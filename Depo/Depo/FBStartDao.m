//
//  FBStartDao.m
//  Depo
//
//  Created by Mahir Tarlan on 08/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "FBStartDao.h"

@implementation FBStartDao

- (void) requestFBStart {
    NSURL *url = [NSURL URLWithString:FB_START_URL];
    
    IGLog(@"FBStartDao requestFBStart called");
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [self sendGetRequest:request];
}

- (void) requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"FBStartDao requestFBStart Response: %@", responseStr);
        [self shouldReturnSuccess];
        return;
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
