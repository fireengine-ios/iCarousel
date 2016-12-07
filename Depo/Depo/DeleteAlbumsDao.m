//
//  DeleteAlbumsDao.m
//  Depo
//
//  Created by Mahir on 13.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "DeleteAlbumsDao.h"

@implementation DeleteAlbumsDao

- (void) requestDeleteAlbums:(NSArray *) uuidList {
    NSURL *url = [NSURL URLWithString:DELETE_ALBUM_URL];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:uuidList options:NSJSONWritingPrettyPrinted error:nil];
    
//    NSLog(@"Album Delete Payload: %@", jsonStr);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request = [self sendPostRequest:request];
    
    
    [request setHTTPBody:[postData mutableCopy]];
    
   // request.tag = REQ_TAG_FOR_ALBUM;
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
    self.currentTask = task;
    [task resume];
}

- (void)requestFinished:(NSData *) data {
//    NSError *error = [request error];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self shouldReturnSuccess];
    });
//    if (!error) {
//        NSString *responseEnc = [request responseString];
//        
////        NSLog(@"Album Delete Response: %@", responseEnc);
//        
//        
//    } else {
//        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
//    }
    
}

@end
