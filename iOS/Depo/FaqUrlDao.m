//
//  FaqUrlDao.m
//  Depo
//
//  Created by Mahir Tarlan on 08/09/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "FaqUrlDao.h"
#import "Util.h"

@implementation FaqUrlDao

- (void) requestFaqUrl {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:FAQ_RETRIEVAL_URL, [Util readLocaleCode]]];
    
    IGLog(@"[GET] FaqUrlDao requestFaqUrl called");
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            IGLog(@"FaqUrlDao requestFaqUrl failed with general error");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                IGLog(@"FaqUrlDao requestFaqUrl Success");
                NSString *faqUrl = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnSuccessWithObject:faqUrl];
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
