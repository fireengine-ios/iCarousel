//
//  FileTagDao.m
//  Depo
//
//  Created by Mahir Tarlan on 19/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "FileTagDao.h"

@implementation FileTagDao

- (void) requestFeedTag:(NSString *) tagVal withKey:(NSString *) keyVal forFiles:(NSString *) uuids {
    NSURL *url = [NSURL URLWithString:FILE_TAG_URL];
    
    NSDictionary *metadata = [NSDictionary dictionaryWithObjectsAndKeys:tagVal, keyVal, nil];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:uuids, @"file-list", metadata, @"metadata", nil];
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:info];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:postData];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void) requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (!error) {
        NSString *responseStr = [request responseString];
        NSLog(@"FileTagDao requestFeedTag Response: %@", responseStr);
        IGLog(@"FileTagDao requestFeedTag request finished successfully");
        [self shouldReturnSuccess];
        return;
    }
    IGLog(@"FileTagDao requestFeedTag failed with general error");
    [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
}

@end
