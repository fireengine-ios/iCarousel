//
//  FileTagDao.m
//  Depo
//
//  Created by Mahir Tarlan on 19/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "FileTagDao.h"

@implementation FileTagDao

- (void) requestFeedTag:(NSString *) tagVal withKey:(NSString *) keyVal forFiles:(NSString *) uuids {
    NSURL *url = [NSURL URLWithString:FILE_TAG_URL];
    
    NSDictionary *metadata = [NSDictionary dictionaryWithObjectsAndKeys:tagVal, keyVal, nil];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:uuids, @"file-list", metadata, @"metadata", nil];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPBody:postData];
    request = [self sendPostRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            IGLog(@"FileTagDao requestFeedTag failed with general error");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                IGLog(@"FileTagDao requestFeedTag request finished successfully");
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
