//
//  DropboxConnectDao.m
//  Depo
//
//  Created by Mahir Tarlan on 19/04/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "DropboxConnectDao.h"

@implementation DropboxConnectDao

- (void) requestConnectDropboxWithToken:(NSString *) tokenVal {
    NSString *connectUrlStr = [NSString stringWithFormat:DROPBOX_CONNECT_URL, tokenVal];
    NSURL *url = [NSURL URLWithString:connectUrlStr];
//    request.tag = REQ_TAG_FOR_DROPBOX;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    request = [self sendPostRequest:request];
    
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
