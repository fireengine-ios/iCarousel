//
//  MigrateDao.m
//  Depo
//
//  Created by Mahir on 03/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "MigrateDao.h"

@implementation MigrateDao

- (void) requestSendMigrate {
    NSURL *url = [NSURL URLWithString:MIGRATION_URL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendPostRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![self checkResponseHasError:response]) {
                    [self shouldReturnSuccess];
                }
                else {
                    [self requestFailed:response];
                }
            });
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
