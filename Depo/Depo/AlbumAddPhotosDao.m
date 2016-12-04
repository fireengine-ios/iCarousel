//
//  AlbumAddPhotosDao.m
//  Depo
//
//  Created by Mahir on 13.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AlbumAddPhotosDao.h"

@implementation AlbumAddPhotosDao

- (void) requestAddPhotos:(NSArray *) uuidList toAlbum:(NSString *) albumUuid {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:ALBUM_ADD_PHOTOS_URL, albumUuid]];
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:uuidList options:NSJSONWritingPrettyPrinted error:nil];
    
//    NSLog(@"Album Add Photos Payload: %@", jsonStr);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request addValue:@"1" forHTTPHeaderField:@"x-meta-strategy"];
    [request addValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData mutableCopy]];
//    request.tag = REQ_TAG_FOR_ALBUM;
    
    request = [self sendPutRequest:request];
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
////        NSLog(@"Album Add Photos Response: %@", responseEnc);
//        
//        [self shouldReturnSuccess];
//    } else {
//        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
//    }
    
}

@end
