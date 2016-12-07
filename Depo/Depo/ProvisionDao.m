//
//  ProvisionDao.m
//  Depo
//
//  Created by Mahir on 03/02/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "ProvisionDao.h"

@implementation ProvisionDao

- (void) requestSendProvision {
    NSURL *url = [NSURL URLWithString:PROVISION_URL];
    
    IGLog(@"[POST] ProvisionDao requestSendProvision called");

    NSDictionary *dict = [[NSDictionary alloc] init];
    

    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
//    NSLog(@"Provision Load: %@", jsonStr);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPBody:postData];
    request = [self sendPostRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                //NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                IGLog(@"ProvisionDao requestFinished successfully");
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
