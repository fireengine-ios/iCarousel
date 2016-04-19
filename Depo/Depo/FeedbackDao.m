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
    
    NSData *postData = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:postData];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"Feedback Response: %@", responseStr);

        [self shouldReturnSuccess];
        return;
    }
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
