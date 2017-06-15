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
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            IGLog(@"FBStopDao request failed with general error");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                IGLog(@"FBStopDao request finished successfully");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnSuccess];
                });
            }
            else {
                [self requestFailed:response];
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
