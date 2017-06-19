//
//  ValidateAuthTokenDao.m
//  Depo
//
//  Created by Mahir on 4.12.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "ValidateAuthTokenDao.h"

@implementation ValidateAuthTokenDao

- (void) requestAuthToken:(NSString *) token {
    NSURL *url = [NSURL URLWithString:AUTH_TOKEN_URL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request addValue:token forHTTPHeaderField:@"X-Auth-Token"];
    
    request = [self sendPostRequest:request];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnSuccess];
                });
            }
            else {
                [self requestFailed:response];
            }
        }
    }]];
    [task resume];
    self.currentTask = task;
}

@end
