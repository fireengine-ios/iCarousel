//
//  DeleteDao.m
//  Depo
//
//  Created by Mahir on 10/24/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "DeleteDao.h"
#import "SyncUtil.h"

@implementation DeleteDao

- (void) requestDeleteFiles:(NSArray *) uuidList {
	NSURL *url = [NSURL URLWithString:DELETE_FILE_URL];
	
    NSData *postData = [NSJSONSerialization dataWithJSONObject:uuidList options:NSJSONWritingPrettyPrinted error:nil];
    
//    NSLog(@"Delete Payload: %@", jsonStr);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendDeleteRequest:request];
    [request setHTTPBody:postData];
    //request.tag = REQ_TAG_FOR_PHOTO;
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            if (![self checkResponseHasError:response]) {
                [self requestFinished:data];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
                });
            }
        }
    }]];
    [task resume];
    self.currentTask = task;
}

- (void)requestFinished:(NSData *) data {
    [SyncUtil write413Lock:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self shouldReturnSuccess];
    });
    //	NSError *error = [request error];
//	
//	if (!error) {
//		NSString *responseEnc = [request responseString];
//		
////        NSLog(@"Delete Response: %@", responseEnc);
    
//    
//	} else {
//        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
//	}
    
}

@end
