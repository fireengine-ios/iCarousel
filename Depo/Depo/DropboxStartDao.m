//
//  DropboxStartDao.m
//  Depo
//
//  Created by Mahir Tarlan on 19/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "DropboxStartDao.h"

@implementation DropboxStartDao

- (void) requestStartDropbox {
    NSURL *url = [NSURL URLWithString:DROPBOX_START_URL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
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
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
