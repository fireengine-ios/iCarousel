//
//  EulaApproveDao.m
//  Depo
//
//  Created by Mahir Tarlan on 31/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "EulaApproveDao.h"

@implementation EulaApproveDao

- (void) requestApproveEulaForId:(int) eulaId {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:APPROVE_EULA_URL, eulaId]];
    
    NSString *log = [NSString stringWithFormat:@"[GET] EulaApproveDao requestApproveEulaForId with eulaId: %d", eulaId];
    IGLog(log);

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendGetRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            IGLog(@"EulaApproveDao requestFinished with general error");

            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                IGLog(@"EulaApproveDao requestFinished successfully");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnSuccess];
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
