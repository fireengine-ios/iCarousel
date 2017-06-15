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
    
    IGLog(@"[GET] FBStartDao requestFBStart called");
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            IGLog(@"FBStartDao request failed with general error");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                IGLog(@"FBStartDao request finished successfully");
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
