//
//  ShareLinkDao.m
//  Depo
//
//  Created by Mahir on 22/01/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "ShareLinkDao.h"

@implementation ShareLinkDao

- (void) requestLinkForFiles:(NSArray *) files {
    [self requestLinkForFiles:files isAlbum:false];
}

- (void) requestLinkForFiles:(NSArray *) files isAlbum:(BOOL)isAlbum {
    NSURL *url = [NSURL URLWithString:SHARE_LINK_URL];
    
    NSString *isAlbumValue = isAlbum ? @"true" : @"false";
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:files forKey:@"fileUuidList"];
    [dict setObject:isAlbumValue forKey:@"isAlbum"];

    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    
//    NSLog(@"Share Payload: %@", jsonStr);
    
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *responseEnc = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    [self shouldReturnSuccessWithObject:responseEnc];
                });
            }
            else {
                [self requestFailed:response];
            }
        }
    }]];
    [task resume];
}

@end
