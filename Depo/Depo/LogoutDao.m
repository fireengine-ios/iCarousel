//
//  LogoutDao.m
//  Depo
//
//  Created by Mahir on 31/01/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "LogoutDao.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "CacheUtil.h"

@implementation LogoutDao

- (void) requestLogout {
    NSURL *url = [NSURL URLWithString:LOGOUT_URL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    if([CacheUtil readRememberMeToken] != nil) {
        [request addValue:[CacheUtil readRememberMeToken] forHTTPHeaderField:@"X-Remember-Me-Token"];
    }
    request = [self sendPostRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Logout Response:%@", responseStr);
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
