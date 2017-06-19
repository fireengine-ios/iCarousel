//
//  MoveDao.m
//  Depo
//
//  Created by Mahir on 02/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MoveDao.h"

@implementation MoveDao

- (void) requestMoveFiles:(NSArray *) fileList toFolder:(NSString *) folderUuid {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:MOVE_URL, folderUuid]];
    
//    SBJSON *json = [SBJSON new];
//    NSString *jsonStr = [json stringWithObject:fileList];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:fileList options:NSJSONWritingPrettyPrinted error:nil];
    
//    NSLog(@"Move Payload: %@", jsonStr);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPBody:[postData mutableCopy]];
    request = [self sendPostRequest:request];
    
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                [self requestFinished:data];
            }
            else {
                [self requestFailed:response];
            }
        }
    }]];
    [task resume];
    self.currentTask = task;
}

- (void)requestFinished:(NSData *) data {
//    NSError *error = [request error];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self shouldReturnSuccess];
    });
//    if (!error) {
//        NSString *responseEnc = [request responseString];
//        NSLog(@"Move Response: %@", responseEnc);
//        [self shouldReturnSuccess];
//    } else {
//        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
//    }
    
}

@end
