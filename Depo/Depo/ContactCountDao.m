//
//  ContactCountDao.m
//  Depo
//
//  Created by Mahir on 16/03/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "ContactCountDao.h"

@implementation ContactCountDao

- (void) requestContactCount {
    NSURL *url = [NSURL URLWithString:TTY_CONTACT_COUNT_URL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                NSDictionary *mainDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                
                if(mainDict != nil && ![mainDict isKindOfClass:[NSNull class]]) {
                    NSNumber *countData = [mainDict objectForKey:@"data"];
                    if(countData != nil && ![countData isKindOfClass:[NSNull class]]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self shouldReturnSuccessWithObject:[NSString stringWithFormat:@"%d", [countData intValue]]];
                        });
                        return;
                    }
                }
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
