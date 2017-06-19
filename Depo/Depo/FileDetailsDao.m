//
//  FileDetailsDao.m
//  Depo
//
//  Created by Mahir Tarlan on 25/03/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "FileDetailsDao.h"

@implementation FileDetailsDao

- (void) requestFileDetails:(NSArray *) uuids {
    NSURL *url = [NSURL URLWithString:DETAILS_URL];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:uuids options:NSJSONWritingPrettyPrinted error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPBody:postData];
    request = [self sendPostRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            IGLog(@"FileDetailsDao requestFileDetails failed with general error");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        } else {
            if (![self checkResponseHasError:response]) {
                IGLog(@"FileDetailsDao requestFileDetails request finished successfully");
                NSArray *mainArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                NSMutableArray *result = [[NSMutableArray alloc] init];
                if(mainArr != nil) {
                    for(NSDictionary *fileDict in mainArr) {
                        [result addObject:[self parseFile:fileDict]];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnSuccessWithObject:result];
                });
            } else {
                [self requestFailed:response];
            }
        }
    }]];
    self.currentTask = task;
    [task resume];
    
}

@end
