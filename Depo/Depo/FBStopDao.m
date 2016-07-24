//
//  FBStopDao.m
//  Depo
//
//  Created by Mahir Tarlan on 22/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "FBStopDao.h"

@implementation FBStopDao

- (void) requestFBStop {
    NSURL *url = [NSURL URLWithString:FB_STOP_URL];
    
    IGLog(@"[GET] FBStopDao requestFBStop called");
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [self sendGetRequest:request];
}

- (void) requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"FBStopDao requestFBStop Response: %@", responseStr);
        IGLog(@"FBStopDao request finished successfully");
        [self shouldReturnSuccess];
        return;
    }
    IGLog(@"FBStopDao request failed with general error");
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
