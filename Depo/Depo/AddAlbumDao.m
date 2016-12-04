//
//  AddAlbumDao.m
//  Depo
//
//  Created by Mahir on 10/15/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "AddAlbumDao.h"

@implementation AddAlbumDao

- (void) requestAddAlbumWithName:(NSString *) name {
	NSURL *url = [NSURL URLWithString:ADD_ALBUM_URL];
	
    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:name, @"label", @"album/photo", @"contentType", nil];
    
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingPrettyPrinted error:nil];
    
//    NSLog(@"Add Album Payload: %@", jsonStr);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPBody:[postData mutableCopy]];
//    request.tag = REQ_TAG_FOR_ALBUM;
    
    request = [self sendPostRequest:request];
    NSURLSessionDataTask *task = [[DepoHttpManager sharedInstance].urlSession dataTaskWithRequest:request completionHandler:[self createCompletionHandlerWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed:response];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![self checkResponseHasError:response]) {
                    [self shouldReturnSuccess];
                }
            });
        }
    }]];
    self.currentTask = task;
    [task resume];
}

@end
