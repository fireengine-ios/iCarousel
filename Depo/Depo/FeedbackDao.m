//
//  FeedbackDao.m
//  Depo
//
//  Created by Mahir Tarlan on 18/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "FeedbackDao.h"

@implementation FeedbackDao

- (void) requestSendFeedbackWithType:(FeedBackType) type andMessage:(NSString *) message {
    NSString *feedbackUrlStr = [NSString stringWithFormat:FEEDBACK_URL, type == FeedBackTypeComplaint ? @"COMPLAINT":@"SUGGESTION"];
    NSURL *url = [NSURL URLWithString:feedbackUrlStr];

    NSData *postData = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    request = [self sendPostRequest:request];
    [request setHTTPBody:postData];
    
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
