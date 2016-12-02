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
    
    SBJSON *json = [SBJSON new];
    NSString *jsonStr = [json stringWithObject:dict];
    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSLog(@"Share Payload: %@", jsonStr);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostBody:[postData mutableCopy]];
    [request setDelegate:self];
    
    [self sendPostRequest:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    if (!error) {
        NSString *responseEnc = [request responseString];
        [self shouldReturnSuccessWithObject:responseEnc];
    } else {
        [self shouldReturnFailWithMessage:GENERAL_ERROR_MESSAGE];
    }
    
}

@end
